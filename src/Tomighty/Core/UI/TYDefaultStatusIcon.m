//
//  Tomighty - http://www.tomighty.org
//
//  This software is licensed under the Apache License Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0.txt
//

#import "TYDefaultStatusIcon.h"

@implementation TYDefaultStatusIcon
{
    __strong NSStatusItem *statusItem;
    __strong NSMutableDictionary *iconImageCache;
    __strong TYImageLoader *imageLoader;
    BOOL _useBlackIconsOnly;
    UIIconStatusType _currentIconStatusType;
}

- (id)initWith:(NSMenu *)aMenu imageLoader:(TYImageLoader *)anImageLoader useBlackIconsOnly:(BOOL)useBlackIconsOnly
{
    self = [super init];
    if(self)
    {
        imageLoader = anImageLoader;
        iconImageCache = [[NSMutableDictionary alloc] initWithCapacity:8];
        statusItem = [self createStatusItem:aMenu];
        _useBlackIconsOnly = useBlackIconsOnly;
    }
    return self;
}

- (NSStatusItem *)createStatusItem:(NSMenu *)menu
{
    NSStatusItem *newStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [newStatusItem setHighlightMode:YES];
    [newStatusItem setImage:[self getIconImage:UIIconStatusTypeIdle]];
    [newStatusItem setAlternateImage:[self getIconImage:UIIconStatusTypeAlternate]];
    [newStatusItem setMenu:menu];
    
    return newStatusItem;
}

- (void)changeIcon:(int)icon
{
    [statusItem setImage:[self getIconImage:icon]];
    _currentIconStatusType = icon;
}

- (NSImage *)getIconImage:(UIIconStatusType)iconType
{
    NSString *iconName = [self getIconImageName:iconType];
    
    NSImage *image = [iconImageCache objectForKey:iconName];
    if(!image)
    {
        image = [imageLoader loadIcon:iconName];
        iconImageCache[iconName] = image;
    }
    return image;
}

- (NSString *)getIconImageName:(UIIconStatusType) iconType
{
    switch(iconType)
    {
        case UIIconStatusTypeIdle:
            return @"icon-status-idle";
            break;
        case UIIconStatusTypePomodoro:
            return _useBlackIconsOnly? @"icon-status-idle" : @"icon-status-pomodoro";
            break;
        case UIIconStatusTypeShortBreak:
            return _useBlackIconsOnly? @"icon-status-idle" : @"icon-status-short-break";
            break;
        case UIIconStatusTypeLongBreak:
            return _useBlackIconsOnly? @"icon-status-idle" : @"icon-status-long-break";
            break;
        case UIIconStatusTypeAlternate:
            return  @"icon-status-alternate";
            break;
        default:
            return @"";
            
    }
}

- (void)setUseBlackIconsOnly:(BOOL) useBlackIconsOnly
{
    _useBlackIconsOnly = useBlackIconsOnly;
    [self refreshCurrentIcon];
}

- (void)refreshCurrentIcon
{
    [self changeIcon:_currentIconStatusType];
}

@end
