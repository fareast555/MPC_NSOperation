//
//  MPC_CKQueryOperation.h
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
/**
 This class and the chaining structure using adapter blocks implemented in this app was build up based on the solution presented on the Apple forums by Quinn The Eskimo, here:
 https://forums.developer.apple.com/thread/25761
 */

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

NS_ASSUME_NONNULL_BEGIN

@interface MPC_CKQueryOperation : MPC_NSOperation
/**
 Designated initializer. The CKRecord type must be set on initialization. The predicate is nullable IF set after creation using the public-facing property.
 
 @param CKRecordType Must match a valid CKDatabase record type or will throw an exception
 @param predicate Pass in a formatted NSPrediate created with [NSPrediate predicateWithFormat:]
 @param desiredKeys Include an array of key strings in the CKRecord Type and only those will be returned. Pass nill to get all data from a record.
 @param resultsLimit No token is returned from this query, so this is strickly to limit the download size
 @param timeoutIntervalForRequest Uses system default if not value is passed
 @return The initialized instance
 
 */
- (instancetype)initWithCKRecordType:(NSString *)CKRecordType
                 usesPrivateDatabase:(BOOL)usesPrivateDatabase  //NO = PublicDB YES = PrivateDB
                           predicate:(nullable NSPredicate *)predicate //Nullible if predicate is set via public property
                         desiredKeys:(nullable NSArray *)desiredKeys
                        resultsLimit:(NSUInteger)resultsLimit
           timeoutIntervalForRequest:(NSUInteger)timeoutIntervalForRequest;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

//If the query predicate depends on a prior operation result, set in an
//intermediate blockOperationWithBlock^() to override the existing (if any) predicate
@property (strong, atomic, nullable) NSPredicate *predicate;

//The final array of downloaded CKRecord objects
//This is available after the operation has been marked as finished
@property (strong, atomic, nullable) NSArray *records;

//To receive individual records on arrival, subscribe to this property for KVO updates
@property (strong, atomic, nullable) CKRecord *individualRecord;



@end

NS_ASSUME_NONNULL_END
