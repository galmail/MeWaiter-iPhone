//
//  ModalManager.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 3/21/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseModalView.h"

@interface ModalManager : NSObject

@property (strong, nonatomic) NSMutableArray *modals;

+ (id)getInstance;

- (BOOL)isShowingModal;

- (void)frameMoveByYDelta:(CGFloat)delta;

- (BaseModalView *)top;

- (void)pushAndShow:(BaseModalView *)modal;

- (void)pushAndShow:(BaseModalView *)modal hidingOthers:(BOOL)hideOthers;

- (void)pushAndShow:(BaseModalView *)modal hidingOthers:(BOOL)hideOthers withCompletionHandler:(OnEndAnimationHandler)completion;

- (void)push:(BaseModalView *)modal hidingOthers:(BOOL)hideOthers;

- (void)push:(BaseModalView *)modal;

- (void)showTopHidingOthers:(BOOL)hideOthers;

- (void)showTopHidingOthers:(BOOL)hideOthers withCompletionHandler:(OnEndAnimationHandler)completion;

- (void)showTop;

- (void)showTopWithCompletionHandler:(OnEndAnimationHandler)completion;

- (void)hideTop;

- (void)hideTopWithCompletionHandler:(OnEndAnimationHandler)completion;

- (void)hide:(BaseModalView *)modal;

- (void)hide:(BaseModalView *)modal withCompletionHandler:(OnEndAnimationHandler)completion;

@end
