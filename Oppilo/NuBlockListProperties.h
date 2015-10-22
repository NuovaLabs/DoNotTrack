//
//  NuBlockList.h
//  Oppilo
//
//  Created by RaviJain on 30/09/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NuBlockListProperties : NSObject

@property(nonatomic,strong)NSString * name;
@property(nonatomic,strong)NSString * type;
@property(nonatomic,assign)BOOL isEnabledByDefault;
@property(nonatomic,assign)BOOL isEnabledByUser;
@property(nonatomic,strong)NSNumber * maxLimit;

+(NuBlockListProperties *)getBlockListFromProperties:(NSDictionary *)properties;
-(NSDictionary *)getDictionary;

@end
