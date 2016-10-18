//
//  NYAlertViewController.m
//
//  Created by Nealon Young on 7/13/15.
//  Copyright (c) 2015 Nealon Young. All rights reserved.
//

#import "NYAlertViewController.h"
#import "NYAlertView.h"

#define NYAlert_iOS8Later ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0)

@interface NYAlertAction ()

@property (weak, nonatomic) UIButton *actionButton;

@end

@implementation NYAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(NYAlertActionStyle)style handler:(void (^)(NYAlertViewController *alertViewController, NYAlertAction *action))handler {
    NYAlertAction *action = [[NYAlertAction alloc] init];
    action.title = title;
    action.style = style;
    action.handler = handler;
    
    return action;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _enabled = YES;
    }
    
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    self.actionButton.enabled = enabled;
}

@end

@interface NYAlertViewPresentationAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property NYAlertViewControllerTransitionStyle transitionStyle;
@property CGFloat duration;

@end

static CGFloat const kDefaultPresentationAnimationDuration = 0.7f;

@implementation NYAlertViewPresentationAnimationController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.duration = kDefaultPresentationAnimationDuration;
    }
    
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionStyle == NYAlertViewControllerTransitionStyleSlideFromTop || self.transitionStyle == NYAlertViewControllerTransitionStyleSlideFromBottom) {
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect initialFrame;
        if (NYAlert_iOS8Later) {
            initialFrame = [transitionContext finalFrameForViewController:toViewController];
        } else {
            UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            initialFrame = [transitionContext finalFrameForViewController:fromViewController];
        }
        
        initialFrame.origin.y = self.transitionStyle == NYAlertViewControllerTransitionStyleSlideFromTop ? -(initialFrame.size.height + initialFrame.origin.y) : (initialFrame.size.height + initialFrame.origin.y);
        toViewController.view.frame = initialFrame;
        
        [[transitionContext containerView] addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:1.f
              initialSpringVelocity:0.3f
                            options:0
                         animations:^{
                             toViewController.view.layer.transform = CATransform3DIdentity;
                             toViewController.view.layer.opacity = 1.0f;
                             toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    } else {
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect finalFrame;
        if (NYAlert_iOS8Later) {
            finalFrame = [transitionContext finalFrameForViewController:toViewController];
        } else {
            UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            finalFrame = [transitionContext finalFrameForViewController:fromViewController];
        }
        
        toViewController.view.frame = finalFrame;
        [[transitionContext containerView] addSubview:toViewController.view];
        
        toViewController.view.layer.transform = CATransform3DMakeScale(1.2f, 1.2f, 1.2f);
        toViewController.view.layer.opacity = 0.0f;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             toViewController.view.layer.transform = CATransform3DIdentity;
                             toViewController.view.layer.opacity = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.transitionStyle) {
        case NYAlertViewControllerTransitionStyleFade:
            return 0.3f;
            break;
            
        case NYAlertViewControllerTransitionStyleSlideFromTop:
        case NYAlertViewControllerTransitionStyleSlideFromBottom:
            return 0.6f;
    }
}

@end

@interface NYAlertViewDismissalAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property NYAlertViewControllerTransitionStyle transitionStyle;
@property CGFloat duration;

@end

static CGFloat const kDefaultDismissalAnimationDuration = 0.6f;

@implementation NYAlertViewDismissalAnimationController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.duration = kDefaultDismissalAnimationDuration;
    }
    
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionStyle == NYAlertViewControllerTransitionStyleSlideFromTop || self.transitionStyle == NYAlertViewControllerTransitionStyleSlideFromBottom) {
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        CGRect finalFrame = [transitionContext finalFrameForViewController:fromViewController];
        finalFrame.origin.y = 1.2f * CGRectGetHeight([transitionContext containerView].frame);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:1.f
              initialSpringVelocity:0.3f
                            options:0
                         animations:^{
                             fromViewController.view.frame = finalFrame;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    } else {
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             fromViewController.view.layer.opacity = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.transitionStyle) {
        case NYAlertViewControllerTransitionStyleFade:
            return 0.3f;
            break;
            
        case NYAlertViewControllerTransitionStyleSlideFromTop:
        case NYAlertViewControllerTransitionStyleSlideFromBottom:
            return 0.6f;
    }}

@end


