//
//  ViewController.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "MyDestinationsViewController.h"
#import "MPC_CloudKitManager.h"
#import "DestinationsDataSource.h"
#import "DestinationCell.h"
#import "Destination.h"

@interface MyDestinationsViewController ()<UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *placeholder;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MPC_CloudKitManager *manager;
@property (strong, nonatomic) DestinationsDataSource *dataSource;
@property (strong, nonatomic) NSArray *destinations;


@end

@implementation MyDestinationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.destinations = [NSArray new];
    self.manager = [[MPC_CloudKitManager alloc]init];
    self.dataSource = [[DestinationsDataSource alloc]initWithDataArray:self.destinations
                                                              editable:YES];
    
    [self _configureTableView];
    [self _tableViewShouldHide];
    [self _registerNibs];
    [self _configureKVO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.manager downloadDestinationsType:DLTypeMyDestinations];
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

#pragma mark - Info copy
- (NSString *)_info
{
    return @"Querying the server now to see if you have added any destinations.\n\nIf not, tap + and click on a destination to add it.";
}

@end
