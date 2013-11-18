//
//  BaseModalView.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/21/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "BaseModalView.h"

#import "UIView+FrameUtils.h"
#import "CommonUtil.h"
#import "ModalManager.h"

#define MODAL_ANIMATION_DURATION_1 0.10
#define MODAL_ANIMATION_DURATION_2 0.15
#define MODAL_TAG_TITLE 1249

@implementation BaseModalView

- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
         closeButton:(NSString *)closeButtonTitle
{
    return [self initWithParent:parent
                backgroundColor:backgroundColor
                      textColor:textColor
                          title:title
                        message:message
                        loading:NO
                     textFields:nil
                  keyboardTypes:nil
                 returnKeyTypes:nil
                   actionButton:nil
            actionButtonHandler:nil
                    closeButton:closeButtonTitle
              closeButtonHander:nil];
}

- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
         closeButton:(NSString *)closeButtonTitle
  closeButtonHandler:(ButtonHandler)closeButtonHandler
{
    return [self initWithParent:parent
                backgroundColor:backgroundColor
                      textColor:textColor
                          title:title
                        message:message
                        loading:NO
                     textFields:nil
                  keyboardTypes:nil
                 returnKeyTypes:nil
                   actionButton:nil
            actionButtonHandler:nil
                    closeButton:closeButtonTitle
              closeButtonHander:closeButtonHandler];
    
}

- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
        actionButton:(NSString *)actionButtonTitle
 actionButtonHandler:(ButtonHandler)actionButtonHandler
         closeButton:(NSString *)closeButtonTitle
{
    return [self initWithParent:parent
                backgroundColor:backgroundColor
                      textColor:textColor
                          title:title
                        message:message
                        loading:NO
                     textFields:nil
                  keyboardTypes:nil
                 returnKeyTypes:nil
                   actionButton:actionButtonTitle
            actionButtonHandler:actionButtonHandler
                    closeButton:closeButtonTitle
              closeButtonHander:nil];
}

- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
{
    return [self initWithParent:parent
                backgroundColor:backgroundColor
                      textColor:textColor
                          title:title
                        message:message
                        loading:YES
                     textFields:nil
                  keyboardTypes:nil
                 returnKeyTypes:nil
                   actionButton:nil
            actionButtonHandler:nil
                    closeButton:nil
              closeButtonHander:nil];
}

- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
          textFields:(NSArray *)textFields
       keyboardTypes:(NSArray *)keyboardTypes
      returnKeyTypes:(NSArray *)returnKeyTypes
        actionButton:(NSString *)actionButtonTitle
 actionButtonHandler:(ButtonHandler)actionButtonHandler
         closeButton:(NSString *)closeButtonTitle

{
    return [self initWithParent:parent
                backgroundColor:backgroundColor
                      textColor:textColor
                          title:title
                        message:message
                        loading:NO
                     textFields:textFields
                  keyboardTypes:keyboardTypes
                 returnKeyTypes:returnKeyTypes
                   actionButton:actionButtonTitle
            actionButtonHandler:actionButtonHandler
                    closeButton:closeButtonTitle
              closeButtonHander:nil];
}

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
  closeButtonHandler:(ButtonHandler)closeButtonHandler
{
    return [self initWithParent:parent
                backgroundColor:backgroundColor
                      textColor:textColor
                          title:title
                        message:message
                        loading:NO
                     textFields:textFields
                  keyboardTypes:keyboardTypes
                 returnKeyTypes:returnKeyTypes
                   actionButton:actionButtonTitle
            actionButtonHandler:actionButtonHandler
                    closeButton:closeButtonTitle
              closeButtonHander:closeButtonHandler];
}

- (id)initWithParent:(UIViewController *)parent
     backgroundColor:(UIColor *)backgroundColor
           textColor:(UIColor *)textColor
               title:(NSString *)title
             message:(NSString *)message
             loading:(BOOL)loading
          textFields:(NSArray *)textFields
       keyboardTypes:(NSArray *)keyboardTypes
      returnKeyTypes:(NSArray *)returnKeyTypes
