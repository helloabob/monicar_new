#import "AsyncSocket.h"
#import "spcaframe.h"
#import "myAudio.h"
#import "myVideo.h"




@interface DjSocket : NSObject{
    AsyncSocket *socket;

	int position;
	int mAoffset;
	int mVoffset;	
	int findhead;
	int mVtime;
	int mAtime;
	
	unsigned int 	play_state;
	unsigned int 	mRecTimeCnt;
	unsigned int 	mPlayTimeCnt;
	unsigned int 	rec_state;
	unsigned int 	rec_offset;
	unsigned int 	play_offset;
	struct TREC_CMD mRecCmd[MAX_REC_NUM];
	
	char vbuff[1024];
	char abuff[1024];
	char headbuf[16];
	struct TCMD mCmdPack;
    myAudio *mA;
    myVideo *mV;
}

-(void)sendCmd:(int)cmd;
-(void)pushcmd:(char)state cmd:(char)cmd;
-(void)pushreccmd;
-(void)startrecpath;
-(void)startplaypath;
-(void)stopplaypath;
-(int)GetRecTimeNext;
-(int)GetRecNumb;
-(void)setVideo:(myVideo *) mv andAudio:(myAudio *) ma;

@end
