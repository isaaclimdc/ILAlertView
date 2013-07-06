//
// ILAlertView
// Version 1.4
// Created by Isaac Lim (isaacl.net) on 1/1/13.
//

#import "ILAlertView.h"
#import "ILAlertViewConfig.h"
#import <QuartzCore/QuartzCore.h>

#define kMaxWidth 280.0f
#define kMaxHeight 300.0f
#define kTitleOneLineHeight 33.0f
#define kMaxTitleHeight 50.0f
#define kBuffer 5.0f
#define kMaxMessageHeight (kMaxHeight - titleLabel.frame.size.height - 3*kBuffer - kButtonHeight)
#define kLabelAutosizeExtra 10.0f
#define kTextViewAutosizeExtra 30.0f

#define kOneButtonMaxWidth (floorf(kMaxWidth/2))
#define kButtonHeight 30.0f
#define kAnimateInDuration 0.4
#define kAnimateOutDuration 0.3
#define kOverlayMaxAlpha 0.2

#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

@interface ILAlertView() {
    UIImageView *bkgImg;
    UILabel *titleLabel;
    UITextView *messageView;
    UIButton *closeButton;
    UIButton *secondButton;
    
    UIWindow *window;
    UIView *overlay;
}
@end

@implementation ILAlertView

- (ILAlertView *)initWithTitle:(NSString *)title
                       message:(NSString *)message
              closeButtonTitle:(NSString *)closeTitle
             secondButtonTitle:(NSString *)secondTitle
           tappedButtonAtIndex:(void(^)(NSInteger buttonIndex))block;
{
    self = [super init];

    if (self) {
        /* ivars */
        self.title = title;
        self.message = message;
        self.storedBlock = block;

        if (!window) {
            UIView *winParent = [[UIApplication sharedApplication].windows objectAtIndex:0];
            window = [winParent.subviews objectAtIndex:0];
        }

        /* self customization */
        UIImage *resizableImg = [kILAlertViewBkgPatternImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        bkgImg = [[UIImageView alloc] initWithImage:resizableImg];
        [self addSubview:bkgImg];

        bkgImg.layer.shadowColor = [UIColor blackColor].CGColor;
        bkgImg.layer.shadowOffset = CGSizeMake(0, 0);
        bkgImg.layer.shadowRadius = 5.0f;
        bkgImg.layer.shadowOpacity = 0.2;
        bkgImg.layer.shouldRasterize = YES;

        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;

        /* titleLabel */
        titleLabel = [[UILabel alloc] init];
        titleLabel.text = self.title;
        titleLabel.numberOfLines = 2;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = kILAlertViewTitleFont;
        titleLabel.textColor = kILAlertViewTitleColor;
        [self addSubview:titleLabel];

        /* messageView */
        messageView = [[UITextView alloc] init];
        messageView.text = self.message;
        messageView.editable = NO;
        messageView.backgroundColor = [UIColor clearColor];
        messageView.textAlignment = NSTextAlignmentCenter;
        messageView.font = kILAlertViewMessageFont;
        messageView.textColor = kILAlertViewMessageColor;
        [self addSubview:messageView];

        /* buttons */
        if (secondTitle) {
            secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [secondButton setTitle:secondTitle forState:UIControlStateNormal];
            [secondButton setTitleColor:kILAlertViewSecondButtonColorDefault forState:UIControlStateNormal];
            [secondButton setTitleColor:kILAlertViewButtonColorSelected forState:UIControlStateHighlighted];
            secondButton.titleLabel.font = kILAlertViewButtonFont;
            secondButton.tag = 1;
            [secondButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:secondButton];
        }
        else {
            secondButton = nil;
        }

        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setTitle:closeTitle forState:UIControlStateNormal];
        [closeButton setTitleColor:kILAlertViewButtonColorDefault forState:UIControlStateNormal];
        [closeButton setTitleColor:kILAlertViewButtonColorSelected forState:UIControlStateHighlighted];
        closeButton.titleLabel.font = kILAlertViewButtonFont;
        closeButton.tag = 0;
        [closeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
    }

    return self;
}

- (void)layoutSubviews
{
    self.frame = CGRectMake(floorf((window.frame.size.width-kMaxWidth)/2),
                            floorf((window.frame.size.height-kMaxHeight)/2),
                            kMaxWidth,
                            kMaxHeight);
    CGSize mainSize = self.frame.size;

    /* Title */
    CGSize actualTitleSize = [self.title sizeWithFont:kILAlertViewTitleFont
                                    constrainedToSize:CGSizeMake(mainSize.width, kMaxTitleHeight)];
    CGFloat titleHeight = MIN(actualTitleSize.height+kLabelAutosizeExtra, kMaxTitleHeight);
    titleLabel.frame = CGRectMake(0,
                                  kBuffer,
                                  mainSize.width,
                                  titleHeight);

    /* Message */
    CGSize actualMessageSize = [self.message sizeWithFont:kILAlertViewMessageFont
                                        constrainedToSize:CGSizeMake(mainSize.width, kMaxMessageHeight)];
    CGFloat messageHeight = MIN(actualMessageSize.height+kTextViewAutosizeExtra, kMaxMessageHeight);
    messageView.frame = CGRectMake(0,
                                   titleLabel.frame.size.height+kBuffer,
                                   mainSize.width,
                                   messageHeight);
    if (messageHeight < kMaxMessageHeight)
        messageView.scrollEnabled = NO;

    /* Buttons */
    CGPoint buttonOrigin = CGPointMake(floorf((mainSize.width-kOneButtonMaxWidth)/2),
                                       messageView.frame.origin.y + messageView.frame.size.height + kBuffer);

    if (secondButton != nil) {
        secondButton.frame = CGRectMake(0,
                                        buttonOrigin.y,
                                        kOneButtonMaxWidth,
                                        kButtonHeight);
        buttonOrigin.x = kOneButtonMaxWidth;
    }
    
    closeButton.frame = CGRectMake(buttonOrigin.x,
                                   buttonOrigin.y,
                                   kOneButtonMaxWidth,
                                   kButtonHeight);

    /* Overall frame */
    CGFloat totalHeight = closeButton.frame.origin.y+kButtonHeight+kBuffer;
    CGRect rect = self.frame;
    rect.size.height = totalHeight;
    self.frame = rect;
    bkgImg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self centerWithOrientation];
}

