
import socket, select

# Box wich reads a stream of strings from TCP *client* and convert them to stimulus (\n as separator).

# most of the code taken from http://www.binarytides.com/python-socket-server-code-example/
BUFFER_SIZE = 1024

# We construct a box instance that inherits from the basic OVBox class
class MyOVBox(OVBox):
    # the constructor creates the box and initializes object variables
   def __init__(self):
      OVBox.__init__(self)
      self.stimLabel = None
      self.stimCode = None
      # list of socket clients
      self.CONNECTION_LIST = []
      # pending off stim
      self.off_stim_to_send = False
      # if so, when to send
      self.off_stim_time = -1

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
      
      # the stim label is taken from the box setting
      self.stimLabel = self.setting['Stimulation']
      # stim send to "disable" VRPN
      self.stimLabelOff = self.setting['StimulationEnd']
      # for how long the stim is "on" after sending response
      # NB: if too short VRPN client may miss events, if too long we won't process pings fast enough
      self.stimDelay = self.setting['OffDelay']
      # we get the corresponding code using the OpenViBE_stimulation dictionnary
      self.stimCode = OpenViBE_stimulation[self.stimLabel]
      # same for "off"
      self.stimCodeOff = OpenViBE_stimulation[self.stimLabelOff]
      # we append to the box output a stimulation header. This is just a header, dates are 0.
      self.output[0].append(OVStimulationHeader(0., 0.))

   def process(self):
    # using timing with stimulations doesn't work well with VRPN and we don't have something similar to LUA box:sleep() (??), work out our own solution to send a delayed stimulation
    
    # if we have a "off" signal pending, deal with it
    if (self.off_stim_to_send):
      # if it's not time yet, just wait
      if self.off_stim_time > self.getCurrentTime():
	return
      # *now* we can work
      else:
	self.send_stim_off()
	self.off_stim_to_send = False
    # no signal to end, we can deal with network
    else:
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
	  
	  #Some incoming message from a client
	  else:
	      data = None
	      # Data recieved from client, process it
	      try:
		  #In Windows, sometimes when a TCP program closes abruptly,
		  # a "Connection reset by peer" exception will be thrown
		  data = sock.recv(BUFFER_SIZE)
		  # echo back the client message and send stimulation within openvibe
	      # client disconnected, so remove from socket list
	      except:
		  #broadcast_data(sock, "Client (%s, %s) is offline" % addr)
		  print "Client offline"
		  sock.close()
		  self.CONNECTION_LIST.remove(sock)
		  continue
	      # we got data, send echo, trigger stim and compute off stim
	      if data != None:
		  print "received data:", data
		  sock.send(data)
		  self.send_stim_on()
		  self.off_stim_to_send = True
		  self.off_stim_time = self.getCurrentTime()+float(self.stimDelay)
      
   def uninitialize(self):
      # we send a stream end.
      end = self.getCurrentTime()
      self.output[0].append(OVStimulationEnd(end, end))
      # close all remote connections
      for sock in self.CONNECTION_LIST:
	if sock != self.server_socket:
	  sock.send("closing!")
	  sock.close();
      # close server socket
      self.server_socket.close();
    
   # send ON stimulation to external world
   def send_stim_on(self):
      # A stimulation set is a chunk which starts at current time and end time is the time step between two calls
      stimSet = OVStimulationSet(self.getCurrentTime(), self.getCurrentTime()+1./self.getClock())
      # the date of the stimulation is simply the current openvibe time when calling the box process
      stimSet.append(OVStimulation(self.stimCode, self.getCurrentTime(), 0.))
      self.output[0].append(stimSet)

   # send OFF stimulation to external world
   def send_stim_off(self):
      # New stim to end VRPN button
      stimSetOff = OVStimulationSet(self.getCurrentTime(), self.getCurrentTime()+1./self.getClock())
      # the date of the stimulation is simply the current openvibe time when calling the box process
      stimSetOff.append(OVStimulation(self.stimCodeOff, self.getCurrentTime(), 0.))
      self.output[0].append(stimSetOff) 

box = MyOVBox()
