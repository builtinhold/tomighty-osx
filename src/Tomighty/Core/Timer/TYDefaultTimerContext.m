//
//  Tomighty - http://www.tomighty.org
//
//  This software is licensed under the Apache License Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0.txt
//

#import "TYDefaultTimerContext.h"

@implementation TYDefaultTimerContext
{
    TYTimerContextType contextType;
    __strong NSString *name;
    int remainingSeconds;
    BOOL IsCycle;
}

+ (id)ofType:(TYTimerContextType)contextType name:(NSString *)name remainingSeconds:(int)initialRemainingSeconds performCycle:(BOOL)performCycle
{
    return [[TYDefaultTimerContext alloc] initAs:contextType name:name remainingSeconds:initialRemainingSeconds performCycle:performCycle];
}

- (id)initAs:(TYTimerContextType)aContextType name:(NSString *)aName remainingSeconds:(int)initialRemainingSeconds performCycle:(BOOL)performCycle;
{
    self = [super init];
    if(self) {
        contextType = aContextType;
        name = aName;
        remainingSeconds = initialRemainingSeconds;
        IsCycle = performCycle;
    }
    return self;
}

- (NSString *)getName
{
    return name;
}

- (int)getRemainingSeconds
{
    return remainingSeconds;
}

- (void)addSeconds:(int)seconds
{
    remainingSeconds += seconds;
}

- (TYTimerContextType)getContextType
{
    return contextType;
}

- (BOOL)getIsCycle
{
    return IsCycle ;
}

- (void)setIsCycle:(BOOL)isCycle
{
    IsCycle = isCycle;
}


@end