@interface NYAlertViewController () <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) UIView *backgroundDimmingView;

/**
 The font used for buttons (actions with style NYAlertActionStyleDefault) in the alert view
 */
@property (nonatomic) UIFont *buttonTitleFont;

/**
 The font used for cancel buttons (actions with style NYAlertActionStyleCancel) in the alert view
 */
@property (nonatomic) UIFont *cancelButtonTitleFont;

/**
 The font used for destructive buttons (actions with style NYAlertActionStyleDestructive) in the alert view
 */
@property (nonatomic) UIFont *destructiveButtonTitleFont;

/**
 The background color for the alert view's buttons corresponsing to default style actions of diffrent states
 */
@property (nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *buttonColorForStateDictionary;

/**
 The background color for the alert view's buttons corresponsing to cancel style actions of diffrent states
 */
@property (nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *cancelButtonColorForStateDictionary;

/**
 The background color for the alert view's buttons corresponsing to destructive style actions of diffrent states
 */
@property (nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *destructiveButtonColorForStateDictionary;

/**
 The background image for the alert view's buttons corresponsing to default style actions of diffrent states
 */
@property (nonatomic) NSMutableDictionary<NSNumber *, UIImage *> *buttonBackgroundImageForStateDictionary;

/**
 The background image for the alert view's buttons corresponsing to cancel style actions of diffrent states
 */
@property (nonatomic) NSMutableDictionary<NSNumber *, UIImage *> *cancelButtonBackgroundImageForStateDictionary;

/**
 The background image for the alert view's buttons corresponsing to destructive style actions of diffrent states
 */
@property (nonatomic) NSMutableDictionary<NSNumber *, UIImage *> *destructiveButtonBackgroundImageForStateDictionary;

/**
 The color used to display the title for buttons corresponsing to default style actions of diffrent states
 */
@property (nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *buttonTitleColorForStateDictionary;

/**
 The color used to display the title for buttons corresponding to cancel style actions of diffrent states
 */
@property (nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *cancelButtonTitleColorForStateDictionary;

/**
 The color used to display the title for buttons corresponsing to destructive style actions of diffrent states
 */
@property (nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *destructiveButtonTitleColorForStateDictionary;

@property (nonatomic) NYAlertView *alertView;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer;

@end

@implementation NYAlertViewController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message {
    NYAlertViewController *alertController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    alertController.title = title;
    alertController.message = message;
    
    return alertController;
}

+ (instancetype)alertControllerWithTitleImage:(UIImage *)titleImage message:(NSString *)message {
    NYAlertViewController *alertController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    alertController.titleImage = titleImage;
    alertController.message = message;
    
    return alertController;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)viewDidDisappear:(BOOL)animated {
    // Necessary to avoid retain cycle - http://stackoverflow.com/a/21218703/1227862
    self.transitioningDelegate = nil;
    [super viewDidDisappear:animated];
}

- (void)commonInit {

    _actions = [NSArray array];
    _textFields = [NSArray array];
    
    _showsStatusBar = YES;
    
    _buttonTitleFont = [UIFont systemFontOfSize:16.0f];
    _cancelButtonTitleFont = [UIFont boldSystemFontOfSize:16.0f];
    _destructiveButtonTitleFont = [UIFont systemFontOfSize:16.0f];
    
    _buttonColorForStateDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@(UIControlStateNormal):[UIColor darkGrayColor], @(UIControlStateDisabled):[UIColor lightGrayColor]}];
    _cancelButtonColorForStateDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@(UIControlStateNormal):[UIColor darkGrayColor]}];
    _destructiveButtonColorForStateDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@(UIControlStateNormal):[UIColor colorWithRed:1.0f green:0.23f blue:0.21f alpha:1.0f]}];
    
    _buttonBackgroundImageForStateDictionary = [NSMutableDictionary dictionary];
    _cancelButtonBackgroundImageForStateDictionary = [NSMutableDictionary dictionary];
    _destructiveButtonBackgroundImageForStateDictionary = [NSMutableDictionary dictionary];
    
    _buttonTitleColorForStateDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@(UIControlStateNormal):[UIColor whiteColor], @(UIControlStateDisabled):[UIColor whiteColor]}];
    _cancelButtonTitleColorForStateDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@(UIControlStateNormal):[UIColor whiteColor]}];
    _destructiveButtonTitleColorForStateDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@(UIControlStateNormal):[UIColor whiteColor]}];
    
    _buttonCornerRadius = 6.0f;
    
    _transitionStyle = NYAlertViewControllerTransitionStyleSlideFromTop;
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    self.panGestureRecognizer.delegate = self;
    self.panGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    self.tapGestureRecognizer.delegate = self;
    self.tapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)loadView {
    self.view = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.backgroundDimmingView = ({
        UIView *dimmingView = [[UIView alloc]initWithFrame:CGRectZero];
        dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        dimmingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        dimmingView;
    });
    [self.view addSubview:self.backgroundDimmingView];
    
    self.alertView = ({
        NYAlertView *aView = [[NYAlertView alloc]initWithFrame:CGRectZero];
        aView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        aView;
    });
    [self.view addSubview:self.alertView];
}

