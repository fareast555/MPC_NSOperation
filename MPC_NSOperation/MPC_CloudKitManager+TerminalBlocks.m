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

@implementation MPC_CloudKitManager (TerminalBlocks)

//Final block deals with results in app-specific manner
- (NSBlockOperation *)_terminalBlockForBatchQuery:(MPC_CKQueryOperation *)queryOp
                                  destinationType:(DestinationType)destinationType
{
    __weak MPC_CloudKitManager *weakSelf = self;
    return [NSBlockOperation blockOperationWithBlock:^{
        
        if (queryOp.error || queryOp.isCancelled) {
            NSLog(@"OP FAILED. Cancelled, and error %@", queryOp.error);
            
        }  else if  (queryOp.records) {
            //Success!
            [weakSelf _updateDestinationWithRecords:((MPC_CKQueryOperation *)queryOp).records
                                    destinationType:destinationType];
        }
        
        [weakSelf _netWorkActivityIndicatorVisible:NO];
    }];
}

- (NSBlockOperation *)_terminalBlockForSaveMyDestination:(MPC_CKSaveRecordOperation *)saveOp
{
    return [NSBlockOperation blockOperationWithBlock:^{
        
        if (saveOp.error && saveOp.isCancelled) {
            //This is a failed op.
            NSLog(@"OP FAILED. Cancelled, and error %@", saveOp.error);
            
            [self _informDelegateOfSaveSuccess:NO previouslySaved:NO error:saveOp.error];
            
        }  else if (!saveOp.error && saveOp.isCancelled) {
            [self _informDelegateOfSaveSuccess:NO previouslySaved:YES error:nil];
            
        } else if (saveOp.savedCKRecord && !saveOp.isCancelled) {
            //Save op complete. Could alert user to a successful save
            NSLog(@"Save op Successful!! Hi-5!");
            [self _informDelegateOfSaveSuccess:YES previouslySaved:NO error:nil];
            
        }
        
        [self _netWorkActivityIndicatorVisible:NO];
    }];
}

- (NSBlockOperation *)_terminalBlockForDeleteMyDestination:(MPC_CKDeleteRecordOperation* )deleteOp
{
    return [NSBlockOperation blockOperationWithBlock:^{
        
        if (deleteOp.deletedCKRecordID) {
            NSLog(@"Deletion was successful!");
        } else {
            NSLog(@"Deletion did fail with error");
        }
        
        [self _netWorkActivityIndicatorVisible:NO];
    }];
}


@end
