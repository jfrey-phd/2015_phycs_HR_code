
# What

Experimental protocol for testing HR feedback hypothesis.

# How

## Dependencies

* espeak, mborola (tts)
    * voices for mbrola: mbrola-fr1 and mbrola-fr4 are usually included in distribution (eg: ubuntu), retrieve fr2 and fr3 from mbrola server (http://tcts.fpms.ac.be/synthesis/mbrola.html) and place those files in the right place in the system.
* python-scipy, python-tk (openvibe scenarios)
* libssl-dev (to compile ser2sock)
* alsa-utils (for "aplay")


## Programs

* openvibe 0.18
* processing 2.2.1
* ser2sock (sources include in repository, "utils" folder )

## Script

In order to execute the complete protocol, you need to run the following:

1. ser2sock: read pulse raw data from serial port, broadcast to TCP. See script "utils/ser2sock_launch.sh"
2. openvibe, "monitor_HR" scenario (in ./openvibe_scenarios)
    * read data from ser2sock, detect heart beats (possible to manipulate threshold in real time)
    * send back an event in TCP at each beat detected
3. openvibe, "record_all" scenario (in ./openvibe_scenarios) -- optional but highly recommanded
    * records data from ser2sock
    * records beats from detect_beats
    * record events from Maestro
4. Maestro with Processing: handles the experiment. read heartbeats from dectect_beats above, send stimulus to record_all

# Where

In order to monitor HR and tune detection, it's better to run the experiment on two computers: ser2sock and Processing on the first one (subject's computer) and two instances of openvibe on the second one (experimenter's computer).

# TCP ports

* raw signal (ser2sock): 10000
* beats (openvibe monitor_HR): 11000
* stims (openvibe recard_all): 11001
