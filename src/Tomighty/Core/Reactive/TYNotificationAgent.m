//
//  TYNotificationAgent.m
//  Tomighty
//
//  Created by David on 09/04/2016.
//


#import "TYNotificationAgent.h"
#import "TYTimerContext.h"

@implementation TYNotificationAgent
{
    __strong id <TYEventBus> eventBus;
    int pomodoroCount;
    int pomodorosPerCycle;
    
}

- (id)initWith:(id<TYEventBus>) anEventBus pomodorosPerCycle:(int) currentPomPerCycle
{
    self = [super init];
    if(self)
    {
        eventBus = anEventBus;
        pomodoroCount = 0;
        pomodorosPerCycle = currentPomPerCycle;
    }
    
    [self registerRequiredEvents];
    
    return self;
}


- (void) registerRequiredEvents
{
    [eventBus subscribeTo:POMODORO_PER_CYCLE_CHANGE subscriber:^(id eventData)
     {
         pomodorosPerCycle = [(NSNumber *)eventData intValue];
     }];
    
    [eventBus subscribeTo:POMODORO_COUNT_CHANGE subscriber:^(id eventData)
     {
         pomodoroCount = [(NSNumber *)eventData intValue];
     }];
    
    [eventBus subscribeTo:POMODORO_COMPLETE subscriber:^(id eventData)
     {
         [self displayNotificationForEvent:POMODORO_COMPLETE];
     }];
    
    [eventBus subscribeTo:SHORT_BREAK_COMPLETE subscriber:^(id eventData)
     {
         [self displayNotificationForEvent:SHORT_BREAK_COMPLETE];
     }];
    
    [eventBus subscribeTo:LONG_BREAK_COMPLETE subscriber:^(id eventData)
     {
         [self displayNotificationForEvent:LONG_BREAK_COMPLETE];
     }];
    
}

- (void) displayNotificationForEvent:(TYEventType) eventType
{
    NSString* message = nil;
    NSString* detailMessage = nil;
    BOOL shouldDisplayDetailMessage = NO;
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    switch (eventType)
    {
        case POMODORO_COMPLETE:
            message = @"Pomodoro Complete";
            BOOL isFinalPomodoro = (pomodoroCount == pomodorosPerCycle ? YES : NO);
            if (!isFinalPomodoro)
            {
                detailMessage = @"Well done, you!";
                shouldDisplayDetailMessage = (arc4random_uniform(10) % 5 == 0 )? YES: NO;
            }
            else
            {
                detailMessage = @"Now relax and take a well deserved break!.";
                shouldDisplayDetailMessage = YES;
            }
            break;
            
        case SHORT_BREAK_COMPLETE:
            message = @"Break finished";
            int pomodorosLeft = pomodorosPerCycle - pomodoroCount;
            detailMessage = [NSString stringWithFormat:@"Only %d pomodoros left and you can take that long break...", pomodorosLeft];
            shouldDisplayDetailMessage = YES;
            break;
            
        case LONG_BREAK_COMPLETE:
            message = @"Break finished";
            detailMessage = @"Time to get back to work.";
            shouldDisplayDetailMessage = YES;
            break;
            
        default:
            break;
    }
    
    
    notification.title = message;
    if(shouldDisplayDetailMessage)
        notification.informativeText = detailMessage;
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end


