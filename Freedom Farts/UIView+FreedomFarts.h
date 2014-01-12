//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  The GPL-3.0 License
//  Copyright (c) 2014 Jesse Squires
//  http://www.gnu.org/licenses
//

#import <UIKit/UIKit.h>

extern NSString * const kFFXAnimationKeyView;
extern NSString * const kFFXAnimationKeyCompletionBlock;

typedef void (^FFXAnimationCompletionBlock)(BOOL finished);


@interface UIView (FreedomFarts)

- (void)ffx_fadeToValue:(CGFloat)val delegate:(id)delegate completion:(FFXAnimationCompletionBlock)block;

@end
