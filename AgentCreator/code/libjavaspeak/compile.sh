
JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

# compile
swig -java speak.i
gcc -fpic -c speak.c speak_wrap.c -I $JAVA_HOME/include -I $JAVA_HOME/include/linux/
gcc -shared speak.o speak_wrap.o -lespeak -o libjavaspeak.so


# install
cp libjavaspeak.so ../
cp Speak.java SpeakJNI.java ../../