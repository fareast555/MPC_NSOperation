//
//  Destination.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import CloudKit;

@interface Destination : NSObject

- (instancetype)initWithCKRecord:(CKRecord *)cloudKitRecord;
- (CKRecord *)CKRecordFromDestination;

@property (strong, nonatomic, readonly) NSString *destinationName;
@property (strong, nonatomic, readonly) UIImage *destinationImage;

//Identifying properties
@property (strong, nonatomic, readonly) CKRecordID *recordID;

@end
