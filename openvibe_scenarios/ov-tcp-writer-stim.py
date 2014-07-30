
import socket, select

# WARNING: does not listen for anything, simply send to clients stim codes

# let's define a new box class that inherits from OVBox
class MyOVBox(OVBox):
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
    print "Chat server started on port " + str(self.port)
      
  # The process method will be called by openvibe on every clock tick
  def process(self):
    
    # First listen for new connections, and new connections only -- this is why we pass only server_socket
    read_sockets,write_sockets,error_sockets = select.select([self.server_socket],[],[], 0)
    for sock in read_sockets:
	# New connection
	sockfd, addr = self.server_socket.accept()
	self.CONNECTION_LIST.append(sockfd)
	print "Client (%s, %s) connected" % addr
    # and... don't bother with incoming messages
    
    # Now deal with stimulations
    # we iterate over all the input chunks in the input buffer
    for chunkIndex in range( len(self.input[0]) ):
      #print "len input:" + str(len(self.input[0]))
      #print "type:" + str(type(self.input[0][chunkIndex]))
      # if it's a header we save it and send the output header (same as input, except it has only one channel named 'Mean'
      if(type(self.input[0][chunkIndex]) == OVStimulationHeader):
	  #print "header stim"
	  # remove from entry
	  self.input[0].pop()
      # we reiceive actual data
      elif(type(self.input[0][chunkIndex]) == OVStimulationSet):
	  stimSet = self.input[0].pop()
	  # even without any signals we receive sets, have to check what they hold
	  nb_stim =  str(len(stimSet))
	  #print "set size: " +  nb_stim
	  for stim in stimSet:
	    #print "a stim: " + str(stim) + ", identifier: " + str(stim.identifier)
	    # send every stim id to every clients
	    self.broadcast_msg(str(stim.identifier))
      # if it's a end-of-stream we just forward that information to the output    
      elif(type(self.input[0][chunkIndex]) == OVStimulationEnd):
	    #print "end stim"
	    self.input[0].pop()
	    #self.output[0].append(self.input[0].pop())
	     
  def uninitialize(self):
    # close all remote connections
    for sock in self.CONNECTION_LIST:
      if sock != self.server_socket:
	try:
	  sock.send("closing!\n")
	# at this point don't bother is message not sent
	except:
	  continue
	sock.close();
    # close server socket
    self.server_socket.close();
      
  # broadcast a message to all clients
  # NB: adds line break
  # TODO: use integer instead of string? http://www.gossamer-threads.com/lists/python/python/666877
  def broadcast_msg(self, msg):
    # save sockets that are closed to remove them later on
    outdated_list = []
    i=0
    #print "nb sockets: " + str(len(self.CONNECTION_LIST))
    for sock in self.CONNECTION_LIST:
      #print "send stim to " + str(sock)
      # If one error should happen, we remove socket from the list
      try:
	sock.send(msg + "\n")
      except:
	# sometimes (always?) it's only during the second write to a close socket that an error is raised?
	print "something bad happened, will close socket"
	outdated_list.append(sock)
      i = i+1
    # now we are outside of the main list, it's time to remove outdated sockets, if any
    for bad_sock in outdated_list:
	print "removing socket..."
	self.CONNECTION_LIST.remove(bad_sock)
	# not very costly to be polite
	bad_sock.close()

# Finally, we notify openvibe that the box instance 'box' is now an instance of MyOVBox.
# Don't forget that step !!
box = MyOVBox()
