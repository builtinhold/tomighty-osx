//
//  TYNotificationAgent.h
//  Tomighty
//
//  Created by David on 09/04/2016.
//  Copyright © 2016 Gig Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYEventBus.h"


@interface TYNotificationAgent : NSObject

- (id)initWith:(id<TYEventBus>)anEventBus pomodorosPerCycle:(int)currentPomPerCycle;


@end


