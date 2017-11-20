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
@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation DestinationsViewController

- (void)viewDidLoad {
    NSLog(@"%s called", __FUNCTION__);
    [super viewDidLoad];
    self.defaults = [NSUserDefaults standardUserDefaults];

    [self _configureDataObjects];
    [self _configureUI];

    [self _configureTableView];
    [self _tableViewShouldHide];
    [self _registerNibs];
    [self _configureKVO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //If this is not the first run, call for data
    if ([self.defaults boolForKey:kFirstDownloadOfDestinationsComplete]) {
        [self downloadDestinations:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self _removeKVOObserving];
}

- (void)_configureDataObjects
{
    self.destinations = [NSArray new];
    self.manager = [[MPC_CloudKitManager alloc]init];
    self.dataSource = [[DestinationsDataSource alloc]initWithDataArray:self.destinations
                                                              editable:NO];
}

- (void)_configureUI
{
    BOOL firsDownloadComplete = [self.defaults boolForKey:kFirstDownloadOfDestinationsComplete];
    NSLog(@" First run shows as %@  ", firsDownloadComplete ? @"YES": @"NO");
    self.infoView.text = [self _infoViewTextForFirstRun:firsDownloadComplete];
    self.downloadButton.hidden = firsDownloadComplete;
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
        [self _updateUserDefaults];
        [self _updateDataSourceWithDestinations:[self.destinations copy]];
        [self _tableViewShouldHide];
        [self _reload];
    }
}

- (void)_updateDataSourceWithDestinations:(NSArray *)destinations
{
    self.dataSource.destinations = destinations;
}

- (void)_updateUserDefaults
{
    [self.defaults setBool:YES forKey:kFirstDownloadOfDestinationsComplete];
    [self.defaults synchronize];
}

- (void)_reload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (IBAction)downloadDestinations:(id)sender
{
    self.downloadButton.enabled = NO;
    [self.manager downloadDestinationsType:DLTypeAllDestinations];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Destination *destination = ((DestinationCell *)[tableView cellForRowAtIndexPath:indexPath]).destination;
    [self.manager saveMyDestination:destination];
}

#pragma mark - Info copy
- (NSString *)_infoViewTextForFirstRun:(BOOL)firstDownloadWasCompleted
{
    return [NSString stringWithFormat:@"%@Tap destinations to add them to your private cloudkit container.%@", firstDownloadWasCompleted ? @"Downloading public destinations...\n\n" : @"", firstDownloadWasCompleted ? @"" :@"\n\nWhen you dismiss this view, your saved destinations will be pulled from the server (ie, none of these are stored locally)."];
}

@end
