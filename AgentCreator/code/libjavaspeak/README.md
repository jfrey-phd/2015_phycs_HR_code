 
# Text to Speech in Java

Originates from http://reynold77.blogspot.fr/2010/03/text-to-speech-in-java-worked-well-on.html

## Dependencies

First of all install the following packages :

1. **espeak**: is a software speech synthesizer for English, and some other languages.
2. **libespeak-dev**: contains the eSpeak development files needed to build against the espeak 
shared library.
3. **SWIG**: SWIG is a compiler that makes it easy to integrate C and C++ code with other
languages including Perl, PHP, Tcl, Ruby, Python, Java,Guile, Mzscheme, Chicken, OCaml,
and C#.

## Steps

1. create a *speak.c* file

        #include <string.h>
        #include <malloc.h>
        #include <espeak/speak_lib.h>
        int initFlag = 0 ;
        /*
        * initFlag == 0 means not initialised and initFlag == 1 means initialised and is ready for
        * text to speech conversion
        */
        
        espeak_POSITION_TYPE position_type;
        espeak_AUDIO_OUTPUT output;
        
        
        void* user_data;
        t_espeak_callback *SynthCallback;
        espeak_PARAMETER Parm;
        
        unsigned int Size,position=0, end_position=0, flags=espeakCHARS_AUTO|espeakENDPAUSE, *unique_identifier;
        
        int setPitch(int value){
        if(initFlag == 0 ){
        printf("espeak Not initialised\n call initialise() first") ;
        return -1 ;
        }
        
        if(value > 99) value = 99 ;
        else if(value < 0) value = 0 ;
        
        espeak_SetParameter(espeakPITCH,value,0) ;
        
        return 0 ;
        }
        
        int setAmplitude(int value){
        if(initFlag == 0 ){
        printf("espeak Not initialised\n call initialise() first") ;
        return -1 ;
        }
        
        if(value > 200) value = 200 ;
        else if(value < 0) value = 0 ;
        
        espeak_SetParameter(espeakVOLUME,value,0) ;
        
        return 0 ;
        }
        
        int setPitchRange(int value){
        if(initFlag == 0 ){
        printf("espeak Not initialised\n call initialise() first") ;
        return -1 ;
        }
        
        if(value > 100) value = 100 ;
        else if(value < 0) value = 0 ;
        
        espeak_SetParameter(espeakRANGE,value,0) ;
        
        return 0 ;
        }
        
        int initialise(){
        if(initFlag == 1) return 0 ;
        
        int Buflength = 500, Options=0 ;
        char *path=NULL;
        char Voice[] = {"default"};
        
        output = AUDIO_OUTPUT_PLAYBACK; 
        
        if(espeak_Initialize(output, Buflength, path, Options ) == EE_INTERNAL_ERROR){
        printf("EE_INTERNAL_ERROR occured inside espeak_Initialize()") ;
        return -1 ;
        }
        
        if(espeak_SetVoiceByName(Voice) != EE_OK ){
        printf("\nEE_BUFFER_FULL | EE_INTERNAL_ERROR occured inside espeak_SetVoiceByName() in initialise()") ;
        return -1 ;
        }
        
        initFlag = 1 ; 
        
        return 0 ;
        }
        
        int espeak(const char *arr){
        if(initFlag == 0 ){
        printf("espeak Not initialised\n call initialise() first") ;
        return -1 ;
        }
        
        Size = strlen(arr)+1;
        printf("Size = %d ; Saying '%s'",Size,arr);
        
        if(espeak_Synth( arr, Size, position, position_type, end_position, flags,unique_identifier, user_data ) != EE_OK){
        printf("\nEE_BUFFER_FULL | EE_INTERNAL_ERROR occured inside espeak_Synth() in espeak()") ;
        return -1 ;
        }
        
        if(espeak_Synchronize( ) != EE_OK){
        printf("\nEE_INTERNAL_ERROR occured inside espeak_Synchronize() in espeak()\n syncronisation failed") ;
        return -1 ;
        }
        
        return 0 ;
        }
        
        int cancel(){
        if(espeak_Cancel() != EE_OK )
        return -1 ;
        
        return 0 ;
        }
        
        int isPlaying(){
        // Returns 1 if audio is played, 0 otherwise.
        return espeak_IsPlaying() ;
        }
        
        int terminate(){
        if(initFlag == 0 ){
        printf("Not initialised\n call initialise() first") ;
        return ;
        } 
        
        printf("\n:Done\n");
        if(espeak_Terminate( ) == EE_INTERNAL_ERROR){
        printf("EE_INTERNAL_ERROR occured inside espeak_Terminate() in terminate()") ;
        return -1 ;
        }
        printf("\n:Terminated !!!\n");
        
        initFlag = 1 ;
        
        return 0 ;
        }


