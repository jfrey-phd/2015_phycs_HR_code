
# What

Experimental protocol for testing HR feedback hypothesis.

# How

In order to execute the complete protocol, you need to run the following programs:

1. ser2sock (in ./utils): read pulse raw data from serial port, broadcast to TCP
2. openvibe 0.18, "monitor_HR" scenario (in ./openvibe_scenarios)
    * read data from ser2sock, detect heart beats (possible to manipulate threshold in real time)
    * send back an event in TCP at each beat detected
3. openvibe 0.18, "record_all" scenario (in ./openvibe_scenarios) -- optional but highly recommanded
    * records data from ser2sock
    * records beats from detect_beats
    * record events from Maestro
4. Maestro with Processing (tested with 2.2.1): handles the experiment. read heartbeats from dectect_beats above, send stimulus to record_all

# Where

In order to monitor HR and tune detection, it's better to run the experiment on two computers: ser2sock and Processing on the first one (subject's computer) and two instances of openvibe on the second one (experimenter's computer).

# TCP ports

* raw signal (ser2sock): 10000
* beats (openvibe monitor_HR): 11000
* stims (openvibe recard_all): 11001
