//
//  Destination.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "Destination.h"

@interface Destination ()
@property (strong, nonatomic, readwrite) NSString *destinationName;
@property (strong, nonatomic, readwrite) UIImage *destinationImage;
@property (strong, nonatomic, readwrite) CKRecordID *recordID;
@end


@implementation Destination

- (instancetype)initWithCKRecord:(CKRecord *)cloudKitRecord
{
    return [self initWithDestinationName:cloudKitRecord[@"destinationName"]
                        destinationImage:[UIImage imageWithData:cloudKitRecord[@"imageData"]] recordID:cloudKitRecord[@"recordID"]];
}

- (instancetype)initWithDestinationName:(NSString *)destinationName
                       destinationImage:(UIImage *)destinationImage
                               recordID:(CKRecordID *)recordID
{
    if ((self = [super init])) {
        _destinationName = destinationName;
        _destinationImage = destinationImage;
        _recordID = recordID;
    }
    
    return self;
}

- (CKRecord *)CKRecordFromDestination
{
   // CKRecordID *ID = [[CKRecordID alloc]initWithRecordName:self.recordID.recordName];
    CKRecord *record = [[CKRecord alloc]initWithRecordType:@"MPCDestination" recordID:self.recordID];
    record[@"destinationName"] = self.destinationName;
    record[@"imageData"] = UIImageJPEGRepresentation(self.destinationImage, 1.0);
    return record;
    
}

@end
