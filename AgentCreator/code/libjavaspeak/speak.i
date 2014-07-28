/* Speak.i */
%module Speak
%{
/* Put header files here or function declarations like below */
extern int setPitch(int value);
extern int setAmplitude(int value);
extern int setPitchRange(int value);
extern int setRate(int value);
extern int setWordgap(int value);
extern int initialise(const char *voice, int MBROLA_voice);
extern int espeak(const char *arr);
extern int cancel() ;
extern int isPlaying();
extern int terminate() ;
extern int setVoice(const char *voice) ;
%}

extern int setPitch(int value);
extern int setAmplitude(int value);
extern int setPitchRange(int value);
extern int setRate(int value);
extern int setWordgap(int value);
extern int initialise(const char *voice, int MBROLA_voice);
extern int espeak(const char *arr);
extern int cancel() ;
extern int isPlaying();
extern int terminate() ; 
extern int setVoice(const char *voice) ;
