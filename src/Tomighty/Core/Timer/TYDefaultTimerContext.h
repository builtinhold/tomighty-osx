//
//  Tomighty - http://www.tomighty.org
//
//  This software is licensed under the Apache License Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0.txt
//

#import <Foundation/Foundation.h>
#import "TYTimerContext.h"

@interface TYDefaultTimerContext : NSObject <TYTimerContext>

+ (id)ofType:(TYTimerContextType)contextType name:(NSString *)name remainingSeconds:(int)initialRemainingSeconds performCycle:(BOOL)performCycle;

@end
