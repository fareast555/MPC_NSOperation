//
//  MPC_CKSaveRecordOperation.h
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/15.
//  Copyright © 2017 Michael Critchley. All rights reserved.

//*****************
//This class saves an individual CKRecord. To create a save op, you can use the factory
//init [MPC_CKSaveRecordOperation MPC_Operation], and pass the record later during execution
//of the operationQueue via an adapter block, or use the custom init.
//*****************

#import "MPC_NSOperation.h"


@interface MPC_CKSaveRecordOperation : MPC_NSOperation

- (instancetype)initWithRecord:(CKRecord *)record
           usesPrivateDatabase:(BOOL)usesPrivateDatabase;  //NO = PublicDB YES = PrivateDB

//Public facing setter. ALL save ops MUST have a record before execution (ie, you can
//initialize this class without them, but a CKRecord must be passed before the "start" method is called
@property (strong, atomic) CKRecord *record;

//If successful, this property will hold the record that was saved.
//Use the record[@"modificationDate"] to recover the exact last modification date.
@property (strong, atomic) CKRecord *savedCKRecord;



@end
