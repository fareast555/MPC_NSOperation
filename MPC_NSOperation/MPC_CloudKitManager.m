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
#import "UIApplication+networkActivitySpinner.h"
@import CloudKit;

@implementation MPC_CloudKitManager

#pragma mark - Query Operation of Records (Public & Private)
- (void)downloadDestinationsType:(DestinationType)destinationType
{
//*****************
  //**For CloudKit, you should usually use the "creationDate" key for queries, which is a meta info key
  //on all CKRecords. The key used below is used only for this demo to avoid the issue of CloudKit
  //initializing all containers with meta information fields set by default to non-indexable, which would
  //break this demo. (You have to change this manually by going into your CloudKit Dashboard).
//*****************
    
    NSLog(@"\n\nMPC_CloudKitManager is now...\n1. Creating a query op to download destinations and \n2. Creating a clean-up block to call at the end of the operation.");

    //1. Create a predicate to get all records
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordCreatedDate < %@", [NSDate date]];

    //2. Ask convenience method to create query op, specifying the destination type (== public/private query)
    MPC_CKQueryOperation *queryOp = [self _queryOpWithPredicate:predicate
                                                destinationType:destinationType];
    
    //3. Call to the MPC_CloudkitManager+TerminalBlocks category to create a terminal block to deal with results
    NSBlockOperation *terminal = [self _terminalBlockForBatchQuery:queryOp
                                                   destinationType:destinationType];
    
    //4. Call to convenience method to package ops and start operations
     //** --> Operations must be packaged IN ORDER OF EXPECTED EXECUTION <-- **
    [self _prepCloudKitChainOperationWithOperations:@[queryOp, terminal]
                                    destinationType:destinationType];
}


#pragma mark - Saving Private Records (The movie!)
//*****************
//In this app, saving is only to the user's private container
//*****************

- (void)saveMyDestination:(Destination *)destination
{
    NSLog(@"\n\nMPC_CloudKitManager is now...\n1. Creating a query op to see if you already saved this destination and\n2. Creating a save op, and adapter block to save the destination if necessary and\n3. Creating a clean-up block to call at the end of the operation.");
    
    //1. Create a CKRecord from instance method on destination object
    CKRecord *myDestinationRecord = [destination CKRecordFromDestination];
    
    //2. Ask convenience method to create a queryOp to check if the user already has this destination saved
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"UUID == %@", myDestinationRecord[@"UUID"]];
    MPC_CKQueryOperation *op1Query = [self _queryOpWithPredicate:predicate
                                                 destinationType:DestinationTypeMyDestinations];
    
    //3. Create a saveOp block to be used if query finds pre-existing record
    MPC_CKSaveRecordOperation *op3Save =  [[MPC_CKSaveRecordOperation alloc]initWithRecord:myDestinationRecord
                                                                       usesPrivateDatabase:YES];
    
    //4. Create an adapter block between query and save - if already saved, query will end.
    MPC_Block *op2Block = [MPC_Block adapterBlockBetweenQueryOp:op1Query
                                                  saveOperation:op3Save
                                      cancelsSaveIfRecordExists:YES];
    
    //5. Call to the MPC_CloudkitManager+TerminalBlocks category to create a block to deal with save results
    NSBlockOperation *terminal = [self _terminalBlockForSaveMyDestination:op3Save];
    
    //6. Call to convenience method to package ops and start operations
     //** --> Operations must be packaged IN ORDER OF EXPECTED EXECUTION <-- **
    [self _prepCloudKitChainOperationWithOperations:@[op1Query, op2Block, op3Save, terminal]
                                    destinationType:DestinationTypeMyDestinations];
}

#pragma mark - Deleting Private Records

- (void)deleteMyDestination:(Destination *)destination
{
    
    NSLog(@"\n\nMPC_CloudKitManager is now...\n1. Creating a deletion operation to delete the destination and\n2. Creating a clean-up block to call at the end of the operation.");
    
    //1. Create a record ID using the UUID string property of the Destination object
    CKRecordID *ID = [[CKRecordID alloc]initWithRecordName:destination.UUID];
    
    //2. Create a delete operation for the private database
    MPC_CKDeleteRecordOperation *op1Delete = [[MPC_CKDeleteRecordOperation alloc]initWithRecordID:ID
                                                                              usesPrivateDatabase:YES];
    
    //3. Call to the MPC_CloudkitManager+TerminalBlocks category to handle deletion results
    NSBlockOperation *terminal = [self _terminalBlockForDeleteMyDestination:op1Delete];
    
    //4. Call to convenience method to package ops and start operations
    //** --> Operations must be packaged IN ORDER OF EXPECTED EXECUTION <-- **
    [self _prepCloudKitChainOperationWithOperations:@[op1Delete, terminal]
                                    destinationType:DestinationTypeMyDestinations];
    
}

#pragma mark - Packaging ops into a queryOp
- (void)_prepCloudKitChainOperationWithOperations:(NSArray *)operationsArray
                                  destinationType:(DestinationType)destinationType
{
     NSLog(@"\n\nMPC_CloudKitManager is now...\n1. Adding a MPC_CKAvailabilityOperation to the start of your operation chain to make sure you have CloudKit availability.");
    //1. Show Network spinner via UIApplication category
    [UIApplication startNetworkActivityIndicator];
    
    //2. Create a mutable working copy
    NSMutableArray *ops = [operationsArray mutableCopy];
    
    //3. All CK operations must first validate if CK is available.
    //Add the check for cloudkit op as array[0]
    [ops insertObject:[MPC_CKAvailabilityCheckOperation MPC_Operation] atIndex:0];
    
    //4. Create an NSOperation Queue
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //5. Call to NSOperationQueue (MPC_NSOperation) category to:
        //a. Add mini adapter blocks in cases where 2 MPC_NSOperations to not use adapter blocks (to pass forward variables)
        //b. Add dependencies
        //c. Add ops to the queue
    [queue addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:[ops copy]];
    
    //6. Operation chain is now in progress. Go make some popcorn and chill.
}

#pragma mark - MPC_NSQueryOperation Convenience constructor

- (MPC_CKQueryOperation *)_queryOpWithPredicate:(NSPredicate *)predicate
                                destinationType:(DestinationType)destinationType
{
    //Translate app-specific enum into a bool
    BOOL shouldUsePrivate = (destinationType == DestinationTypeMyDestinations) ? YES : NO;
    
    return  [[MPC_CKQueryOperation alloc] initWithCKRecordType:@"MPCDestination"
                                           usesPrivateDatabase:shouldUsePrivate
                                                     predicate:predicate
                                                   desiredKeys:nil //Nil == return all object properties
                                                  resultsLimit:60
                                     timeoutIntervalForRequest:40];
}

@end
