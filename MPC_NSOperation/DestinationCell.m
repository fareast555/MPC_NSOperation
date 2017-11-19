//
//  DestinationCell.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/19.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "DestinationCell.h"
#import "Destination.h"

@interface DestinationCell()
@property (weak, nonatomic) IBOutlet UIImageView *destinationImageView;
@property (weak, nonatomic) IBOutlet UILabel *destinationName;


@end


@implementation DestinationCell


+ (NSString *)nibName
{
    return @"DestinationCell";
}
+ (NSString *)reuseID
{
    return @"DestinationCellReuseID";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setDestination:(Destination *)destination
{
    _destination = destination;
    
    [self _configureWithDestination:self.destination];
}

- (void)_configureWithDestination:(Destination *)destination
{
    self.destinationImageView.image = destination.destinationImage;
    self.destinationName.text = destination.destinationName;
  //  [self.contentView bringSubviewToFront:self.destinationName];
}


@end
