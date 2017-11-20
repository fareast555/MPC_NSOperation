//
//  AllDestinationsViewController.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/20.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "AllDestinationsViewController.h"
#import "MPC_CloudKitManager.h"
#import "DestinationsDataSource.h"
#import "DestinationCell.h"
#import "Destination.h"

@interface AllDestinationsViewController ()<UITableViewDelegate>

//IB Outlets
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UITextView *infoView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//Global properties
@property (strong, nonatomic) MPC_CloudKitManager *manager;
@property (strong, nonatomic) DestinationsDataSource *dataSource;
@property (strong, nonatomic) NSArray *destinations;
@property (strong, nonatomic) NSUserDefaults *defaults;
@end

@implementation AllDestinationsViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    [self _configureDataObjects];
    [self _configureUI];
    [self _configureNavigationBar];
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
    
     [self.view layoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self _removeKVOObserving];
}

- (void)_configureDataObjects
{
    //1. Create an array to hold local destination objects
    self.destinations = [NSArray new];
    
    //2. Create an instance of the CloudKit manager
    self.manager = [[MPC_CloudKitManager alloc]init];
    
    //3. Create an instance of the dedicated data source
    self.dataSource = [[DestinationsDataSource alloc]initWithDataArray:self.destinations
                                                              editable:NO];
    //4. Point the table view to this data source
    self.tableView.dataSource = self.dataSource;
}

- (void)_configureUI
{
    //1. Is this the user's first run? Recover from defaults
    BOOL firsDownloadComplete = [self.defaults boolForKey:kFirstDownloadOfDestinationsComplete];
  
    //2. Set the information text
    self.infoView.text = [self _infoViewTextForFirstRun:firsDownloadComplete];
    
    //3. Hide the configure CloudKit start button if not the first app run
    self.downloadButton.hidden = firsDownloadComplete;
    
}

- (void)_configureTableView
{
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)_configureNavigationBar
{
    //1. Set title
    self.title = @"Destinations";
    
    //2. Set tint colours
    [self.navigationController.navigationBar setBarTintColor:[self _lightBlue]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //3. Set title color
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    //4. Set 'Done' button
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_dismissView:)];
    [self.navigationItem setRightBarButtonItem:cancel];
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

- (void)_dismissView:(id)sender
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
        
        //1. Recover array
        self.destinations = [change objectForKey:@"new"];
        
        //2. Set the default that user has done at least one download
        [self _updateUserDefaults];
        
        //3. Forward latest objects to dedicated dataSource object
        [self _updateDataSourceWithDestinations:[self.destinations copy]];
        
        //4. Check if table view should hide (due to now destinations)
        [self _tableViewShouldHide];
        
        //5. Rock and roll!
        [self _reload];
    }
}

- (void)_updateDataSourceWithDestinations:(NSArray *)destinations
{
    //Forward latest objects to dedicated dataSource object
    self.dataSource.destinations = destinations;
}

- (void)_updateUserDefaults
{
    //Set the default that user has done at least one download
    [self.defaults setBool:YES forKey:kFirstDownloadOfDestinationsComplete];
    [self.defaults synchronize];
}

- (void)_reload
{
    //Grab the main thread before reloading
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (IBAction)downloadDestinations:(id)sender
{
    //1. If received from the once-only button click, disable the button
    self.downloadButton.enabled = NO;
    
    //2. Call to begin download process
    [self.manager downloadDestinationsType:DLTypeAllDestinations];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1. Deselect the cell that was tapped
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //2. Get a reference to the destination tapped via the cell tapped at the indexPath
    Destination *destination = ((DestinationCell *)[tableView cellForRowAtIndexPath:indexPath]).destination;
    
    //3. Call to save the destination in background
    [self.manager saveMyDestination:destination];
}

#pragma mark - Values
- (NSString *)_infoViewTextForFirstRun:(BOOL)firstDownloadWasCompleted
{
    return [NSString stringWithFormat:@"%@Tap destinations to add them to your private cloudkit container.%@", firstDownloadWasCompleted ? @"Downloading public destinations...\n\n" : @"", firstDownloadWasCompleted ? @"" :@"\n\nWhen you dismiss this view, your saved destinations will be pulled from the server (ie, none of these are stored locally)."];
}

- (UIColor *)_lightBlue
{
    return [UIColor colorWithRed:0.25 green:0.478 blue:1.0 alpha:1.0];
}

@end
