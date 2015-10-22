//
//  OppiloBlockerListManager.m
//  Oppilo
//
//  Created by RaviJain on 30/09/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import "OppiloBlockerListManager.h"
#import <SafariServices/SafariServices.h>
#import "OppiloUtils.h"
#import "NuBlockListProperties.h"
#import "NUWhiiteListRule.h"
#import "OppilioAppConstants.h"

@interface OppiloBlockerListManager  ()

@property(nonatomic,strong)NSDictionary * defaultPreferences;
@property(nonatomic,strong)NSDictionary * blockerJsonList;
@property(nonatomic,strong)NSDictionary * currentUserPreferences;
@property(nonatomic,strong)NSArray * availableBlockLists;
@property(nonatomic,strong)NSMutableDictionary * availableBlockListsDictionary;


@end

@implementation OppiloBlockerListManager


+ (id)sharedManager {
    
    static OppiloBlockerListManager *sharedBlockListManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBlockListManager = [[self alloc] init];
    });
    return sharedBlockListManager;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [self loadDefaultBlockerPlist];
        [self loadPreferencesPlist];
        [self processUserPreferences];

    }
    return self;
}


-(void)initialize
{
    [self createBlockListJsonIfRequired];
}

-(void)loadPreferencesPlist
{
    
    if(_defaultPreferences == nil)
    {
        NSDictionary * plist = nil;
        
        NSString * pathForPreferences = [[NSBundle mainBundle]pathForResource:@"AvailableBlockList" ofType:@"plist"];
        plist = [[NSDictionary alloc]initWithContentsOfFile:pathForPreferences];
        
        _defaultPreferences = plist;
    }
    
    if(_currentUserPreferences == nil)
    {
        NSString * filePath = [OppiloUtils getPathForCurrentUserPreferences];
        if([[NSFileManager defaultManager]fileExistsAtPath:filePath])
        {
            _currentUserPreferences = [[NSDictionary alloc]initWithContentsOfFile:filePath];
        }
        else
        {
            _currentUserPreferences = _defaultPreferences;
        }
    }
    
}

-(void)loadDefaultBlockerPlist
{
    if(_blockerJsonList == nil)
    {
        NSDictionary * plist = nil;
        
        NSString * pathForPreferences = [[NSBundle mainBundle]pathForResource:@"DefaultBlockerJson" ofType:@"plist"];
        plist = [[NSDictionary alloc]initWithContentsOfFile:pathForPreferences];
        
        _blockerJsonList = plist    ;
    }
    
}

-(void)processUserPreferences
{
    NSArray * blockListsArray = [_currentUserPreferences objectForKey:@"AvailableBlockList"];
    __block NSMutableDictionary * blockListsDict = [[NSMutableDictionary alloc]init];
    
    [blockListsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NuBlockListProperties * blocklIst = [NuBlockListProperties getBlockListFromProperties:obj];
        [blockListsDict setObject:blocklIst forKey:blocklIst.name];
    }];
    
    _availableBlockListsDictionary = blockListsDict;

    _availableBlockLists =  [_availableBlockListsDictionary allValues];

}

-(void)createBlockListJsonIfRequired
{
    if(![self isDefaultContentBlockListCreated])
    {
        [self createContentBlockList:_currentUserPreferences];
        [self reloadBlockerListInExtension];
    }
}

-(BOOL)isDefaultContentBlockListCreated
{
    BOOL isCreated = false;
    isCreated = [OppiloUtils doesBlockerListFileExists] ;
    return isCreated;
}



-(void)createContentBlockList:(NSDictionary *)preferences
{
    
    NSMutableArray * arrayBlockList = [[NSMutableArray alloc]init];
    
    NSArray * blockList =  [self processBlockList:preferences];
    [blockList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NuBlockListProperties * properties = [NuBlockListProperties getBlockListFromProperties:obj];
        
        NSArray * blockListArray = [self getFilterListFromBlockListWithProperties:properties];
        [arrayBlockList addObject:blockListArray];

    }];
    
    NSArray * whiteListRules = [self getWhitelistRules];
    
    if(whiteListRules.count > 0)
    {
        [arrayBlockList addObject:whiteListRules];
    }

    NSData * combindeFilters =  [self combineFilterLists:arrayBlockList];
    
    [self writeToDefaultBlockerList:combindeFilters];

}

-(NSArray *)processBlockList:(NSDictionary *)preferences
{

    __block NSMutableArray * blockListToBeAdded = [[NSMutableArray alloc]init];
    NSArray * blockListsArray = [preferences objectForKey:@"AvailableBlockList"];
    
    [blockListsArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL isEnabled = [[obj objectForKey:@"IsEnabledByDefault"]boolValue];
        if(isEnabled)
        {
            [blockListToBeAdded addObject:obj];
        }
    }];
    
    return blockListToBeAdded;
}


