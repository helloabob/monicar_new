//
//  myAudio.m
//  Test
//
//  Created by MacBook on 12-7-30.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "myAudio.h"



@implementation myAudio

@synthesize mContext;
@synthesize mDevice;


BOOL isPlay=YES;



-(void)startPlay{
	isPlay=YES;
}
-(void)stopPlay{
	[self stopSound];
	isPlay=NO;
}

void interruptionListenerCallback(void  *inUserData ,UInt32 interruptionState){
    
    myAudio *controller = (myAudio *) inUserData;
	
	if (interruptionState==kAudioSessionBeginInterruption) {
		[controller _haltOpenALSession];
	} else if (interruptionState==kAudioSessionEndInterruption) {
		[controller _resumeOpenALSession];
	}
}

-(void)_haltOpenALSession{
    AudioSessionSetActive(NO);
    // set the current context to NULL will 'shutdown' openAL
    alcMakeContextCurrent(NULL);
    // now suspend your context to 'pause' your sound world
    alcSuspendContext(mContext);
}

-(void)_resumeOpenALSession{
    // Reset audio session
    UInt32 category = kAudioSessionCategory_AmbientSound;
    AudioSessionSetProperty ( kAudioSessionProperty_AudioCategory, sizeof (category), &category );
	
    // Reactivate the current audio session
    AudioSessionSetActive(YES);
	
    // Restore open al context
    alcMakeContextCurrent(mContext);
    // 'unpause' my context
    alcProcessContext(mContext);
}

-(void)initOpenAL

{
	
    OSStatus result = AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, self);
    UInt32 category = kAudioSessionCategory_AmbientSound;
    result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    
    mDevice=alcOpenDevice(NULL);
	
    if (mDevice) {
		
        mContext=alcCreateContext(mDevice, NULL);
		
        alcMakeContextCurrent(mContext);
		
    }
	
	
	alGenSources(1, &outSourceID);
	
	alSpeedOfSound(1.0);
	
	alDopplerVelocity(1.0);
	
	alDopplerFactor(1.0);
	
	alSourcef(outSourceID, AL_PITCH, 1.0f);
	
	alSourcef(outSourceID, AL_GAIN, 1.0f);
	
	alSourcei(outSourceID, AL_LOOPING, AL_FALSE);
	
	alSourcef(outSourceID, AL_SOURCE_TYPE, AL_STREAMING);
	
	
}




- (void) openAudioFromQueue:(unsigned char*)data dataSize:(UInt32)dataSize

{
	if (isPlay) {
        
    
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
        NSCondition* ticketCondition= [[NSCondition alloc] init];
	
        [ticketCondition lock];
	
	
        ALuint bufferID = 0;
	
        alGenBuffers(1, &bufferID);
	
    
	
        NSData * tmpData = [NSData dataWithBytes:data length:dataSize];
	
        alBufferData(bufferID, AL_FORMAT_MONO16, (char*)[tmpData bytes], (ALsizei)[tmpData length], 8000);
	
        alSourceQueueBuffers(outSourceID, 1, &bufferID);
	
	
        [self updataQueueBuffer];
	
	
        ALint stateVaue;
	
        alGetSourcei(outSourceID, AL_SOURCE_STATE, &stateVaue);
	
	
        [ticketCondition unlock];
	
        [ticketCondition release];
	
        ticketCondition = nil;
        alDeleteBuffers(1, &bufferID);
	
        [pool release];
	
        pool = nil;
    }else{
        [self clearBuffer];
    }
	
}




- (BOOL) updataQueueBuffer

{
	
	ALint stateVaue;
	
	int processed, queued;
	
	
	alGetSourcei(outSourceID, AL_SOURCE_STATE, &stateVaue);
	
	
	if (stateVaue == AL_STOPPED ||
		
		stateVaue == AL_PAUSED ||
		stateVaue == AL_INITIAL)
	{
	/*	alGetSourcei(outSourceID, AL_BUFFERS_PROCESSED, &processed);
		if(processed > 1)
		{
			while(processed--)
			{
				ALuint buff;
				alSourceUnqueueBuffers(outSourceID, 1, &buff);
				alDeleteBuffers(1, &buff);
			}
		}
		else   */
		[self playSound];
		
		return NO;
		
	}
	
	
    alGetSourcei(outSourceID, AL_BUFFERS_PROCESSED, &processed);
	
	alGetSourcei(outSourceID, AL_BUFFERS_QUEUED, &queued);
	
	
	NSLog(@"Processed = %d\n", processed);
	
	NSLog(@"Queued = %d\n", queued);
	
	
    while(processed--)
		
    {
		
        ALuint buff;
		
        alSourceUnqueueBuffers(outSourceID, 1, &buff);
		
		alDeleteBuffers(1, &buff);
		
	}
	
	
	return YES;
	
}

-(void)playSound{
	alSourcePlay(outSourceID);
}

-(void)stopSound{
	alSourceStop(outSourceID);
	
}

-(void)cleanUpOpenAL{
	alDeleteSources(1, &outSourceID);
	alcDestroyContext(mContext);
	alcCloseDevice(mDevice);
}

- (void)clearBuffer{
    int processed;
    alGetSourcei(outSourceID, AL_BUFFERS_PROCESSED, &processed);
    
    
    while(processed--)
        
    {
        
        ALuint buff;
        
        alSourceUnqueueBuffers(outSourceID, 1, &buff);
        
        alDeleteBuffers(1, &buff);
        
    }
}



- (id)init{
    if (self = [super init]){
       
		//pos2=0;
		[self initOpenAL];
		
		
    }
    return self;
}


-(void)dealloc{
	
	
	[self cleanUpOpenAL];
    
    [super dealloc];
}

@end
