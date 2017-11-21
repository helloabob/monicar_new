#import "DemoViewController.h"
//#import "gmeNSF/Test.h"
// #import "MmsPlayer.h"

#import "KKScrollView.h"
#import "SWRouteRecord.h"
#import "SHKActivityIndicator.h"

//#define kFilteringFactor   0.03

@interface DemoViewController()
- (void) excuteRecordPath:(NSArray*)arr;
- (void) socketMSGWithModel:(SWPathModel*)model;
@end

@implementation DemoViewController;

@synthesize djSocket;
@synthesize mA,mV;
@synthesize record = _record;


long starttime;
BOOL gravity=NO;
BOOL isRecord=NO;
int deta=32;

 

-(void)showButton:(int)func image1:(NSString*)str1 image2:(NSString*)str2 x:(int)x y:(int)y Hidden:(BOOL)isHidden{
	UIImage *img1 = [UIImage imageNamed:str1];
	UIImage *img2 = [UIImage imageNamed:str2];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	if(x<0){
		x=screenWidth-img1.size.width/2+x;
	}
	[btn setFrame:CGRectMake(x,y, img1.size.width/2, img1.size.height/2)];
	[btn setTag:func];
	
	[btn addTarget:self action:@selector(butClick:) forControlEvents:UIControlEventTouchUpInside];
#warning 这里我修改了下，你对照下
	[btn setBackgroundImage:img1 forState:UIControlStateNormal];
	[btn setBackgroundImage:img2 forState:UIControlStateHighlighted | UIControlStateSelected ];
    [btn setBackgroundImage:img2 forState:UIControlStateSelected ];
	[btn setHidden:isHidden];
	[self.view addSubview:btn];
	//[btn release];
}

