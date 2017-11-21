//
//  CloudKitSetUpManager.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/21.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "CloudKitSetUpManager.h"
#import "Constants.h"
#import "MPC_CKSaveRecordOperation.h"
#import "MPC_CKAvailabilityCheckOperation.h"
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
    
    for (NSDictionary *place in [self destinationsArray]) {
        CKRecordID *ID = [[CKRecordID alloc]initWithRecordName:[[NSUUID UUID]UUIDString]];
        CKRecord *record = [[CKRecord alloc]initWithRecordType:@"MPCDestination" recordID:ID];
        record[@"destinationName"] = [place objectForKey:@"name"];
        NSData *imageData = UIImageJPEGRepresentation([place objectForKey:@"image"], 0.1);
        record[@"imageData"] = imageData;
        
        //Add custom ID fields to circumvent non-indexed meta deta for demo users
        record[@"recordCreatedDate"] = [NSDate date];
        record[@"UUID"] = ID.recordName;
        
        MPC_CKSaveRecordOperation *save = [[MPC_CKSaveRecordOperation alloc]initWithRecord:record
                                                                       usesPrivateDatabase:NO];
        
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
            [self.delegate databaseInitializationDidFailWithError:error CloudKitSetUpManager:self];
    });
}

@end
