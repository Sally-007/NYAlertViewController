//
//  NYAlertView.h
//
//  Created by Nealon Young on 7/13/15.
//  Copyright (c) 2015 Nealon Young. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYAlertViewLayout.h"
/**
 *  给定默认设置的 textView
 */
@interface NYAlertTextView : UILabel

@end

typedef NS_ENUM(NSInteger, NYAlertViewButtonType) {
    NYAlertViewButtonTypeFilled,
    NYAlertViewButtonTypeBordered
};

@interface UIButton (BackgroundColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@end

@interface NYAlertViewButton : UIButton

@property (nonatomic) NYAlertViewButtonType type;

@property (nonatomic) CGFloat cornerRadius;

@end


@interface NYAlertTitleView : UIView

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UIImageView *titleImageView;

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitleImage:(UIImage *)titleImage;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end


@interface NYAlertView : UIView

@property (nonatomic) NYAlertViewLayout *layout;

@property (nonatomic) UIButton *cornerIconButton;
@property (nonatomic) NYAlertTitleView *titleView;
@property (nonatomic) NYAlertTextView *messageTextView;
@property (nonatomic) UIView *contentView;

@property (nonatomic) CGFloat maximumWidth;

@property (nonatomic, readonly) UIView *alertBackgroundView;

@property (nonatomic, readonly) NSLayoutConstraint *backgroundViewVerticalCenteringConstraint;

@property (nonatomic) NSArray<NYAlertViewButton *> *actionButtons;

@property (nonatomic) NSArray<UITextField *> *textFields;

@end
