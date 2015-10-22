//
//  ViewController.m
//  Oppilo
//
//  Created by RaviJain on 29/09/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import "ViewController.h"
#import "PageViewController.h"
#import "MessageViewController.h"
#import "AppSetupViewController.h"
#import "ExtensionSetupViewController.h"
#import "OppiloBlockerListManager.h"
#import "OppilioAppConstants.h"

@interface ViewController () <UIPageViewControllerDataSource, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) PageViewController            *pageController;
@property (strong, nonatomic) MessageViewController         *messageController;
@property (strong, nonatomic) AppSetupViewController        *appSetupController;
@property (strong, nonatomic) ExtensionSetupViewController  *extensionSetupController;
@property (nonatomic, assign) BOOL                          appSetupStepRequired;
@property (weak, nonatomic) IBOutlet UITableView            *tableView;
@property (strong, nonatomic) NSMutableArray                *sections;
@property (nonatomic, assign) BOOL                          isSocPriv;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    _sections = [[NSMutableArray alloc] initWithCapacity:3];
    
    _isSocPriv = [kContentBlockerAppCode isEqualToString:@"op_soc"] || [kContentBlockerAppCode isEqualToString:@"op_priv"];
    if (_isSocPriv) {
        _sections = [@[@"HELP", @"RATE"] mutableCopy];
    } else {
        _sections = [@[@"WHITELIST", @"HELP", @"RATE"] mutableCopy];
    }
    
    UIStoryboard *storyboard = [self storyboard];
    self.messageController = [storyboard instantiateViewControllerWithIdentifier:@"MessageVCId"];

    _appSetupStepRequired = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppOptionsRequired"] boolValue];
    
    if (_appSetupStepRequired) {
        self.appSetupController = [storyboard instantiateViewControllerWithIdentifier:@"AppSetupVCId"];
    }
    self.extensionSetupController = [storyboard instantiateViewControllerWithIdentifier:@"ExtensionSetupVCId"];
    self.extensionSetupController.launchedFromNav = NO;

    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    self.title = appName;
    
    if (_isSocPriv) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.23 green:0.60 blue:0.85 alpha:1.0];
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.26 alpha:1.0];
    }

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    BOOL introShown = [userDefaults boolForKey:@"IntroShown"];
    if (!introShown) {
        
        self.pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageVCId"];
        self.pageController.dataSource = self;
        [self.pageController setViewControllers:@[_messageController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        [self presentViewController:self.pageController animated:YES completion:nil];
        
        [userDefaults setBool:YES forKey:@"IntroShown"];
        [userDefaults synchronize];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultTableCell"];
    NSString *sectionName = [_sections objectAtIndex:indexPath.section];
    
    if ([sectionName isEqualToString:@"WHITELIST"]) {
        [cell.textLabel setText:NSLocalizedString(@"WHITELIST_DOMAIN", nil)];
    } else if ([sectionName isEqualToString:@"HELP"]) {
        [cell.textLabel setText:NSLocalizedString(@"HELP", nil)];
    } else if ([sectionName isEqualToString:@"RATE"]) {
        [cell.textLabel setText:NSLocalizedString(@"RATE", nil)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionName = [_sections objectAtIndex:indexPath.section];

    if ([sectionName isEqualToString:@"WHITELIST"]) {
        
        [self addWhitelist];
        
    } else if ([sectionName isEqualToString:@"HELP"]) {
        
        [self launchHelp];
        
    } else if ([sectionName isEqualToString:@"RATE"]) {
     
        [self rateApp];
    }
    
    [self.tableView reloadData];
}

- (void) rateApp
{
    NSString *appStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";
    NSURL * url =   [NSURL URLWithString:[NSString stringWithFormat:appStoreURLFormat, kContentBlockerAppStoreId]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) launchHelp
{
    ExtensionSetupViewController *vc = (ExtensionSetupViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"ExtensionSetupVCId"];
    vc.launchedFromNav = YES;
    
    UINavigationController *navVc  = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navVc animated:YES completion:nil];
}

- (void) addWhitelist
{
    UIAlertController *whitelistController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ADD_WHITELIST_TITLE", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        ;
    }];
    
    UIAlertAction *addDomain = [UIAlertAction actionWithTitle:NSLocalizedString(@"ADD", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *keyField = [whitelistController.textFields firstObject];
        
        if ([keyField.text length] > 0) {
            
            [[OppiloBlockerListManager sharedManager] addWhiteListRule:keyField.text];
        }
    }];
    
    [whitelistController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"WHITELIST_DOMAIN_PLACEHOLDER", nil);
    }];
    
    [whitelistController addAction:cancel];
    [whitelistController addAction:addDomain];
    
    [self presentViewController:whitelistController animated:YES completion:nil];

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 130)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, tableView.frame.size.width - 15, 60)];

        if (_isSocPriv) {
            [label setText:NSLocalizedString(@"APP_MSG", nil)];
        } else {
            [label setText:NSLocalizedString(@"WHITELIST_HELP_TXT", nil)];
        }
        
        label.numberOfLines = 0;
        
        [label setTextColor:[UIColor darkTextColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:14.0f]];
        
        [containerView addSubview:label];
        return containerView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 130;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isSocPriv) {
        return 60;
    } else {
        return 44;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[MessageViewController class]]) {
        return nil;
    } else if ([viewController isKindOfClass:[AppSetupViewController class]]) {
        return self.messageController;
    } else if ([viewController isKindOfClass:[ExtensionSetupViewController class]]) {
        
        if (_appSetupStepRequired) {
            return self.appSetupController;
        } else {
            return self.messageController;
        }
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[MessageViewController class]]) {
        if (_appSetupStepRequired) {
            return self.appSetupController;
        } else {
            return self.extensionSetupController;
        }
    } else if ([viewController isKindOfClass:[AppSetupViewController class]]) {
        return self.extensionSetupController;
    } else if ([viewController isKindOfClass:[ExtensionSetupViewController class]]) {
        return nil;
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (_isSocPriv && section == 1) {
        return @"Copyright © 2015 Nuova Labs";
    } else {
        return nil;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    if (_appSetupStepRequired) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
