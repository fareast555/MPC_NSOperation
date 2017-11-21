//
//  DestinationsDataSource.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/19.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "DestinationsDataSource.h"
#import "MPC_CloudKitManager.h"
#import "Destination.h"
#import "DestinationCell.h"

@interface DestinationsDataSource()
@property (assign, nonatomic) BOOL editable;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) MPC_CloudKitManager *manager;

//Short term animation values
@property (strong, nonatomic) NSString *destinationUUID;
@property (assign, nonatomic) CGRect cellBounds;
@end

@implementation DestinationsDataSource

- (instancetype)initWithDataArray:(NSArray<Destination *> *)dataArray
                         editable:(BOOL)editable
{
    if ((self = [super init])) {
        _dataArray = [dataArray mutableCopy];
        _editable = editable;
        _manager = [[MPC_CloudKitManager alloc]init];
    }
    return self;
}

- (void)setDestinations:(NSArray<Destination *> *)destinations
{
    _dataArray = [destinations mutableCopy];
}

#pragma mark - Animation
- (void)cellWasTappedWithDestinationUUID:(NSString *)UUID bounds:(CGRect)bounds sizeShouldIncrease:(BOOL)increase
{
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DestinationCell *cell = [tableView dequeueReusableCellWithIdentifier:[DestinationCell reuseID] forIndexPath:indexPath];
    cell.destination = self.dataArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editable && editingStyle == UITableViewCellEditingStyleDelete) {
        
        Destination *destination = [self.dataArray objectAtIndex:indexPath.row];
        [self.manager deleteMyDestination:destination];
        
        [self.dataArray removeObjectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}


@end
