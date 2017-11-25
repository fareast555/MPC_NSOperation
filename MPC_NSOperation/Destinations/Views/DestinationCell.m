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
//@property (weak, nonatomic) IBOutlet UIImageView *destinationImageView;
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

- (void)setDestination:(Destination *)destination
{
    _destination = destination;
    [self _configureWithDestination:self.destination];
}

- (void)_configureWithDestination:(Destination *)destination
{
    self.destinationImageView.image = destination.destinationImage;
    self.destinationName.text = destination.destinationName;
}

#pragma mark - animate self
- (void)animate
{
    [UIView animateWithDuration:0.10
                          delay:0
         usingSpringWithDamping:0.9
          initialSpringVelocity:6
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        
        self.destinationImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.03, 1.03);
                         
    } completion:^(BOOL finished2) {
        [UIView animateWithDuration:0.15
                         animations:^{
            self.destinationImageView.transform = CGAffineTransformIdentity;
        }];
    }];
    
}


@end
