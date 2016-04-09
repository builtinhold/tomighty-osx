//
//  Tomighty - http://www.tomighty.org
//
//  This software is licensed under the Apache License Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0.txt
//

#import "TYUserDefaultsPreferences.h"
#import "TYEventBus.h"

NSString * const PREF_TIME_POMODORO            = @"org.tomighty.time.pomodoro";
NSString * const PREF_TIME_SHORT_BREAK         = @"org.tomighty.time.short_break";
NSString * const PREF_TIME_LONG_BREAK          = @"org.tomighty.time.long_break";
NSString * const PREF_PLAY_SOUND_WHEN_TIMER_STARTS        = @"org.tomighty.sound.play_on_timer_start";
NSString * const PREF_PLAY_SOUND_WHEN_TIMER_GOES_OFF         = @"org.tomighty.sound.play_on_timer_stop";
NSString * const PREF_PLAY_TICKTOCK_SOUND_DURING_POMODORO  = @"org.tomighty.sound.play_tick_tock_during_pomodoro";
NSString * const PREF_PLAY_TICKTOCK_SOUND_DURING_BREAK     = @"org.tomighty.sound.play_tick_tock_during_break";
NSString * const PREF_USE_BLACK_ICONS_ONLY  =  @"org.tomighty.use_black_icons_only";
NSString * const PREF_NUMBER_POMODOROS_PER_CYCLE = @"org.tomighty.number_pomodoros_per_cycle";

@implementation TYUserDefaultsPreferences
{
    __strong id <TYEventBus> eventBus;
}

- (id)initWith:(id <TYEventBus>)anEventBus
{
    self = [super init];
    if(self)
    {
        eventBus = anEventBus;
        
        NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
        
        [defaultValues setObject:[NSNumber numberWithInt:25] forKey:PREF_TIME_POMODORO];
        [defaultValues setObject:[NSNumber numberWithInt:5] forKey:PREF_TIME_SHORT_BREAK];
        [defaultValues setObject:[NSNumber numberWithInt:15] forKey:PREF_TIME_LONG_BREAK];
        [defaultValues setObject:[NSNumber numberWithInt:true] forKey:PREF_PLAY_SOUND_WHEN_TIMER_STARTS];
        [defaultValues setObject:[NSNumber numberWithInt:true] forKey:PREF_PLAY_SOUND_WHEN_TIMER_GOES_OFF];
        [defaultValues setObject:[NSNumber numberWithInt:true] forKey:PREF_PLAY_TICKTOCK_SOUND_DURING_POMODORO];
        [defaultValues setObject:[NSNumber numberWithInt:true] forKey:PREF_PLAY_TICKTOCK_SOUND_DURING_BREAK];
        [defaultValues setObject:[NSNumber numberWithInt:false] forKey:PREF_USE_BLACK_ICONS_ONLY];
        [defaultValues setObject:[NSNumber numberWithInt:4] forKey:PREF_NUMBER_POMODOROS_PER_CYCLE];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    }
    return self;
}

- (int)getInt:(NSString *)key
{
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:key];
}

- (void)setInt:(NSString *)key value:(int)value
{
    int actualValue = [self getInt:key];
    if(value != actualValue)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
        
        [eventBus publish:PREFERENCE_CHANGE data:key];
        
        //It would have been nice passing just a dictionary around in a generic way.
        //But that would force us to include TYPreferences everywhere defeating the purpose
        //of the eventBus handing over the values.
        if(key == PREF_USE_BLACK_ICONS_ONLY)
            [eventBus publish:ICON_TYPE_CHANGE data:[NSNumber numberWithInt:value]];
        else if(key == PREF_NUMBER_POMODOROS_PER_CYCLE)
            [eventBus publish:POMODORO_PER_CYCLE_CHANGE data:[NSNumber numberWithInt:value]];
        
    }
}

@end
