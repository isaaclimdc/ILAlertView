//
// ILAlertView
// Version 1.1
// Created by Isaac Lim (isaacl.net) on 1/1/13.
//

#define kMaxWidth 280.0f
#define kMaxHeight 300.0f
#define kTitleOneLineHeight 33.0f
#define kMaxTitleHeight 50.0f
#define kBuffer 5.0f
#define kMaxMessageHeight (kMaxHeight - titleLabel.frame.size.height - 3*kBuffer - kButtonHeight)
#define kLabelAutosizeExtra 10.0f
#define kTextViewAutosizeExtra 30.0f

#define kOneButtonMaxWidth kMaxWidth/2
#define kButtonHeight 30.0f
#define kAnimateInDuration 0.4
#define kAnimateOutDuration 0.3
#define kOverlayMaxAlpha 0.2

#import "ILAlertView.h"

@interface ILAlertView() {
    UILabel *titleLabel;
    UITextView *messageView;
    UIWindow *window;
    UIView *overlay;
}
@property (nonatomic, copy) void (^storedBlock)(NSInteger buttonIndex);
@end

@implementation ILAlertView

@synthesize title = _title, message = _message;

- (ILAlertView *)initWithTitle:(NSString *)title
                       message:(NSString *)message
              closeButtonTitle:(NSString *)closeTitle
             secondButtonTitle:(NSString *)secondTitle
           tappedButtonAtIndex:(void(^)(NSInteger buttonIndex))block;
{
    window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    
    CGRect frame = CGRectMake((window.frame.size.width-kMaxWidth)/2,
                              (window.frame.size.height-kMaxHeight)/2,
                              kMaxWidth,
                              kMaxHeight);

    self = [super initWithFrame:frame];
    
    if (self) {
        /* ivars */
        self.title = title;
        self.message = message;
        self.storedBlock = block;
        
        /* self customization */
        self.backgroundColor = [UIColor colorWithPatternImage:kILAlertViewBkgPatternImage];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 3);
        self.layer.shadowOpacity = 0.2;
        self.layer.cornerRadius = 5.0f;

        /* titleLabel */
        CGSize actualTitleSize = [self.title sizeWithFont:kILAlertViewTitleFont constrainedToSize:CGSizeMake(frame.size.width, kMaxTitleHeight)];
        CGFloat titleHeight = MIN(actualTitleSize.height+kLabelAutosizeExtra, kMaxTitleHeight);
        
        titleLabel = [[UILabel alloc] initWithFrame:
                     CGRectMake(0,
                                kBuffer,
                                frame.size.width,
                                titleHeight)];
        titleLabel.text = self.title;
        if (titleHeight > kTitleOneLineHeight)
            titleLabel.numberOfLines = 2;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = kILAlertViewTitleFont;
        titleLabel.textColor = kILAlertViewTitleColor;
        [self addSubview:titleLabel];

        /* messageView */
        CGSize actualMessageSize = [self.message sizeWithFont:kILAlertViewMessageFont constrainedToSize:CGSizeMake(frame.size.width, kMaxMessageHeight)];
        CGFloat messageHeight = MIN(actualMessageSize.height+kTextViewAutosizeExtra, kMaxMessageHeight);

        messageView = [[UITextView alloc] initWithFrame:
                       CGRectMake(0,
                                  titleLabel.frame.size.height+kBuffer,
                                  frame.size.width,
                                  messageHeight)];
        messageView.text = self.message;
        messageView.editable = NO;
        messageView.backgroundColor = [UIColor clearColor];
        messageView.textAlignment = NSTextAlignmentCenter;
        messageView.font = kILAlertViewMessageFont;
        messageView.textColor = kILAlertViewMessageColor;
        if (messageHeight < kMaxMessageHeight)
            messageView.scrollEnabled = NO;
        [self addSubview:messageView];

        /* buttons */
        CGPoint buttonOrigin = CGPointMake((frame.size.width-kOneButtonMaxWidth)/2,
                                           messageView.frame.origin.y + messageView.frame.size.height + kBuffer);
        
        if (secondTitle) {
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [closeButton setTitle:secondTitle forState:UIControlStateNormal];
            [closeButton setTitleColor:kILAlertViewSecondButtonColorDefault forState:UIControlStateNormal];
            [closeButton setTitleColor:kILAlertViewButtonColorSelected forState:UIControlStateHighlighted];
            closeButton.titleLabel.font = kILAlertViewButtonFont;
            closeButton.tag = 1;
            [closeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

            [closeButton sizeToFit];
            closeButton.frame = CGRectMake(0,
                                           buttonOrigin.y,
                                           kOneButtonMaxWidth,
                                           kButtonHeight);
            [self addSubview:closeButton];

            buttonOrigin.x = kOneButtonMaxWidth;
        }

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setTitle:closeTitle forState:UIControlStateNormal];
        [closeButton setTitleColor:kILAlertViewButtonColorDefault forState:UIControlStateNormal];
        [closeButton setTitleColor:kILAlertViewButtonColorSelected forState:UIControlStateHighlighted];
        closeButton.titleLabel.font = kILAlertViewButtonFont;
        closeButton.tag = 0;
        [closeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [closeButton sizeToFit];
        closeButton.frame = CGRectMake(buttonOrigin.x,
                                       buttonOrigin.y,
                                       kOneButtonMaxWidth,
                                       kButtonHeight);
        [self addSubview:closeButton];

        /* Adjust overall frame */
        CGFloat totalHeight = closeButton.frame.origin.y+kButtonHeight+kBuffer;
        if (totalHeight < kMaxHeight) {
            CGRect rect = self.frame;
            rect.size.height = totalHeight;
            self.frame = rect;
            self.center = window.center;
        }
    }
    
    return self;
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
    if (self.storedBlock)
        self.storedBlock(tag);
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
    overlay = [[UIView alloc] initWithFrame:window.frame];
    overlay.backgroundColor = [UIColor blackColor];
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
