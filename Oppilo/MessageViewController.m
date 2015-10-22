//
//  MessageViewController.m
//  Oppilo
//
//  Created by Kinshuk  Kar on 10/1/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import "MessageViewController.h"
#import "OppilioAppConstants.h"
@interface MessageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView    *imageView;
@property (weak, nonatomic) IBOutlet UILabel        *welcomeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel        *welcomeMsgLabel;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.welcomeTitleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"WELCOME_TITLE", nil), kContentBlockerAppName]];
    [self.welcomeMsgLabel setText:NSLocalizedString(@"WELCOME_MSG", nil)];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.23 green:0.60 blue:0.85 alpha:1.0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
