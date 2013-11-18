//
//  ModalManager.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 3/21/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "ModalManager.h"

#import "UIView+FrameUtils.h"

#define MODAL_MAKUKULA_TAG 666888

@implementation ModalManager

+ (id)getInstance {
	static ModalManager *instance = nil;
	@synchronized(self) {
		if (instance == nil) {
			instance = [[ModalManager alloc] init];
		}
		return instance;
	}
}

- (id)init {
	if (self = [super init]) {
        self.modals = [NSMutableArray arrayWithCapacity:5];
	}
	return self;
}

- (BOOL)isShowingModal
{
    return ([self top].superview != nil);
}

- (BaseModalView *)top
{
    return (self.modals.count > 0)? [self.modals objectAtIndex:(self.modals.count - 1)] : nil;
}

- (void)frameMoveByYDelta:(CGFloat)delta
{
    for (UIView *modal in self.modals) {
        [modal frameMoveByYDelta:delta];
    }
}

- (void)pushAndShow:(BaseModalView *)modal
{
    [self pushAndShow:modal hidingOthers:YES];
}

- (void)pushAndShow:(BaseModalView *)modal hidingOthers:(BOOL)hideOthers
{
    [self pushAndShow:modal hidingOthers:hideOthers withCompletionHandler:nil];
}

- (void)pushAndShow:(BaseModalView *)modal hidingOthers:(BOOL)hideOthers withCompletionHandler:(OnEndAnimationHandler)completion
{
    [self push:modal hidingOthers:hideOthers];
    [self showTopHidingOthers:hideOthers withCompletionHandler:completion];
}

- (void)push:(BaseModalView *)modal
{
    [self push:modal hidingOthers:YES];
}

- (void)push:(BaseModalView *)modal hidingOthers:(BOOL)hideOthers
{
    if (!hideOthers && self.modals.count > 0) {
        modal.finalAlpha = 0.0;
        [self addMakukula:[self.modals lastObject]];
    }
    [self.modals addObject:modal];
}

- (void)showTopHidingOthers:(BOOL)hideOthers
{
    [self showTopHidingOthers:hideOthers withCompletionHandler:nil];
}

- (void)hideNextWithCompletionHandler:(OnEndAnimationHandler)completion
{
    if (self.modals.count > 1) {
        NSInteger next = (self.modals.count - 2);
        BaseModalView *modal = [self.modals objectAtIndex:next];
        [self.modals removeObjectAtIndex:next];
        [self removeMakukula:modal];
        [modal hideWithCompletionHandler:^{
            [self hideNextWithCompletionHandler:completion];
        }];
    } else {
        if (completion != nil) {
            completion();
        }        
    }
}

- (void)showTopHidingOthers:(BOOL)hideOthers withCompletionHandler:(OnEndAnimationHandler)completion
{
    if (hideOthers) {
        [self hideNextWithCompletionHandler:^{
            [[self top] showWithCompletionHandler:completion];
        }];
    } else {
        [[self top] showWithCompletionHandler:completion];
    }
}

- (void)showTop
{
    [self showTopHidingOthers:YES];
}

- (void)showTopWithCompletionHandler:(OnEndAnimationHandler)completion
{
    [self showTopHidingOthers:YES withCompletionHandler:completion];
}

- (void)hideTop
{
    [self hideTopWithCompletionHandler:nil];
}

- (void)hideTopWithCompletionHandler:(OnEndAnimationHandler)completion
{
    [[self top] hideWithCompletionHandler:^{
        if (self.modals.count > 0) {
            [self.modals removeObjectAtIndex:(self.modals.count - 1)];
        }
        [self removeMakukula:[self top]];        
        if (completion != nil) {
            completion();
        }
    }];
}

- (void)hide:(BaseModalView *)modal
{
    [self hide:modal withCompletionHandler:nil];
}

- (void)hide:(BaseModalView *)modal withCompletionHandler:(OnEndAnimationHandler)completion
{
    if (modal == [self top]) {
        [self hideTopWithCompletionHandler:completion];
    } else {
        [modal hideWithCompletionHandler:completion]; // No es el caso normal. Lo pongo por si acaso.
    }
}

- (void)addMakukula:(BaseModalView *)modal
{
    UIView *makukulaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, modal.modal.frame.size.width, modal.modal.frame.size.width)];
    makukulaView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:MODAL_BACKGROUND_ALPHA];
    makukulaView.tag = MODAL_MAKUKULA_TAG;
    [modal.modal addSubview:makukulaView];
}

- (void)removeMakukula:(BaseModalView *)modal
{
    UIView *makukulaView = [modal.modal viewWithTag:MODAL_MAKUKULA_TAG];
    [makukulaView removeFromSuperview];
}

@end