-(void)showButtonEx:(int)func image1:(NSString*)str1 image2:(NSString*)str2 x:(int)x y:(int)y{
	UIImage *img1 = [UIImage imageNamed:str1];
	UIImage *img2 = [UIImage imageNamed:str2];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	if(x<0){
		x=screenWidth-img1.size.width/2+x;
	}
	[btn setFrame:CGRectMake(x,y, img1.size.width*2/3, img1.size.height*2/3)];
	[btn setTag:func];
	[btn addTarget:self action:@selector(butClickEx:) forControlEvents:UIControlEventTouchDown];
	[btn addTarget:self action:@selector(butClickUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
	[btn setBackgroundImage:img1 forState:UIControlStateNormal];
	[btn setBackgroundImage:img2 forState:UIControlStateHighlighted];
	//[btn setBackgroundImage:img2 forState:UIControlState];
	[self.view addSubview:btn];
	//[btn release];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.05];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	djSocket=[[DjSocket alloc]init];
	
    mV=[[myVideo alloc] init];
    mA=[[myAudio alloc] init];
    
    [djSocket setVideo:mV andAudio:mA];
    [mA startPlay];
	

    
    [mV.scrollView setFrame:self.view.bounds];
    
    
	[self.view addSubview:mV.scrollView];
    
	
	[self showButton:42 image1:@"icon_r9_c5_s1.png" image2:@"icon_r11_c5_s1.png" x:100 y:440 Hidden:NO];//重力感应
	[self showButton:43 image1:@"icon_r13_c5_s1.png" image2:@"icon_r15_c5_s1.png" x:100 y:440 Hidden:YES];//1选中
	
	
	[self showButton:34 image1:@"icon_r9_c30_s1.png" image2:@"icon_r11_c30_s1.png" x:60 y:440  Hidden:NO];//红外等已关闭
	[self showButton:35 image1:@"icon_r13_c30_s1.png" image2:@"icon_r15_c30_s1.png" x:60 y:440  Hidden:YES];//红外灯已开启
	
    
	
	[self showButton:31 image1:@"icon_r9_c18_s1.png" image2:@"icon_r11_c18_s1.png" x:140 y:440 Hidden:NO];//录像
	[self showButton:32 image1:@"icon_r13_c13_s1.png" image2:@"icon_r15_c13_s1.png" x:140 y:440  Hidden:YES];
	[self showButton:33 image1:@"icon_r13_c40_s1.png" image2:@"icon_r15_c40_s1.png" x:140 y:440 Hidden:YES];
	
	
	
	
	[self showButton:12 image1:@"icon_r9_c24_s1.png" image2:@"icon_r11_c24_s1.png" x:180 y:440 Hidden:YES];//已关闭音频
	[self showButton:13 image1:@"icon_r13_c24_s1.png" image2:@"icon_r15_c24_s1.png" x:180 y:440 Hidden:NO];//已开启音频
	
	
	
	
	[self showButton:10 image1:@"icon_r9_c33_s1.png" image2:@"icon_r11_c33_s1.png" x:220 y:440 Hidden:NO];//车灯开
	[self showButton:11 image1:@"icon_r13_c33_s1.png" image2:@"icon_r15_c33_s1.png" x:220 y:440 Hidden:YES];//车灯关
	
	
	
	[self showButton:44 image1:@"icon_r18_c34_s1.png" image2:@"icon_r18_c39_s1.png" x:-10 y:440 Hidden:NO];//拍照
	
	
	
	[self showButton:45 image1:@"icon_r19_c3_s1.png" image2:@"icon_r21_c3_s1.png" x:10 y:440 Hidden:NO];//设置
	[self showButton:46 image1:@"icon_r19_c11_s1.png" image2:@"icon_r19_c24_s1.png" x:-10 y:440 Hidden:NO];//图片
	[self showButton:47 image1:@"icon_r17_c44_s1.png" image2:@"icon_r17_c46_s1.png" x:10 y:400 Hidden:NO];//路径
	
	
	
	[self showButtonEx:7 image1:@"icon_r4_c32_s1.png" image2:@"icon_r4_c37_s1.png" x:260 y:220];//上
	[self showButtonEx:5 image1:@"icon_r6_c32_s1.png" image2:@"icon_r6_c37_s1.png" x:260 y:310];//下
	[self showButtonEx:8 image1:@"icon_r4_c32_s1.png" image2:@"icon_r4_c37_s1.png" x:10 y:220];//上
	[self showButtonEx:6 image1:@"icon_r6_c32_s1.png" image2:@"icon_r6_c37_s1.png" x:10 y:310];//下
    
    
    BOOL flag1 = [mV.scrollView canDeleteScale];
    ////////////////////////////
    BOOL flag2 = [mV.scrollView canAddScale];
    
    UIButton *Addbutton = (UIButton*)[self.view viewWithTag:40];
    Addbutton.enabled = flag2;
    UIButton *deleBtn = (UIButton*)[self.view viewWithTag:41];
    deleBtn.enabled = flag1;
    if(flag2){
        [mV.scrollView addScale];
    }
    
    //初始化路径记录器
    SWRouteRecord* record = [[SWRouteRecord alloc] init];
    self.record = record;
    [record release];
}

- (void)viewWillAppear:(BOOL)animated{
    
    if([[self.view viewWithTag:12] isHidden]){
    
      mA=[[myAudio alloc] init];
     [mA startPlay];
    }

    NSArray *arrayOffsetX = nil;
    if (screenWidth == 320) {
        arrayOffsetX = @[@60,@100,@140,@180,@220];
    }else if (screenWidth == 375) {
        arrayOffsetX = @[@70,@120,@170,@220,@270];
    } else {
        arrayOffsetX = @[@78,@136,@194,@252,@310];
    }
    
    switch ([[UIApplication sharedApplication] statusBarOrientation]){
       case UIInterfaceOrientationPortrait:
        
            mV.imgView.frame = CGRectMake(mV.imgView.frame.origin.x, mV.imgView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
            
            [self layoutViewsWithTag:40 point:CGPointMake(10, 5)];
            [self layoutViewsWithTag:41 point:CGPointMake(screenWidth-46, 5)];
            [self layoutViewsWithTag:42 point:CGPointMake([arrayOffsetX[1] floatValue], screenHeight-40)];
            [self layoutViewsWithTag:43 point:CGPointMake([arrayOffsetX[1] floatValue], screenHeight-40)];
            [self layoutViewsWithTag:34 point:CGPointMake([arrayOffsetX[0] floatValue], screenHeight-40)];
            [self layoutViewsWithTag:35 point:CGPointMake([arrayOffsetX[0] floatValue], screenHeight-40)];
            
            [self layoutViewsWithTag:31 point:CGPointMake([arrayOffsetX[2] floatValue], screenHeight-40)];
            [self layoutViewsWithTag:32 point:CGPointMake([arrayOffsetX[2] floatValue], screenHeight-40)];
            [self layoutViewsWithTag:33 point:CGPointMake([arrayOffsetX[2] floatValue], screenHeight-40)];
            
            [self layoutViewsWithTag:12 point:CGPointMake([arrayOffsetX[3] floatValue], screenHeight-40)];
            [self layoutViewsWithTag:13 point:CGPointMake([arrayOffsetX[3] floatValue], screenHeight-40)];
            
            [self layoutViewsWithTag:10 point:CGPointMake([arrayOffsetX[4] floatValue], screenHeight-40)];
            [self layoutViewsWithTag:11 point:CGPointMake([arrayOffsetX[4] floatValue], screenHeight-40)];
            
            [self layoutViewsWithTag:44 point:CGPointMake(screenWidth-44, screenHeight-80)];
            
            [self layoutViewsWithTag:45 point:CGPointMake(10, screenHeight-40)];
            [self layoutViewsWithTag:46 point:CGPointMake(screenWidth-46, screenHeight-40)];
            [self layoutViewsWithTag:47 point:CGPointMake(10, screenHeight-80)];
            
            [self layoutViewsWithTag:7 point:CGPointMake(screenWidth-60, screenHeight-260)];
            [self layoutViewsWithTag:5 point:CGPointMake(screenWidth-60, screenHeight-170)];
            [self layoutViewsWithTag:8 point:CGPointMake(10, screenHeight-260)];
            [self layoutViewsWithTag:6 point:CGPointMake(10, screenHeight-170)];
            
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            mV.imgView.frame = CGRectMake(mV.imgView.frame.origin.x, mV.imgView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
            
            [self layoutViewsWithTag:40 point:CGPointMake(10, 5)];
            UIButton *button = (UIButton*)[self.view viewWithTag:41];
            CGRect buttonFrame = button.frame;
            [self layoutViewsWithTag:41 point:CGPointMake(self.view.bounds.size.width - buttonFrame.size.width, 5)];
            
            //////////
            button = (UIButton*)[self.view viewWithTag:45];
            buttonFrame = button.frame;
            float offY = self.view.bounds.size.height - buttonFrame.size.height;
            [self layoutViewsWithTag:45 point:CGPointMake(10, offY)];
            buttonFrame.origin = CGPointMake(buttonFrame.origin.x + 40 + 80, offY);
            ///////////////////////////////
            button = (UIButton*)[self.view viewWithTag:34];
            [self layoutViewsWithTag:34 point:buttonFrame.origin];
            button = (UIButton*)[self.view viewWithTag:35];
            [self layoutViewsWithTag:35 point:buttonFrame.origin];
            buttonFrame.origin = CGPointMake(buttonFrame.origin.x + 60 , offY);
            
            ///////////////////////////////
            button = (UIButton*)[self.view viewWithTag:42];
            [self layoutViewsWithTag:42 point:buttonFrame.origin];
            buttonFrame.origin = CGPointMake(buttonFrame.origin.x , offY);
            button = (UIButton*)[self.view viewWithTag:43];
            [self layoutViewsWithTag:43 point:buttonFrame.origin];
            
            buttonFrame.origin = CGPointMake(buttonFrame.origin.x + 60, offY);
            
            button = (UIButton*)[self.view viewWithTag:31];
            [self layoutViewsWithTag:31 point:buttonFrame.origin];
            button = (UIButton*)[self.view viewWithTag:32];
            [self layoutViewsWithTag:32 point:buttonFrame.origin];
            button = (UIButton*)[self.view viewWithTag:33];
            [self layoutViewsWithTag:33 point:buttonFrame.origin];
            buttonFrame.origin = CGPointMake(buttonFrame.origin.x + 60, offY);
            ///////////////////////////////
            button = (UIButton*)[self.view viewWithTag:12];
            [self layoutViewsWithTag:12 point:buttonFrame.origin];
            button = (UIButton*)[self.view viewWithTag:13];
            [self layoutViewsWithTag:13 point:buttonFrame.origin];
            buttonFrame.origin = CGPointMake(buttonFrame.origin.x + 60, offY);
            ///////////////////////////////    ///////////////////////////////
            button = (UIButton*)[self.view viewWithTag:10];
            [self layoutViewsWithTag:10 point:buttonFrame.origin];
            button = (UIButton*)[self.view viewWithTag:11];
            [self layoutViewsWithTag:11 point:buttonFrame.origin];
            buttonFrame.origin = CGPointMake(buttonFrame.origin.x + 60, offY);
            
            /////////////////////////
            //////////////////////////////////////////////////////////////
            button = (UIButton*)[self.view viewWithTag:46];
            [self layoutViewsWithTag:46 point:CGPointMake(self.view.bounds.size.width - button.frame.size.width, offY)];
            
            ///////////////////////////////    ///////////////////////////////
            button = (UIButton*)[self.view viewWithTag:44];
            buttonFrame = button.frame;
            /*
             [self layoutViewsWithTag:47 point:CGPointMake(10, self.view.bounds.size.height - 60 - 10)];
             
             [self layoutViewsWithTag:44 point:CGPointMake(self.view.bounds.size.width - buttonFrame.size.width, (self.view.bounds.size.height - 60 - 10))];
             */
            [self layoutViewsWithTag:47 point:CGPointMake(65, 285)];
            
            [self layoutViewsWithTag:44 point:CGPointMake(415-30,285)];
            
            
            //// 箭头button
            button = (UIButton*)[self.view viewWithTag:7];
            buttonFrame = button.frame;
            buttonFrame.origin = CGPointMake(self.view.bounds.size.width - buttonFrame.size.width, (self.view.bounds.size.height - 2*button.bounds.size.height)/2.0);
            [self layoutViewsWithTag:7 point:buttonFrame.origin];
            
            buttonFrame.origin = CGPointMake(buttonFrame.origin.x, buttonFrame.origin.y+20 + buttonFrame.size.height);
            [self layoutViewsWithTag:5 point:buttonFrame.origin];
            buttonFrame.origin = CGPointMake(self.view.bounds.size.width - buttonFrame.size.width, (self.view.bounds.size.height - 2*button.bounds.size.height)/2.0);
            [self layoutViewsWithTag:8 point:CGPointMake(10, buttonFrame.origin.y)];
            [self layoutViewsWithTag:6 point:CGPointMake(10, buttonFrame.origin.y +20+ buttonFrame.size.height)];
            break;
     }   
    [super viewWillAppear:animated];
    
    
}



-(void) butClick:(id)sender{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int tag=((UIButton *)sender).tag;
	UIButton *myButton1;
	UIButton *myButton2;
	if (tag<14) {
		
		UIButton *myButton1,*myButton2;
		if (tag==10) {//车灯开
			[djSocket pushcmd:1 cmd:KEY_LED];
			myButton1 = (UIButton *)[self.view viewWithTag:10];
			myButton2 = (UIButton *)[self.view viewWithTag:11];
			[myButton1 setHidden:YES];
			[myButton2 setHidden:NO];
			
			
		}
		if (tag==11) {//车灯关
			[djSocket pushcmd:0 cmd:KEY_LED];
			myButton1 = (UIButton *)[self.view viewWithTag:11];
			myButton2 = (UIButton *)[self.view viewWithTag:10];
			[myButton1 setHidden:YES];
			[myButton2 setHidden:NO];
			
			
		}
		if (tag==12) {//开启音频
			[djSocket pushcmd:1 cmd:KEY_AUDIO];
			[mA startPlay];
			myButton1 = (UIButton *)[self.view viewWithTag:12];
			myButton2 = (UIButton *)[self.view viewWithTag:13];
			[myButton1 setHidden:YES];
			[myButton2 setHidden:NO];
						
		}
		if (tag==13) { //关闭音频
			[djSocket pushcmd:0 cmd:KEY_AUDIO];
			[mA stopPlay];
		
			[[self.view viewWithTag:13] setHidden:YES];
			[[self.view viewWithTag:12] setHidden:NO];
		
			
		}
		
		
	}else{
		if (tag==31) { //开启录像
			
			[mV startWitting];
			
			myButton1 = (UIButton *)[self.view viewWithTag:31];
			myButton2 = (UIButton *)[self.view viewWithTag:32];
			UIButton *myButton3=(UIButton *)[self.view viewWithTag:33];
			
			[myButton1 setHidden:YES];
			[myButton2 setHidden:NO];
			[myButton3 setHidden:YES];
			
            
			
			
		}
		
		if (tag==32) { //停止或暂停录像对话框询问
			
			UIAlertView* dialog = [[UIAlertView alloc] init];
			[dialog setDelegate:self];
			[dialog setTitle:@"Pause Or Save？"];
			[dialog setMessage:@" "];
			[dialog addButtonWithTitle:@"Pause"];
			
			[dialog addButtonWithTitle:@"Save"];
			
			isRecord=YES;
			CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 100.0);
			[dialog setTransform: moveUp];
			[dialog show];
			
			[dialog release];
			
			
			
		}
		
		if (tag==33) { //
            
			[mV resumeRecord];
			[[self.view viewWithTag:31] setHidden:YES];
			[[self.view viewWithTag:32] setHidden:NO];
			[[self.view viewWithTag:33] setHidden:YES];
			
		}
		
		if (tag==34) { //开启红外灯
			
			[djSocket pushcmd:1 cmd:KEY_IR_LED];//开启红外灯
			myButton1 = (UIButton *)[self.view viewWithTag:34];
			myButton2 = (UIButton *)[self.view viewWithTag:35];
			
			[myButton1 setHidden:YES];
			[myButton2 setHidden:NO];
			
			
			
			
		}
		if (tag==35) { //关闭红外灯
			[djSocket pushcmd:0 cmd:KEY_IR_LED];//关闭红外灯
			myButton1 = (UIButton *)[self.view viewWithTag:35];
			myButton2 = (UIButton *)[self.view viewWithTag:34];
			
			[myButton1 setHidden:YES];
			[myButton2 setHidden:NO];
			
			
			
		}
		if(tag==40){//放大
            
            
            BOOL flag2 = [mV.scrollView canAddScale];
            if(flag2){
                [mV.scrollView addScale];
            }
            UIButton *Addbutton = (UIButton*)[self.view viewWithTag:40];
            Addbutton.enabled = flag2;
            
            ////////////////////////////
            BOOL flag1 = [mV.scrollView canDeleteScale];
            ////////////////////////////
            
            UIButton *deleBtn = (UIButton*)[self.view viewWithTag:41];
            deleBtn.enabled = flag1;
            
			//启用动画移动
			[UIImageView beginAnimations:nil context:NULL];
			
			//移动时间1秒
			[UIImageView setAnimationDuration:1];
			
			//图片持续移动
			[UIImageView setAnimationBeginsFromCurrentState:YES];
            
            
            
            
            //////////// /////////////////////
			int width=mV.imgView.frame.size.width;
			int height=mV.imgView.frame.size.height;
			if (width<screenWidth/2*3) {
				//重新定义图片的位置和尺寸,位置
				mV.imgView.frame = CGRectMake(0, 0, width+deta, height+deta);
				mV.imgView.center= CGPointMake(screenWidth/2, screenWidth/4*3);
				//完成动画移动
				[UIImageView commitAnimations];
			}
			
		}
		if(tag==41){//缩小
			
            ////////////////////////////
            BOOL flag1 = [mV.scrollView canDeleteScale];
            if(flag1){
                
                [mV.scrollView deleteScale];
            }
            UIButton *deleBtn = (UIButton*)[self.view viewWithTag:41];
            deleBtn.enabled = flag1;
            ////////////////////////////
			BOOL flag2 = [mV.scrollView canAddScale];
            
            UIButton *Addbutton = (UIButton*)[self.view viewWithTag:40];
            Addbutton.enabled = flag2;
            ///////////////////////
            
            //启用动画移动
			[UIImageView beginAnimations:nil context:NULL];
			
			//移动时间1秒
			[UIImageView setAnimationDuration:1];
			
			//图片持续移动
			[UIImageView setAnimationBeginsFromCurrentState:YES];
			
            
			int width=mV.imgView.frame.size.width;
			int height=mV.imgView.frame.size.height;
			if (width>screenWidth) {
				//重新定义图片的位置和尺寸,位置
				mV.imgView.frame = CGRectMake(0, 0, width-deta, height-deta);
				mV.imgView.center= CGPointMake(screenWidth/2, screenWidth/4*3);
				//完成动画移动
				[UIImageView commitAnimations];
			}
		}
		if (tag==42) {//重力感应开
			[djSocket pushcmd:1 cmd:KEY_SENSOR];//重力感应开
			myButton1 = (UIButton *)[self.view viewWithTag:42];
			myButton2 = (UIButton *)[self.view viewWithTag:43];
			[myButton1 setHidden:YES];
			[myButton2 setHidden:NO];
			gravity=YES;
			
		}
		if (tag==43) {//重力感应关
            
			[djSocket pushcmd:0 cmd:KEY_SENSOR];//重力感应关
			myButton1 = (UIButton *)[self.view viewWithTag:43];
			myButton2 = (UIButton *)[self.view viewWithTag:42];
			[myButton1 setHidden:YES];
			[myButton2 setHidden:NO];
            [djSocket clearcmd];
			gravity=NO;
            
            
			
		}
		if(tag==44){//拍照
			
			//UIImage *img=[UIImage imageWithData:UIImageJPEGRepresentation(djSocket.imgView.image,1.0)];
			UIImageWriteToSavedPhotosAlbum(mV.image,self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
			UIAlertView* dialog = [[UIAlertView alloc] init];
			[dialog setDelegate:self];
			[dialog setTitle:@"Saved Album"];
			[dialog setMessage:@" "];
			[dialog addButtonWithTitle:@"OK"];
			//[dialog addButtonWithTitle:@"视频"];
			
			
			CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 100.0);
			[dialog setTransform: moveUp];
			[dialog show];
			[dialog release];
			//[djSocket setCamera];
            
		}
		if(tag==45){//设置
            
                NSArray* recordPath = [self.record readRecordFromDisk:@"1"];
                [self excuteRecordPath:recordPath];
                          
            

		}
		if(tag==46){//相册
			
            UIButton *myButton = (UIButton *)[self.view viewWithTag:12];
             if ([myButton isHidden]) {
               [mA stopPlay];
                
             }
			UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
			//imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
			imagePickerController.sourceType =UIImagePickerControllerSourceTypeSavedPhotosAlbum;
			imagePickerController.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:imagePickerController.sourceType];
			imagePickerController.allowsImageEditing=YES;
			
			imagePickerController.delegate = self;
			
			[self presentModalViewController:imagePickerController animated:YES];
			
			[imagePickerController release];
		}
        if (47 == tag) {
            if ([((UIButton *)sender) isSelected]) {
					[djSocket stoprecpath];
//                [self.record stopRecordPath];
                [((UIButton *)sender) setSelected:![((UIButton *)sender) isSelected]];
            }else{
					[djSocket startrecpath];
//                	[self.record startRecordPath];
                	[((UIButton *)sender) setSelected:![((UIButton *)sender) isSelected]];
            }
            
        }
	}
	[pool release];
	
	
}

-(void) butClickEx:(id)sender
{    
    char key;
    int tag=((UIButton *)sender).tag;
	if (!gravity) {
		if(tag==7){
			[djSocket pushcmd:1 cmd:KEY_RIGHT_UP];//右上按下
            key  = KEY_RIGHT_UP;
		}else if(tag==5){
			[djSocket pushcmd:1 cmd:KEY_RIGHT_DOWN];//右下按下
            key= KEY_RIGHT_DOWN;
			//curTag=0;
		}else if(tag==8){
			[djSocket pushcmd:1 cmd:KEY_LEFT_UP];//左上按下
            key= KEY_LEFT_UP;
			//curTag=0;
		}else if(tag == 6){
#warning 这里还应该是else if（tag== 6）？
			[djSocket pushcmd:1 cmd:KEY_LEFT_DOWN];//左下按下
            key = KEY_LEFT_DOWN;
		}
	}
/*  
    if(tag == 5 || tag == 6|| tag ==7 || tag ==8){
        [self.record recordModelWithOption:0x01 andKey:key];
    }
*/	
    
}

-(void) butClickUp:(id)sender{
    char key;
    int tag=((UIButton *)sender).tag;
	if (!gravity) {
        //int tagplus=curTag+tag;
		if(tag==7){
			[djSocket pushcmd:0 cmd:KEY_RIGHT_UP];//右上离开
            key = KEY_RIGHT_UP;
		}else if(tag==5){
			[djSocket pushcmd:0 cmd:KEY_RIGHT_DOWN];//右下离开
            key = KEY_RIGHT_DOWN;
			//curTag=0;
		}else if(tag==8){
			[djSocket pushcmd:0 cmd:KEY_LEFT_UP];//左上离开
            key = KEY_LEFT_UP;
			//curTag=0;
		}else if(tag == 6){
#warning 这里还应该是else if（tag== 6）？
			[djSocket pushcmd:0 cmd:KEY_LEFT_DOWN];//左下离开
            key = KEY_LEFT_DOWN;
		}
    }
/*
    if(tag == 5 || tag == 6|| tag ==7 || tag ==8){
        [self.record recordModelWithOption:0x01 andKey:key];
    }
*/	
    
}


-(void)viewDidUnload {
	[djSocket pushcmd:0 cmd:KER_REC];//关闭录音
}

-(void)dealloc{
    [djSocket release];
    
	[mA release];
    [mV release];
    
    [_record release];
    
    [super dealloc];
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if (gravity) {
       
        float lastx = acceleration.x;
        float lasty = acceleration.y;
        float lastz = acceleration.z;
        
        
        double tmp = lastx;
        
        switch ([[UIApplication sharedApplication] statusBarOrientation])
        {
            case UIInterfaceOrientationLandscapeRight:
                lastx = -lasty;
                lasty = tmp;
                
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                lastx = lasty;
                lasty = -tmp;
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown:
                lastx = -lastx;
                lasty = -lasty;
                break;
            case UIInterfaceOrientationPortrait:
                break;
        }
        float  moveX = lastx;
        float  moveY = lasty;
        float  moveZ = lastz;
        
        if (!starttime) {
            starttime=acceleration.timestamp;
        }
        
        if (acceleration.timestamp>starttime+1&&(fabs(moveX)>=.3||fabs(moveY)>=.3||fabs(moveZ)>=.3)) {
            
            if (moveX>=.3&&moveY>-.3) {//右上
				[djSocket pushcmd:1 cmd:KEY_RIGHT_UP];//右上按下
				[djSocket pushcmd:0 cmd:KEY_RIGHT_DOWN];//右下离开				
				[djSocket pushcmd:0 cmd:KEY_LEFT_UP];//左上离开								
				[djSocket pushcmd:0 cmd:KEY_LEFT_DOWN];//左下离开								
            }
            
            else if (moveX<=-.3&&moveY>-.3) {//左上
				[djSocket pushcmd:0 cmd:KEY_RIGHT_UP];//右上离开				
				[djSocket pushcmd:0 cmd:KEY_RIGHT_DOWN];//右下离开				
				[djSocket pushcmd:1 cmd:KEY_LEFT_UP];//左上按下								
				[djSocket pushcmd:0 cmd:KEY_LEFT_DOWN];//左下离开								
            }
            else if (moveX>=.3&&moveY<=-.3) {//右下
				[djSocket pushcmd:0 cmd:KEY_RIGHT_UP];//右上离开				
				[djSocket pushcmd:1 cmd:KEY_RIGHT_DOWN];//右下离开				
				[djSocket pushcmd:0 cmd:KEY_LEFT_UP];//左上按下								
				[djSocket pushcmd:0 cmd:KEY_LEFT_DOWN];//左下离开								
            }
            
            else if (moveX<=-.3&&moveY<=-.3) {//左下
				[djSocket pushcmd:0 cmd:KEY_RIGHT_UP];//右上离开				
				[djSocket pushcmd:0 cmd:KEY_RIGHT_DOWN];//右下离开				
				[djSocket pushcmd:0 cmd:KEY_LEFT_UP];//左上按下								
				[djSocket pushcmd:1 cmd:KEY_LEFT_DOWN];//左下离开								
            }
            
            else if (fabs(moveX)<.3&&moveY>=.3) {//往前
				[djSocket pushcmd:1 cmd:KEY_RIGHT_UP];//右上离开				
				[djSocket pushcmd:0 cmd:KEY_RIGHT_DOWN];//右下离开				
				[djSocket pushcmd:1 cmd:KEY_LEFT_UP];//左上按下								
				[djSocket pushcmd:0 cmd:KEY_LEFT_DOWN];//左下离开								
            }
            
            else if (fabs(moveX)<.3&&moveY<=-.3) {//往后
				[djSocket pushcmd:0 cmd:KEY_RIGHT_UP];//右上离开				
				[djSocket pushcmd:1 cmd:KEY_RIGHT_DOWN];//右下离开				
				[djSocket pushcmd:0 cmd:KEY_LEFT_UP];//左上按下								
				[djSocket pushcmd:1 cmd:KEY_LEFT_DOWN];//左下离开								
            }
            else{//停止
				[djSocket pushcmd:0 cmd:KEY_RIGHT_UP];//右上离开				
				[djSocket pushcmd:0 cmd:KEY_RIGHT_DOWN];//右下离开				
				[djSocket pushcmd:0 cmd:KEY_LEFT_UP];//左上按下								
				[djSocket pushcmd:0 cmd:KEY_LEFT_DOWN];//左下离开								
            }
        }
    }
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (buttonIndex) {
		case 0:
		{
			if (isRecord) {
				//暂停
				isRecord=NO;
				[mV pauseRecord];
				[[self.view viewWithTag:31] setHidden:YES];
				[[self.view viewWithTag:32] setHidden:YES];
				[[self.view viewWithTag:33] setHidden:NO];
			}
			
		}
			break;
		case 1:
			
		{
			if (isRecord) {
				//保存
				isRecord=NO;
				[mV stopVideoWritting];
				[[self.view viewWithTag:31] setHidden:NO];
				[[self.view viewWithTag:32] setHidden:YES];
				[[self.view viewWithTag:33] setHidden:YES];
				UIAlertView* dialog = [[UIAlertView alloc] init];
				[dialog setDelegate:self];
				[dialog setTitle:@"Saved Album"];
				[dialog setMessage:@" "];
				[dialog addButtonWithTitle:@"OK"];
				//[dialog addButtonWithTitle:@"视频"];
				
				
				CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 100.0);
				[dialog setTransform: moveUp];
				[dialog show];
				[dialog release];
				
			}
		}
			
			break;
            
		default:
			break;
	}
	
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
		// Show error message...
		
    }
    else  // No errors
    {
		// Show message image successfully saved
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return !gravity;
    return YES;
}

- (void)layoutViewsWithTag:(int)tag point:(CGPoint)point{
    UIButton *button = (UIButton *)[self.view viewWithTag:tag];
    CGRect rect = button.frame;
    rect.origin = point;
    button.frame = rect;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
    
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait
        || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        NSArray *arrayOffsetX = nil;
        if (screenWidth == 320) {
            arrayOffsetX = @[@60,@100,@140,@180,@220];
        }else if (screenWidth == 375) {
            arrayOffsetX = @[@70,@120,@170,@220,@270];
        } else {
            arrayOffsetX = @[@78,@136,@194,@252,@310];
        }
        mV.imgView.frame = CGRectMake(mV.imgView.frame.origin.x, mV.imgView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
        
//        [self layoutViewsWithTag:40 point:CGPointMake(10, 5)];
//        [self layoutViewsWithTag:41 point:CGPointMake(274, 5)];
//        [self layoutViewsWithTag:42 point:CGPointMake(100, 440)];
//        [self layoutViewsWithTag:43 point:CGPointMake(100, 440)];
//        [self layoutViewsWithTag:34 point:CGPointMake(60, 440)];
//        [self layoutViewsWithTag:35 point:CGPointMake(60, 440)];
//
//        [self layoutViewsWithTag:31 point:CGPointMake(140, 440)];
//        [self layoutViewsWithTag:32 point:CGPointMake(140, 440)];
//        [self layoutViewsWithTag:33 point:CGPointMake(140, 440)];
//
//        [self layoutViewsWithTag:12 point:CGPointMake(180, 440)];
//        [self layoutViewsWithTag:13 point:CGPointMake(180, 440)];
//
//        [self layoutViewsWithTag:10 point:CGPointMake(220, 440)];
//        [self layoutViewsWithTag:11 point:CGPointMake(220, 440)];
//
//        [self layoutViewsWithTag:44 point:CGPointMake(278, 400)];
//
//        [self layoutViewsWithTag:45 point:CGPointMake(10, 440)];
//        [self layoutViewsWithTag:46 point:CGPointMake(274, 440)];
//        [self layoutViewsWithTag:47 point:CGPointMake(10, 400)];
//
//        [self layoutViewsWithTag:7 point:CGPointMake(260, 220)];
//        [self layoutViewsWithTag:5 point:CGPointMake(260, 310)];
//        [self layoutViewsWithTag:8 point:CGPointMake(10, 220)];
//        [self layoutViewsWithTag:6 point:CGPointMake(10, 310)];
        
        [self layoutViewsWithTag:40 point:CGPointMake(10, 5)];
        [self layoutViewsWithTag:41 point:CGPointMake(screenWidth-46, 5)];
        [self layoutViewsWithTag:42 point:CGPointMake([arrayOffsetX[1] floatValue], screenHeight-40)];
        [self layoutViewsWithTag:43 point:CGPointMake([arrayOffsetX[1] floatValue], screenHeight-40)];
        [self layoutViewsWithTag:34 point:CGPointMake([arrayOffsetX[0] floatValue], screenHeight-40)];
        [self layoutViewsWithTag:35 point:CGPointMake([arrayOffsetX[0] floatValue], screenHeight-40)];
        
        [self layoutViewsWithTag:31 point:CGPointMake([arrayOffsetX[2] floatValue], screenHeight-40)];
        [self layoutViewsWithTag:32 point:CGPointMake([arrayOffsetX[2] floatValue], screenHeight-40)];
        [self layoutViewsWithTag:33 point:CGPointMake([arrayOffsetX[2] floatValue], screenHeight-40)];
        
        [self layoutViewsWithTag:12 point:CGPointMake([arrayOffsetX[3] floatValue], screenHeight-40)];
        [self layoutViewsWithTag:13 point:CGPointMake([arrayOffsetX[3] floatValue], screenHeight-40)];
        
        [self layoutViewsWithTag:10 point:CGPointMake([arrayOffsetX[4] floatValue], screenHeight-40)];
        [self layoutViewsWithTag:11 point:CGPointMake([arrayOffsetX[4] floatValue], screenHeight-40)];
        
        [self layoutViewsWithTag:44 point:CGPointMake(screenWidth-44, screenHeight-80)];
        
        [self layoutViewsWithTag:45 point:CGPointMake(10, screenHeight-40)];
        [self layoutViewsWithTag:46 point:CGPointMake(screenWidth-46, screenHeight-40)];
        [self layoutViewsWithTag:47 point:CGPointMake(10, screenHeight-80)];
        
        [self layoutViewsWithTag:7 point:CGPointMake(screenWidth-60, screenHeight-260)];
        [self layoutViewsWithTag:5 point:CGPointMake(screenWidth-60, screenHeight-170)];
        [self layoutViewsWithTag:8 point:CGPointMake(10, screenHeight-260)];
        [self layoutViewsWithTag:6 point:CGPointMake(10, screenHeight-170)];
        
        
    }
    else
    {
        mV.imgView.frame = CGRectMake(mV.imgView.frame.origin.x, mV.imgView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
        
        int paddingX = (screenWidth-20)/7 ;
        
        [self layoutViewsWithTag:40 point:CGPointMake(10, 5)];
        UIButton *button = (UIButton*)[self.view viewWithTag:41];
        CGRect buttonFrame = button.frame;
        [self layoutViewsWithTag:41 point:CGPointMake(self.view.bounds.size.width - buttonFrame.size.width, 5)];
        
        //////////
        button = (UIButton*)[self.view viewWithTag:45];
        buttonFrame = button.frame;
        float offY = self.view.bounds.size.height - buttonFrame.size.height;
        [self layoutViewsWithTag:45 point:CGPointMake(10, offY)];
//        buttonFrame.origin = CGPointMake(buttonFrame.origin.x + 40 + 80, offY);
        buttonFrame.origin = CGPointMake(buttonFrame.origin.x + paddingX, offY);
        ///////////////////////////////
        button = (UIButton*)[self.view viewWithTag:34];
        [self layoutViewsWithTag:34 point:buttonFrame.origin];
        button = (UIButton*)[self.view viewWithTag:35];
        [self layoutViewsWithTag:35 point:buttonFrame.origin];
        buttonFrame.origin = CGPointMake(buttonFrame.origin.x + paddingX , offY);
        
        ///////////////////////////////
        button = (UIButton*)[self.view viewWithTag:42];
        [self layoutViewsWithTag:42 point:buttonFrame.origin];
        buttonFrame.origin = CGPointMake(buttonFrame.origin.x , offY);
        button = (UIButton*)[self.view viewWithTag:43];
        [self layoutViewsWithTag:43 point:buttonFrame.origin];
        
        buttonFrame.origin = CGPointMake(buttonFrame.origin.x + paddingX, offY);
        
        button = (UIButton*)[self.view viewWithTag:31];
        [self layoutViewsWithTag:31 point:buttonFrame.origin];
        button = (UIButton*)[self.view viewWithTag:32];
        [self layoutViewsWithTag:32 point:buttonFrame.origin];
        button = (UIButton*)[self.view viewWithTag:33];
        [self layoutViewsWithTag:33 point:buttonFrame.origin];
        buttonFrame.origin = CGPointMake(buttonFrame.origin.x + paddingX, offY);
        ///////////////////////////////
        button = (UIButton*)[self.view viewWithTag:12];
        [self layoutViewsWithTag:12 point:buttonFrame.origin];
        button = (UIButton*)[self.view viewWithTag:13];
        [self layoutViewsWithTag:13 point:buttonFrame.origin];
        buttonFrame.origin = CGPointMake(buttonFrame.origin.x + paddingX, offY);
        ///////////////////////////////    ///////////////////////////////
        button = (UIButton*)[self.view viewWithTag:10];
        [self layoutViewsWithTag:10 point:buttonFrame.origin];
        button = (UIButton*)[self.view viewWithTag:11];
        [self layoutViewsWithTag:11 point:buttonFrame.origin];
        buttonFrame.origin = CGPointMake(buttonFrame.origin.x + paddingX, offY);
        
        /////////////////////////
        //////////////////////////////////////////////////////////////
        button = (UIButton*)[self.view viewWithTag:46];
        [self layoutViewsWithTag:46 point:CGPointMake(self.view.bounds.size.width - button.frame.size.width - 8, offY)];
        
        ///////////////////////////////    ///////////////////////////////
        button = (UIButton*)[self.view viewWithTag:44];
        buttonFrame = button.frame;
    /*
        [self layoutViewsWithTag:47 point:CGPointMake(10, self.view.bounds.size.height - 60 - 10)];
        
        [self layoutViewsWithTag:44 point:CGPointMake(self.view.bounds.size.width - buttonFrame.size.width, (self.view.bounds.size.height - 60 - 10))];
        */
        [self layoutViewsWithTag:47 point:CGPointMake(10, 285)];
        
        [self layoutViewsWithTag:44 point:CGPointMake(screenWidth-40,285)];
        
        //// 箭头button
        button = (UIButton*)[self.view viewWithTag:7];
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(self.view.bounds.size.width - buttonFrame.size.width, (self.view.bounds.size.height - 2*button.bounds.size.height)/2.0);
        [self layoutViewsWithTag:7 point:buttonFrame.origin];
        
        buttonFrame.origin = CGPointMake(buttonFrame.origin.x, buttonFrame.origin.y +20+ buttonFrame.size.height);
        [self layoutViewsWithTag:5 point:buttonFrame.origin];
        buttonFrame.origin = CGPointMake(self.view.bounds.size.width - buttonFrame.size.width, (self.view.bounds.size.height - 2*button.bounds.size.height)/2.0);
        [self layoutViewsWithTag:8 point:CGPointMake(10, buttonFrame.origin.y)];
        [self layoutViewsWithTag:6 point:CGPointMake(10, buttonFrame.origin.y +20+ buttonFrame.size.height)];
    }
}

#pragma mark-
#pragma mark - Private Method
/*
- (void) excuteRecordPath:(NSArray*)arr{
    //该记录的条数
    int recordCount = [arr count];
    if (!recordCount) {
        [[SHKActivityIndicator currentIndicator] displayCompleted:@"Sorry，No records！"];
        return;
    }
    double prevTime = [[((SWPathModel*)[arr objectAtIndex:0]) time] doubleValue];
    for (SWPathModel* model in arr) {
        double timeInterval = [model.time doubleValue] - prevTime;
        prevTime = [model.time doubleValue];
        
        [self performSelector:@selector(socketMSGWithModel:) withObject:model afterDelay:timeInterval];
    }
}
*/
- (void) excuteRecordPath:(NSArray*)arr{
    //该记录的条数
	int recordCount = [djSocket GetRecNumb];
    if (recordCount==0) {
        [[SHKActivityIndicator currentIndicator] displayCompleted:@"Sorry，No records！"];
        return;
    }
	[djSocket startplaypath];
}
- (void) socketMSGWithModel:(SWPathModel*)model{
    [djSocket pushcmd:[model.commandCode charValue] cmd:[model.commandKey charValue]];//右上离开
}

@end
