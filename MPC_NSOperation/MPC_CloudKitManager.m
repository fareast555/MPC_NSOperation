//
//  MPC_CloudKitManager.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.

#import "MPC_CloudKitManager.h"
#import "Destination.h"
#import "MPC_CKDeleteRecordOperation.h"
#import "MPC_CKSaveRecordOperation.h"
#import "MPC_CKQueryOperation.h"
#import "MPC_CKAvailabilityCheckOperation.h"
#import "NSOperationQueue+MPC_NSOperationQueue.h"
@import CloudKit;

NSString * const kDatabaseInitialized = @"kDatabaseInitializedDefaultKey";
NSString * const kFirstDownloadOfDestinationsComplete = @"kFirstDownloadOfDestinationsCompleteKey";

@implementation MPC_CloudKitManager

#pragma mark - network spinner
- (void)_netWorkActivityIndicatorVisible:(BOOL)visible
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:visible];
}

#pragma mark - Public Save and Query methods

- (void)downloadDestinationsType:(DLType)destinationType
{
    //1. Create a predicate to get all records in public or private DB
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordCreatedDate < %@", [NSDate date]];

    //2. Create query op, specifying the destination type for public / private query
    MPC_CKQueryOperation *queryOp = [self _queryOpWithPredicate:predicate
                                                destinationType:destinationType];
    
    //3. Send ops for more complex packaging
    [self _prepCloudKitChainOperationWithOperations:@[queryOp]
                                    destinationType:destinationType];
}

- (void)saveMyDestination:(Destination *)destination
{
    //1. Create a CKRecord from instance method on destination object
    CKRecord *myDestination = [destination CKRecordFromDestination];
    
    //2. Save as an individual record
    [self _saveIndividualRecord:myDestination
                destinationType:DLTypeMyDestinations];
}

- (void)_saveIndividualRecord:(CKRecord *)record
              destinationType:(DLType)destinationType
{
    //1. Create a queryOp to check if the user already has this destination saved
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"UUID == %@", record[@"UUID"]];
    MPC_CKQueryOperation *op1Query = [self _queryOpWithPredicate:predicate
                                                 destinationType:destinationType];
    
    //2. Create a saveOp block to be used if query finds pre-existing record
    MPC_CKSaveRecordOperation *op3Save = [self _saveRecord:record
                                           destinationType:destinationType];
    
    //3. Create an adapter block between query and dave - if already saved, query will end.
    NSBlockOperation *op2Block = [self _adapterBlockBetweenOp1:op1Query
                                                           Op2:op3Save];
    
    //4. Prep ops and start operation
    [self _prepCloudKitChainOperationWithOperations:@[op1Query, op2Block, op3Save]
                                    destinationType:DLTypeMyDestinations];
}