- (BOOL)prefersStatusBarHidden {
    return !self.showsStatusBar;
}

- (CGFloat)maximumWidth {
    return self.alertView.maximumWidth;
}

- (void)setMaximumWidth:(CGFloat)maximumWidth {
    self.alertView.maximumWidth = maximumWidth;
}

- (UIView *)alertViewContentView {
    return self.alertView.contentView;
}

- (void)setAlertViewContentView:(UIView *)alertViewContentView {
    self.alertView.contentView = alertViewContentView;
}

- (void)setBackgroundTapDismissalGestureEnabled:(BOOL)backgroundTapDismissalGestureEnabled {
    _backgroundTapDismissalGestureEnabled = backgroundTapDismissalGestureEnabled;
    
    self.tapGestureRecognizer.enabled = backgroundTapDismissalGestureEnabled;
}

- (void)setSwipeDismissalGestureEnabled:(BOOL)swipeDismissalGestureEnabled {
    _swipeDismissalGestureEnabled = swipeDismissalGestureEnabled;
    
    self.panGestureRecognizer.enabled = swipeDismissalGestureEnabled;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer {
    self.alertView.backgroundViewVerticalCenteringConstraint.constant = [gestureRecognizer translationInView:self.view].y;
    
    CGFloat windowHeight = CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds);
    self.backgroundDimmingView.alpha = 0.7f - (fabs([gestureRecognizer translationInView:self.view].y) / windowHeight);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat verticalGestureVelocity = [gestureRecognizer velocityInView:self.view].y;
        
        // If the gesture is moving fast enough, animate the alert view offscreen and dismiss the view controller. Otherwise, animate the alert view back to its initial position
        if (fabs(verticalGestureVelocity) > 500.0f) {
            CGFloat backgroundViewYPosition;
            
            if (verticalGestureVelocity > 500.0f) {
                backgroundViewYPosition = CGRectGetHeight(self.view.frame);
            } else {
                backgroundViewYPosition = -CGRectGetHeight(self.view.frame);
            }
            
            CGFloat animationDuration = 500.0f / fabs(verticalGestureVelocity);
            
            self.alertView.backgroundViewVerticalCenteringConstraint.constant = backgroundViewYPosition;
            [UIView animateWithDuration:animationDuration
                                  delay:0.0f
                                options:0
                             animations:^{
                                 self.backgroundDimmingView.alpha = 0.0f;
                                 [self.view layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
        } else {
            self.alertView.backgroundViewVerticalCenteringConstraint.constant = 0.0f;
            [UIView animateWithDuration:0.5f
                                  delay:0.0f
                                options:0
                             animations:^{
                                 self.backgroundDimmingView.alpha = 0.7f;
                                 [self.view layoutIfNeeded];
                             }
                             completion:nil];
        }
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer {
    
    if (self.backgroundTapDismissalGestureEnabled) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self createActionButtons];
    self.alertView.textFields = self.textFields;
}

- (void)setAlertViewBackgroundColor:(UIColor *)alertViewBackgroundColor {
    _alertViewBackgroundColor = alertViewBackgroundColor;
    
    self.alertView.alertBackgroundView.backgroundColor = alertViewBackgroundColor;
}

- (void)createActionButtons {
    NSMutableArray *buttons = [NSMutableArray array];
    
    // Create buttons for each action
    for (int i = 0; i < [self.actions count]; i++) {
        NYAlertAction *action = self.actions[i];
        
        NYAlertViewButton *button = [NYAlertViewButton buttonWithType:UIButtonTypeCustom];
        
        button.tag = i;
        [button addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        button.enabled = action.enabled;
        
        button.cornerRadius = self.buttonCornerRadius;
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitle:action.title forState:UIControlStateNormal];
        
        switch (action.style) {
            case NYAlertActionStyleDefault: {
                if (self.buttonTitleColorForStateDictionary[@(UIControlStateNormal)]) {
                    [button setTitleColor:self.buttonTitleColorForStateDictionary[@(UIControlStateNormal)] forState:UIControlStateNormal];
                }
                if (self.buttonTitleColorForStateDictionary[@(UIControlStateHighlighted)]) {
                    [button setTitleColor:self.buttonTitleColorForStateDictionary[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
                }
                if (self.buttonTitleColorForStateDictionary[@(UIControlStateDisabled)]) {
                    [button setTitleColor:self.buttonTitleColorForStateDictionary[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
                }
                
                if (self.buttonColorForStateDictionary[@(UIControlStateNormal)]) {
                    [button setBackgroundColor:self.buttonColorForStateDictionary[@(UIControlStateNormal)] forState:UIControlStateNormal];
                }
                if (self.buttonColorForStateDictionary[@(UIControlStateHighlighted)]) {
                    [button setBackgroundColor:self.buttonColorForStateDictionary[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
                }
                if (self.buttonColorForStateDictionary[@(UIControlStateDisabled)]) {
                    [button setBackgroundColor:self.buttonColorForStateDictionary[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
                }
                
                if (self.buttonBackgroundImageForStateDictionary[@(UIControlStateNormal)]) {
                    [button setBackgroundImage:self.buttonBackgroundImageForStateDictionary[@(UIControlStateNormal)] forState:UIControlStateNormal];
                }
                if (self.buttonBackgroundImageForStateDictionary[@(UIControlStateHighlighted)]) {
                    [button setBackgroundImage:self.buttonBackgroundImageForStateDictionary[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
                }
                if (self.buttonBackgroundImageForStateDictionary[@(UIControlStateDisabled)]) {
                    [button setBackgroundImage:self.buttonBackgroundImageForStateDictionary[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
                }
                
                button.titleLabel.font = self.buttonTitleFont;
                break;
            }
            case NYAlertActionStyleCancel: {
                if (self.cancelButtonTitleColorForStateDictionary[@(UIControlStateNormal)]) {
                    [button setTitleColor:self.cancelButtonTitleColorForStateDictionary[@(UIControlStateNormal)] forState:UIControlStateNormal];
                }
                if (self.cancelButtonTitleColorForStateDictionary[@(UIControlStateHighlighted)]) {
                    [button setTitleColor:self.cancelButtonTitleColorForStateDictionary[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
                }
                if (self.cancelButtonTitleColorForStateDictionary[@(UIControlStateDisabled)]) {
                    [button setTitleColor:self.cancelButtonTitleColorForStateDictionary[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
                }
                
                if (self.cancelButtonColorForStateDictionary[@(UIControlStateNormal)]) {
                    [button setBackgroundColor:self.cancelButtonColorForStateDictionary[@(UIControlStateNormal)] forState:UIControlStateNormal];
                }
                if (self.cancelButtonColorForStateDictionary[@(UIControlStateHighlighted)]) {
                    [button setBackgroundColor:self.cancelButtonColorForStateDictionary[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
                }
                if (self.cancelButtonColorForStateDictionary[@(UIControlStateDisabled)]) {
                    [button setBackgroundColor:self.cancelButtonColorForStateDictionary[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
                }
                
                if (self.cancelButtonBackgroundImageForStateDictionary[@(UIControlStateNormal)]) {
                    [button setBackgroundImage:self.cancelButtonBackgroundImageForStateDictionary[@(UIControlStateNormal)] forState:UIControlStateNormal];
                }
                if (self.cancelButtonBackgroundImageForStateDictionary[@(UIControlStateHighlighted)]) {
                    [button setBackgroundImage:self.cancelButtonBackgroundImageForStateDictionary[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
                }
                if (self.cancelButtonBackgroundImageForStateDictionary[@(UIControlStateDisabled)]) {
                    [button setBackgroundImage:self.cancelButtonBackgroundImageForStateDictionary[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
                }
                
                button.titleLabel.font = self.cancelButtonTitleFont;
                break;
            }
            case NYAlertActionStyleDestructive: {
                if (self.destructiveButtonTitleColorForStateDictionary[@(UIControlStateNormal)]) {
                    [button setTitleColor:self.destructiveButtonTitleColorForStateDictionary[@(UIControlStateNormal)] forState:UIControlStateNormal];
                }
                if (self.destructiveButtonTitleColorForStateDictionary[@(UIControlStateHighlighted)]) {
                    [button setTitleColor:self.destructiveButtonTitleColorForStateDictionary[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
                }
                if (self.destructiveButtonTitleColorForStateDictionary[@(UIControlStateDisabled)]) {
                    [button setTitleColor:self.destructiveButtonTitleColorForStateDictionary[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
                }
                
                if (self.destructiveButtonColorForStateDictionary[@(UIControlStateNormal)]) {
                    [button setBackgroundColor:self.destructiveButtonColorForStateDictionary[@(UIControlStateNormal)] forState:UIControlStateNormal];
                }
                if (self.destructiveButtonColorForStateDictionary[@(UIControlStateHighlighted)]) {
                    [button setBackgroundColor:self.destructiveButtonColorForStateDictionary[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
                }
                if (self.destructiveButtonColorForStateDictionary[@(UIControlStateDisabled)]) {
                    [button setBackgroundColor:self.destructiveButtonColorForStateDictionary[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
                }
                
                if (self.destructiveButtonBackgroundImageForStateDictionary[@(UIControlStateNormal)]) {
                    [button setBackgroundImage:self.destructiveButtonBackgroundImageForStateDictionary[@(UIControlStateNormal)] forState:UIControlStateNormal];
                }
                if (self.destructiveButtonBackgroundImageForStateDictionary[@(UIControlStateHighlighted)]) {
                    [button setBackgroundImage:self.destructiveButtonBackgroundImageForStateDictionary[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
                }
                if (self.destructiveButtonBackgroundImageForStateDictionary[@(UIControlStateDisabled)]) {
                    [button setBackgroundImage:self.destructiveButtonBackgroundImageForStateDictionary[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
                }
                
                button.titleLabel.font = self.destructiveButtonTitleFont;
                break;
            }
        }
        
        [buttons addObject:button];
        
        action.actionButton = button;
    }
    
    self.alertView.actionButtons = buttons;
}

- (void)actionButtonPressed:(UIButton *)button {
    NYAlertAction *action = self.actions[button.tag];
    action.handler(self, action);
}

- (void)setDisplayAlertViewCornerIconButtonWithConfigurationBlock:(void(^)(NYAlertViewController *alertViewController, UIButton *iconButton))configurationBlock {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (configurationBlock) {
        configurationBlock(self, button);
    }
    [self.alertView setCornerIconButton:button];
}

- (void)setHideAlertViewCornerIconButton {
    [self.alertView setCornerIconButton:nil];
}

#pragma mark - Getters/Setters

- (void)setAlertViewlayout:(NYAlertViewLayout *)alertViewlayout {
    _alertViewlayout = alertViewlayout;
    [self.alertView setLayout:alertViewlayout];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    if (title.length == 0) {
        [self.alertView setTitleView:nil];
    } else {
        [self.alertView setTitleView:({
            NYAlertTitleView *tview = [[NYAlertTitleView alloc]initWithTitle:title];
            if (self.titleFont) {
                tview.titleLabel.font = self.titleFont;
            }
            if (self.titleColor) {
                tview.titleLabel.textColor = self.titleColor;
            }
            tview;
        })];
    }
}

- (void)setTitleImage:(UIImage *)titleImage {
    _titleImage = titleImage;
    
    if (!titleImage) {
        [self.alertView setTitleView:nil];
    } else {
        [self.alertView setTitleView:({
            NYAlertTitleView *tview = [[NYAlertTitleView alloc]initWithTitleImage:titleImage];
            tview;
        })];
    }
}

- (void)setMessage:(NSString *)message {
    _message = message;
    
    if (message.length == 0) {
        [self.alertView setMessageTextView:nil];
    } else {
        [self.alertView setMessageTextView:({
            NYAlertTextView *textView = [[NYAlertTextView alloc]initWithFrame:CGRectZero];
            textView.textColor = self.messageColor;
            textView.font = self.messageFont;
            textView.text = message;
            textView;
        })];
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.alertView.titleView.titleLabel.font = titleFont;
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    self.alertView.messageTextView.font = messageFont;
}

- (void)setButtonTitleFont:(UIFont *)buttonTitleFont {
    _buttonTitleFont = buttonTitleFont;
    
    [self.alertView.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        NYAlertAction *action = self.actions[idx];
        
        if (action.style != NYAlertActionStyleCancel) {
            button.titleLabel.font = buttonTitleFont;
        }
    }];
}

- (void)setCancelButtonTitleFont:(UIFont *)cancelButtonTitleFont {
    _cancelButtonTitleFont = cancelButtonTitleFont;
    
    [self.alertView.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        NYAlertAction *action = self.actions[idx];
        
        if (action.style == NYAlertActionStyleCancel) {
            button.titleLabel.font = cancelButtonTitleFont;
        }
    }];
}

- (void)setDestructiveButtonTitleFont:(UIFont *)destructiveButtonTitleFont {
    _destructiveButtonTitleFont = destructiveButtonTitleFont;
    
    [self.alertView.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        NYAlertAction *action = self.actions[idx];
        
        if (action.style == NYAlertActionStyleDestructive) {
            button.titleLabel.font = destructiveButtonTitleFont;
        }
    }];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.alertView.titleView.titleLabel.textColor = titleColor;
}

- (void)setMessageColor:(UIColor *)messageColor {
    _messageColor = messageColor;
    self.alertView.messageTextView.textColor = messageColor;
}

- (CGFloat)alertViewCornerRadius {
    return self.alertView.alertBackgroundView.layer.cornerRadius;
}

- (void)setAlertViewCornerRadius:(CGFloat)alertViewCornerRadius {
    self.alertView.alertBackgroundView.layer.cornerRadius = alertViewCornerRadius;
}

- (void)setButtonCornerRadius:(CGFloat)buttonCornerRadius {
    _buttonCornerRadius = buttonCornerRadius;
    
    for (NYAlertViewButton *button in self.alertView.actionButtons) {
        button.cornerRadius = buttonCornerRadius;
    }
}

- (void)setActionButtonTitleFont:(UIFont *)buttonTitleFont forStyle:(NYAlertActionStyle)style {
    
    switch (style) {
        case NYAlertActionStyleDefault: {
            _buttonTitleFont = buttonTitleFont;
            break;
        }
        case NYAlertActionStyleCancel: {
            _cancelButtonTitleFont = buttonTitleFont;
            break;
        }
        case NYAlertActionStyleDestructive: {
            _destructiveButtonTitleFont = buttonTitleFont;
            break;
        }
    }
    
    [self.alertView.actionButtons enumerateObjectsUsingBlock:^(NYAlertViewButton * button, NSUInteger idx, BOOL *stop) {
        NYAlertAction *action = self.actions[idx];
        
        if (style == action.style) {
            button.titleLabel.font = buttonTitleFont;
        }
    }];
}

- (void)setActionButtonBackgroundColor:(UIColor *)backgroundColor forStyle:(NYAlertActionStyle)style state:(UIControlState)state {
    
    switch (style) {
        case NYAlertActionStyleDefault: {
            if (backgroundColor) {
                self.buttonColorForStateDictionary[@(state)] = backgroundColor;
            } else {
                [self.buttonColorForStateDictionary removeObjectForKey:@(state)];
            }
            break;
        }
        case NYAlertActionStyleCancel: {
            if (backgroundColor) {
                self.cancelButtonColorForStateDictionary[@(state)] = backgroundColor;
            } else {
                [self.cancelButtonColorForStateDictionary removeObjectForKey:@(state)];
            }
            break;
        }
        case NYAlertActionStyleDestructive: {
            if (backgroundColor) {
                self.destructiveButtonColorForStateDictionary[@(state)] = backgroundColor;
            } else {
                [self.destructiveButtonColorForStateDictionary removeObjectForKey:@(state)];
            }
            break;
        }
    }
    
    [self.alertView.actionButtons enumerateObjectsUsingBlock:^(NYAlertViewButton * button, NSUInteger idx, BOOL *stop) {
        NYAlertAction *action = self.actions[idx];
        
        if (style == action.style) {
            [button setBackgroundColor:backgroundColor forState:state];
        }
    }];
}

- (void)setActionButtonBackgroundImage:(UIImage *)backgroundImage forStyle:(NYAlertActionStyle)style state:(UIControlState)state {
    
    switch (style) {
        case NYAlertActionStyleDefault: {
            if (backgroundImage) {
                self.buttonBackgroundImageForStateDictionary[@(state)] = backgroundImage;
            } else {
                [self.buttonBackgroundImageForStateDictionary removeObjectForKey:@(state)];
            }
            break;
        }
        case NYAlertActionStyleCancel: {
            if (backgroundImage) {
                self.cancelButtonBackgroundImageForStateDictionary[@(state)] = backgroundImage;
            } else {
                [self.cancelButtonBackgroundImageForStateDictionary removeObjectForKey:@(state)];
            }
            break;
        }
        case NYAlertActionStyleDestructive: {
            if (backgroundImage) {
                self.destructiveButtonBackgroundImageForStateDictionary[@(state)] = backgroundImage;
            } else {
                [self.destructiveButtonBackgroundImageForStateDictionary removeObjectForKey:@(state)];
            }
            break;
        }
    }
    
    [self.alertView.actionButtons enumerateObjectsUsingBlock:^(NYAlertViewButton * button, NSUInteger idx, BOOL *stop) {
        NYAlertAction *action = self.actions[idx];
        
        if (style == action.style) {
            [button setBackgroundImage:backgroundImage forState:state];
        }
    }];
}

- (void)setActionButtonTitleColor:(UIColor *)titleColor forStyle:(NYAlertActionStyle)style state:(UIControlState)state {
    
    switch (style) {
        case NYAlertActionStyleDefault: {
            if (titleColor) {
                self.buttonTitleColorForStateDictionary[@(state)] = titleColor;
            } else {
                [self.buttonTitleColorForStateDictionary removeObjectForKey:@(state)];
            }
            break;
        }
        case NYAlertActionStyleCancel: {
            if (titleColor) {
                self.cancelButtonTitleColorForStateDictionary[@(state)] = titleColor;
            } else {
                [self.cancelButtonTitleColorForStateDictionary removeObjectForKey:@(state)];
            }
            break;
        }
        case NYAlertActionStyleDestructive: {
            if (titleColor) {
                self.destructiveButtonTitleColorForStateDictionary[@(state)] = titleColor;
            } else {
                [self.destructiveButtonTitleColorForStateDictionary removeObjectForKey:@(state)];
            }
            break;
        }
    }
    
    [self.alertView.actionButtons enumerateObjectsUsingBlock:^(NYAlertViewButton * button, NSUInteger idx, BOOL *stop) {
        NYAlertAction *action = self.actions[idx];
        
        if (style == action.style) {
            [button setTitleColor:titleColor forState:state];
        }
    }];
}

- (void)addAction:(NYAlertAction *)action {
    _actions = [self.actions arrayByAddingObject:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    
    configurationHandler(textField);
    
    _textFields = [self.textFields arrayByAddingObject:textField];
}

- (void)buttonPressed:(UIButton *)sender {
    NYAlertAction *action = self.actions[sender.tag];
    action.handler(self, action);
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    NYAlertViewPresentationAnimationController *presentationAnimationController = [[NYAlertViewPresentationAnimationController alloc] init];
    presentationAnimationController.transitionStyle = self.transitionStyle;
    return presentationAnimationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    NYAlertViewDismissalAnimationController *dismissalAnimationController = [[NYAlertViewDismissalAnimationController alloc] init];
    dismissalAnimationController.transitionStyle = self.transitionStyle;
    return dismissalAnimationController;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([gestureRecognizer isEqual:self.tapGestureRecognizer]) {
        UIView *alertBackgroundView = self.alertView.alertBackgroundView;
        CGPoint touchPoint = [touch locationInView:self.view];
        CGRect alertBackgroundViewAbsoluteFrame = [alertBackgroundView convertRect:alertBackgroundView.bounds toView:self.view];
        if (CGRectContainsPoint(alertBackgroundViewAbsoluteFrame, touchPoint)) {
            return NO;
        }
    }
    
    // Don't recognize the pan gesture in the button, so users can move their finger away after touching down
    if (([touch.view isKindOfClass:[UIButton class]])) {
        return NO;
    }
    
    return YES;
}

@end
