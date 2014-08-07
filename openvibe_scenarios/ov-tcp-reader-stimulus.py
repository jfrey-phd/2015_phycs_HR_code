
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
    # each client has its corresponding broken message
    self.broken_msg = {}

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
    self.broken_msg[self.server_socket] = ""
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
          # init corresponding value for broken_msg
          self.broken_msg[sockfd]=""
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
              # remove socket from list and cleanup dictionnary
              self.CONNECTION_LIST.remove(sock)
              del self.broken_msg[sock]
              continue
          # empty string == deco
          if data != None and data == "":
              print "Client offline, remove from list"
              sock.close()
              self.CONNECTION_LIST.remove(sock)
              del self.broken_msg[sock]
          # we got data, dig into ittrigger stim
          elif data != None:
              print "received data: [", data, "]"
              self.process_data(data, sock)
      
  # get data from network and makes proper label (split strings/reconstruct messages if needed)
  # since each client has its own state, need socket
  # (code from ov-tcp-reader-analog)
  def process_data(self, data, sock):
    # debug
    if self.broken_msg[sock] != "":
      print "====concatenating [" + self.broken_msg[sock] + "]"
      
    # flag to check for carriage return
    mes_OK = True
    # Retrieve data, each line should correspond to one stimulation
    # append eventual partial message from a previous broken code
    input_message = self.broken_msg[sock]+data
    # if not terminated by line return, there's a problem
    if input_message[len(input_message)-1] != '\n':
      print "============== Error ==============="
      mes_OK = False
    
    # on carriage return == one value
    # WARNING: compared to java algo, trailing \n will produce empty elements
    strs=input_message.split('\n')

    # stop before last, because message can be incomplete
    for i in range(0, len(strs)-1):
      print "received: [" + strs[i] + "]"
      # see what it can do...
      self.send_stim(strs[i])
      # if we are in this loop (at least one code ending with line return), then last broken message has been sent
      self.broken_msg[sock]=""
    # last code
    last = strs[len(strs)-1]
    # if message is broken, then save it in the right buffer (won't lost data if one code is split across several "packets", because buffer has already be concatenated to input_message)
    if not(mes_OK):
      self.broken_msg[sock] = last
      print "====partial code: " +  self.broken_msg[sock]
    # everything ok, treat the same the last element
    else:
      print "received: [" + last + "]"
      self.send_stim(last)
      # if the last chunk is ok, we don't have any pending broken message
      self.broken_msg[sock]=""
    
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
    # don't bother with empty value (split does that)
    if label != '':
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
