//
//  myVideo.h
//  Test
//
//  Created by Antares on 12-9-5.
//
//


#import "spcaframe.h"
#import "KKScrollView.h"

@class KKScrollView;


@interface myVideo : NSObject{
   
	NSMutableData *jpgData;
//    UIImageView *imgView;
//    KKScrollView *scrollView;
//    UIImage *image;
	
}
@property(nonatomic,retain)UIImageView *imgView;
@property(nonatomic,retain)UIImage *image;
@property (nonatomic, retain) KKScrollView *scrollView;



@end