- (void)deleteMyDestination:(Destination *)destination
{
    NSMutableArray *opsArray = [NSMutableArray new];
    
    CKRecordID *ID = [[CKRecordID alloc]initWithRecordName:destination.UUID];
    MPC_CKDeleteRecordOperation *op1Delete = [[MPC_CKDeleteRecordOperation alloc]initWithRecordID:ID
                                                                              usesPrivateDatabase:YES];
    
    [opsArray addObject:op1Delete];
    
    //1. Show Network spinner
    [self _netWorkActivityIndicatorVisible:YES];
    
    
    //3. All CK operations must first validate if CK is available.
    //Add the check for cloudkit op as array[0]
    [opsArray insertObject:[MPC_CKAvailabilityCheckOperation MPC_Operation] atIndex:0];
    
    //4. Add a clean up block to handle results
    NSBlockOperation *terminal = [self _deletionTerminalBlockWithDeletionOperation:op1Delete];
    
    [opsArray addObject:terminal];
    NSLog(@"Ops array now has %li ops", (long)opsArray.count);

    
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
                                  destinationType:(DLType)destinationType
{
    //1. Show Network spinner
    [self _netWorkActivityIndicatorVisible:YES];
    
    //2. Create a working copy
    NSMutableArray *ops = [operationsArray mutableCopy];
    
    //3. All CK operations must first validate if CK is available.
    //Add the check for cloudkit op as array[0]
    [ops insertObject:[MPC_CKAvailabilityCheckOperation MPC_Operation] atIndex:0];
    
    //4. Add a clean up block to handle results
    NSBlockOperation *terminal = [self _terminalBlockFollowingOp:[ops lastObject]
                                                 destinationType:destinationType];
    [ops addObject:terminal];
    
    //5. Create an NSOperation Queue
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //6. Call to NSOperationQueue (MPC_NSOperation) category to:
        //a. Add mini adapter blocks in cases where 2 MPC_NSOperations to not use adapter blocks (to pass forward variables)
        //b. Add dependencies
        //c. Add ops to the queue
    [queue addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:[ops copy]];
    
    //7. Operation chain is now in progress. Go make some popcorn and chill.
}



#pragma mark - MPC_NSOperations

- (MPC_CKQueryOperation *)_queryOpWithPredicate:(NSPredicate *)predicate
                                destinationType:(DLType)destinationType
{
    BOOL shouldUsePrivate = (destinationType == DLTypeMyDestinations) ? YES : NO;
    
   return  [[MPC_CKQueryOperation alloc] initWithCKRecordType:@"MPCDestination"
                                          usesPrivateDatabase:shouldUsePrivate
                                                    predicate:predicate
                                                  desiredKeys:nil
                                                 resultsLimit:60
                                    timeoutIntervalForRequest:40];
}

- (MPC_CKSaveRecordOperation *)_saveRecord:(CKRecord *)record
                           destinationType:(DLType)destinationType
{
    BOOL shouldUsePrivate = (destinationType == DLTypeMyDestinations) ? YES : NO;
    
    return [[MPC_CKSaveRecordOperation alloc]initWithRecord:record
                                        usesPrivateDatabase:shouldUsePrivate];
}

#pragma Mark - Adapter Blocks
//In this app, all intermediate adapters are between QueryOp -> SaveOp
- (NSBlockOperation *)_adapterBlockBetweenOp1:(MPC_NSOperation *)op1
                                          Op2:(MPC_NSOperation *)op2
{
    return [NSBlockOperation blockOperationWithBlock:^{
        
        //1.Pass forward state variables
        op2.error = op1.error;
        if (op1.isCancelled) [op2 cancel];
       
        //2. If a record is returned in query, user has it
        if (((MPC_CKQueryOperation *)op1).individualRecord) {
            //Cancel the subsequent operations
            [op2 cancel];
            
            //SaveOp was created with a CKRecord, so null that record
            ((MPC_CKSaveRecordOperation *)op2).record = nil;
            
            NSLog(@"Got a record returned in query, so will null and cancel");

        } else {
            NSLog(@"No record returned in query op (adapter block), so proceding to save");

        }
    }];
}

- (NSBlockOperation *)_terminalBlockFollowingOp:(MPC_NSOperation *)op
                                destinationType:(DLType)destinationType
{
    NSLog(@"Calling for a terminal block with destination type %@", (destinationType == DLTypeAllDestinations) ? @"ALL Ds" : @"MY Ds");

    
    __weak MPC_CloudKitManager *weakSelf = self;
    return [NSBlockOperation blockOperationWithBlock:^{
        
        if (op.error && op.isCancelled) {
            //This is a failed op.
            NSLog(@"OP FAILED. Cancelled, and error %@", op.error);
            
        }  else if (!op.error && op.isCancelled && [op isKindOfClass:[MPC_CKSaveRecordOperation class]]) {
            NSLog(@"Save Op was cancelled. User already had record");
            
        } else if ([op isKindOfClass:[MPC_CKSaveRecordOperation class]] && !op.isCancelled) {
            //Save op complete. Could alert user to a successful save
            NSLog(@"Save op Successful!! Hi-5!");
            
        } else if ([op isKindOfClass:[MPC_CKQueryOperation class]] && !op.isCancelled) {
            [weakSelf _updateDestinationWithRecords:((MPC_CKQueryOperation *)op).records
                                    destinationType:destinationType];
        } 
        
         [weakSelf _netWorkActivityIndicatorVisible:NO];
    }];
}

- (NSBlockOperation *)_deletionTerminalBlockWithDeletionOperation:(MPC_CKDeleteRecordOperation* )op
{
     __weak MPC_CloudKitManager *weakSelf = self;
    return [NSBlockOperation blockOperationWithBlock:^{
       
        if (op.deletedCKRecordID) {
            NSLog(@"Deletion was successful!");
        } else {
            NSLog(@"Deletion did fail with error");
        }
        
     [weakSelf _netWorkActivityIndicatorVisible:NO];
    }];
}

#pragma mark - UPDATE destinations
- (void)_updateDestinationWithRecords:(NSArray *)records
                      destinationType:(DLType)destinationType
{
    NSMutableArray *destinations = [NSMutableArray new];
    for (CKRecord *record in records) {
        Destination *destination = [[Destination alloc]initWithCKRecord:record];
        [destinations addObject:destination];
    }
    NSLog(@"UPDATE with records called...destination type %@", (destinationType == DLTypeAllDestinations) ? @"ALL Ds" : @"MY Ds");
        if (destinationType == DLTypeAllDestinations)
            [self _KVOUpdateAllDestinations:[destinations copy]];
        else
            [self _KVOupdateMyDestinations:[destinations copy]];
    
}

- (void)_KVOUpdateAllDestinations:(NSArray *)destinationsArray
{
    NSLog(@"Going to KVO ALL destinations with %li places", destinationsArray.count);
    if (destinationsArray.count < 1) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setValue:destinationsArray forKey:@"destinations"];
    });
}

