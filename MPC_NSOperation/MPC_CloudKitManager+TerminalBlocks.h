//
//  MPC_CloudKitManager+TerminalBlocks.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/22.
//  Copyright © 2017 Michael Critchley. All rights reserved.


#import "MPC_CloudKitManager.h"
@class MPC_CKSaveRecordOperation;
@class MPC_CKQueryOperation;
@class MPC_CKDeleteRecordOperation;

@interface MPC_CloudKitManager (TerminalBlocks)

- (NSBlockOperation *)_terminalBlockForBatchQuery:(MPC_CKQueryOperation *)queryOp
                                  destinationType:(DestinationType)destinationType;

- (NSBlockOperation *)_terminalBlockForSaveMyDestination:(MPC_CKSaveRecordOperation *)saveOp;

- (NSBlockOperation *)_terminalBlockForDeleteMyDestination:(MPC_CKDeleteRecordOperation* )deleteOp;

@end
