//
//  NuBlockList.m
//  Oppilo
//
//  Created by RaviJain on 30/09/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import "NuBlockListProperties.h"

@implementation NuBlockListProperties

+(NuBlockListProperties *)getBlockListFromProperties:(NSDictionary *)properties
{
    NuBlockListProperties * blockList = [[NuBlockListProperties alloc]init];
    blockList.name = [properties objectForKey:@"Name"];
    blockList.type = [properties objectForKey:@"Type"];
    blockList.isEnabledByDefault = [properties objectForKey:@"IsEnabledByDefault"];
    blockList.maxLimit = @([[properties objectForKey:@"MaxLimit"]doubleValue]);
    return blockList;
}

-(NSDictionary *)getDictionary
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setObject:self.name forKey:@"Name"];
    [dict setObject:self.type forKey:@"Type"];
    [dict setObject:@(self.isEnabledByDefault) forKey:@"isEnabledByDefault"];
    [dict setObject:@(self.isEnabledByUser) forKey:@"isEnabledByUser"];
    [dict setObject:self.maxLimit forKey:@"maxLimit"];
    return dict;
}

@end