actionButton:(NSString *)actionButtonTitle
 actionButtonHandler:(ButtonHandler)actionButtonHandler
         closeButton:(NSString *)closeButtonTitle
   closeButtonHander:(ButtonHandler)closeButtonHandler;
{
    self = [super initWithFrame:parent.view.frame];
    if (self) {
        
        self.finalAlpha = MODAL_BACKGROUND_ALPHA;
        CGFloat height = 0;
        
        self.parent = parent;
        
        self.modal = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 30, 200)];
        self.modal.backgroundColor = backgroundColor;
        
        CGFloat paddingTop = 20;
        CGFloat paddingBottom = 10;
        
        height += paddingTop;
        
        if (title != nil) {

            CGFloat titlePaddingSide = 10;
            CGFloat titleWidth = self.modal.frame.size.width - 2*titlePaddingSide;
            CGFloat titleHeight = 40;
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingTop, titleWidth, titleHeight)];
            titleLabel.text = title;
            titleLabel.font = [UIFont systemFontOfSize:38];
            titleLabel.textColor = textColor;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.tag = MODAL_TAG_TITLE;
            [self.modal addSubview:titleLabel];
            [titleLabel frameCenterHorizontallyInParent];
            height += titleHeight;
            
        }
        
        if (message != nil) {
            
            CGFloat msgPaddingSide = 10;
            CGFloat msgLineHeight = 28;
            CGFloat lineWidth = self.modal.frame.size.width - 2*msgPaddingSide;
            UIFont *font = [UIFont systemFontOfSize:24];

            NSMutableArray *wordArray = [NSMutableArray arrayWithArray:[message componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            
            while (wordArray.count > 0) {
                
                UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(msgPaddingSide, height, lineWidth, msgLineHeight)];
                msgLabel.textAlignment = NSTextAlignmentCenter;
                msgLabel.textColor = textColor;
                msgLabel.backgroundColor = [UIColor clearColor];
                msgLabel.font = font;
                [self.modal addSubview:msgLabel];
                
                height += msgLabel.frame.size.height;
                
                NSString *lineMessage = @"";
                NSMutableString *nextLineMessage = [NSMutableString stringWithString:@""];
                
                NSString *word = [wordArray objectAtIndex:0];
                [nextLineMessage appendString:[NSString stringWithFormat:@"%@ ", word]];

                while (([nextLineMessage sizeWithFont:font].width < lineWidth) && (wordArray.count > 0)) {
                
                    lineMessage = [NSString stringWithString:nextLineMessage];
                    [wordArray removeObjectAtIndex:0];
                    
                    if (wordArray.count > 0) {
                        NSString *word = [wordArray objectAtIndex:0];
                        [nextLineMessage appendString:[NSString stringWithFormat:@"%@ ", word]];
                    }
                    
                }
                
                msgLabel.text = lineMessage;
                [msgLabel frameCenterHorizontallyInParent];
            }
        
        }
 
        CGFloat buttonsPadding = 10;
        height += buttonsPadding;
        
        if (loading) {
            CGFloat imageSide = 10;
            CGFloat imageSidePadding = 2;
            CGFloat viewWidth = 3*(imageSide + 2*imageSidePadding);
            CGFloat viewHeight = imageSide + 2*imageSidePadding;
            
            UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, height, viewWidth, viewHeight)];
            
            self.loadingImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bola_process.png"]];
            self.loadingImage1.alpha = 1.0;
            self.loadingImage1.frame = CGRectMake(imageSidePadding, imageSidePadding, imageSide, imageSide);
            [loadingView addSubview:self.loadingImage1];

            self.loadingImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bola_process.png"]];
            self.loadingImage1.alpha = 0.3;
            self.loadingImage2.frame = CGRectMake(3*imageSidePadding + imageSide, imageSidePadding, imageSide, imageSide);
            [loadingView addSubview:self.loadingImage2];

            self.loadingImage3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bola_process.png"]];
            self.loadingImage1.alpha = 0.3;
            self.loadingImage3.frame = CGRectMake(5*imageSidePadding + 2*imageSide, imageSidePadding, imageSide, imageSide);
            [loadingView addSubview:self.loadingImage3];
            
            [self.modal addSubview:loadingView];
            
            [loadingView frameCenterHorizontallyInParent];
            
            [self.loadingTimer invalidate];
            self.loadingTimer = nil;
            self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(nextLoadingImage) userInfo:nil repeats:NO];
            
            height += viewHeight;
        }
        
        NSMutableArray *mutableTextFields = [NSMutableArray arrayWithCapacity:3];
        
        if (textFields != nil) {
            for (int i = 0; i < textFields.count; i++) {
            
                CGFloat textFieldHeight = 40;
                
                id<UITextFieldDelegate> delegate = nil;
                if ([self.parent conformsToProtocol:@protocol(UITextFieldDelegate)]) {
                    delegate = (id<UITextFieldDelegate>)self.parent;
                }
                
                /*
                BaseTextField *textFieldView = [[BaseTextField alloc] initWithFrame:CGRectMake(0, height, self.modal.frame.size.width - 30, textFieldHeight)
                                                                        placeholder:[textFields objectAtIndex:i]
                                                                          textColor:backgroundColor
                                                                           delegate:delegate
                                                                       keyboardType:[[keyboardTypes objectAtIndex:i] intValue]
                                                                      returnKeyType:[[returnKeyTypes objectAtIndex:i] intValue]
                                                ];
                */
                
                UITextField *textFieldView = [[UITextField alloc] initWithFrame:CGRectMake(0, height, self.modal.frame.size.width - 30, textFieldHeight)];
                textFieldView.placeholder = [textFields objectAtIndex:i];
                textFieldView.clearButtonMode = UITextFieldViewModeAlways;
                textFieldView.backgroundColor = [UIColor whiteColor];
                textFieldView.textColor = [UIColor blackColor];
                textFieldView.borderStyle = UITextBorderStyleRoundedRect;
                textFieldView.autocapitalizationType = UITextAutocapitalizationTypeNone;
                textFieldView.keyboardType = [[keyboardTypes objectAtIndex:i] intValue];
                textFieldView.returnKeyType = [[returnKeyTypes objectAtIndex:i] intValue];
                textFieldView.autocorrectionType = UITextAutocorrectionTypeNo;
                textFieldView.delegate = delegate;

                
                [mutableTextFields addObject:textFieldView];
                [self.modal addSubview:textFieldView];
                [textFieldView frameCenterHorizontallyInParent];
                height += textFieldHeight;
            }
        }
        
        self.textFields = [NSArray arrayWithArray:mutableTextFields];
        
        if (actionButtonTitle != nil) {
            self.actionButtonHandler = actionButtonHandler;
            
            CGFloat actionButtonHeight = 40;
            UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            actionButton.frame = CGRectMake(0, height, self.modal.frame.size.width, actionButtonHeight);
            [actionButton addTarget:self action:@selector(executeActionHandler) forControlEvents:UIControlEventTouchUpInside];
            [actionButton setBackgroundImage:[CommonUtil imageWithColor:[UIColor blueColor] size:CGSizeMake(actionButton.frame.size.width, actionButton.frame.size.height)]
                                    forState:UIControlStateNormal];
            [actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [actionButton setTitle:actionButtonTitle forState:UIControlStateNormal];
            [self.modal addSubview:actionButton];
            
            height += actionButtonHeight;
        }
        
        if (closeButtonTitle != nil) {
            self.closeButtonHandler = closeButtonHandler;

            CGFloat closeButtonHeight = 40;
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            closeButton.frame = CGRectMake(0, height, self.modal.frame.size.width, closeButtonHeight);
            [closeButton addTarget:self action:@selector(executeCloseHandler) forControlEvents:UIControlEventTouchUpInside];
            [closeButton setBackgroundImage:[CommonUtil imageWithColor:[UIColor blueColor] size:CGSizeMake(closeButton.frame.size.width, closeButton.frame.size.height)]
                                    forState:UIControlStateNormal];
            [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [closeButton setTitle:closeButtonTitle forState:UIControlStateNormal];
            [self.modal addSubview:closeButton];
            
            height += closeButtonHeight;
        }
        
        height += paddingBottom;
        
        [self.modal frameResizeToHeight:height];
        [CommonUtil addShadowToView:self.modal withColor:[UIColor blackColor] alpha:0.8 radius:10.0 offset:CGSizeMake(0.0, 0.0)];        
    }
    return self;
}

