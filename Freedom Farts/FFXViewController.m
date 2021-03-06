//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  The GPL-3.0 License
//  Copyright (c) 2014 Jesse Squires
//  http://www.gnu.org/licenses
//

#import "FFXViewController.h"

#import <Social/Social.h>
#import <JSQSystemSoundPlayer/JSQSystemSoundPlayer.h>
#import <BButton/BButton.h>
#import <SVWebViewController/SVWebViewController.h>

#import "FFXButtonAnimator.h"
#import "FFXWelcomeViewController.h"
#import "UIView+FreedomFarts.h"
#import "UIColor+FreedomFarts.h"
#import "UIDevice+FreedomFarts.h"
#import "UIAlertView+FreedomFarts.h"
#import "UIImage+FreedomFarts.h"

static NSString * const kFFXActionFacebook = @"Facebook";
static NSString * const kFFXActionTwitter = @"Twitter";

@interface FFXViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) FFXButtonAnimator *buttonAnimator;
@property (assign, nonatomic) BOOL isFirstLaunch;
@property (assign, nonatomic) BOOL isFirstFart;
@property (copy, nonatomic) NSString *currentSound;

- (void)ffx_handleTapGestureRecognizer:(UITapGestureRecognizer *)tap;

- (void)ffx_displaySocialComposerSheetwithService:(NSString *)service;

- (void)ffx_animateFartButton:(UIButton *)button;

- (void)ffx_stopFarting;

- (void)ffx_presentWelcomeView;

- (void)ffx_toggleButtonsEnabled:(BOOL)enabled sender:(UIButton *)sender;

@end



@implementation FFXViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.buttonAnimator = [FFXButtonAnimator new];
    self.isFirstLaunch = YES;
    self.isFirstFart = YES;
    
    self.imageView.image = [[UIImage imageNamed:@"capitol"] ffx_blurredImageWithBlurValue:0.6f];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.layer.opacity = 0.6f;
    
    for (NSUInteger i = 0; i < [self.buttons count]; i++) {
        BButton *eachBtn = [self.buttons objectAtIndex:i];
        
        if ([eachBtn.titleLabel.text isEqualToString:@"Vote!"]) {
            [eachBtn setColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
        }
        else {
            eachBtn.tag = i;
            [eachBtn setColor:[UIColor ffx_patrioticRedColor]];
        }
    }
    
    for (NSLayoutConstraint *eachConstraint in self.buttonSpacingConstraints) {
        eachConstraint.constant = [UIDevice ffx_isPhone4Inch] ? 24.0f : 14.0f;
    }
    
    self.topSpacingConstraint.constant = [UIDevice ffx_isPhone4Inch] ? 38.0f : 26.0f;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(ffx_handleTapGestureRecognizer:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self ffx_presentWelcomeView];
    self.navigationItem.prompt = nil;
}

#pragma mark - Status bar

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (IBAction)votePressed:(UIButton *)sender
{
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithName:@"fart-short" extension:kJSQSystemSoundTypeWAV];
    
    SVWebViewController *vc = [[SVWebViewController alloc] initWithAddress:@"http://www.vote411.org"];
    
    [sender ffx_pulseForDuration:0.15 repeatCount:1.0 delegate:self completion:^(BOOL finished) {
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (IBAction)fartPressed:(UIButton *)sender
{
    [self.view bringSubviewToFront:sender];
    [self ffx_toggleButtonsEnabled:NO sender:sender];
    
    self.currentSound = [sender.titleLabel.text lowercaseString];
    
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithName:self.currentSound
                                                 extension:kJSQSystemSoundTypeWAV
                                                completion:^{
                                                    [self ffx_toggleButtonsEnabled:YES sender:nil];
                                                }];
    
    [self ffx_animateFartButton:sender];
}

- (IBAction)hexedBitsPressed:(UIBarButtonItem *)sender
{
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithName:@"fart-high" extension:kJSQSystemSoundTypeWAV];
    SVWebViewController *vc = [[SVWebViewController alloc] initWithAddress:@"http://www.hexedbits.com"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionPressed:(UIBarButtonItem *)sender
{
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithName:@"fart-high" extension:kJSQSystemSoundTypeWAV];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Tell your friends that you've joined the Fart Party! In God, We Fart."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:@"I only fart in private"
                                              otherButtonTitles:@"Facebook", @"Twitter", nil];
    [sheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark - Gesture recognizers

- (void)ffx_handleTapGestureRecognizer:(UITapGestureRecognizer *)tap
{
    [self ffx_stopFarting];
}

#pragma mark - Shake event

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self ffx_stopFarting];
    }
}

