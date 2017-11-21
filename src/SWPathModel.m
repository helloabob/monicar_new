//
//  SWPathModel.m
//  Test
//
//  Created by Orange on 12-9-11.
//
//

#import "SWPathModel.h"

@implementation SWPathModel
@synthesize time = _time;
@synthesize commandCode= _commandCode;
@synthesize commandKey = _commandKey;

-(void) dealloc
{
    [_time release];
    [_commandCode release];
    [_commandKey release];
    [super dealloc];
}

/*
 * 开始准备存缓存的
 */

//
//- (id)initWithAttributes:(NSDictionary *)attributes{
//    self = [super init];
//    if(self){
//        _time = [[attributes valueForKeyPath:@"time"] retain];
//        _option = [[attributes valueForKeyPath:@"option"] retain];
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeObject:_time forKey:@"time"];
//    [aCoder encodeObject:_option forKey:@"option"];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder{
//    self = [super init];
//    if(self){
//        _time = [aDecoder decodeObjectForKey:@"time"];
//        _option = [aDecoder decodeObjectForKey:@"option"];
//    }
//    return self;
//}
//
//+ (void)saveBannersToDisk:(NSArray *)array{
//    if(array !=nil && array.count>0){
//        [NSKeyedArchiver archiveRootObject:array toFile:[SWPathModel pathForDataFile]];
//    }
//}
//
//+ (NSArray *)loadBannersFromDisk{
//    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile:[SWPathModel pathForDataFile]];
//    return arr;
//}
//
//+ (NSString *)pathForDataFile{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask, YES);
//	NSString *cachesDirectory = [NSString stringWithString:[paths objectAtIndex:0]];
//    cachesDirectory = [cachesDirectory stringByExpandingTildeInPath];
//    NSString *filename = @"data.model";
//    return [cachesDirectory stringByAppendingPathComponent:filename];
//}

@end
