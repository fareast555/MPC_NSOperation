//
//  MPC_CKFetchUserRecordIDOperation.h
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
/**
 This class and the chaining structure using adapter blocks implemented in this app was build up based on the solution presented on the Apple forums by Quinn The Eskimo, here:
 https://forums.developer.apple.com/thread/25761
 */

/*****************
This class checks the iCloud container of your app to find the unique "User" object for this user.
 
 If the operation is successful, a single CKRecordID and a CKReference to that User record can be accessed via the public-facing properties.

This fetch is used usually just to confirm identity once, after which, you will save a custom myCKUserType record for users that contains their information.

The CKReference object (referenceToUniqueUserOfCKReferenceTypeUser) is a CKReference to the unique User record for the device user. 
 
 To initialize, either use -(instanceType)init, or use the convenience factory method.
 [MPC_CKFetchUserRecordIDOperation MPC_Operation]
*****************/

#import <Foundation/Foundation.h>
#import "MPC_NSOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPC_CKFetchUserRecordIDOperation : MPC_NSOperation

/* The recordID and reference to the base USER object assigned to every iCloud user will be available if the user record is found. T
 
 ** These objects are available AFTER this operation is completed.**
 */
@property (strong, atomic) CKRecordID *recordID;
@property (strong, atomic) CKReference *referenceToUniqueUserOfCKReferenceTypeUser;

@end

NS_ASSUME_NONNULL_END
