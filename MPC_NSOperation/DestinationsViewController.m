//
//  ViewController.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "DestinationsViewController.h"
#import "MPC_CloudKitManager.h"
#import "DestinationsDataSource.h"
#import "DestinationCell.h"
#import "Destination.h"

@interface DestinationsViewController ()<UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UITextView *infoView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MPC_CloudKitManager *manager;
@property (strong, nonatomic) DestinationsDataSource *dataSource;
@property (strong, nonatomic) NSArray *destinations;

@end

@implementation DestinationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.destinations = [NSArray new];
    self.manager = [[MPC_CloudKitManager alloc]init];
    self.dataSource = [[DestinationsDataSource alloc]initWithDataArray:self.destinations
                                                              editable:NO];
    
    [self _configureTableView];
    [self _tableViewShouldHide];
    [self _registerNibs];
    [self _configureKVO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self _removeKVOObserving];
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
    self.infoView.text = [self _info];
}

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark KVO Observing
- (void)_configureKVO
{
    [self.manager addObserver:self
                   forKeyPath:@"destinations"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

- (void)_removeKVOObserving
{
    [self.manager removeObserver:self forKeyPath:@"destinations"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"destinations"] &&
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

- (IBAction)downloadDestinations:(id)sender
{
    [self.manager downloadDestinationsType:DLTypeAllDestinations];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s called", __FUNCTION__);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Destination *destination = ((DestinationCell *)[tableView cellForRowAtIndexPath:indexPath]).destination;
    [self.manager saveMyDestination:destination];
}

#pragma mark - Info copy
- (NSString *)_info
{
    return @"This demo requires some setup to use your own CloudKit container, so please check out the README.ME before getting started.\n\nWhen ready, tap the button below. Follow the log information in your log window area and see MPC_CloudKitManager.m for detailed documentation of how it's working under the hood. \n\n1. Download the images.\n\n2. Click an image to save it to your personal saved images (which will also run a series of operations such as checking for your cloudkit, querying to see if you have the destination saved already, and saving it if you don't.";
}

@end
