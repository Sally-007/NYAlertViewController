//
//  NYAlertViewLayout.h
//  NYAlertViewDemo
//
//  Created by guangbool on 16/8/30.
//  Copyright © 2016年 Nealon Young. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  `NYAlertView` 的布局
 */
@interface NYAlertViewLayout : NSObject

@property (nonatomic) UIEdgeInsets titleViewEdgeInsets;

@property (nonatomic) UIEdgeInsets messageTextViewEdgeInsets;

@property (nonatomic) UIEdgeInsets contentViewEdgeInsets;

@property (nonatomic) UIEdgeInsets textFieldContainerViewEdgeInsets;

@property (nonatomic) CGFloat verticalSpacingBetweenActionTextFields;

@property (nonatomic) UIEdgeInsets actionButtonContainerViewEdgeInsets;

@property (nonatomic) CGFloat actionButtonHeight;

@property (nonatomic) CGFloat horizonSpacingBetweenActionButtons;

@property (nonatomic) CGFloat verticalSpacingBetweenActionButtons;

@end