- (void)show
{
    [self showWithCompletionHandler:nil];
}

- (void)showWithCompletionHandler:(OnEndAnimationHandler)completion
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    [self.parent.view addSubview:self];                             
    [UIView animateWithDuration:MODAL_ANIMATION_DURATION_1
                     animations:^{
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.finalAlpha];
                     }
                     completion:^(BOOL finished){
                         [self addSubview:self.modal];
                         [self.modal frameCenterInParent];
                         
                         CGFloat grow = 1.1;
                         CGFloat normal = (float)1.0 / (float)grow;
                         
                         [UIView animateWithDuration:MODAL_ANIMATION_DURATION_2
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.transform = CGAffineTransformScale(self.transform, grow, grow);
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:MODAL_ANIMATION_DURATION_2
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseInOut
                                                               animations:^{
                                                                   self.transform = CGAffineTransformScale(self.transform, normal, normal);
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   
                                                                   if (completion != nil) {
                                                                       completion();
                                                                   }
                                                                   
                                                               }
                                               ];
                                          }
                        ];
     
                     }
    ];
}

- (void)executeActionHandler
{
    if (self.actionButtonHandler != nil) {
        self.actionButtonHandler();
    }
}

- (void)executeCloseHandler
{
    if (self.closeButtonHandler != nil) {
        self.closeButtonHandler();
    } else {
        [[ModalManager getInstance] hide:self];
    }
}

