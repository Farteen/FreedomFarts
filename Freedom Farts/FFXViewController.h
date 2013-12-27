//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  The MIT License
//  Copyright (c) 2012 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@class SAMGradientView, BButton;

@interface FFXViewController : UIViewController

@property (weak, nonatomic) IBOutlet SAMGradientView *gradientView;

- (IBAction)fartPressed:(UIButton *)sender;

- (IBAction)hexedBitsPressed:(UIButton *)sender;

@end
