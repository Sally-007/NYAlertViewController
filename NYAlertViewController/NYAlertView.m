//
//  NYAlertView.m
//
//  Created by Nealon Young on 7/13/15.
//  Copyright (c) 2015 Nealon Young. All rights reserved.
//

#import "NYAlertView.h"

@implementation NYAlertTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    [self commonInit];
    
    return self;
}
//
//- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
//    self = [super initWithFrame:frame textContainer:textContainer];
//
//    self.textContainerInset = UIEdgeInsetsZero;
//    [self commonInit];
//
//    return self;
//}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
//    self.editable = NO;
    self.textAlignment = NSTextAlignmentLeft;
    self.textColor = [UIColor darkGrayColor];
    self.numberOfLines = 0;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
//    self.scrollEnabled = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize])) {
        [self invalidateIntrinsicContentSize];
    }
}

//- (CGSize)intrinsicContentSize {
//    if ([self.text length]) {
//        return self.contentSize;
//    } else {
//        return CGSizeZero;
//    }
//}

@end

@implementation UIButton (BackgroundColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    [self setBackgroundImage:[self imageWithColor:color] forState:state];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation NYAlertViewButton

+ (id)buttonWithType:(UIButtonType)buttonType {
    return [super buttonWithType:UIButtonTypeCustom];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shouldRasterize = YES;
    
    self.layer.borderWidth = 1.0f;
    
    self.cornerRadius = 4.0f;
    self.clipsToBounds = YES;
    
    [self tintColorDidChange];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self invalidateIntrinsicContentSize];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    if (self.type == NYAlertViewButtonTypeFilled) {
        if (self.enabled) {
            [self setBackgroundColor:self.tintColor];
        }
    } else {
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
    
    self.layer.borderColor = self.tintColor.CGColor;
    
    [self setNeedsDisplay];
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGSize)intrinsicContentSize {
    if (self.hidden) {
        return CGSizeZero;
    }
    
    return CGSizeMake([super intrinsicContentSize].width + 12.0f, 30.0f);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.layer.borderColor = self.tintColor.CGColor;
    
    if (self.type == NYAlertViewButtonTypeBordered) {
        self.layer.borderWidth = 1.0f;
    } else {
        self.layer.borderWidth = 0.0f;
    }
    
    if (self.state == UIControlStateHighlighted) {
        self.layer.backgroundColor = self.tintColor.CGColor;
    } else {
        if (self.type == NYAlertViewButtonTypeBordered) {
            self.layer.backgroundColor = nil;
            [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        } else {

        }
    }
}

@end

@interface NYAlertTitleView ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIImageView *titleImageView;

@end

@implementation NYAlertTitleView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        self.titleLabel = ({
            UILabel *label = [[UILabel alloc]init];
            [label setTranslatesAutoresizingMaskIntoConstraints:NO];
            label.numberOfLines = 2;
            label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor darkGrayColor];
            label;
        });
        
        self.titleLabel.text = title;
        [self addSubview:self.titleLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
    
    return self;
}

- (instancetype)initWithTitleImage:(UIImage *)titleImage {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        self.titleImageView = ({
            UIImageView *imgView = [[UIImageView alloc]initWithImage:titleImage];
            [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
            imgView;
        });
        
        [self addSubview:self.titleImageView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
    
    return self;
}

@end


@interface NYAlertView ()

@property (nonatomic) UIView *titleViewContainerView;
@property (nonatomic) UIView *messageTextViewContainerView;
@property (nonatomic) UIView *contentViewContainerView;
@property (nonatomic) UIView *textFieldContainerView;
@property (nonatomic) UIView *actionButtonContainerView;

@property (nonatomic) NSLayoutConstraint *alertBackgroundWidthConstraint;

@property (nonatomic) NSLayoutConstraint *titleViewContainerViewTopConstraint;
@property (nonatomic) NSLayoutConstraint *titleViewContainerViewLeadingConstraint;
@property (nonatomic) NSLayoutConstraint *titleViewContainerViewTrailingConstraint;

@property (nonatomic) NSLayoutConstraint *messageTextViewContainerViewTopConstraint;
@property (nonatomic) NSLayoutConstraint *messageTextViewContainerViewLeadingConstraint;
@property (nonatomic) NSLayoutConstraint *messageTextViewContainerViewTrailingConstraint;

@property (nonatomic) NSLayoutConstraint *contentViewContainerViewTopConstraint;
@property (nonatomic) NSLayoutConstraint *contentViewContainerViewLeadingConstraint;
@property (nonatomic) NSLayoutConstraint *contentViewContainerViewTrailingConstraint;

@property (nonatomic) NSLayoutConstraint *textFieldContainerViewTopConstraint;
@property (nonatomic) NSLayoutConstraint *textFieldContainerViewLeadingConstraint;
@property (nonatomic) NSLayoutConstraint *textFieldContainerViewTrailingConstraint;

@property (nonatomic) NSLayoutConstraint *actionButtonContainerViewTopConstraint;
@property (nonatomic) NSLayoutConstraint *actionButtonContainerViewBottomConstraint;
@property (nonatomic) NSLayoutConstraint *actionButtonContainerViewLeadingConstraint;
@property (nonatomic) NSLayoutConstraint *actionButtonContainerViewTrailingConstraint;

@property (nonatomic) NSLayoutConstraint *cornerIconButtonCenterXConstraint;
@property (nonatomic) NSLayoutConstraint *cornerIconButtonCenterYConstraint;

@end

@implementation NYAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.layout = ({
            NYAlertViewLayout *lout = [[NYAlertViewLayout alloc]init];
            UIEdgeInsets commInsets = UIEdgeInsetsMake(0, 20, 0, 20);
            lout.titleViewEdgeInsets = commInsets;
            lout.messageTextViewEdgeInsets = commInsets;
            lout.contentViewEdgeInsets = commInsets;
            lout.textFieldContainerViewEdgeInsets = commInsets;
            lout.actionButtonContainerViewEdgeInsets = commInsets;
            lout;
        });
        self.maximumWidth = 480.0f;
        
        _alertBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.alertBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.alertBackgroundView.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
        self.alertBackgroundView.layer.cornerRadius = 6.0f;
        self.alertBackgroundView.clipsToBounds = YES;
        [self addSubview:_alertBackgroundView];
        
        _titleViewContainerView = [[UIView alloc]initWithFrame:CGRectZero];
        [self.titleViewContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.titleViewContainerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.alertBackgroundView addSubview:self.titleViewContainerView];
        
        _messageTextViewContainerView = [[UIView alloc]initWithFrame:CGRectZero];
        [self.messageTextViewContainerView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh+1 forAxis:UILayoutConstraintAxisVertical];
        [self.messageTextViewContainerView setContentHuggingPriority:UILayoutPriorityDefaultHigh+1 forAxis:UILayoutConstraintAxisVertical];
        [self.messageTextViewContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.messageTextViewContainerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.alertBackgroundView addSubview:self.messageTextViewContainerView];
        
        _contentViewContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentViewContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.contentViewContainerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.alertBackgroundView addSubview:self.contentViewContainerView];
        
        _textFieldContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.textFieldContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.textFieldContainerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.alertBackgroundView addSubview:self.textFieldContainerView];
        
        _actionButtonContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.actionButtonContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.actionButtonContainerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.alertBackgroundView addSubview:self.actionButtonContainerView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        
        CGFloat alertBackgroundViewWidth = MIN(CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds),
                                               CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds)) * 0.8f;
        
        if (alertBackgroundViewWidth > self.maximumWidth) {
            alertBackgroundViewWidth = self.maximumWidth;
        }
        
        _alertBackgroundWidthConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0.0f
                                                                        constant:alertBackgroundViewWidth];
        
        [self addConstraint:self.alertBackgroundWidthConstraint];
        
        _backgroundViewVerticalCenteringConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                  attribute:NSLayoutAttributeCenterY
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeCenterY
                                                                                 multiplier:1.0f
                                                                                   constant:0.0f];
        
        [self addConstraint:self.backgroundViewVerticalCenteringConstraint];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:0.9f
                                                          constant:0.0f]];
        
        {
            // titleViewContainerView constraints configures
            _titleViewContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.titleViewContainerView
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.alertBackgroundView
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0f
                                                                                 constant:self.layout.titleViewEdgeInsets.top];
            
            [self.alertBackgroundView addConstraint:self.titleViewContainerViewTopConstraint];
            
            _titleViewContainerViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.titleViewContainerView
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.alertBackgroundView
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                   multiplier:1.0f
                                                                                     constant:self.layout.titleViewEdgeInsets.left];
            
            [self.alertBackgroundView addConstraint:self.titleViewContainerViewLeadingConstraint];
            
            _titleViewContainerViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                     attribute:NSLayoutAttributeTrailing
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.titleViewContainerView
                                                                                     attribute:NSLayoutAttributeTrailing
                                                                                    multiplier:1.0f
                                                                                      constant:self.layout.titleViewEdgeInsets.right];
            
            [self.alertBackgroundView addConstraint:self.titleViewContainerViewTrailingConstraint];
        }
        
        {
            // messageTextViewContainerView constraints configures
            CGFloat topSpacing = MAX(self.layout.titleViewEdgeInsets.bottom, self.layout.messageTextViewEdgeInsets.top);
            _messageTextViewContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.messageTextViewContainerView
                                                                                      attribute:NSLayoutAttributeTop
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self.titleViewContainerView
                                                                                      attribute:NSLayoutAttributeBottom
                                                                                     multiplier:1.0f
                                                                                       constant:topSpacing];
            
            [self.alertBackgroundView addConstraint:self.messageTextViewContainerViewTopConstraint];
            
            _messageTextViewContainerViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.messageTextViewContainerView
                                                                                          attribute:NSLayoutAttributeLeading
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:self.alertBackgroundView
                                                                                          attribute:NSLayoutAttributeLeading
                                                                                         multiplier:1.0f
                                                                                           constant:self.layout.messageTextViewEdgeInsets.left];
            
            [self.alertBackgroundView addConstraint:self.messageTextViewContainerViewLeadingConstraint];
            
            _messageTextViewContainerViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                           attribute:NSLayoutAttributeTrailing
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.messageTextViewContainerView
                                                                                           attribute:NSLayoutAttributeTrailing
                                                                                          multiplier:1.0f
                                                                                            constant:self.layout.messageTextViewEdgeInsets.right];
            
            [self.alertBackgroundView addConstraint:self.messageTextViewContainerViewTrailingConstraint];
        }
        
        {
            // contentViewContainerView constraints configures
            CGFloat topSpacing = MAX(self.layout.messageTextViewEdgeInsets.bottom, self.layout.contentViewEdgeInsets.top);
            _contentViewContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.contentViewContainerView
                                                                                  attribute:NSLayoutAttributeTop
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.messageTextViewContainerView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0f
                                                                                   constant:topSpacing];
            
            [self.alertBackgroundView addConstraint:self.contentViewContainerViewTopConstraint];
            
            _contentViewContainerViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.contentViewContainerView
                                                                                      attribute:NSLayoutAttributeLeading
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self.alertBackgroundView
                                                                                      attribute:NSLayoutAttributeLeading
                                                                                     multiplier:1.0f
                                                                                       constant:self.layout.contentViewEdgeInsets.left];
            
            [self.alertBackgroundView addConstraint:self.contentViewContainerViewLeadingConstraint];
            
            _contentViewContainerViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                       attribute:NSLayoutAttributeTrailing
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.contentViewContainerView
                                                                                       attribute:NSLayoutAttributeTrailing
                                                                                      multiplier:1.0f
                                                                                        constant:self.layout.contentViewEdgeInsets.right];
            
            [self.alertBackgroundView addConstraint:self.contentViewContainerViewTrailingConstraint];
        }
        
        {
            // textFieldContainerView constraints configures
            CGFloat topSpacing = MAX(self.layout.contentViewEdgeInsets.bottom, self.layout.textFieldContainerViewEdgeInsets.top);
            _textFieldContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.textFieldContainerView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.contentViewContainerView
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1.0f
                                                                                    constant:topSpacing];
            
            [self.alertBackgroundView addConstraint:self.textFieldContainerViewTopConstraint];
            
            _textFieldContainerViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.textFieldContainerView
                                                                                        attribute:NSLayoutAttributeLeading
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.alertBackgroundView
                                                                                        attribute:NSLayoutAttributeLeading
                                                                                        multiplier:1.0f
                                                                                        constant:self.layout.textFieldContainerViewEdgeInsets.left];
            
            [self.alertBackgroundView addConstraint:self.textFieldContainerViewLeadingConstraint];
            
            _textFieldContainerViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                        attribute:NSLayoutAttributeTrailing
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.textFieldContainerView
                                                                                        attribute:NSLayoutAttributeTrailing
                                                                                        multiplier:1.0f
                                                                                            constant:self.layout.textFieldContainerViewEdgeInsets.right];
            
            [self.alertBackgroundView addConstraint:self.textFieldContainerViewTrailingConstraint];
        }
        
        {
            // actionButtonContainerView constraints configures
            CGFloat topSpacing = MAX(self.layout.textFieldContainerViewEdgeInsets.bottom, self.layout.actionButtonContainerViewEdgeInsets.top);
            _actionButtonContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.actionButtonContainerView
                                                                                   attribute:NSLayoutAttributeTop
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.textFieldContainerView
                                                                                   attribute:NSLayoutAttributeBottom
                                                                                  multiplier:1.0f
                                                                                    constant:topSpacing];
            
            [self.alertBackgroundView addConstraint:self.actionButtonContainerViewTopConstraint];
            
            _actionButtonContainerViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.actionButtonContainerView
                                                                                       attribute:NSLayoutAttributeLeading
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.alertBackgroundView
                                                                                       attribute:NSLayoutAttributeLeading
                                                                                      multiplier:1.0f
                                                                                        constant:self.layout.actionButtonContainerViewEdgeInsets.left];
            
            [self.alertBackgroundView addConstraint:self.actionButtonContainerViewLeadingConstraint];
            
            _actionButtonContainerViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                        attribute:NSLayoutAttributeTrailing
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.actionButtonContainerView
                                                                                        attribute:NSLayoutAttributeTrailing
                                                                                       multiplier:1.0f
                                                                                         constant:self.layout.actionButtonContainerViewEdgeInsets.right];
            
            [self.alertBackgroundView addConstraint:self.actionButtonContainerViewTrailingConstraint];
            
            _actionButtonContainerViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                            attribute:NSLayoutAttributeBottom
                                                                                            relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.actionButtonContainerView
                                                                                            attribute:NSLayoutAttributeBottom
                                                                                        multiplier:1.0f
                                                                                            constant:self.layout.actionButtonContainerViewEdgeInsets.bottom];
            
            [self.alertBackgroundView addConstraint:self.actionButtonContainerViewBottomConstraint];
        }
    }
    
    return self;
}


