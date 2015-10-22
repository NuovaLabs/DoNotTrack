//
//  ActionRequestHandler.m
//  NUContentBlocker
//
//  Created by RaviJain on 29/09/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import "ActionRequestHandler.h"
#import "OppiloUtils.h"

@interface ActionRequestHandler ()

@end

@implementation ActionRequestHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
    
    NSItemProvider *attachment = [[NSItemProvider alloc] initWithContentsOfURL:[self getBlockListFilePath]];
    
    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    item.attachments = @[attachment];
    
    [context completeRequestReturningItems:@[item] completionHandler:nil];
}



-(NSURL *)getBlockListFilePath
{
    NSURL * fileUrl = nil;
    BOOL doesFileExist = [OppiloUtils doesBlockerListFileExists];
//    if(doesFileExist)
    {
        NSString * filePath = [OppiloUtils getPathForBlockerListJson];
        fileUrl = [NSURL fileURLWithPath:filePath];
    }
//    else
//    {
//        fileUrl = [[NSBundle mainBundle] URLForResource:@"adblocking_1" withExtension:@"json"];
//    }
    
    return fileUrl;
    
}


@end
