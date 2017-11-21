//
//  SWRouteRecord.m
//  Test
//
//  Created by Orange on 12-9-10.
//
//

#import "SWRouteRecord.h"
#import "SWPathModel.h"

@interface SWRouteRecord()
+ (NSString *)pathForDataFile:(NSString *)aRecordID;
@end

@implementation SWRouteRecord
@synthesize pathArray = _pathArray;

-(void) dealloc
{
    [_pathArray removeAllObjects];
    [_pathArray release];
    
    [super dealloc];
}

- (id) init{
    if (self = [super init]) {
        //do some work
        isRecordPath = NO;
    }
    return self;
}

#pragma mark -
#pragma mark - SWRouteRecord Public Methods
- (void) startRecordPath{
    isRecordPath = YES;
}

/*
 * Description:1、停止记录路径;2、保存记录到硬盘
 */
#warning 这个RecordID肯定不是1，看后期怎么设计了。比如你设定这个APP缺省最大能记录多少个，然后按照时间值排序一组一组来。后续我们再做。
- (void) stopRecordPath{
    isRecordPath = NO;
    [self saveRecordToDisk:@"1"];
}

- (void)readRecordFromDisk{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByExpandingTildeInPath];
    
    
    if([fileManager fileExistsAtPath:documentsDirectory] ){
        NSArray *array=[fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
        for(NSString *p in array){
            NSString *fullPath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,p];
            [fileManager removeItemAtPath: fullPath error:nil];
        }
    }
}

- (void)cleanCacheRecords{
    [self.pathArray removeAllObjects];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


- (NSArray*)readRecordFromDisk:(NSString*) recordID{
    if([self.pathArray count]> 0)
        return nil;
    
    NSString* path = [SWRouteRecord pathForDataFile:recordID];
    NSMutableArray *tmp = [NSMutableArray arrayWithContentsOfFile:path];
    NSMutableArray *result = [NSMutableArray array];
    
    for(int i = 0;i < tmp.count; i+= 2){
        NSDictionary* dict = (NSDictionary*)[tmp objectAtIndex:i];
        NSNumber *commandCode = [dict objectForKey:@"code"];
        NSNumber *commandKey = [dict objectForKey:@"key"];
        NSNumber *time = [dict objectForKey:@"time"];
        
        SWPathModel *model = [[SWPathModel alloc] init];
        model.time = time;
        model.commandCode = commandCode;
        model.commandKey = commandKey;
        [result addObject:model];
        [model release];
    }
    if(self.pathArray){
        [self.pathArray release];
        self.pathArray = nil;
    }
    
    return self.pathArray = [[NSMutableArray alloc] initWithArray:result];
}

- (void)saveRecordToDisk:(NSString*) recordID{
    if ([self.pathArray count]) {
        NSString* path = [SWRouteRecord pathForDataFile:recordID];
        
        NSMutableArray *tmp = [NSMutableArray array];
        for(int i = 0;i < self.pathArray.count; i++){
            SWPathModel *model = [self.pathArray objectAtIndex:i];
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:model.time,@"time",model.commandKey,@"key",model.commandCode,@"code", nil];
            
            [tmp addObject:dict];
        }
        
        BOOL flag = [tmp writeToFile:path atomically:YES];
        NSLog(@"save path = %@ %@ %d\n", path,self.pathArray,flag);
    }
    [self cleanCacheRecords];
}

-(void)recordModelWithOption:(char)state andKey:(PHONE_CMD)key{
    if (!isRecordPath)
        return;
    
    SWPathModel *model = [[SWPathModel alloc] init];
    model.commandCode = [NSNumber numberWithChar:state];
    model.commandKey = [NSNumber numberWithChar:key];
    model.time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    [self.pathArray addObject:model];
    [model release];
}



#pragma mark -
#pragma mark - SWRouteRecord Private Methods
+ (NSString *)pathForDataFile:(NSString *)aRecordID{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
	NSString *cachesDirectory = [NSString stringWithString:[paths objectAtIndex:0]];
    cachesDirectory = [cachesDirectory stringByExpandingTildeInPath];
    NSString *filename = [NSString stringWithFormat:@"data.record.%@",aRecordID];
    return [cachesDirectory stringByAppendingPathComponent:filename];
}

@end
