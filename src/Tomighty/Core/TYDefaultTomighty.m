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
    
    BOOL isCycle;
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
        
        isCycle = NO;
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
                                        remainingSeconds:minutes * 60
                                        performCycle:isCycle];
    [timer start:timerContext];
}

- (void)startCycle
{
    [self setPerformCycle:YES];
    [self startPomodoro];
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
    [self setPerformCycle:NO];
    [timer manualStop];
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

- (void)setPerformCycle:(BOOL) performCycle
{
    isCycle = performCycle;
}

- (void) registerRequiredEvents
{
    [eventBus subscribeTo:POMODORO_COMPLETE subscriber:^(id eventData)
    {
        [self incrementPomodoroCount];
        
        [self handlePossibleStatusChangeIfFrom:POMODORO_COMPLETE];
        
    }];

    [eventBus subscribeTo:SHORT_BREAK_COMPLETE subscriber:^(id eventData)
    {
        [self handlePossibleStatusChangeIfFrom:SHORT_BREAK_COMPLETE];
    }];
    
    [eventBus subscribeTo:LONG_BREAK_COMPLETE subscriber:^(id eventData)
    {
        [self handlePossibleStatusChangeIfFrom:LONG_BREAK_COMPLETE];
    }];
}

- (BOOL) isLastPomodoroOfTheCycle
{
    return pomodoroCount == [preferences getInt:PREF_NUMBER_POMODOROS_PER_CYCLE];
}

- (void) handlePossibleStatusChangeIfFrom:(TYEventType)eventType
{
    if(isCycle == YES)
    {
        switch(eventType)
        {
            case POMODORO_COMPLETE:
                if([self isLastPomodoroOfTheCycle])
                    [self startLongBreak];
                else
                    [self startShortBreak];
                break;
            case SHORT_BREAK_COMPLETE:
                [self startPomodoro];
                break;
            case LONG_BREAK_COMPLETE:
                [self startPomodoro];
                break;
            default:
                break;
        }
    }
}

@end