// Pass through touches outside the backgroundView for the presentation controller to handle dismissal
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if ([subview hitTest:[self convertPoint:point toView:subview] withEvent:event]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setMaximumWidth:(CGFloat)maximumWidth {
    _maximumWidth = maximumWidth;
    self.alertBackgroundWidthConstraint.constant = maximumWidth;
}

- (void)setCornerIconButton:(UIButton *)cornerIconButton {
    [self.cornerIconButton removeFromSuperview];
    
    _cornerIconButton = cornerIconButton;
    
    _cornerIconButtonCenterXConstraint = nil;
    _cornerIconButtonCenterYConstraint = nil;
    
    if (cornerIconButton) {
        [self.cornerIconButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.cornerIconButton];
        
        CGFloat align = self.layout.cornerIconButtonCenterAlignAlertViewTopRightCorner;
        
        _cornerIconButtonCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_cornerIconButton attribute:NSLayoutAttributeCenterX multiplier:1 constant:align];
        
        _cornerIconButtonCenterYConstraint = [NSLayoutConstraint constraintWithItem:_cornerIconButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.alertBackgroundView attribute:NSLayoutAttributeTop multiplier:1 constant:align];
        
        [self addConstraint:_cornerIconButtonCenterXConstraint];
        [self addConstraint:_cornerIconButtonCenterYConstraint];
    }
}

