
import socket, traceback, numpy

BUFFER_SIZE = 2048
# in seconds, how long do we wait between two connection attempts
WAITTIME_BEFORE_RECO = 0.5

connected =  False

# WARNING: does not write anyting, simply listen to server data

# let's define a new box class that inherits from OVBox
class MyOVBox(OVBox):
  def __init__(self):
    OVBox.__init__(self)
    
    # for sending data to openvibe
    self.samplingFrequency = 100
    # must be a dividor of samplingFrequency... not too small?
    self.epochSampleCount = 25
    self.startTime = 0.
    self.endTime = 0.
    self.dimensionSizes = list()
    self.dimensionLabels = list()
    self.timeBuffer = list()
    self.signalBuffer = None
    self.signalHeader = None
    
    self.lastValue = 0

  # the initialize method reads settings and outputs the first header
  def initialize(self):
    # connection infos
    self.ip = self.setting['IP']
    self.port = int(self.setting['Port'])
    # in case a code is split between several network buffer
    self.broken_msg = ""
    # init client
    self.create_socket()
    self.connect_to_server()
    self.buffer = []
    
    #creation of the signal header -- simplified code with one channel at the moment
    self.dimensionLabels.append( 'Chan1')
    self.dimensionLabels += self.epochSampleCount*['']
    self.dimensionSizes = [1, self.epochSampleCount]
    self.signalHeader = OVSignalHeader(0., 0., self.dimensionSizes, self.dimensionLabels, self.samplingFrequency)
    self.output[0].append(self.signalHeader)
    
    #creation of the first signal chunk
    self.endTime = 1.*self.epochSampleCount/self.samplingFrequency
    self.signalBuffer = numpy.zeros(self.epochSampleCount)
    self.updateTimeBuffer()
    self.updateSignalBuffer()
    

  #the followin are taken from openvibe doc, sample code for oscillator
  def updateStartTime(self):
    self.startTime += 1.*self.epochSampleCount/self.samplingFrequency

  def updateEndTime(self):
    self.endTime = float(self.startTime + 1.*self.epochSampleCount/self.samplingFrequency)

  def updateTimeBuffer(self):
    self.timeBuffer = numpy.arange(self.startTime, self.endTime, 1./self.samplingFrequency)

  def updateSignalBuffer(self):
        self.signalBuffer[:] = 100.*numpy.sin( 2.*numpy.pi*1.*self.timeBuffer )

  def sendSignalBufferToOpenvibe(self):
    start = self.timeBuffer[0]
    end = self.timeBuffer[-1] + 1./self.samplingFrequency
    bufferElements = self.signalBuffer.reshape(self.epochSampleCount).tolist()
    self.output[0].append( OVSignalBuffer(start, end, bufferElements) )

      
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
          #print "data: [" + data + "]"
          # at this point we got data, let's check it
          self.process_data(data)
    
    # Check if it's time to send the buffer
    start = self.timeBuffer[0]
    end = self.timeBuffer[-1]
    if self.getCurrentTime() >= end:
        # will interpolate/decimate data depending on what we received
        self.sendSignalBufferToOpenvibe()
        # reset data for next buffer
        #self.signalBuffer= []
        self.buffer = []
        self.updateStartTime()
        self.updateEndTime()
        self.updateTimeBuffer()
        self.updateSignalBuffer()
    
   
  # copied from processing sketch, check message consistency, produce data
  def process_data(self, data):
    # debug
    #if self.broken_msg != "":
      #print "====concatenating [" + self.broken_msg + "]"
      
    # flag to check for carriage return
    mes_OK = True
    # Retrieve data, each line should correspond to one stimulation
    # append eventual partial message from a previous broken code
    input_message = self.broken_msg+data
    # if not terminated by line return, there's a problem
    if input_message[len(input_message)-1] != '\n':
      #print "============== Error ==============="
      mes_OK = False
    
    # on carriage return == one value
    # WARNING: compared to java algo, trailing \n will produce empty elements
    strs=input_message.split('\n')

    # stop before last, because message can be incomplete
    for i in range(0, len(strs)-1):
      #print "received: [" + strs[i] + "]"
      # see what it can do...
      self.trigger(strs[i])
      # if we are in this loop (at least one code ending with line return), then last broken message has been sent
      self.broken_msg=""
    # last code
    last = strs[len(strs)-1]
    # if message is broken, then save it in the right buffer (which could hold already something if the same code is split across several "packets")
    if not(mes_OK):
      self.broken_msg += last
      #print "====partial code: " +  self.broken_msg
    # everything ok, treat the same the last element
    else:
      #print "received: [" + last + "]"
      self.trigger(last)
      # if the last chunk is ok, we don't have any pending broken message
      self.broken_msg=""
    
    
  # called by process_data for each value received
  def trigger(self, value):
    # don't bother with empty value (split does that)
    if value != '':
      #print "value: " + value
      self.buffer.append(float(value))

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
    except:
      traceback.print_exc()
      print "Failed to connect"
      self.connected = False
    else:
      print "Connected"
      self.connected = True

# Finally, we notify openvibe that the box instance 'box' is now an instance of MyOVBox.
# Don't forget that step !!
box = MyOVBox()
