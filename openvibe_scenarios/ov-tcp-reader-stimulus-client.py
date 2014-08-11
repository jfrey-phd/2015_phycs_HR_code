
import socket, traceback

# Box wich reads a stream of strings from TCP *server* and convert them to stimulus (\n as separator).

BUFFER_SIZE = 2048
# in seconds, how long do we wait between two connection attempts
WAITTIME_BEFORE_RECO = 0.5

# NB: does not write anyting, simply listen to server data

# let's define a new box class that inherits from OVBox
class MyOVBox(OVBox):
  def __init__(self):
    OVBox.__init__(self)
    # will spam stdout if True
    self.debug = False
    # in case a code is split between several network buffer
    self.broken_msg = ""
    
  # the initialize method reads settings and outputs the first header
  def initialize(self):
    # connection infos
    self.ip = self.setting['IP']
    self.port = int(self.setting['Port'])
    # try get debug flag from GUI
    try:
      debug = (self.setting['Debug']=="true")
    except:
      print "Couldn't find debug flag"
    else:
      self.debug=debug
    print "Debug flag:" + str(self.debug)
    # init client
    self.create_socket()
    self.connect_to_server()
    # we append to the box output a stimulation header. This is just a header, dates are 0.
    self.output[0].append(OVStimulationHeader(0., 0.))
      
  # need to be call also upon deco from server to avoid "[Errno 106] Transport endpoint is already connected") and create a new one (to avoid "[Errno 9] Bad file descriptor") on following reco
  def create_socket(self):
    self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # non-blocking socket
    self.client_socket.setblocking(0)
    # try to connect
    self.connected = False
    
  # The process method will be called by openvibe on every clock tick
  def process(self):
    # if not connected, may try reco
    if not(self.connected):
      if self.getCurrentTime() - self.last_attempt > WAITTIME_BEFORE_RECO:
        self.connect_to_server()
    # if connected, listen to data
    else:
      # listen to new data
      try:
        data = self.client_socket.recv(BUFFER_SIZE)
      # in non blocking sockets, an error is raised if nothing is received
      except:
        next
      else:
        # no data means server deconnected; we have to close socket and clean message buffer
        if data == '':
          print "Deconnected"
          self.create_socket()
          self.broken_msg = ""
        else:
          if self.debug:
            print "data: [" + data + "]"
          # at this point we got data, let's check it
          self.process_data(data)

  # copied from processing sketch, check message consistency, produce data
  def process_data(self, data):
    # debug
    if self.broken_msg != "" and self.debug:
      print "====concatenating [" + self.broken_msg + "]"
      
    # flag to check for carriage return
    mes_OK = True
    # Retrieve data, each line should correspond to one stimulation
    # append eventual partial message from a previous broken code
    input_message = self.broken_msg+data
    # if not terminated by line return, there's a problem
    if input_message[len(input_message)-1] != '\n':
      if self.debug:
        print "============== Error ==============="
      mes_OK = False
    
    # on carriage return == one value
    # WARNING: compared to java algo, trailing \n will produce empty elements
    strs=input_message.split('\n')

    # stop before last, because message can be incomplete
    for i in range(0, len(strs)-1):
      if self.debug:
        print "received: [" + strs[i] + "]"
      # see what it can do...
      self.trigger(strs[i])
      # if we are in this loop (at least one code ending with line return), then last broken message has been sent
      self.broken_msg=""
    # last code
    last = strs[len(strs)-1]
    # if message is broken, then save it in the right buffer (won't lost data if one code is split across several "packets", because buffer has already be concatenated to input_message)
    if not(mes_OK):
      self.broken_msg = last
      if self.debug:
        print "====partial code: " +  self.broken_msg
    # everything ok, treat the same the last element
    else:
      #print "received: [" + last + "]"
      self.trigger(last)
      # if the last chunk is ok, we don't have any pending broken message
      self.broken_msg=""
    
  # called by process_data for each value received
  # send stimulation to external world
  # white spaces should have been removed at this point
  def trigger(self, label):
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

  def uninitialize(self):
    # close client socket
    if self.connected:
      self.client_socket.close()
    
  # (re)tries to connect to server
  def connect_to_server(self):
    self.last_attempt = self.getCurrentTime()
    print "Connection attempt at: " + str(self.last_attempt) + "s"
    try:
      # create connection
      self.client_socket.connect((self.ip, self.port))
    except Exception as e:
      print "Failed to connect" + " -- " + str(e)
      self.connected = False
    else:
      print "Connected"
      self.connected = True

# Finally, we notify openvibe that the box instance 'box' is now an instance of MyOVBox.
# Don't forget that step !!
box = MyOVBox()
