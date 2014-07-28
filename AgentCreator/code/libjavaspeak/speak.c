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
 