- (void)centerWithOrientation
{
    if (IS_LANDSCAPE) {
        self.center = CGPointMake(window.center.y, window.center.x);
    }
    else {
        self.center = window.center;
    }
}

+ (ILAlertView *)showWithTitle:(NSString *)title
                       message:(NSString *)message
              closeButtonTitle:(NSString *)closeTitle
             secondButtonTitle:(NSString *)secondTitle
           tappedButtonAtIndex:(void(^)(NSInteger buttonIndex))block
{
    ILAlertView *alert = [[ILAlertView alloc] initWithTitle:title
                                                    message:message
                                           closeButtonTitle:closeTitle
                                          secondButtonTitle:secondTitle
                                        tappedButtonAtIndex:block];

    [alert showAlertAnimated:YES];

    return alert;
}

- (IBAction)buttonTapped:(id)sender {
    NSUInteger tag = ((UIButton *)sender).tag;
    if (self.storedBlock) {
        self.storedBlock(tag);
    }
    [self dismissAlertAnimated:YES];
}

#pragma mark - Animate Alert

- (void)showAlertAnimated:(BOOL)animated {
    [self showOverlayAnimated:animated];

    [window addSubview:self];
    [messageView becomeFirstResponder];

    if (animated) {
        self.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{self.alpha = 1.0;}];

        self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);

        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.5],
                                  [NSNumber numberWithFloat:1.2],
                                  [NSNumber numberWithFloat:0.9],
                                  [NSNumber numberWithFloat:1.0], nil];
        bounceAnimation.duration = kAnimateInDuration;
        bounceAnimation.removedOnCompletion = NO;
        [self.layer addAnimation:bounceAnimation forKey:@"bounce"];

        self.layer.transform = CATransform3DIdentity;
    }
}

- (void)dismissAlertAnimated:(BOOL)animated {
    [self dismissOverlayAnimated:animated];

    [UIView animateWithDuration:kAnimateOutDuration animations:^{self.alpha = 0.0;}];

    self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);

    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0],
                              [NSNumber numberWithFloat:1.1],
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:0.0], nil];
    bounceAnimation.duration = kAnimateOutDuration;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.delegate = self;
    [self.layer addAnimation:bounceAnimation forKey:@"bounce"];

    self.layer.transform = CATransform3DIdentity;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (flag)
        [self removeFromSuperview];
}

#pragma mark - Animate Overlay

- (void)showOverlayAnimated:(BOOL)animated {
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    overlay.backgroundColor = [UIColor blackColor];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [window addSubview:overlay];

    if (animated) {
        overlay.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{
            overlay.alpha = kOverlayMaxAlpha;
        }];
    }
    else {
        overlay.alpha = kOverlayMaxAlpha;
    }

}

- (void)dismissOverlayAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            overlay.alpha = 0.0;
        } completion:^(BOOL finished) {
            [overlay removeFromSuperview];
        }];
    }
    else {
        [overlay removeFromSuperview];
    }
}

@end
