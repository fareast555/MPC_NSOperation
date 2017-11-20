//
//  MPC_CKDeleteRecordOperation.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/21.
//  Copyright © 2017 Michael Critchley. All rights reserved.

//*****************
//This class will delete an individual CKRecord via it's CKRecordID. To create a delete op,
//you can use the factory init [MPC_CKSaveRecordOperation MPC_Operation], and pass the recordID
//later during execution of the operationQueue via an adapter block, or use the custom init.
//*****************

#import "MPC_NSOperation.h"

@interface MPC_CKDeleteRecordOperation : MPC_NSOperation

- (instancetype)initWithRecordID:(CKRecordID *)recordID
             usesPrivateDatabase:(BOOL)usesPrivateDatabase;  //NO = PublicDB YES = PrivateDB

//Public facing setter. ALL delete ops MUST have a recordID before execution (ie, you can
//initialize this class without them, but a CKRecordID must be passed before the "start" method is called
@property (strong, atomic) CKRecordID *recordID;

//If successful, this property will hold the recordID of the CKRecord that was deleted
//(a copy is returned from the server).
//This recordID indicates that the delete operation was successful.
@property (strong, atomic) CKRecordID *deletedCKRecordID;


@end
