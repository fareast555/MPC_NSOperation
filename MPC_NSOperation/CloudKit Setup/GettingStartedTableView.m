//
//  GettingStartedTableView.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/20.
//  Copyright © 2017 Michael Critchley. All rights reserved.


#import "GettingStartedTableView.h"

NSString *const kSequeToGeneralTabExplanationID = @"sequeToGeneralTab";
NSString *const kSequeToCapabilitiesTabExplanationID = @"sequeToCapabilitiesTab";


#pragma mark - Custom dismiss segue
@implementation DismissSegue: UIStoryboardSegue
- (void)perform
{
    UIViewController *sourceVC = self.sourceViewController;
    [sourceVC.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end;

#pragma mark - Getting Started Table View
@interface GettingStartedTableView ()<UITableViewDelegate>
@end

@implementation GettingStartedTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Getting started";
}

#pragma mark - Table view delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //1. Create an image holder
    UIImage *image = nil;
    
    //2. Load the correct image to the destination view controller
    if ([segue.identifier isEqualToString:kSequeToGeneralTabExplanationID])
        image = [UIImage imageNamed:@"info_General.png"];
    else if ([segue.identifier isEqualToString:kSequeToCapabilitiesTabExplanationID])
        image = [UIImage imageNamed:@"info_Capabilities.png"];
    
    //3. Get a pointer to the destination controller
    UIViewController *vc = segue.destinationViewController;
    
    //4. Set the image via its tag (set in CloudKitStarter.storyboard)
    UIImageView *imageView = [vc.view viewWithTag:1];
    imageView.image = image;
}


@end
