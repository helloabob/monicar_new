//
//  myVideo.m
//  Test
//
//  Created by Antares on 12-9-5.
//
//

#import "myVideo.h"


#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>


@implementation myVideo

@synthesize imgView = _imgView;
@synthesize image = _image;
@synthesize scrollView = _scrollView;



AVAssetWriter *videoWriter;
AVAssetWriterInput *writerInput;
AVAssetWriterInput *audioWriterInput;
AVAssetWriterInputPixelBufferAdaptor *adaptor;



NSString *fullPath;
int  frame;
CGSize size;
int videoflag=0;




#pragma mark 
- (id)init{
    if (self = [super init]){
        
		jpgData=[[NSMutableData alloc]init];
		
//        _imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
//        _imgView.backgroundColor=[UIColor redColor];
//        _imgView.image=nil;
//        
        _scrollView = [[KKScrollView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
       
    }
    return self;
}




-(void)decodeData:(char*)data length:(int)length
{
	struct TVDATA *tvData=(struct TVDATA *)data;
	if(jpgData==nil){
		jpgData=[[NSMutableData alloc]init];
	}
	[jpgData appendBytes:(char*)tvData+8 length:length-8];
    
  
    
	if(tvData->m_frag_totle-1==tvData->m_frag_cur)
	{
        self.image = [UIImage imageWithData:jpgData];
        [jpgData release];
        jpgData = nil;
		
		[self performSelectorOnMainThread:@selector(updateImageView) withObject:nil waitUntilDone:!NO];
		
		
		//jpgData.length=0;
	}
}


-(void)updateImageView
{
	
//    if(_imgView.image!=nil){
//        [_imgView.image release];
//    }
//    _imgView.image=_image;
    
    
    [_scrollView setDisplayImage:_image];
    
	
	if (videoflag==1) {
        [self performSelectorOnMainThread:@selector(writeVideo) withObject:nil waitUntilDone:!NO];
        
	}
	
	
	
}
-(void)pauseRecord{
	videoflag=0;
}

-(void)resumeRecord{
	videoflag=1;
}




- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image1 size:(CGSize)size
{
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    NSDictionary *options = nil;
    CVPixelBufferRef pxbuffer = NULL;
	CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, &pxbuffer);
	
	NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
	
	CVPixelBufferLockBaseAddress(pxbuffer, 0);
	void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
	NSParameterAssert(pxdata != NULL);
	
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
	NSParameterAssert(context);
	
//    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image1), CGImageGetHeight(image1)), image1);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image1);
	
	CGColorSpaceRelease(rgbColorSpace);
	CGContextRelease(context);
	
	CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
	
	return pxbuffer;
}

-(void)prepareVideoSetting{
	NSMutableString *buildPath = [[NSMutableString alloc] init];
	[buildPath setString:@"Documents/"];
	int aNumber =arc4random()%8999 + 1000;
	
	[buildPath appendString:@"temporary"];
	[buildPath appendString:[NSString stringWithFormat:@"%d",aNumber]];
	[buildPath appendString:@".mov"];
    fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:buildPath] retain];
	[buildPath release];
	
	//NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mov"];
	
	size = CGSizeMake(320,240);//定义视频的大�?
	NSError *error = nil;
	
	//unlink([moviePath UTF8String]);
	
	//�?initialize compression engine
	videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:fullPath]
											fileType:AVFileTypeQuickTimeMovie
											   error:&error];
	NSParameterAssert(videoWriter);
	if(error)
		NSLog(@"error = %@", [error localizedDescription]);
	
	NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
								   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
								   [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
	writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
	
	
    //NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
	
	adaptor = [[AVAssetWriterInputPixelBufferAdaptor
                assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil] retain];
	NSParameterAssert(writerInput);
	NSParameterAssert([videoWriter canAddInput:writerInput]);
	
	if ([videoWriter canAddInput:writerInput])
		NSLog(@" ");
	else
		NSLog(@" ");
	
	[videoWriter addInput:writerInput];
   
	
}

-(void)startWitting{
	[self prepareVideoSetting];
	[videoWriter startWriting];
	[videoWriter startSessionAtSourceTime:kCMTimeZero];
	//dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
	frame = 0;
    videoflag=1;
}

- (void)writeVideo
{
    
	//合成多张图片为一个视频文�?	
    if([writerInput isReadyForMoreMediaData])
    {
        
        
        CVPixelBufferRef buffer = NULL;
        CGSize tmpSize = CGSizeMake(_image.size.width, _image.size.height);
        buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[_image CGImage] size:tmpSize];
       
        frame++;
        CMTime lastTime = CMTimeMake(frame,12.5);
        
        
        if (buffer)
        {
            
            if(![adaptor appendPixelBuffer:buffer withPresentationTime:lastTime])
                NSLog(@"FAIL");
            else
                CFRelease(buffer);
        }
        
    }
	
}

-(void)stopVideoWritting{
	//[audioWriterInput markAsFinished];
	[writerInput markAsFinished];
	[videoWriter finishWriting];
	[videoWriter release];
	void(^completionBlock)(NSURL *, NSError *) =
    ^(NSURL *assetURL, NSError *error)
	{
		if(error != nil){
			//error
		}
		//remove temp movie file
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		if([fileMgr removeItemAtPath:fullPath error:&error] != YES){
			//error
		}
	};
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	NSURL *filePathURL = [NSURL fileURLWithPath:fullPath isDirectory:NO];
	if([library videoAtPathIsCompatibleWithSavedPhotosAlbum:filePathURL]){
		
		[library writeVideoAtPathToSavedPhotosAlbum:filePathURL completionBlock:completionBlock];
	}
	//clean up
	[library release];
	
    videoflag=0;
    
	
}



-(void)dealloc{
    [jpgData release];
	[_imgView release];
    [_scrollView release];
    
    [super dealloc];
}
@end
