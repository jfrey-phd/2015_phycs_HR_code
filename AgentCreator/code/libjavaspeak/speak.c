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

unsigned int Size, position=0, end_position=0, flags=espeakCHARS_AUTO|espeakENDPAUSE, *unique_identifier;

int setPitch(int value) {
  if (initFlag == 0 ) {
    printf("espeak Not initialised\n call initialise() first") ;
    return -1 ;
  }

  if (value > 99) value = 99 ;
  else if (value < 0) value = 0 ;

  espeak_SetParameter(espeakPITCH, value, 0) ;

  return 0 ;
}

int setAmplitude(int value) {
  if (initFlag == 0 ) {
    printf("espeak Not initialised\n call initialise() first") ;
    return -1 ;
  }

  if (value > 200) value = 200 ;
  else if (value < 0) value = 0 ;

  espeak_SetParameter(espeakVOLUME, value, 0) ;

  return 0 ;
}

int setPitchRange(int value) {
  if (initFlag == 0 ) {
    printf("espeak Not initialised\n call initialise() first") ;
    return -1 ;
  }

  if (value > 100) value = 100 ;
  else if (value < 0) value = 0 ;

  espeak_SetParameter(espeakRANGE, value, 0) ;

  return 0 ;
}

int setRate(int value) {
  if (initFlag == 0 ) {
    printf("espeak Not initialised\n call initialise() first") ;
    return -1 ;
  }

  if (value > 450) value = 450 ;
  else if (value < 80) value = 80 ;

  espeak_SetParameter(espeakRATE, value, 0) ;

  return 0 ;
}

// units of 10ms
int setWordgap(int value) {
  if (initFlag == 0 ) {
    printf("espeak Not initialised\n call initialise() first") ;
    return -1 ;
  }

  espeak_SetParameter(espeakWORDGAP, value, 0) ;

  return 0 ;
}

// voice: select voice name (eg: "default" without MBOROLA)
// MBROLA_voice: 0 for espeak voices, 1 for MBROLA voices
int initialise(const char *voice, int MBROLA_voice) {
  if (initFlag == 1) return 0 ;

  int Buflength = 500, Options=0 ;
  char *path=NULL;
  
  output = AUDIO_OUTPUT_PLAYBACK; 

  if (espeak_Initialize(output, Buflength, path, Options ) == EE_INTERNAL_ERROR) {
    printf("EE_INTERNAL_ERROR occured inside espeak_Initialize()") ;
    return -1 ;
  }
  
  if(MBROLA_voice==0) {
    espeak_SetParameter(espeakVOICETYPE, 0, 0);
  }
  else {
    espeak_SetParameter(espeakVOICETYPE, 1, 0);
  }
  
  if (espeak_SetVoiceByName(voice) != EE_OK ) {
    printf("\nEE_BUFFER_FULL | EE_INTERNAL_ERROR occured inside espeak_SetVoiceByName() in initialise()") ;
    return -1 ;
  }
  
    espeak_VOICE *voice_spec = espeak_GetCurrentVoice(); 
  //voice_spec->gender=2;
//   if (espeak_SetVoiceByProperties(voice_spec) != EE_OK ) {
//     printf("\nEE_BUFFER_FULL | EE_INTERNAL_ERROR occured inside espeak_SetVoiceByProperties in initialise()") ;
//     return -1 ;
//   }

  initFlag = 1 ; 

  return 0 ;
}

int espeak(const char *arr) {
  if (initFlag == 0 ) {
    printf("espeak Not initialised\n call initialise() first") ;
    return -1 ;
  }

  Size = strlen(arr)+1;
  printf("Size = %d ; Saying '%s'", Size, arr);

  if (espeak_Synth( arr, Size, position, position_type, end_position, flags, unique_identifier, user_data ) != EE_OK) {
    printf("\nEE_BUFFER_FULL | EE_INTERNAL_ERROR occured inside espeak_Synth() in espeak()") ;
    return -1 ;
  }

  if (espeak_Synchronize( ) != EE_OK) {
    printf("\nEE_INTERNAL_ERROR occured inside espeak_Synchronize() in espeak()\n syncronisation failed") ;
    return -1 ;
  }

  return 0 ;
}

int cancel() {
  if (espeak_Cancel() != EE_OK )
    return -1 ;

  return 0 ;
}

int isPlaying() {
  // Returns 1 if audio is played, 0 otherwise.
  return espeak_IsPlaying() ;
}

int terminate() {
  if (initFlag == 0 ) {
    printf("Not initialised\n call initialise() first") ;
    return ;
  } 

  printf("\n:Done\n");
  if (espeak_Terminate( ) == EE_INTERNAL_ERROR) {
    printf("EE_INTERNAL_ERROR occured inside espeak_Terminate() in terminate()") ;
    return -1 ;
  }
  printf("\n:Terminated !!!\n");

  initFlag = 1 ;

  return 0 ;
}

// select voice withe its name.
// FIXME: MBROLA option has to be set upon initialization
int setVoice(const char *voice) {
  if (espeak_SetVoiceByName(voice) != EE_OK ) {
    printf("\nEE_BUFFER_FULL | EE_INTERNAL_ERROR occured inside espeak_SetVoiceByName() in initialise()") ;
    return -1 ;
  }
  return 0;
}

// select gender: 0=none 1=male, 2=female
// dead code, not working, an idea for selecting gender of default voice (no use for MBOROLA)
// int setGender(int gender) {
//   espeak_VOICE *voice_spec = espeak_GetCurrentVoice(); 
//   voice_spec->gender=gender;
//   if (espeak_SetVoiceByProperties(voice_spec) != EE_OK ) {
//     printf("\nEE_BUFFER_FULL | EE_INTERNAL_ERROR occured inside espeak_SetVoiceByProperties in initialise()") ;
//     return -1 ;
//   }
//   return 0;
// }

