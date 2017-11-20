//
//  ViewController.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "MyDestinationsViewController.h"
#import "MPC_CloudKitManager.h"
#import "AllDestinationsViewController.h"
#import "DestinationsDataSource.h"
#import "DestinationCell.h"
#import "Destination.h"
#import "PlaceHolderView.h"

@interface MyDestinationsViewController ()<UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *placeholder;
@property (weak, nonatomic) IBOutlet UIView *swipeRightView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MPC_CloudKitManager *manager;
@property (strong, nonatomic) DestinationsDataSource *dataSource;
@property (strong, nonatomic) NSArray *destinations;
@property (strong, nonatomic) UINavigationController *allDestinationsNavigationController;


@end

@implementation MyDestinationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%s called", __FUNCTION__);
    self.destinations = [NSArray new];
    self.manager = [[MPC_CloudKitManager alloc]init];
    self.dataSource = [[DestinationsDataSource alloc]initWithDataArray:self.destinations
                                                              editable:YES];
    
    [self.swipeRightView setAlpha:0.0];
    [self.swipeRightView.layer setCornerRadius:10];
    [self _configureTableView];
    [self _tableViewShouldHide];
    [self _registerNibs];
    [self _configureKVO];
}

- (void)_initializeDatabase
{
    [self _presentPlaceholder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Check if the cloudkit database has been initialized
    if (![[NSUserDefaults standardUserDefaults]boolForKey:kDatabaseInitialized])
        [self _presentPlaceholder];
    
    //Else try to download user destinations
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self.manager downloadDestinationsType:DLTypeMyDestinations];
        });
        
//        dispatch_async(dispatch_get_main_queue(),^{
//            //Create a nav controller to speed things up
//            self.allDestinationsNavigationController = [self _createAllDestinationsNavController];
//        });
//
        
    }
    
    
    
    
}



- (void)_configureTableView
{
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)_tableViewShouldHide
{
    self.tableView.hidden = self.destinations ? (self.destinations.count > 0 ? NO : YES) : NO;
    [self.view layoutSubviews];
}

- (void)_registerNibs
{
    [self.tableView registerNib:[UINib nibWithNibName:[DestinationCell nibName] bundle:nil]
         forCellReuseIdentifier:[DestinationCell reuseID]];
}

- (void)viewWillLayoutSubviews
{
    self.tableView.frame = self.view.window.bounds;
    self.placeholder.text = [self _info];
}

#pragma mark KVO Observing
- (void)_configureKVO
{
    
    [self.manager addObserver:self
                   forKeyPath:@"MyDestinations"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    
    if ([keyPath isEqualToString:@"MyDestinations"] &&
        [object isKindOfClass:[MPC_CloudKitManager class]]) {

        //Recover array
        self.destinations = [change objectForKey:@"new"];
        [self _updateDataSourceWithDestinations:[self.destinations copy]];
        [self _tableViewShouldHide];
        [self _reload];

    }
}

- (void)_updateDataSourceWithDestinations:(NSArray *)destinations
{
    self.dataSource.destinations = destinations;
}

- (void)_reload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove Destination";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.swipeRightView.alpha == 0.0) {
        [self _animateSwipeHelpAnimateIN:[NSNumber numberWithBool:YES]];
    }
}

- (void)_animateSwipeHelpAnimateIN:(NSNumber *)animateIn
{
    BOOL fadeIn = [animateIn boolValue];
    [UIView animateWithDuration:0.3 animations:^{
        self.swipeRightView.alpha = fadeIn ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        if (fadeIn)
        [self performSelector:@selector(_animateSwipeHelpAnimateIN:) withObject:[NSNumber numberWithBool:NO] afterDelay:1.5];
    }];
}

#pragma mark - Navigation
- (void)_presentPlaceholder
{
    UIStoryboard *placeholderSB = [UIStoryboard storyboardWithName:@"CloudKitStarter" bundle:nil];
    UINavigationController *NC = [placeholderSB instantiateViewControllerWithIdentifier:@"placeholderNavConID"];
    [self presentViewController:NC animated:YES completion:nil];

}

- (IBAction)presentAllDestinationsView:(id)sender
{

    AllDestinationsViewController *dvc = [[AllDestinationsViewController alloc]init];

    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:dvc];

        [self presentViewController:nc
                           animated:YES
                         completion:nil];
  
}


#pragma mark - Info copy
- (NSString *)_info
{
    return @"Querying the server now to see if you have added any destinations.\n\nIf not, tap + and click on a destination to add it.";
}

@end
