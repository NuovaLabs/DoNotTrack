//
//  OppiloAppService.m
//  Oppilo
//
//  Created by RaviJain on 30/09/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import "OppiloManager.h"
#import "OppiloBlockerListManager.h"

@implementation OppiloManager



+ (id)sharedManager {
    
    static OppiloManager *sharedOpilloManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOpilloManager = [[self alloc] init];
    });
    return sharedOpilloManager;
}


-(id)init
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}


- (void) applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[OppiloBlockerListManager sharedManager]initialize];
   // [[OppiloBlockerListManager sharedManager]addWhiteListRule:@"www.wordhippo.com"];
    
    
    return true;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    return true;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    
}

- (void) onAppEnteredForeGround
{
    
    
}

- (void) onAppEnteredBackGround
{
    
    
}

- (void) onAppResignActive
{
    
    
    
}


-(void)initialize
{
    
    
}


@end
