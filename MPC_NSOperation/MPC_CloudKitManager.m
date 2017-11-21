//
//  MPC_CloudKitManager.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.

#import "MPC_CloudKitManager.h"
#import "Destination.h"
#import "MPC_Block.h"
#import "MPC_CKAvailabilityCheckOperation.h"
#import "MPC_CKQueryOperation.h"
#import "MPC_CKSaveRecordOperation.h"
#import "MPC_CKDeleteRecordOperation.h"
#import "NSOperationQueue+MPC_NSOperationQueue.h"
#import "MPC_CloudKitManager+TerminalBlocks.h"
@import CloudKit;

@implementation MPC_CloudKitManager

#pragma mark - network spinner
- (void)_netWorkActivityIndicatorVisible:(BOOL)visible
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:visible];
}

#pragma mark - KVO Properties
- (void)_KVOUpdateAllDestinations:(NSArray *)destinationsArray
{
    if (destinationsArray.count < 1) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self setValue:destinationsArray forKey:@"destinations"];
    });
}

- (void)_KVOupdateMyDestinations:(NSArray *)destinationsArray
{
    if (destinationsArray.count < 1) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setValue:destinationsArray forKey:@"myDestinations"];
    });
}

#pragma mark - Query Records/Public & Private
- (void)downloadDestinationsType:(DestinationType)destinationType
{
    //1. Create a predicate to get all records
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordCreatedDate < %@", [NSDate date]];

    //2. Create query op, specifying the destination type for public / private query
    MPC_CKQueryOperation *queryOp = [self _queryOpWithPredicate:predicate
                                                destinationType:destinationType];
    
    //3. Create a terminal block to deal with results VIA MPC_CloudkitManager+TerminalBlocks category
    NSBlockOperation *terminal = [self _terminalBlockForBatchQuery:queryOp destinationType:destinationType];
    
    //3. Package ops to start operations
    [self _prepCloudKitChainOperationWithOperations:@[queryOp, terminal]
                                    destinationType:destinationType];
}

#pragma mark - UPDATE destinations with batch query results
- (void)_updateDestinationWithRecords:(NSArray *)records
                      destinationType:(DestinationType)destinationType
{
    NSMutableArray *destinations = [NSMutableArray new];
    for (CKRecord *record in records) {
        Destination *destination = [[Destination alloc]initWithCKRecord:record];
        [destinations addObject:destination];
    }
    
    if (destinationType == DestinationTypeAllDestinations)
        [self _KVOUpdateAllDestinations:[destinations copy]];
    else
        [self _KVOupdateMyDestinations:[destinations copy]];
}


#pragma mark - Saving Private Records
- (void)saveMyDestination:(Destination *)destination
{
    //1. Create a CKRecord from instance method on destination object
    CKRecord *myDestination = [destination CKRecordFromDestination];
    
    //2. Save as an individual record
    [self _saveIndividualRecord:myDestination
                destinationType:DestinationTypeMyDestinations];
}

- (void)_saveIndividualRecord:(CKRecord *)record
              destinationType:(DestinationType)destinationType
{
    //1. Create a queryOp to check if the user already has this destination saved
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"UUID == %@", record[@"UUID"]];
    MPC_CKQueryOperation *op1Query = [self _queryOpWithPredicate:predicate
                                                 destinationType:destinationType];
    
    //2. Create a saveOp block to be used if query finds pre-existing record
    BOOL shouldUsePrivate = (destinationType == DestinationTypeAllDestinations) ? NO : YES;
    MPC_CKSaveRecordOperation *op3Save =  [[MPC_CKSaveRecordOperation alloc]initWithRecord:record
                                                                       usesPrivateDatabase:shouldUsePrivate];
    
    //3. Create an adapter block between query and dave - if already saved, query will end.
    MPC_Block *op2Block = [MPC_Block adapterBlockBetweenQueryOp:op1Query
                                                  saveOperation:op3Save
                                      cancelsSaveIfRecordExists:YES];
    
    //4. Terminal block to deal with save results, VIA MPC_CloudkitManager+TerminalBlocks category
    NSBlockOperation *terminal = [self _terminalBlockForSaveMyDestination:op3Save];
    
    //5. Package ops and start operation
    [self _prepCloudKitChainOperationWithOperations:@[op1Query, op2Block, op3Save, terminal]
                                    destinationType:DestinationTypeMyDestinations];
}