- (void)setTitleView:(NYAlertTitleView *)titleView {
    [self.titleView removeFromSuperview];
    
    _titleView = titleView;
    
    if (titleView) {
        [self.titleView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.titleViewContainerView addSubview:self.titleView];
        
        [self.titleViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleViewContainerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        
        [self.titleViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.titleViewContainerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        
        [self.titleViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleViewContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        
        [self.titleViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleViewContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
    }
}

- (void)setMessageTextView:(NYAlertTextView *)messageTextView {
    [self.messageTextView removeFromSuperview];
    
    _messageTextView = messageTextView;
    
    if (messageTextView) {
        [self.messageTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.messageTextViewContainerView addSubview:self.messageTextView];

//        [self.messageTextViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.messageTextViewContainerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self.messageTextViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.messageTextViewContainerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self.messageTextViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.messageTextViewContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
//        [self.messageTextViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.messageTextViewContainerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        [self.messageTextViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.messageTextViewContainerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        
        [self.messageTextViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.messageTextViewContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        
        [self.messageTextViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.messageTextViewContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];

    }
}

- (void)setContentView:(UIView *)contentView {
    [self.contentView removeFromSuperview];
    
    _contentView = contentView;
    
    if (contentView) {
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentViewContainerView addSubview:self.contentView];

        [self.contentViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentViewContainerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        
        [self.contentViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentViewContainerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        
        [self.contentViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentViewContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        
        [self.contentViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentViewContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
    }
}

- (void)setTextFields:(NSArray *)textFields {
    for (UITextField *textField in self.textFields) {
        [textField removeFromSuperview];
    }
    
    _textFields = textFields;
    
    for (int i = 0; i < [textFields count]; i++) {
        UITextField *textField = textFields[i];
        [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.textFieldContainerView addSubview:textField];
        
        [self.textFieldContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textField]-|"
                                                                                            options:0
                                                                                            metrics:nil
                                                                                              views:NSDictionaryOfVariableBindings(textField)]];
        
        // Pin the first text field to the top of the text field container view
        if (i == 0) {
            [self.textFieldContainerView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textFieldContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        } else {
            UITextField *previousTextField = textFields[i - 1];
            [self.textFieldContainerView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:self.layout.verticalSpacingBetweenActionTextFields]];
        }
        
        // Pin the final text field to the bottom of the text field container view
        if (i == ([textFields count] - 1)) {
            [self.textFieldContainerView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textFieldContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        }
    }
}

- (void)setActionButtons:(NSArray<NYAlertViewButton *> *)actionButtons {
    for (UIButton *button  in self.actionButtons) {
        [button removeFromSuperview];
    }
    
    _actionButtons = actionButtons;
    
    // add height constraint for all action buttons
    [actionButtons enumerateObjectsUsingBlock:^(NYAlertViewButton  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.actionButtonContainerView addSubview:obj];
        [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:obj
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:0
                                                         constant:self.layout.actionButtonHeight]];
    }];
    
    // If there are 2 actions, display the buttons next to each other. Otherwise, stack the buttons vertically at full width
    if ([actionButtons count] == 2) {
        UIButton *firstButton = actionButtons[0];
        UIButton *lastButton = actionButtons[1];
        
        [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:firstButton
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:lastButton
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f]];
        
        [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:firstButton
                                                                                   attribute:NSLayoutAttributeTop
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.actionButtonContainerView
                                                                                   attribute:NSLayoutAttributeTop
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f]];
        
        [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:firstButton
                                                                                   attribute:NSLayoutAttributeBottom
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.actionButtonContainerView
                                                                                   attribute:NSLayoutAttributeBottom
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f]];
        
        [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:firstButton
                                                                                   attribute:NSLayoutAttributeLeading
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.actionButtonContainerView
                                                                                   attribute:NSLayoutAttributeLeading
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f]];
        
        [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:lastButton
                                                                                   attribute:NSLayoutAttributeLeading
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:firstButton
                                                                                   attribute:NSLayoutAttributeTrailing
                                                                                  multiplier:1.0f
                                                                                    constant:self.layout.horizonSpacingBetweenActionButtons]];
        
        [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:lastButton
                                                                                   attribute:NSLayoutAttributeTrailing
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.actionButtonContainerView
                                                                                   attribute:NSLayoutAttributeTrailing
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f]];
        
        [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:firstButton
                                                                                   attribute:NSLayoutAttributeCenterY
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:lastButton
                                                                                   attribute:NSLayoutAttributeCenterY
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f]];
    } else {
        for (int i = 0; i < [actionButtons count]; i++) {
            UIButton *actionButton = actionButtons[i];
            
            [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:actionButton
                                                                                       attribute:NSLayoutAttributeLeading
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.actionButtonContainerView
                                                                                       attribute:NSLayoutAttributeLeading
                                                                                      multiplier:1.0f
                                                                                        constant:0.0f]];
            
            [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:actionButton
                                                                                       attribute:NSLayoutAttributeTrailing
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.actionButtonContainerView
                                                                                       attribute:NSLayoutAttributeTrailing
                                                                                      multiplier:1.0f
                                                                                        constant:0.0f]];
            
            if (i == 0) {
                [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:actionButton
                                                                                           attribute:NSLayoutAttributeTop
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.actionButtonContainerView
                                                                                           attribute:NSLayoutAttributeTop
                                                                                          multiplier:1.0f
                                                                                            constant:0.0f]];
            } else {
                UIButton *previousButton = actionButtons[i - 1];
                
                [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:actionButton
                                                                                           attribute:NSLayoutAttributeTop
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:previousButton
                                                                                           attribute:NSLayoutAttributeBottom
                                                                                          multiplier:1.0f
                                                                                            constant:self.layout.verticalSpacingBetweenActionButtons]];
            }
            
            if (i == ([actionButtons count] - 1)) {
                [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:actionButton
                                                                                           attribute:NSLayoutAttributeBottom
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.actionButtonContainerView
                                                                                           attribute:NSLayoutAttributeBottom
                                                                                          multiplier:1.0f
                                                                                            constant:0.0f]];
            }
        }
    }
}

