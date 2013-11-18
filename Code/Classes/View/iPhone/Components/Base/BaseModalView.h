//
//  BaseModalView.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/21/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommonUtil.h"

typedef void(^ButtonHandler)(void);

#define MODAL_BACKGROUND_ALPHA 0.6

@interface BaseModalView : UIView

@property CGFloat finalAlpha;
@property (strong, nonatomic) UIViewController *parent;
@property (strong, nonatomic) UIView *modal;
@property (strong, nonatomic) ButtonHandler actionButtonHandler;
@property (strong, nonatomic) ButtonHandler closeButtonHandler;
@property (strong, nonatomic) NSTimer *loadingTimer;
@property (strong, nonatomic) UIImageView *loadingImage1;
@property (strong, nonatomic) UIImageView *loadingImage2;
@property (strong, nonatomic) UIImageView *loadingImage3;
@property (strong, nonatomic) NSArray *textFields; // of BaseTextField

/* title + message + close */
- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
         closeButton:(NSString *)closeButtonTitle;

- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
         closeButton:(NSString *)closeButtonTitle
  closeButtonHandler:(ButtonHandler)closeButtonHandler;

/* title + message + action + close */
- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
        actionButton:(NSString *)actionButtonTitle
 actionButtonHandler:(ButtonHandler)actionButtonHandler
         closeButton:(NSString *)closeButtonTitle;

/* title + message + loading */
- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message;

/* title + message + textfield + action + close */
- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
          textFields:(NSArray *)textFields
       keyboardTypes:(NSArray *)keyboardTypes // of UIKeyboardType
      returnKeyTypes:(NSArray *)returnKeyTypes // of UIReturnKeyType
        actionButton:(NSString *)actionButtonTitle
 actionButtonHandler:(ButtonHandler)actionButtonHandler
         closeButton:(NSString *)closeButtonTitle;

- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
          textFields:(NSArray *)textFields
       keyboardTypes:(NSArray *)keyboardTypes // of UIKeyboardType
      returnKeyTypes:(NSArray *)returnKeyTypes // of UIReturnKeyType
        actionButton:(NSString *)actionButtonTitle
 actionButtonHandler:(ButtonHandler)actionButtonHandler
         closeButton:(NSString *)closeButtonTitle
  closeButtonHandler:(ButtonHandler)closeButtonHandler;

/* base constructor */
- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
             loading:(BOOL)loading
          textFields:(NSArray *)textFields
       keyboardTypes:(NSArray *)keyboardTypes // of UIKeyboardType
      returnKeyTypes:(NSArray *)returnKeyTypes // of UIReturnKeyType
        actionButton:(NSString *)actionButtonTitle
 actionButtonHandler:(ButtonHandler)actionButtonHandler
         closeButton:(NSString *)closeButtonTitle
   closeButtonHander:(ButtonHandler)closeButtonHandler;

- (void)show;

- (void)showWithCompletionHandler:(OnEndAnimationHandler)completion;

- (void)hide;

- (void)hideWithCompletionHandler:(OnEndAnimationHandler)completion;

@end
