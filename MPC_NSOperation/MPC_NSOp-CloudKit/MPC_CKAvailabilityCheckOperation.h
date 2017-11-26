//
//  CKAvailabilityCheckBlockOperation.h
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
/**
 This class and the chaining structure using adapter blocks implemented in this app was build up based on the solution presented on the Apple forums by Quinn The Eskimo, here:
 https://forums.developer.apple.com/thread/25761
 */


//*****************
  //This class checks if CloudKit is available.
  //This class exposes the CKAccountStatus and error before operation is marked as finished

  //CKAccountStatus cases are:
  //CKAccountStatusAvailable
  //CKAccountStatusNoAccount
  //CKAccountStatusRestricted
  //CKAccountStatusCouldNotDetermine
  //
  //CKAccountStatusAvailable  -- ONLY this case results in success. All others will cancel this operation
//*****************


#import <Foundation/Foundation.h>
#import "MPC_NSOperation.h"

@interface MPC_CKAvailabilityCheckOperation : MPC_NSOperation

//CKAccount status only shows if user had iCloud turned on. It does not
//imply a presence or absence of a network connection
@property (assign, atomic) CKAccountStatus status;

@end