#pragma mark - Core animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    FFXAnimationCompletionBlock block = [anim valueForKey:kFFXAnimationKeyCompletionBlock];
    if (block) {
        block(flag);
    }
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self ffx_displaySocialComposerSheetwithService:SLServiceTypeFacebook];
    }
    else if (buttonIndex == 2) {
        [self ffx_displaySocialComposerSheetwithService:SLServiceTypeTwitter];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithName:@"fart-long" extension:kJSQSystemSoundTypeWAV];
}

#pragma mark - Social

- (void)ffx_displaySocialComposerSheetwithService:(NSString *)service
{
    if (![SLComposeViewController isAvailableForServiceType:service]) {
        if ([service isEqualToString:SLServiceTypeFacebook]) {
            [UIAlertView ffx_showNoFacebookAlert];
        }
        else if ([service isEqualToString:SLServiceTypeTwitter]) {
            [UIAlertView ffx_showNoTwitterAlert];
        }
        return;
    }
    
    SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:service];
    [composer setInitialText:@"I've joined the Fart Party! And you can too! #FreedomFartsApp"];
    [composer addURL:[NSURL URLWithString:@"http://www.freedomfarts.com"]];
    [self presentViewController:composer animated:YES completion:nil];
}

#pragma mark - Utilities

- (void)ffx_animateFartButton:(UIButton *)button
{
    switch (button.tag) {
        case 1:
            [self.buttonAnimator animateFartSpangledBanner:button delegate:self];
            break;
            
        case 2:
            [self.buttonAnimator animateAmericaTheFart:button delegate:self];
            break;
            
        case 3:
            [self.buttonAnimator animateMyFartTisOfThee:button delegate:self];
            break;
            
        case 4:
            [self.buttonAnimator animateBattleFarts:button delegate:self];
            break;
            
        case 5:
            [self.buttonAnimator animateGodFartAmerica:button delegate:self];
            break;
            
        case 6:
            [self.buttonAnimator animateYankeeFarter:button delegate:self];
            break;
    }
}

- (void)ffx_stopFarting
{
    if (!self.currentSound) {
        return;
    }
    
    [self ffx_toggleButtonsEnabled:YES sender:nil];
    [[JSQSystemSoundPlayer sharedPlayer] stopSoundWithFilename:self.currentSound];
    
    for (BButton *eachBtn in self.buttons) {
        [eachBtn.layer removeAllAnimations];
    }
    
    self.currentSound = nil;
}

- (void)ffx_presentWelcomeView
{
    if (self.isFirstLaunch) {
        [[JSQSystemSoundPlayer sharedPlayer] playSoundWithName:@"fart-low" extension:kJSQSystemSoundTypeWAV];
        [FFXWelcomeViewController presentWelcomeViewFromViewController:self];
        self.isFirstLaunch = NO;
    }
}

- (void)ffx_toggleButtonsEnabled:(BOOL)enabled sender:(UIButton *)sender
{
    if (self.isFirstFart && !enabled && sender) {
        self.navigationItem.prompt = @"shake / tap to stop";
        self.isFirstFart = NO;
    }
    else {
        self.navigationItem.prompt = nil;
    }
    
    self.navigationItem.leftBarButtonItem.enabled = enabled;
    self.navigationItem.rightBarButtonItem.enabled = enabled;
    
    for (BButton *eachButton in self.buttons) {
        eachButton.userInteractionEnabled = enabled;
        
        if (!sender || (sender && ![eachButton isEqual:sender])) {
            eachButton.enabled = enabled;
            [eachButton ffx_fadeToValue:enabled ? 1.0f : 0.25f
                               delegate:nil
                             completion:nil];
        }
    }
}

@end
