
import socket, select

# Box wich reads a stream of strings from TCP *client* and convert them to stimulus (\n as separator).

# WARNING: all white spaces will be lost (should be ok since no stim has white spaces...)
# WARNING: will ignore all strings which could not be resolved to stimulations

# FIXME: all labels do not seem to work, eg OVTK_StimulationId_TrainCompleted fail in dict OpenViBE_stimulation

# most of the code taken from http://www.binarytides.com/python-socket-server-code-example/
BUFFER_SIZE = 1024

# We construct a box instance that inherits from the basic OVBox class
class MyOVBox(OVBox):
  # the constructor creates the box and initializes object variables
  def __init__(self):
    OVBox.__init__(self)
    # list of socket clients
    self.CONNECTION_LIST = []

  # the initialize method reads settings and outputs the first header
  def initialize(self):
    # connection infos
    self.ip = self.setting['IP']
    self.port = int(self.setting['Port'])
    # init server
    self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # this has no effect, why ?
    self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    # create connection
    self.server_socket.bind((self.ip, self.port))
    self.server_socket.listen(1)
    # Add server socket to the list of readable connections
    self.CONNECTION_LIST.append(self.server_socket)
    print "Chat server started on port " + str(self.port)
    
    # we append to the box output a stimulation header. This is just a header, dates are 0.
    self.output[0].append(OVStimulationHeader(0., 0.))

  def process(self):
      # we just listen at the moment
      self.listen_net()

  # listen and response to network
  def listen_net(self):
    # Get the list sockets which are ready to be read through select
    # last parameter for timeout
    read_sockets,write_sockets,error_sockets = select.select(self.CONNECTION_LIST,[],[], 0)

    for sock in read_sockets: 
      #New connection
      if sock == self.server_socket:
          # Handle the case in which there is a new connection recieved through server_socket
          sockfd, addr = self.server_socket.accept()
          self.CONNECTION_LIST.append(sockfd)
          print "Client (%s, %s) connected" % addr
      #data pending
      else:
          data = None
          # Data recieved from client, process it
          try:
              #In Windows, sometimes when a TCP program closes abruptly,
              # a "Connection reset by peer" exception will be thrown
              data = sock.recv(BUFFER_SIZE)
          # error, so remove from socket list
          except:
              #broadcast_data(sock, "Client (%s, %s) is offline" % addr)
              print "Error while reading, remove client"
              sock.close()
              self.CONNECTION_LIST.remove(sock)
              continue
          # empty string == deco
          if data != None and data == "":
              print "Client offline, remove from list"
              sock.close()
              self.CONNECTION_LIST.remove(sock)
          # we got data, trigger stim
          elif data != None:
              print "received data: [", data, "]"
              # remove white space at the same time
              self.send_stim(data.strip())
      
  def uninitialize(self):
    # we send a stream end.
    end = self.getCurrentTime()
    self.output[0].append(OVStimulationEnd(end, end))
    # close all remote connections
    for sock in self.CONNECTION_LIST:
      if sock != self.server_socket:
        # could send message on closing to client... or not
        #sock.send("closing!")
        sock.close();
    # close server socket
    self.server_socket.close();
    
  # send stimulation to external world
  # white spaces should have been removed at this point
  def send_stim(self, label):
    print "Got label: ", label
     # we get the corresponding code using the OpenViBE_stimulation dictionnary
    try:
      stimCode = OpenViBE_stimulation[label]
    # an exception means lookup failed in dict label:code
    except:
      print "Cannot get corresponding code, ignoring"
    # at this point we got a stimulation
    else:
      print "Corresponding code: ", stimCode
      # A stimulation set is a chunk which starts at current time and end time is the time step between two calls
      stimSet = OVStimulationSet(self.getCurrentTime(), self.getCurrentTime()+1./self.getClock())
      # the date of the stimulation is simply the current openvibe time when calling the box process
      stimSet.append(OVStimulation(stimCode, self.getCurrentTime(), 0.))
      self.output[0].append(stimSet)

box = MyOVBox()
