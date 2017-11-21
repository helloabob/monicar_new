//
//  SWPathModel.h
//  Test
//
//  Created by Orange on 12-9-11.
//
//

#import <Foundation/Foundation.h>

@interface SWPathModel : NSObject{
    NSNumber* _time;
    NSNumber* _commandCode;
    NSNumber* _commandKey;
}

@property(nonatomic,retain) NSNumber* time;
@property(nonatomic,retain) NSNumber* commandCode;
@property(nonatomic,retain) NSNumber* commandKey;

@end
