
import socket, time, traceback

BUFFER_SIZE = 2048
# in seconds, how long do we wait between two connection attempts
WAITTIME_BEFORE_RECO = 0.5

connected =  False

# WARNING: does not write anyting, simply listen to server data

# let's define a new box class that inherits from OVBox
class MyOVBox(OVBox):
  def __init__(self):
    OVBox.__init__(self)

  # the initialize method reads settings and outputs the first header
  def initialize(self):
    # connection infos
    self.ip = self.setting['IP']
    self.port = int(self.setting['Port'])
    # init client
    self.create_socket()
    self.connect_to_server()
  
  # need to be call also upon deco from server to avoid "[Errno 106] Transport endpoint is already connected") and create a new one (to avoid "[Errno 9] Bad file descriptor") on following reco
  def create_socket(self):
    self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # non-blocking socket
    self.client_socket.setblocking(0)
    # try to connect
    self.connected = False
    
  # The process method will be called by openvibe on every clock tick
  def process(self):
    # if connected, listen to data
    if self.connected:
      # listen to new data
      try:
        data = self.client_socket.recv(BUFFER_SIZE)
      # in non blocking sockets, an error is raised if nothing is received
      except:
        next
      else:
        # no data means server deconnected; we have to close socket (to avoid "[Errno 106] Transport endpoint is already connected") and create a new one (to avoid "[Errno 9] Bad file descriptor") on reco
        if data == '':
          print "Deconnected"
          self.create_socket()
        else:
          print "data: [" + data + "]"
    # not connected, way try reco
    else:
      if time.clock() - self.last_attempt > WAITTIME_BEFORE_RECO:
        self.connect_to_server()

  def uninitialize(self):
    # close client socket
    if self.connected:
      self.client_socket.close();
    
  # (re)tries to connect to server
  def connect_to_server(self):
    self.last_attempt = time.clock()
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
