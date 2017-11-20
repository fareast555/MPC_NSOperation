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
@property (strong, nonatomic, readwrite) NSString *UUID;
@property (strong, nonatomic, readwrite) NSDate *recordCreatedDate;
@end


@implementation Destination

- (instancetype)initWithCKRecord:(CKRecord *)cloudKitRecord
{
    return [self initWithDestinationName:cloudKitRecord[@"destinationName"]
                        destinationImage:[UIImage imageWithData:cloudKitRecord[@"imageData"]]
                                recordID:cloudKitRecord[@"recordID"]
                             createdDate:cloudKitRecord[@"creationDate"]];
}

- (instancetype)initWithDestinationName:(NSString *)destinationName
                       destinationImage:(UIImage *)destinationImage
                               recordID:(CKRecordID *)recordID
                            createdDate:(NSDate *)createdDate
{
    if ((self = [super init])) {
        _destinationName = destinationName;
        _destinationImage = destinationImage;
        _UUID = recordID.recordName;
        _recordCreatedDate = createdDate;
    }
    
    return self;
}

- (CKRecord *)CKRecordFromDestination
{
    CKRecordID *ID = [[CKRecordID alloc]initWithRecordName:self.UUID];
    CKRecord *record = [[CKRecord alloc]initWithRecordType:@"MPCDestination" recordID:ID];
    record[@"destinationName"] = self.destinationName;
    record[@"imageData"] = UIImageJPEGRepresentation(self.destinationImage, 1.0);
    
    //Add custom ID fields to circumvent non-indexed meta deta for demo users
    record[@"recordCreatedDate"] = self.recordCreatedDate;
    record[@"UUID"] = self.UUID;
    return record;
    
}

@end