- (void)_KVOupdateMyDestinations:(NSArray *)destinationsArray
{
     NSLog(@"Going to KVO MY destinations with %li places", destinationsArray.count);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setValue:destinationsArray forKey:@"MyDestinations"];
    });
}

#pragma mark - Cloudkit container Initialization
- (void)initializeDestinations
{

    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    NSMutableArray *ops = [NSMutableArray new];
    
    for (NSDictionary *place in [self destinationsArray]) {
        CKRecordID *ID = [[CKRecordID alloc]initWithRecordName:[[NSUUID UUID]UUIDString]];
        CKRecord *record = [[CKRecord alloc]initWithRecordType:@"MPCDestination" recordID:ID];
        record[@"destinationName"] = [place objectForKey:@"name"];
        NSData *imageData = UIImageJPEGRepresentation([place objectForKey:@"image"], 0.1);
        record[@"imageData"] = imageData;
        
        //Add custom ID fields to circumvent non-indexed meta deta for demo users
        record[@"recordCreatedDate"] = [NSDate date];
        record[@"UUID"] = ID.recordName;
        
        MPC_CKSaveRecordOperation *save = [self _saveRecord:record destinationType:DLTypeAllDestinations];
        [ops addObject:save];
    }
    //Add a final block
    [ops addObject:[self _finalInitBlockFollowingSaveOp:[ops lastObject]]];
    
    //Package and start
    [queue addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:ops];

}


- (NSArray *)destinationsArray
{
    NSMutableArray *placesArray = [NSMutableArray new];
    [placesArray addObject:@{@"name" : @"Angkor Wat, Cambodia",
                             @"image":[UIImage imageNamed:@"angkor.jpg"]}];
    
    [placesArray addObject:@{@"name" : @"Bagan, Myanmar",
                             @"image":[UIImage imageNamed:@"bagan.JPG"]}];
    
    [placesArray addObject:@{@"name" : @"British Columbia, Canada",
                             @"image":[UIImage imageNamed:@"bc.JPG"]}];
    
    [placesArray addObject:@{@"name" : @"Borobudur, Indondesia",
                             @"image":[UIImage imageNamed:@"borobudur.JPG"]}];
    
    [placesArray addObject:@{@"name" : @"Phraya Nakhon, Thailand",
                             @"image":[UIImage imageNamed:@"phrayanakhon.JPG"]}];
    
    [placesArray addObject:@{@"name" : @"Koh Samed, Thailand",
                             @"image":[UIImage imageNamed:@"samed.JPG"]}];
    
    [placesArray addObject:@{@"name" : @"Yangon, Myanmar",
                             @"image":[UIImage imageNamed:@"yangon.JPG"]}];
    
    return [placesArray copy];
}
    
    
- (NSBlockOperation *)_finalInitBlockFollowingSaveOp: (MPC_CKSaveRecordOperation *)saveOp
{
        return [NSBlockOperation blockOperationWithBlock:^{

            if (!saveOp.error && !saveOp.isCancelled) {
                //Inform the delegate save ops were successful
                [self _informDelegateOfInitializationSuccess:YES error:nil];
                
                //Set a global default of the initialized state
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kDatabaseInitialized];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
            //Else. Inform delegate of abject failure and disappointing their parents
            } else
                [self _informDelegateOfInitializationSuccess:NO error:saveOp.error];
    }];
}

- (void)_informDelegateOfInitializationSuccess:(BOOL)success error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
             [self.delegate databaseInitializationDidSucceeedInMPC_CloudKitManager:self];
        } else
        [self.delegate databaseInitializationDidFailWithError:error inMPC_CloudKitManager:self];
    });
}


@end
