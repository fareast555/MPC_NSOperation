//
//  MPC_CKQueryOperation.h
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
//  Copyright © 2017 Michael Critchley. All rights reserved.

//*****************
//This class runs a CKQuery on the CKRecordType passed, using the specified NSPredicate object.
//You can leave the predicate as nil on initWithCKRecord... provided the class is passed a
//predicate before execution by an intermediary adaptor block (see the MPC_NSOperations.h file for
//an example of this kind of block).

//Subscribe via KVO to the "individualRecord" CKRecord property to get records fed to your calling
//class as they arrive. Or you can wait for the operation to complete, then recover all records at
//once via the "records" array property.
//*****************

#import <Foundation/Foundation.h>
#import "MPC_NSOperation.h"

@interface MPC_CKQueryOperation : MPC_NSOperation

- (instancetype)initWithCKRecordType:(NSString *)CKRecordType
                 usesPrivateDatabase:(BOOL)usesPrivateDatabase  //NO = PublicDB YES = PrivateDB
                           predicate:(NSPredicate *)predicate //Nullible if predicate is set via public property
                         desiredKeys:(NSArray *)desiredKeys
                        resultsLimit:(NSUInteger)resultsLimit
           timeoutIntervalForRequest:(NSUInteger)timeoutIntervalForRequest;

//If the query predicate depends on a prior operation result, set in an
//intermediate blockOperationWithBlock^() to override the existing (if any) predicate
@property (strong, atomic) NSPredicate *predicate;

//The final array of downloaded CKRecord objects
//This is available after the operation has been marked as finished
@property (strong, atomic) NSArray *records;

//To receive individual records on arrival, subscribe to this property for KVO updates
@property (strong, atomic) CKRecord *individualRecord;



@end
