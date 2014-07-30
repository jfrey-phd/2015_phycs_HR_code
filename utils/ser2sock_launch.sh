 #/bin/sh

# baud rate up to arduino, change tty accordingly
ser2sock -s /dev/ttyACM0  -0 -b 115200 -p 10000
