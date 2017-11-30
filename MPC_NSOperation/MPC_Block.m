//
//  MPC_Block.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/21.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "MPC_Block.h"
#import "MPC_CKDeleteRecordOperation.h"
#import "MPC_CKSaveRecordOperation.h"
#import "MPC_CKQueryOperation.h"
#import "MPC_CKAvailabilityCheckOperation.h"
#import "NSOperationQueue+MPC_NSOperationQueue.h"
@import CloudKit;
@import UIKit;

@interface MPC_Block()

@end

@implementation MPC_Block

+ (MPC_Block *)adapterBlockBetweenQueryOp:(MPC_CKQueryOperation *)operation1Query
                            saveOperation:(MPC_CKSaveRecordOperation *)operation2Save
                cancelsSaveIfRecordExists:(BOOL)cancelsSaveIfRecordExists
{
    return [[self class]blockOperationWithBlock:^{
        
        //1.Pass forward state variables
        operation2Save.error = operation1Query.error;
        if (operation1Query.isCancelled) [operation2Save cancel];
        
        //2. If a record is returned in query, user has it
        if (((MPC_CKQueryOperation *)operation1Query).individualRecord && cancelsSaveIfRecordExists) {
            
            NSLog(@"\n\nMPC_Block: The query operation found a previously-existing record. So the entire save operation is being cancelled.");

            //Cancel the subsequent operations
            [operation2Save cancel];
            
            //SaveOp was created with a CKRecord, so null that record
            ((MPC_CKSaveRecordOperation *)operation2Save).record = nil;
        }
        
        //Log for demo app
        if (!((MPC_CKQueryOperation *)operation1Query).individualRecord && !operation1Query.isCancelled && !operation1Query.error && cancelsSaveIfRecordExists) {
            NSLog(@"\n\nMPC_Block: The query operation did not find a previously-existing record. So proceeding to save the destination to your private CKContainer.");
        }
        
        
        
    }];
}

@end