-(NSArray *)getFilterListFromBlockListWithProperties:(NuBlockListProperties *)properties
{
    [self loadDefaultBlockerPlist];
    NSDictionary * lists = [_blockerJsonList objectForKey:properties.type];
    NSArray * files = [lists objectForKey:properties.name];
    

   __block NSMutableArray * filterList = [[NSMutableArray alloc]init];
    
   __block NSUInteger numOfFilters = 0;
    
    [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

      NSArray * list =  [self getFilterListHavingName:obj];
        
      if([properties.maxLimit doubleValue] != -1 && [properties.maxLimit doubleValue]!=0)
      {
          if(numOfFilters < [properties.maxLimit doubleValue])
          {
              if(numOfFilters + [list count] > [properties.maxLimit doubleValue])
              {
                  NSUInteger numOFFiltersRemaining = [properties.maxLimit doubleValue] - numOfFilters;
                  NSArray * arrayToBeAdded = [list subarrayWithRange:NSMakeRange(0, numOFFiltersRemaining)];
                  [filterList addObjectsFromArray:arrayToBeAdded];
              }
              else
              {
                  numOfFilters = numOfFilters + [list count];
                  [filterList addObjectsFromArray:list];
              }
          }
          
      }
      else
      {
          [filterList addObjectsFromArray:list];
      }
    }];
    
    return filterList;
}

-(NSArray *)getFilterListHavingName:(NSString *)name
{
    NSString * fileName = [name stringByDeletingPathExtension];
    NSString * path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"json"];
    NSData * data = [[NSData alloc]initWithContentsOfFile:path];
    
    NSArray * arrayData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return arrayData;
}

-(NSData *)combineFilterLists:(NSArray *)filterLists
{
    NSData * combineFilters = nil;
    
    
    __block NSMutableArray * combineFiltersArray = [[NSMutableArray alloc]init];

    
    [filterLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [combineFiltersArray addObjectsFromArray:obj];
        
    }];
    
    NSLog(@"numbers of filters %@",@(combineFiltersArray.count));
    if(combineFiltersArray.count >  50000)
    {
        NSArray * filteredArray = [combineFiltersArray subarrayWithRange:NSMakeRange(0, 50000)];
        combineFiltersArray = [[NSMutableArray alloc]init];
        [combineFiltersArray addObjectsFromArray:filteredArray];
    }
    
    combineFilters = [NSJSONSerialization dataWithJSONObject:combineFiltersArray options:NSJSONWritingPrettyPrinted error:nil];

    return combineFilters   ;
}


-(void)writeToDefaultBlockerList:(NSData *)data
{
    NSString * path = [OppiloUtils getPathForBlockerListJson];
    [data writeToFile:path atomically:YES];
 }

-(void)reloadBlockerListInExtension
{
    [SFContentBlockerManager reloadContentBlockerWithIdentifier:kContentBlockerGroupName completionHandler:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"RELOAD FAILED WITH ERROR - %@",[error localizedDescription]);
        }
    }];
}

-(NSArray *)getAvailableBlockLists
{
    return _availableBlockLists;

}

-(void)changeBlockListStatus:(NuBlockListProperties *)blockListProperty
{
    NuBlockListProperties * currentBlockListProperty = [_availableBlockListsDictionary objectForKey:blockListProperty.name];
    
    if(currentBlockListProperty.isEnabledByUser != blockListProperty.isEnabledByUser)
    {
        currentBlockListProperty.isEnabledByUser = blockListProperty.isEnabledByUser;
        [_availableBlockListsDictionary setObject:currentBlockListProperty forKey:blockListProperty.name];
        
        _availableBlockLists = [_availableBlockListsDictionary allValues];
        
        [self loadBlockListJsonFromUserPreferences:_availableBlockLists];
        
    
    }
}

-(void)loadBlockListJsonFromUserPreferences:(NSArray *)userPreference;
{
   __block  NSMutableArray * userPrefDictArray = [[NSMutableArray alloc]init];
    
    [userPreference enumerateObjectsUsingBlock:^(NuBlockListProperties * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary * objDict = [obj getDictionary];
        [userPrefDictArray addObject:objDict];
    }];
    
    NSDictionary * userDictionary = @{@"AvailableBlockList":userPrefDictArray};
    _currentUserPreferences = userDictionary;
    
    [self saveUserPreferencesToFileSystem];
    
    [self createContentBlockList:_currentUserPreferences];
    
    [self reloadBlockerListInExtension];

}


-(void)saveUserPreferencesToFileSystem
{
    [_currentUserPreferences writeToFile:[OppiloUtils getPathForCurrentUserPreferences] atomically:YES];
}

-(void)addWhiteListRule:(NSString *)triggerUrlFilter
{
    NUWhiiteListRule * whiteListRule = [[NUWhiiteListRule alloc]initWithDomain:triggerUrlFilter];
    NSString * rule = [whiteListRule getWhiteListRule];

    NSData * ruleData = [rule dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary * ruleDict = [NSJSONSerialization JSONObjectWithData:ruleData options:NSJSONReadingMutableContainers error:nil];
    
    
    NSArray * currentRules = [self getWhitelistRules];
    
    NSMutableArray * newRules = [[NSMutableArray alloc]initWithArray:currentRules];
    [newRules addObject:ruleDict];
    
    [self writeBackWhiteListRules:newRules];
    
    [self createContentBlockList:_currentUserPreferences];
    
    [self reloadBlockerListInExtension];

    
}

-(NSArray *)getWhitelistRules
{
    NSArray * whiteListRules = [[NSArray alloc]init];
    if([OppiloUtils doesWhiteListJsonExist])
    {
        NSString * filePath = [OppiloUtils getPathForWhiteListJson];
        NSData * data = [NSData dataWithContentsOfFile:filePath];
        whiteListRules = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    
    return  whiteListRules  ;
}


-(void)writeBackWhiteListRules:(NSArray *)rules
{
    NSString * filePath = [OppiloUtils getPathForWhiteListJson];
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:rules options:NSJSONWritingPrettyPrinted error:nil];
    
    [jsonData writeToFile:filePath atomically:YES];
}

@end
