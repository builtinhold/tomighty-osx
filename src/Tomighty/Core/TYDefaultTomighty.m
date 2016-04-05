//
//  Tomighty - http://www.tomighty.org
//
//  This software is licensed under the Apache License Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0.txt
//

#import "TYDefaultTimerContext.h"
#import "TYDefaultTomighty.h"
#import "TYEventBus.h"
#import "TYPreferences.h"

@implementation TYDefaultTomighty
{
    int pomodoroCount;
    
    __strong id <TYTimer> timer;
    __strong id <TYPreferences> preferences;
    __strong id <TYEventBus> eventBus;
}

- (id)initWith:(id <TYTimer>)aTimer
   preferences:(id <TYPreferences>)aPreferences
      eventBus:(id <TYEventBus>)anEventBus
{
    self = [super init];
    if(self)
    {
        pomodoroCount = 0;
        timer = aTimer;
        preferences = aPreferences;
        eventBus = anEventBus;
    
        [self registerRequiredEvents];
    }
    return self;
}

- (void)startTimer:(TYTimerContextType)contextType
       contextName:(NSString *)contextName
           minutes:(int)minutes
{
    id <TYTimerContext> timerContext = [TYDefaultTimerContext
                                        ofType:contextType
                                        name:contextName
                                        remainingSeconds:minutes /* 60*/];
    [timer start:timerContext];
}

- (void)startPomodoro
{
    [self startTimer:POMODORO
         contextName:@"Pomodoro"
             minutes:[preferences getInt:PREF_TIME_POMODORO]];
}

- (void)startShortBreak
{
    [self startTimer:SHORT_BREAK
         contextName:@"Short break"
             minutes:[preferences getInt:PREF_TIME_SHORT_BREAK]];
}

- (void)startLongBreak
{
    [self startTimer:LONG_BREAK
         contextName:@"Long break"
             minutes:[preferences getInt:PREF_TIME_LONG_BREAK]];

}

- (void)stopTimer
{
    [timer stop];
}

- (void)setPomodoroCount:(int)newCount
{
    pomodoroCount = newCount;
    [eventBus publish:POMODORO_COUNT_CHANGE data:[NSNumber numberWithInt:pomodoroCount]];
}

- (void)resetPomodoroCount
{
    [self setPomodoroCount:0];
}

- (void)incrementPomodoroCount
{
    int newCount = pomodoroCount + 1;
    
    if(newCount > [preferences getInt:PREF_NUMBER_POMODOROS_PER_CYCLE])
    {
        newCount = 1;
    }
    
    [self setPomodoroCount:newCount];
}

- (void) registerRequiredEvents
{
    [eventBus subscribeTo:POMODORO_COMPLETE subscriber:^(id eventData)
     {
         [self incrementPomodoroCount];
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
    int pomodorosPerCycle = [preferences getInt:PREF_NUMBER_POMODOROS_PER_CYCLE];
    
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
            int pomodorosLeft = pomodorosPerCycle < pomodoroCount;
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
