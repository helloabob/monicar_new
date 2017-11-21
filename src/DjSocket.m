#import "DjSocket.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>


@implementation DjSocket


int timestamp;

-(void)setVideo:(myVideo *) mv andAudio:(myAudio *) ma{
    mV=mv;
    mA=ma;
    [self connect];
}


#pragma mark 发送

-(void)test:(int)cmd{
	static int serial=0;
	
	mCmdPack.signature=0x7E;
	mCmdPack.serial=serial++;
	mCmdPack.bodylen=7+MAX_KEY;
	mCmdPack.checknum=0;
	
	if(play_state)
	{
		if(mPlayTimeCnt >= mRecCmd[play_offset].time)
		{
			[self pushreccmd];
			mPlayTimeCnt = 0;
		}
	}

	
	NSData *sendData = [[NSData alloc]initWithBytes:&mCmdPack length:sizeof(mCmdPack)];
	
	char *d=(char *)sendData.bytes;
	for(int i=0,f=sendData.length-1;i<f;i++){
		d[f]+=d[i];
	}
	[socket writeData:sendData withTimeout:-1 tag:0];
	
    [sendData release];
}
-(unsigned char)Get_Head_Checksum:(unsigned char *)buff length:(unsigned int)length
{
	unsigned char checksum=0;
	unsigned int i;
	for(i=0;i<length;i++)
		checksum += buff[i];
	return checksum;
}
-(int)CheckPackageHeader:(unsigned char *)pHead
{
	int CheckSum;
	struct Tphead	*pWpHead = (struct Tphead *)pHead;
	if(pWpHead->signature != 0x7e)
	{
		return -1;
	}
	CheckSum = [self Get_Head_Checksum:pHead length:sizeof(struct Tphead)-1];
	if(CheckSum != pWpHead->checknum)
	{
		return -1;
	}
	return 0;
}
-(void)startrecpath
{
	rec_offset = 0;
	rec_state = 1;
	mRecTimeCnt = 0;
}
-(void)stoprecpath
{
	rec_state = 0;
}
-(void)startplaypath
{
	play_state = 1;
	play_offset = 0;
	mPlayTimeCnt = 0;
}
-(void)stopplaypath
{
	play_state = 0;
	play_offset = 0;
}
-(int)GetRecTimeNext
{
	int tmptime;
	if(play_offset >= rec_offset)
	{//已经播放完毕
		play_offset = 0;
		return -1;
	}
	else
	{
		tmptime = mRecCmd[play_offset].time;
		return tmptime;
	}
}
-(int)GetRecNumb
{
	return rec_offset;
}
-(void)pushreccmd
{
	int tmp;
	for(tmp=0;tmp<=KEY_RIGHT_DOWN;tmp++)
		mCmdPack.cmd[tmp] = mRecCmd[play_offset].cmd[tmp];
	play_offset++;
	if(play_offset >= rec_offset)
		play_state = 0;
}
-(void)pushcmd:(char)state cmd:(char)cmd
{
	if((cmd >= MAX_KEY)||(play_state)) return;
	mCmdPack.cmd[cmd] = state;
	if((rec_state)&&(cmd <= KEY_RIGHT_DOWN))
	{
		if(rec_offset >= MAX_REC_NUM)
		{//超过记录长度，停止记录
			rec_state = 0;
		}
		else
		{
//			mRecCmd[rec_offset].time =[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
			mRecCmd[rec_offset].time = mRecTimeCnt;
			mRecTimeCnt = 0;
			for(int tmp=0;tmp<=KEY_RIGHT_DOWN;tmp++)
				mRecCmd[rec_offset].cmd[tmp] = mCmdPack.cmd[tmp];
			rec_offset++;
		}
	}
}

