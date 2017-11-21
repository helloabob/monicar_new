//
//  SWRouteRecord.h
//  Test
//
//  Created by Orange on 12-9-10.
//
//

#import <Foundation/Foundation.h>
#import "SWPathModel.h"
#import "spcaframe.h"

@interface SWRouteRecord : NSObject{
    NSMutableArray* _pathArray;
    
    BOOL isRecordPath;
}

@property(nonatomic,retain) NSMutableArray* pathArray;

- (void) startRecordPath;
- (void) stopRecordPath;

- (void) cleanDiskRecords;
- (void) cleanCacheRecords;

- (NSArray*) readRecordFromDisk:(NSString*) recordID;
- (void) saveRecordToDisk:(NSString*) recordID;

- (void) recordModelWithOption:(char)state andKey:(PHONE_CMD)key;

@end
