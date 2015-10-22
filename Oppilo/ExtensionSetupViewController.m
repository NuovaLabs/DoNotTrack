//
//  ExtensionSetupViewController.m
//  Oppilo
//
//  Created by Kinshuk  Kar on 10/1/15.
//  Copyright © 2015 Nuova Labs. All rights reserved.
//

#import "ExtensionSetupViewController.h"
#import "OppilioAppConstants.h"

@interface ExtensionSetupViewController ()

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *goToSettingsLabel;

@end

@implementation ExtensionSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor colorWithRed:0.32 green:0.40 blue:0.62 alpha:1.0]];
    
    if (self.launchedFromNav) {
        
        [self.doneButton setHidden:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];

    } else {
        
        [self.doneButton setHidden:NO];
        [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
        self.doneButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.doneButton.layer.borderWidth = 2.0f;
        [self.doneButton setBackgroundColor:[UIColor clearColor]];
    }
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"SETUP_APP", nil), kContentBlockerAppName];
    [self.goToSettingsLabel setText:NSLocalizedString(@"GO_TO_SETTINGS", nil)];
    
    //@"Setup Oppilo";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    
    [self dismissViewControllerAnimated:self completion:nil];
}

@end
