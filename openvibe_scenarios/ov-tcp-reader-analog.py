
import socket, traceback, numpy
from scipy.interpolate import interp1d

# Box wich reads a stream of strings from TCP and convert them to signal (\n as separator).

# Select Interpolation method in openvibe, use an int:
# 0: linear (default)
# 1: cubic
# 2: nearest

BUFFER_SIZE = 2048
# in seconds, how long do we wait between two connection attempts
WAITTIME_BEFORE_RECO = 0.5

# NB: does not write anyting, simply listen to server data

# WARNING: due to network latency or arduino delays, will probably modify data a bit for synchronization sake

# let's define a new box class that inherits from OVBox
class MyOVBox(OVBox):
  def __init__(self):
    OVBox.__init__(self)
    
    # for sending data to openvibe
    # WARNING: too high and interpolation will occur, too low and data will be decimated... depending on chunk size.
    self.samplingFrequency = 512
    # big chunk for closer interpolation/decimation
    self.epochSampleCount = 128
    self.startTime = 0.
    self.endTime = 0.
    self.dimensionSizes = list()
    self.dimensionLabels = list()
    self.timeBuffer = list()
    self.signalBuffer = None
    self.signalHeader = None
    # useful if not enough data (0 or 1 value)
    self.lastValue = 0
    # will spam stdout if True
    self.debug = False
    # interpolation method, see class header for help
    self.interpolation = 'linear'

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
    # FIXME: a list is not efficient
    self.buffer = []
    # get debug flag from GUI
    self.debug = (self.setting['Debug']=="true")
    
    interpolation_code = 0
    # try to recover interpolation method
    interpolation_code = 0
    try:
      # set as an int from box settings
      interpolation_code = int(self.setting['Interpolation method'])
    except:
      print "Couldn't find interpolation method"
    else:
      # only 0/1/2, otherwise back to default 0
      if (interpolation_code < 0) or (interpolation_code > 2):
        print "Bad interpolation selected (" + str(interpolation_code) + "), back to default"
        interpolation_code = 0
    
    # convert code to method name
    if interpolation_code == 1:
      self.interpolation = 'cubic'
    elif interpolation_code == 2:
      self.interpolation = 'nearest'
    else:
      self.interpolation = 'linear'
    print "Interpolation method: " + str(self.interpolation)

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
    #self.updateSignalBuffer()
    

  #the followin are taken from openvibe doc, sample code for oscillator
  def updateStartTime(self):
    self.startTime += 1.*self.epochSampleCount/self.samplingFrequency

  def updateEndTime(self):
    self.endTime = float(self.startTime + 1.*self.epochSampleCount/self.samplingFrequency)

  def updateTimeBuffer(self):
    self.timeBuffer = numpy.arange(self.startTime, self.endTime, 1./self.samplingFrequency)

  #def updateSignalBuffer(self):
  #  self.signalBuffer = 100.*numpy.sin( 2.*numpy.pi*1.*self.timeBuffer )

  #the sensitive part: will interpolate/decimate signal to fit openvibe timing
  def sendSignalBufferToOpenvibe(self):
    start = self.timeBuffer[0]
    end = self.timeBuffer[-1] + 1./self.samplingFrequency
    #bufferElements = self.signalBuffer.reshape(self.epochSampleCount).tolist()
    if self.debug:
      print "buffer size: " + str(len(self.buffer))
    # the chunk we gonna fill
    chunkBuffer = numpy.zeros(self.epochSampleCount);
    if self.debug:
      print "chunk size: " + str(self.epochSampleCount)
    
    #if buffer empty, give it at least one element
    if len(self.buffer) < 1:
      self.buffer.append(self.lastValue)
      if self.debug:
        print "Empty buffer, put last value: " + str(self.lastValue)
    
    # we will have to adapt sigal to fit openvibe requisite
    if len(self.buffer) != self.epochSampleCount:
      if self.debug:
        print "Damn, buffer and chunk len mismatch"
      chunkBuffer=self.resample(numpy.asarray(self.buffer), self.epochSampleCount)
    # won't happen often, just have to copy
    else:
      if self.debug:
        print "Lucky: same size for buffer and chunk"
      for i in range(0, min(len(self.buffer), len(chunkBuffer))):
        chunkBuffer[i]=self.buffer[i]
      
    self.output[0].append( OVSignalBuffer(start, end, chunkBuffer.tolist()) )

  # from the array array_from, return an array nb_samples long with interpolated data (could cause decimation if nb_samples smaller)
  def resample(self, array, nb_samples):
    # the chunk we gonna fill
    chunkBuffer = numpy.zeros(nb_samples);
    
    # got no data, won't return any data
    if (len(array) == 0):
      if self.debug:
        print "Empty array, can't seek any data"
    # with one element we won't interpolate much, just replicate the one item
    elif (len(array) == 1):
      chunkBuffer = chunkBuffer+array[0]
    # the real scenario!
    else:
      if self.debug:
        if len(array) < nb_samples:
          print "Oversampling!"
        else:
          print "Decimation!"
      # two spaces: in and out
      x_in = numpy.linspace(0,1,len(array))
      x_out = numpy.linspace(0,1,nb_samples)
      # interpolation data, using the method seleced by the user
      f = interp1d(x_in, array, kind=self.interpolation)
      # fill output with interpolation
      chunkBuffer=f(x_out)
    
    if self.debug:
      print "Before:", array
      print "After:", chunkBuffer
    return chunkBuffer
    
      
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
        #self.updateSignalBuffer()
    
   
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
      # record for sendSignalBufferToOpenvibe()
      self.lastValue = float(value)

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
