//
//  myAudio.h
//  Test
//
//  Created by MacBook on 12-7-30.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import <AudioToolbox/AudioToolbox.h>

#import <OpenAL/al.h>

#import <OpenAL/alc.h>



@interface myAudio : NSObject {
	
	ALCcontext *mContext;
    ALCdevice *mDevice;
	ALuint outSourceID;
	
	
	
}

@property (nonatomic) ALCcontext *mContext;

@property (nonatomic) ALCdevice *mDevice;

-(void)initOpenAL;

-(void)playSound;

-(void)stopSound;

-(void)cleanUpOpenALID;

-(void)cleanUpOpenAL;

@end
