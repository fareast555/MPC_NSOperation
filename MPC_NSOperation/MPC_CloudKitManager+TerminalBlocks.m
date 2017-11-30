//
//  MPC_CloudKitManager+TerminalBlocks.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/22.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "MPC_CloudKitManager+TerminalBlocks.h"
#import "MPC_CKSaveRecordOperation.h"
#import "MPC_CKQueryOperation.h"
#import "MPC_CKDeleteRecordOperation.h"
#import "UIApplication+networkActivitySpinner.h"
#import "Destination.h"

@implementation MPC_CloudKitManager (TerminalBlocks)

#pragma mark - Query Operation Terminal Block
- (NSBlockOperation *)_terminalBlockForBatchQuery:(MPC_CKQueryOperation *)queryOp
                                  destinationType:(DestinationType)destinationType
{
    //1. Create a weak version of self to avoid retain cycles
    __weak MPC_CloudKitManager *weakSelf = self;
    
    //2. Create and return an NSBlockOperation
    return [NSBlockOperation blockOperationWithBlock:^{
        
        //3. For the query, either an error or cancellation == failure
        if (queryOp.error || queryOp.isCancelled) {
            NSLog(@"\n\nOP FAILED. Cancelled, and error %@", queryOp.error);
            
        }  else if  (queryOp.records) {
            //4. Call to updater logic method to return results via KVO
            [weakSelf _updateDestinationWithRecords:((MPC_CKQueryOperation *)queryOp).records
                                    destinationType:destinationType];
        }
        
        //5. Hide Network spinner via UIApplication category
        [UIApplication stopNetworkActivityIndicator];

    }];
}

#pragma mark - Save Operation Terminal Block
- (NSBlockOperation *)_terminalBlockForSaveMyDestination:(MPC_CKSaveRecordOperation *)saveOp
{
    //1. Create a weak version of self to avoid retain cycles
    __weak MPC_CloudKitManager *weakSelf = self;
    
     //2. Create and return an NSBlockOperation
    return [NSBlockOperation blockOperationWithBlock:^{
        
        //3. For the save op, an error AND a cancellation == failure
        if (saveOp.error && saveOp.isCancelled) {
            
            //4. Update the delegate of failure
            [weakSelf _informDelegateOfSaveSuccess:NO previouslySaved:NO error:saveOp.error];
            
            NSLog(@"\n\nMPC_CloudKitManager+TerminalBlocks: Your save op failed with error %@.", saveOp.error);
            
        //5. NO error AND a cancelled op == intentional abort due to user already having destination
        }  else if (!saveOp.error && saveOp.isCancelled) {
            
            //6. Update the delegate that s/he already has the destination
            [weakSelf _informDelegateOfSaveSuccess:NO previouslySaved:YES error:nil];
        
        //7. A returned record AND no cancellation == Success. Yeah!
        } else if (saveOp.savedCKRecord && !saveOp.isCancelled) {
            NSLog(@"\n\nMPC_CloudKitManager+TerminalBlocks: Save op successful!! Hi-5!");
            
            //8. Update the delegate of save success
            [weakSelf _informDelegateOfSaveSuccess:YES previouslySaved:NO error:nil];
            
        }
        
        //9. Hide Network spinner via UIApplication category
        [UIApplication stopNetworkActivityIndicator];
    }];
}

#pragma mark - Delete Operation Terminal Block
- (NSBlockOperation *)_terminalBlockForDeleteMyDestination:(MPC_CKDeleteRecordOperation* )deleteOp
{
    
    return [NSBlockOperation blockOperationWithBlock:^{
        
        if (deleteOp.deletedCKRecordID) {
            NSLog(@"\n\nMPC_CloudKitManager+TerminalBlocks: Destination deletion was successful!");
        } else {
            NSLog(@"\n\nMPC_CloudKitManager+TerminalBlocks. Destination deletion failed. %@", deleteOp.error);
        }
        
        //5. Hide Network spinner via UIApplication category
        [UIApplication stopNetworkActivityIndicator];
    }];
}

#pragma mark - App updater for QUERY destinations
//*****************
//Receives the results of a batch query and sorts them to public properties that are KVO
//observable based on if they are from the public or private database
//*****************

- (void)_updateDestinationWithRecords:(NSArray *)records
                      destinationType:(DestinationType)destinationType
{
    //1. Create a holder array
    NSMutableArray *destinationRecords = [NSMutableArray new];
    
    //2. Iterate through the downloaded records
    for (CKRecord *record in records) {
        
        //3. For each record, initialize a new destination object
        Destination *destination = [[Destination alloc]initWithCKRecord:record];
        
        //4. Add the new destination object to the holder array
        [destinationRecords addObject:destination];
    }
    
    //5. Update the applicable KVO observable property to inform other classed to update
    if (destinationType == DestinationTypeAllDestinations)
        [self _KVOUpdateAllDestinations:[destinationRecords copy]];
    else
        [self _KVOupdateMyDestinations:[destinationRecords copy]];
}

#pragma mark - KVO Properties
- (void)_KVOUpdateAllDestinations:(NSArray *)destinationsArray
{
    if (destinationsArray.count < 1) return;
    NSLog(@"\n\nMPC_CloudKitManager+TerminalBlocks: Informing the app via KVO that the query found some publicly available destinations");
    
    //Get main thread before sending to a class that will update view state
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setValue:destinationsArray forKey:@"destinations"];
    });
}

- (void)_KVOupdateMyDestinations:(NSArray *)destinationsArray
{
    if (destinationsArray.count < 1) return;
    
    NSLog(@"\n\nMPC_CloudKitManager+TerminalBlocks: Informing the app via KVO that the query found the destinations you saved to your private CloudKit container");
    
    //Get main thread before sending to a class that will update view state
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setValue:destinationsArray forKey:@"myDestinations"];
    });
}


#pragma mark - MPC_CloudKitManager Delegate
- (void)_informDelegateOfSaveSuccess:(BOOL)success
                     previouslySaved:(BOOL)previouslySaved
                               error:(NSError *)error
{
    //Inform the delegate of save success on main queue to sync with view-state updating classes
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate saveDestinationSaved:success
                 destinationPreviouslySaved:previouslySaved
                                      error:error
                        MPC_CloudKitManager:self];
    });
}


@end