2. create a *speak.i* file. It contains the function prototypes that are to be called from Java and is present in *speak.c* file.

        /* speak.i */
        %module Speak
        %{
        /* Put header files here or function declarations like below */
        extern int setPitch(int value);
        extern int setAmplitude(int value);
        extern int setPitchRange(int value);
        extern int initialise();
        extern int espeak(const char *arr);
        extern int cancel() ;
        extern int isPlaying();
        extern int terminate() ;
        %}
        
        extern int setPitch(int value);
        extern int setAmplitude(int value);
        extern int setPitchRange(int value);
        extern int initialise();
        extern int espeak(const char *arr);
        extern int cancel() ;
        extern int isPlaying();
        extern int terminate() ;


3. Perform this at the command prompt

        $ swig -java speak.i

    This creates the wrapper class for java and also produces a *speak_wrap.c* file

4. Compile the *speak.c* and *speak_wrap.c* files using gcc

        $ gcc -fpic -c Speak.c Speak_wrap.c -I $JAVA_HOME/include -I $JAVA_HOME/include/linux/

    Note: **$JAVA_HOME** is the path to the java installation directory, *eg* for ubuntu:

        $ JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

5. Create a shared library by linking the object codes to espeak's shared library:

        $ gcc -shared Speak.o Speak_wrap.o -lespeak -o libjavaSpeak.so

Note: this creates a new shared library named libjavaSpeak.so which we will use in our java
program.

## Using in standalone program

1. Create a java program to test the new library :

        public class Main{
        public static void main(String[] args){
        if(args.length != 1){
        System.out.println("USAGE: java -Djava.library.path=. Main ");
        return ;
        } 
        
        if(isContain44greaterNos(args[0])){
        //if more than 44 consecutive digits are given then espeak would fail
        System.out.println("NOTE: should not contain more than 44 consecutive digits");
        return ;
        }
        
        System.loadLibrary("javaSpeak"); 
        Speak.initialise() ;
        
        Speak.setPitch(99) ;
        Speak.setPitchRange(99) ;
        
        Speak.espeak(args[0]); 
        Speak.terminate(); 
        }
        
        private static boolean isContain44greaterNos(String numCheck){
        return numCheck.matches("\\d{45,}") ;
        
        }
        }


2. Compile the main file

        $ javac Main.java

3. Run the main file

        $ java -Djava.library.path=. Main <text to speak>

NOTE: if we place the libjavaSpeak.so shared library in the $JAVA_HOME/jre/lib/i386/
folder; the we could run the program as

        $ java Main <text to speak>

## Using with Processing

Here is a minimal exemple:

1. Put *Speak.java* and *SpeakJNI.java* in the sketch folder.
2. Put *libjavaspeak.so* in a subfolder called *data*
3. In setup add:

        Speak.initialise() ;
        Speak.setPitch(99) ;
        Speak.setPitchRange(99);

4. Create a function *speak()*

        void speak() {
          Speak.espeak("Hello everybody!");
        }

5. Use thread mechanism so as not to block the main program:

        thread("speak");
