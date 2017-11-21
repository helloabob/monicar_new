#import "DjSocket.h"
#import "spcaframe.h"
#import "myAudio.h"
#import "myVideo.h"

#import "SWRouteRecord.h"



@interface DemoViewController : UIViewController<UIAccelerometerDelegate,UIAlertViewDelegate>
{  
	//UILabel*label;
	DjSocket *djSocket;
	myAudio *mA;
    myVideo *mV;
    
    SWRouteRecord* _record;
}

@property (nonatomic,retain) DjSocket *djSocket;
@property (nonatomic,retain) myAudio *mA;
@property (nonatomic,retain) myVideo *mV;
@property (nonatomic,retain) SWRouteRecord* record;

@end  