- (void)hide
{
    [[ModalManager getInstance] hideWithCompletionHandler:nil];
}

- (void)hideWithCompletionHandler:(OnEndAnimationHandler)completion
{
    [self.loadingTimer invalidate];
    self.loadingTimer = nil;
 
    CGFloat grow = 1.1;
    CGFloat normal = (float)1.0 / (float)grow;
    [UIView animateWithDuration:MODAL_ANIMATION_DURATION_2
                     animations:^{
                         self.transform = CGAffineTransformScale(self.transform, grow, grow);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:MODAL_ANIMATION_DURATION_2
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.transform = CGAffineTransformScale(self.transform, normal, normal);
                                          }
                                          completion:^(BOOL finished) {
                                              [self.modal removeFromSuperview];                                              
                                              [UIView animateWithDuration:MODAL_ANIMATION_DURATION_1
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseInOut
                                                               animations:^{
                                                                   self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [self removeFromSuperview];
                                                                   
                                                                   if (completion != nil) {
                                                                       completion();
                                                                   }
                                                                   
                                                               }
                                               ];
                                          }
                          ];
                     }
     ];
}

- (void)nextLoadingImage
{
    [self.loadingTimer invalidate];
    self.loadingTimer = nil;
    
    CGFloat nextTimer = 0.25;
    if (float_equal(self.loadingImage1.alpha, 1.0)) {
        
        self.loadingImage1.alpha = 0.3;
        self.loadingImage2.alpha = 1.0;
        
    } else if (float_equal(self.loadingImage2.alpha, 1.0)) {

        self.loadingImage2.alpha = 0.3;
        self.loadingImage3.alpha = 1.0;
        
        nextTimer = 0.5;
        
    } else if (float_equal(self.loadingImage3.alpha, 1.0)) {

        self.loadingImage3.alpha = 0.3;
        self.loadingImage1.alpha = 1.0;
        
    }
    
    self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:nextTimer target:self selector:@selector(nextLoadingImage) userInfo:nil repeats:NO];
    
}

@end
