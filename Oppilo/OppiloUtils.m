//
//  OppiloUtils.m
//  Oppilo
//
//  Created by RaviJain on 30/09/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import "OppiloUtils.h"
#import "OppilioAppConstants.h"

@implementation OppiloUtils

+(NSUserDefaults *)getUserDefaults
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:[OppiloUtils getAppGroupName]];
    return userDefaults;
}


+(NSString *)getAppGroupName
{
    return kContentBlockerAppGroupName;
}

+(NSString *)getPathForAppGroupDirectory
{
    NSURL *fileManagerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[OppiloUtils getAppGroupName]];
    NSString *tmpPath = [NSString stringWithFormat:@"%@", fileManagerURL.path];
    NSString *finalPath = [NSString stringWithFormat:@"%@",[tmpPath stringByAppendingString:@"/Documents"]];
    
    if(![[NSFileManager defaultManager]fileExistsAtPath:finalPath isDirectory:nil])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:finalPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return finalPath;

}

+(NSString *)getPathForBlockerListJson
{
    NSString * directoryPath = [OppiloUtils getPathForAppGroupDirectory];
    NSString * blockerListPath = [NSString stringWithFormat:@"%@/%@",directoryPath,@"oppiloList.json"];
    return blockerListPath;
}

+(BOOL)doesBlockerListFileExists
{
    
    if([[NSFileManager defaultManager]fileExistsAtPath:[OppiloUtils getPathForBlockerListJson] isDirectory:nil])
    {
        return YES;
    }
    
    return NO;
}

+(NSString *)getPathForCurrentUserPreferences
{
    NSString * filePath = [OppiloUtils getPathForAppGroupDirectory];
    NSString * userPrefFilePath = [NSString stringWithFormat:@"%@/%@",filePath,@"currentUserPref.plist"];
    return userPrefFilePath;    
}


+(NSString *)getPathForWhiteListJson
{
    NSString * filePath = [OppiloUtils getPathForAppGroupDirectory];
    NSString * userPrefFilePath = [NSString stringWithFormat:@"%@/%@",filePath,@"whiteList.json"];
    return userPrefFilePath;
}

+(BOOL)doesWhiteListJsonExist
{
    
    if([[NSFileManager defaultManager]fileExistsAtPath:[OppiloUtils getPathForWhiteListJson] isDirectory:nil])
    {
        return YES;
    }
    
    return NO;
}

@end
