
import socket, select

BUFFER_SIZE = 2

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
    self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # non-blocking socket
    self.client_socket.setblocking(0)
    # create connection
    self.client_socket.connect((self.ip, self.port))
      
  # The process method will be called by openvibe on every clock tick
  def process(self):
    #while 1:
    try:
      data = self.client_socket.recv(BUFFER_SIZE)
    except:
      print "no data"
    else:
      if data == '':
        print "deco !"
      else:
        print "data !"
        print "data: [" + data + "]"
     
  def uninitialize(self):
    # close client socket
    self.client_socket.close();

# Finally, we notify openvibe that the box instance 'box' is now an instance of MyOVBox.
# Don't forget that step !!
box = MyOVBox()