#pragma mark - Deleting Private Records

- (void)deleteMyDestination:(Destination *)destination
{
    NSMutableArray *opsArray = [NSMutableArray new];
    
    CKRecordID *ID = [[CKRecordID alloc]initWithRecordName:destination.UUID];
    MPC_CKDeleteRecordOperation *op1Delete = [[MPC_CKDeleteRecordOperation alloc]initWithRecordID:ID usesPrivateDatabase:YES];
    
    [opsArray addObject:op1Delete];
    
    //1. Show Network spinner
    [self _netWorkActivityIndicatorVisible:YES];
    
    
    //3. All CK operations must first validate if CK is available.
    //Add the check for cloudkit op as array[0]
    [opsArray insertObject:[MPC_CKAvailabilityCheckOperation MPC_Operation] atIndex:0];
    
    //4. Add a clean up block to handle results
    NSBlockOperation *terminal = [self _terminalBlockForDeleteMyDestination:op1Delete];
    
    //Add to array
    [opsArray addObject:terminal];
    
    //5. Create an NSOperation Queue
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //6. Call to NSOperationQueue (MPC_NSOperation) category to:
    //a. Add mini adapter blocks in cases where 2 MPC_NSOperations to not use adapter blocks (to pass forward variables)
    //b. Add dependencies
    //c. Add ops to the queue
    [queue addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:[opsArray copy]];
    
    //7. Operation chain is now in progress. Go make some popcorn and chill.
}

#pragma mark - Packaging ops into a queryOp
- (void)_prepCloudKitChainOperationWithOperations:(NSArray *)operationsArray
                                  destinationType:(DestinationType)destinationType
{
    //1. Show Network spinner
    [self _netWorkActivityIndicatorVisible:YES];
    
    //2. Create a working copy
    NSMutableArray *ops = [operationsArray mutableCopy];
    
    //3. All CK operations must first validate if CK is available.
    //Add the check for cloudkit op as array[0]
    [ops insertObject:[MPC_CKAvailabilityCheckOperation MPC_Operation] atIndex:0];
    
    //4. Create an NSOperation Queue
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //6. Call to NSOperationQueue (MPC_NSOperation) category to:
        //a. Add mini adapter blocks in cases where 2 MPC_NSOperations to not use adapter blocks (to pass forward variables)
        //b. Add dependencies
        //c. Add ops to the queue
    [queue addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:[ops copy]];
    
    //7. Operation chain is now in progress. Go make some popcorn and chill.
}

#pragma mark - MPC_NSOperations Convenience constructors

- (MPC_CKQueryOperation *)_queryOpWithPredicate:(NSPredicate *)predicate
                                destinationType:(DestinationType)destinationType
{
    BOOL shouldUsePrivate = (destinationType == DestinationTypeMyDestinations) ? YES : NO;
    
   return  [[MPC_CKQueryOperation alloc] initWithCKRecordType:@"MPCDestination"
                                          usesPrivateDatabase:shouldUsePrivate
                                                    predicate:predicate
                                                  desiredKeys:nil
                                                 resultsLimit:60
                                    timeoutIntervalForRequest:40];
}


#pragma mark - MPC_CloudKitManager Delegate
- (void)_informDelegateOfSaveSuccess:(BOOL)success previouslySaved:(BOOL)previouslySaved error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate saveDestinationSaved:success destinationPreviouslySaved:previouslySaved error:error MPC_CloudKitManager:self];
    });
}

@end
