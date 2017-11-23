//
//  MPC_CloudKitManager+TerminalBlocks.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/22.
//  Copyright © 2017 Michael Critchley. All rights reserved.
/*****************
This class is primarily responsible for the creation of terminal blocks and final clean up of CloudKit
operations. Terminal blocks are the clean-up crew of the NSOperationQueue. Use these to pick
up the final error object, the .isCancelled state, and any objects produced in the final operation.
 
 This class is a category of the MPC_CloudkitManager. That is, it can call "self" and also
 access public methods or properties on the MPC_CloudkitManager class. This category:
 
 1. Separates the terminal block creation from the main class to allow for easier parsing of
    methods and to reduce clutter.
 
 2. Terminal blocks are really a *thing* on their own, so keeping this logic separate from the
    executive manager makes sense.
 
 3. The most app-specific logic of an operation is the terminal block and updating. That is,
    the primary class is left as a fairly re-usable entity, as almost any app using CloudKit
    will follow the same, or almost the same, steps for saving, deleting, etc. This category
    is the part that really needs to be re-created from scratch for every app.
 *****************/

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
