/* Speak.i */
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
