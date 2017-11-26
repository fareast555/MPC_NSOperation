//
//  MPC_CKFetchUserRecordIDOperation.h
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
/**
 This class and the chaining structure using adapter blocks implemented in this app was build up based on the solution presented on the Apple forums by Quinn The Eskimo, here:
 https://forums.developer.apple.com/thread/25761
 */

//*****************
//This class returns a single CKRecordID if it identifies the unique user that exists in the "User" record type.
//This check is used usually just to confirm identity once, after which, you will save a custom
//myCKUserType record for users that contains their information.

//The referenceToUniqueUserOfCKReferenceTypeUser CKReference is a convenience step that provides
//a CKReference to the unique User record for the device user. Place this reference (or one you
//create yourself via the recordID) on your custom user object to find
//your custom object directly, skipping this step.
//*****************

#import <Foundation/Foundation.h>
#import "MPC_NSOperation.h"

@interface MPC_CKFetchUserRecordIDOperation : MPC_NSOperation

@property (strong, atomic) CKRecordID *recordID;
@property (strong, atomic) CKReference *referenceToUniqueUserOfCKReferenceTypeUser;

@end
