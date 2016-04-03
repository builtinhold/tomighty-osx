//
//  Tomighty - http://www.tomighty.org
//
//  This software is licensed under the Apache License Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0.txt
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UIIconStatusType)
{
    UIIconStatusTypeIdle = 0,
    UIIconStatusTypePomodoro = 1,
    UIIconStatusTypeShortBreak = 2,
    UIIconStatusTypeLongBreak = 3,
    UIIconStatusTypeAlternate = 4
    
} ;

@protocol TYStatusIcon <NSObject>

- (void)changeIcon:(int) iconName;

- (void) setUseBlackIconsOnly:(BOOL)useBlackIconsOnly;

@end
