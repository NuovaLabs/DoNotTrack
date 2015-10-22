//
//  OppiloBlockerListManager.h
//  Oppilo
//
//  Created by RaviJain on 30/09/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NuBlockListProperties.h"

@interface OppiloBlockerListManager : NSObject

+ (id)sharedManager;
-(void)initialize;

-(NSArray *)getAvailableBlockLists;

-(void)changeBlockListStatus:(NuBlockListProperties *)blockList;

-(void)loadBlockListJsonFromUserPreferences:(NSArray *)userPreference;

-(void)addWhiteListRule:(NSString *)triggerUrlFilter;

@end
