//
//  NUWhiiteListRule.m
//  Oppilo
//
//  Created by RaviJain on 01/10/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import "NUWhiiteListRule.h"

@implementation NUWhiiteListRule

-(id)initWithDomain:(NSString *)domain
{
    self = [super init];
    if(self)
    {
        self.triggerUrlFilter = domain;
    }
    
    return self;
}
-(NSString *)getWhiteListRule
{
    NSString * rule1 =  [NSString stringWithFormat:@"{ \"trigger\": { \"url-filter\": \"%@\"}, \"action\": {\"type\": \"ignore-previous-rules\"}}",self.triggerUrlFilter ];
    
    
    NSString * rule = [NSString stringWithFormat:@"{ \"trigger\": { \"url-filter\":\".*\",\"if-domain\":[\"*%@\"]}, \"action\": {\"type\": \"ignore-previous-rules\"}}",self.triggerUrlFilter ];
    
    return rule;
}
@end
