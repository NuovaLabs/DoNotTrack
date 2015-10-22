//
//  NUWhiiteListRule.h
//  Oppilo
//
//  Created by RaviJain on 01/10/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUWhiiteListRule : NSObject

@property(nonatomic,strong)NSString * triggerUrlFilter;
-(NSString *)getWhiteListRule;
-(id)initWithDomain:(NSString *)domain;

@end
