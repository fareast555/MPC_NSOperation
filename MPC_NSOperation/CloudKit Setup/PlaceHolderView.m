//
//  PlaceHolderView.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/20.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "PlaceHolderView.h"
#import "MPC_CloudKitManager.h"

@interface PlaceHolderView ()<MPC_CloudKitManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIButton *attemptCloudKitButton;
@property (weak, nonatomic) IBOutlet UILabel *cloudKitSaveStatus;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation PlaceHolderView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Ensure that spinner is OFF at first load
    [self.spinner stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Call for a one-time configuration
    [self _configureView];
}

- (void)_configureView
{
    //1. Only perform set up if values have not been set
    if (self.attemptCloudKitButton.layer.cornerRadius == 8)
        return;
    
    //2. Round button edges
    self.attemptCloudKitButton.layer.cornerRadius = 8;
    
    //3. Set button padding
    CGFloat width = self.attemptCloudKitButton.titleLabel.intrinsicContentSize.width + 18;
    CGFloat height = self.attemptCloudKitButton.titleLabel.intrinsicContentSize.height + 18;
    
    [self.attemptCloudKitButton.widthAnchor constraintEqualToConstant:width].active = YES;
    [self.attemptCloudKitButton.heightAnchor constraintEqualToConstant:height].active = YES;
    
    //4. Set textView message
    self.infoTextView.text = [self _info];
    self.cloudKitSaveStatus.text = @"Attempting to save data...\n";
    
    //5. Show a border for small screens around textView to prompt scrollability
    if ([UIScreen mainScreen].bounds.size.width < 330) {
        self.infoTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.infoTextView.layer.borderWidth = 0.5;
    }
    
    //6. Butt textview up against top edge
    self.infoTextView.contentInset = UIEdgeInsetsMake(4.0,0.0,0,0.0);
    
    //7. Set font manually (not working in Storyboard for 5S)
    self.infoTextView.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightThin];
    
    //8. Tell system to re-render
    [self.view layoutSubviews];
}


- (IBAction)saveTestDataToiCloud:(id)sender
{
    [self _presentConfirmationAlert];
}

- (void)_initializeCloudKit {
    
    [self _configureInitializingInProgress];
    MPC_CloudKitManager *manager = [[MPC_CloudKitManager alloc]init];
    manager.delegate = self;
    [manager initializeDestinations];
}

- (void)_configureInitializingInProgress
{
    self.attemptCloudKitButton.enabled = NO;
    self.cloudKitSaveStatus.text = @"Attempting to save data...\n";
    self.cloudKitSaveStatus.textColor = [UIColor darkGrayColor];
    self.cloudKitSaveStatus.hidden = NO;
    [self _animateSpinner:YES];
   
}

#pragma mark - MPC_CloudKitManagerDelegate
- (void)databaseInitializationDidSucceeedInMPC_CloudKitManager:(MPC_CloudKitManager *)manager
{
    [self _animateSpinner:NO];
    self.cloudKitSaveStatus.text = @"Success!\n";
    self.cloudKitSaveStatus.textColor = [UIColor greenColor];
    [self performSelector:@selector(_dismissView)
               withObject:nil
               afterDelay:1.0];
}

- (void)_dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)databaseInitializationDidFailWithError:(NSError *)error inMPC_CloudKitManager:(MPC_CloudKitManager *)manager
{
    [self _animateSpinner:NO];
    self.cloudKitSaveStatus.text = @"Ouch! Unable to set up Cloudit.\nCheck the ReadMe.ME file.";
    self.cloudKitSaveStatus.textColor = [UIColor redColor];
    self.attemptCloudKitButton.enabled = YES;
}

- (void)_animateSpinner:(BOOL)animate
{
    if (animate)
        [self.spinner startAnimating];
    else
        [self.spinner stopAnimating];
}

#pragma mark - Alert
- (void)_presentConfirmationAlert
{
    __weak UIButton *weakButton = self.attemptCloudKitButton;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Is your CloudKit Container set up?"
                                                                   message:@"If not, go to the ReadMe.ME file or the 'Show me tab' to learn how. Otherwise, let's initialize that container!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action)
    {
        [weakButton setEnabled:YES];
    }];
    UIAlertAction *proceed = [UIAlertAction actionWithTitle:@"Let's go!"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action)
    {
        [self _initializeCloudKit];
    }];
    
    [alert addAction:proceed];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)_info
{
    return @"This demo requires some setup to use your own CloudKit container, so please check out the README.ME file for some details, or tap 'Show Me.'\n\nWhen your own CloudKit Container is turned on, tap the button below to install demo data.\n\nAs you download or save destinations, follow the log information in your log window area, and see MPC_CloudKitManager.m for detailed documentation of how it's working under the hood.";
}

@end
