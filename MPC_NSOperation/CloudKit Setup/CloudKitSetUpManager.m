//
//  CloudKitSetUpManager.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/21.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "CloudKitSetUpManager.h"
#import "Constants.h"
#import "MPC_CKAvailabilityCheckOperation.h"
#import "MPC_CKQueryOperation.h"
#import "MPC_CKSaveRecordOperation.h"
#import "NSOperationQueue+MPC_NSOperationQueue.h"
@import CloudKit;
@import UIKit;

@implementation CloudKitSetUpManager

#pragma mark - Cloudkit container Initialization
- (void)initializeDestinations
{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    NSMutableArray *ops = [NSMutableArray new];
    MPC_CKAvailabilityCheckOperation *checkop = [MPC_CKAvailabilityCheckOperation MPC_Operation];
    [ops addObject:checkop];
    
    //Check via query if the database is already established (if records already exist)
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordCreatedDate < %@", [NSDate date]];
    MPC_CKQueryOperation *query = [[MPC_CKQueryOperation alloc]initWithCKRecordType:@"MPCDestination"
                                                                usesPrivateDatabase:NO
                                                                          predicate:predicate
                                                                        desiredKeys:nil
                                                                       resultsLimit:10
                                                          timeoutIntervalForRequest:15];
    
     [ops addObject:query];


    NSArray *destinations = [self destinationsArray];
    
    for (NSDictionary *place in destinations) {
        
        //Create a new CKRecord
        CKRecordID *ID = [[CKRecordID alloc]initWithRecordName:[[NSUUID UUID]UUIDString]];
        CKRecord *record = [[CKRecord alloc]initWithRecordType:@"MPCDestination" recordID:ID];
        
        //Populate record fields
        record[@"destinationName"] = [place objectForKey:@"name"];
        NSData *imageData = UIImageJPEGRepresentation([place objectForKey:@"image"], 0.1);
        record[@"imageData"] = imageData;
        
        //Add custom ID fields to circumvent non-indexed meta deta for demo users
        record[@"recordCreatedDate"] = [NSDate date];
        record[@"UUID"] = ID.recordName;
        
        MPC_CKSaveRecordOperation *save = [[MPC_CKSaveRecordOperation alloc]initWithRecord:record
                                                                       usesPrivateDatabase:NO];
        
        //If this is the first save op, add an adapter between the query and save to create checking logic.
        //We need to test if there is data, and allow for a query error, which will happen if the database
        //is not yet established.
        if (place == [destinations firstObject])
            [ops addObject:[self adapterBetweenQueryOp:query saveOp:save]];
        
        //Add new save operations
        [ops addObject:save];
       
    }
    //Add a final logic block to process results of queue
    [ops addObject:[self _finalInitBlockFollowingSaveOp:[ops lastObject]]];
    
    //Package and start
    [queue addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:ops];
}

- (NSBlockOperation *)adapterBetweenQueryOp:(MPC_CKQueryOperation *)queryOp saveOp:(MPC_CKSaveRecordOperation *)saveOp
{
    return [NSBlockOperation blockOperationWithBlock:^{
        //If records already exist (database is already initialized), cancel process
        if (queryOp.records)
            [saveOp cancel];
    }];
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

        //If no error, we have either saved records, or they were already saved and save op was cancelled
        if (!saveOp.error) {
            //Inform the delegate save ops were successful
            [self _informDelegateOfInitializationSuccess:YES error:nil];
            
            //Set a global default of the initialized state
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kDatabaseInitialized];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            //Else. Inform delegate of its abject failure and disappointing its parents
        } else if (saveOp.error)
            [self _informDelegateOfInitializationSuccess:NO error:saveOp.error];
    }];
}

- (void)_informDelegateOfInitializationSuccess:(BOOL)success error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            [self.delegate databaseInitializationDidSucceeedInMPC_CloudKitManager:self];
        } else
            [self.delegate databaseInitializationDidFailWithError:error CloudKitSetUpManager:self];
    });
}

@end
