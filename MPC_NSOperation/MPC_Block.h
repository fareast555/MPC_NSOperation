//
//  MPC_Block.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/21.
//  Copyright © 2017 Michael Critchley. All rights reserved.

/*****************

 


 *****************/

#import <Foundation/Foundation.h>
#import "MPC_CloudKitManager.h"

@class MPC_CKAvailabilityCheckOperation;
@class MPC_CKSaveRecordOperation;
@class MPC_CKQueryOperation;
@class MPC_CKDeleteRecordOperation;

@interface MPC_Block : NSBlockOperation

+ (MPC_Block *)adapterBlockBetweenQueryOp:(MPC_CKQueryOperation *)operation1Query
                            saveOperation:(MPC_CKSaveRecordOperation *)operation2Save
                cancelsSaveIfRecordExists:(BOOL)cancelsSaveIfRecordExists;

@end