- (void)setLayout:(NYAlertViewLayout *)layout {
    
    _layout = layout;
    
    self.titleViewContainerViewTopConstraint.constant = layout.titleViewEdgeInsets.top;
    self.titleViewContainerViewLeadingConstraint.constant = layout.titleViewEdgeInsets.left;
    self.titleViewContainerViewTrailingConstraint.constant = layout.titleViewEdgeInsets.right;
    
    self.messageTextViewContainerViewTopConstraint.constant = MAX(layout.titleViewEdgeInsets.bottom, layout.messageTextViewEdgeInsets.top);
    self.messageTextViewContainerViewLeadingConstraint.constant = layout.messageTextViewEdgeInsets.left;
    self.messageTextViewContainerViewTrailingConstraint.constant = layout.messageTextViewEdgeInsets.right;
    
    self.contentViewContainerViewTopConstraint.constant = MAX(layout.messageTextViewEdgeInsets.bottom, layout.contentViewEdgeInsets.top);
    self.contentViewContainerViewLeadingConstraint.constant = layout.contentViewEdgeInsets.left;
    self.contentViewContainerViewTrailingConstraint.constant = layout.contentViewEdgeInsets.right;
    
    self.backgroundViewVerticalCenteringConstraint.constant = layout.centeringInsets.top > 0 ? (-layout.centeringInsets.top) : (layout.centeringInsets.bottom > 0 ? layout.centeringInsets.bottom : 0);

    self.textFieldContainerViewTopConstraint.constant = MAX(layout.contentViewEdgeInsets.bottom, layout.textFieldContainerViewEdgeInsets.top);
    self.textFieldContainerViewLeadingConstraint.constant = layout.textFieldContainerViewEdgeInsets.left;
    self.textFieldContainerViewTrailingConstraint.constant = layout.textFieldContainerViewEdgeInsets.right;
    
    self.actionButtonContainerViewTopConstraint.constant = MAX(layout.textFieldContainerViewEdgeInsets.bottom, layout.actionButtonContainerViewEdgeInsets.top);
    self.actionButtonContainerViewLeadingConstraint.constant = layout.actionButtonContainerViewEdgeInsets.left;
    self.actionButtonContainerViewTrailingConstraint.constant = layout.actionButtonContainerViewEdgeInsets.right;
    self.actionButtonContainerViewBottomConstraint.constant = layout.actionButtonContainerViewEdgeInsets.bottom;
    
    _cornerIconButtonCenterXConstraint.constant = layout.cornerIconButtonCenterAlignAlertViewTopRightCorner;
    _cornerIconButtonCenterYConstraint.constant = layout.cornerIconButtonCenterAlignAlertViewTopRightCorner;
    
}

@end
