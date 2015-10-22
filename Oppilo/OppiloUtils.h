//
//  OppiloUtils.h
//  Oppilo
//
//  Created by RaviJain on 30/09/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OppiloUtils : NSObject

+(NSUserDefaults *)getUserDefaults;
+(NSString *)getPathForAppGroupDirectory;
+(NSString *)getPathForBlockerListJson;
+(BOOL)doesBlockerListFileExists;
+(NSString *)getPathForCurrentUserPreferences;

+(NSString *)getPathForWhiteListJson;
+(BOOL)doesWhiteListJsonExist;

@end
