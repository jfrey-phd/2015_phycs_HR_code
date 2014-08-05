
# What

Experimental protocol for testing HR feedback hypothesis.

# How

In order to execute the complete protocol, you need to run the following programs:

1. ser2sock (in ./utils): read pulse raw data from serial port, broadcast to TCP
2. openvibe 0.18, "monitor_HR" scenario (in ./openvibe_scenarios)
    * read data from ser2sock, detect heart beats (possible to manipulate threshold in real time)
    * send back an event in TCP at each beat detected
3. Maestro with Processing: handles the experiment. read heartbeats from dectect_beats above
4. openvibe 0.18, "record_data" scenario (in ./openvibe_scenarios) -- optional but highly recommanded
    * records data from ser2sock
    * records beats from detect_beats
    * record events from Maestro
    
# TCP ports

* raw signal (ser2sock): 10000
* beats (openvibe monitor_HR): 11000