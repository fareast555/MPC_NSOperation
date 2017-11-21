//
//  DestinationCell.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/19.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Destination;

@interface DestinationCell : UITableViewCell

+ (NSString *)nibName;
+ (NSString *)reuseID;

@property (weak, nonatomic) IBOutlet UIImageView *destinationImageView;
@property (strong, nonatomic) Destination *destination;

@end