-(void)movebyte:(char *)buf length:(int)length
{
	int cnt;
	for(cnt=0;cnt<length;cnt++)
		buf[cnt] = buf[cnt+1];
}
-(int)findheadpack:(char *)buf length:(int)length
{
	int offset,ret,cnt,inoffset;
    
	inoffset = 0;
	while(position < sizeof(struct Tphead)&&(inoffset<length))
	{
		offset = inoffset;
		while(position < sizeof(struct Tphead)&&(offset<length))
		{
			headbuf[position] = buf[offset];
			offset++;
			position++;
		}
		if(position == sizeof(struct Tphead))
		{
			ret = [self CheckPackageHeader:headbuf];
			if(ret == 0)
			{//校验通过，找到数据包头
				findhead = 1;
				return offset;
			}
			else
			{//校验失败，寻找下一个数据包头
				[self movebyte:headbuf length:sizeof(struct Tphead)];
				position--;
				inoffset++;
			}
		}
		else
			break;
	}
	return offset;
}
-(int)copytoapp:(char *)buf length:(int)length
{
	int cnt;
	struct Tphead *pBuf;
	pBuf = (struct Tphead *)headbuf;
	if(pBuf->cmd == AUDIO_PACK)
	{
		cnt = 0;
		while((mAoffset < pBuf->bodylen)&&(cnt < length))
		{
			abuff[mAoffset] = buf[cnt];
			cnt++;
			mAoffset++;
		}
    
		if(mAoffset == pBuf->bodylen)
		{
/*
			findhead = 0;
			position = 0;
			mAtime = pBuf->serial;
			if(mVtime <= mAtime)
				[mA openAudioFromQueue:abuff dataSize:(UInt32)mAoffset];
            [mA clearBuffer];
			mAoffset = 0;  
*/
            findhead = 0;
			position = 0;
			if(mAtime == 0)
				mAtime = pBuf->serial;
			else
			{
				if((pBuf->serial - mAtime) > 2)
					[mA clearBuffer];
			}
            [mA openAudioFromQueue:abuff dataSize:(UInt32)mAoffset];
			mAtime = pBuf->serial;
			mAoffset = 0;
		}
		return cnt;
	}
	else if(pBuf->cmd == VIODE_PACK)
	{
		cnt = 0;
		while((mVoffset < pBuf->bodylen)&&(cnt < length))
		{
			vbuff[mVoffset] = buf[cnt];
			cnt++;
			mVoffset++;
		}
		if(mVoffset == pBuf->bodylen)
		{
			findhead = 0;
			position = 0;
			mVtime = pBuf->serial;
			[mV decodeData:vbuff length:mVoffset];
			mVoffset = 0;
		}
		mRecTimeCnt++;
		mPlayTimeCnt++;
		return cnt;
	}
	else
	{
		findhead = 0;
		position = 0;
		return 0;
	}
}

-(void)on_Recv:(char*)data length:(int)length{
	int offset,ret,cnt,datalen;
    
	datalen = length;
	offset = 0;
	while(datalen)
	{
		if(findhead == 0)
		{
			ret = [self findheadpack:&data[offset] length:datalen];
			datalen -= ret;
			offset += ret;
		}
		if(findhead)
		{
			ret = [self copytoapp:&data[offset] length:datalen];
			datalen -= ret;
			offset += ret;
		}
	}
	[self test:0];
}
/*
 -(void)on_Recv:(char*)data length:(int)length{
 static short requestLength=0;
 static char cmd=0;
 int pos=0;
 
 while (YES) {
 //读header
 while (position<sizeof(struct Tphead) && length-pos>0) {
 header[position]=data[pos];
 position++;
 pos++;
 }
 //header 没读完
 if (position<sizeof(struct Tphead)) {
 break;
 }
 
 requestLength=((struct Tphead*)header)->bodylen;
 cmd=((struct Tphead*)header)->cmd;
 timestamp=((struct Tphead*)header)->serial;
 
 //label.text  = [NSString stringWithFormat:@"requestLength=%d",requestLength];
 
 
 //body为0
 if (requestLength==0) {
 position=0;
 continue;
 }
 
 //读body
 if(cmd==1){
 while (position<requestLength+sizeof(struct Tphead) && length-pos>0) {
 vbuff[position-sizeof(struct Tphead)]=data[pos];
 position++;
 pos++;
 }
 
 if (position==requestLength+sizeof(struct Tphead)) {
 [mV decodeData:vbuff length:requestLength];
 position=0;
 }else {
 break;
 }
 }
 if(cmd==2){
 while (position<requestLength+sizeof(struct Tphead) && length-pos>0) {
 abuff[position-sizeof(struct Tphead)]=data[pos];
 position++;
 pos++;
 }
 
 if (position==requestLength+sizeof(struct Tphead)) {
 
 [mA openAudioFromQueue:abuff dataSize:(UInt32)requestLength];
 position=0;
 }else {
 break;
 }
 }
 }
 }
 */



-(void)connect{
    NSError *err = [[NSError alloc]init];
    BOOL b=[socket connectToHost:@"192.168.1.11" onPort:8000 withTimeout:-1 error:&err];
 //   BOOL b=[socket connectToHost:@"163.125.84.233" onPort:8000 withTimeout:-1 error:&err];
    if (!b){
        NSLog(@"failed err=%@",err);
    }
    [err release];
}
-(void)clearcmd
{
	int cnt;
	for(cnt=0;cnt<KEY_SENSOR;cnt++)
		mCmdPack.cmd[cnt] = 0;
}

#pragma mark socket
- (id)init{
    if (self = [super init]){
        socket = [[AsyncSocket alloc] initWithDelegate:self];
		//[self connect];
    }
    return self;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"didConnectToHost");
    [socket readDataWithTimeout:-1 tag:0];
}


- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"onSocketDidDisconnect");
	position=0;
    [mA stopSound];
    [mA clearBuffer];
   	[self connect];
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSLog(@"--did receive video ---\n");
    
	[self on_Recv:(char*)[data bytes] length:[data length]];
    [socket readDataWithTimeout:-1 tag:0];
}

-(void)dealloc{
    [socket release];
	[super dealloc];
}
@end
