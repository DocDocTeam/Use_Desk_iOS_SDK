//
//  BlurPresentationController.m
//  UseDesk
//
//  Created by Mark on 17/10/2018.
//

#import "BlurPresentationController.h"

@interface BlurPresentationController()

@property (nonatomic, strong) UIVisualEffectView *effectView;

@end

@implementation BlurPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.effectView = [[UIVisualEffectView alloc] init];
    }
    return self;
}

- (BOOL)shouldPresentInFullscreen {
    return true;
}

- (UIModalPresentationStyle)presentationStyle {
    return UIModalPresentationOverFullScreen;
}

- (void)presentationTransitionWillBegin {
    self.effectView.frame = self.containerView.bounds;
    [self.containerView addSubview:self.effectView];
    id<UIViewControllerTransitionCoordinator> coordinator = self.presentingViewController.transitionCoordinator;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    } completion: nil];
}

- (void)dismissalTransitionWillBegin {
    id<UIViewControllerTransitionCoordinator> coordinator = self.presentingViewController.transitionCoordinator;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.effectView.effect = nil;
    } completion: nil];
}

@end
