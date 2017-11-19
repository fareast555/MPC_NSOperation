//
//  CKAvailabilityCheckBlockOperation.h
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
//  Copyright © 2017 Michael Critchley. All rights reserved.


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
