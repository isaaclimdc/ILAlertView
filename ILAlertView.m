//
// ILAlertView
// Version 1.4.1
// Created by Isaac Lim (isaacl.net) on 1/1/13.
//

#import "ILAlertView.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - Background Pattern Image

/* Change this to whatever pattern you want to use. For best results, use
 * use an image that can be seamlessly tiled in multiple directions
 */
#define kILAlertViewBkgPatternImage [UIImage imageNamed:@"alertBkg.png"]

#pragma mark - Fonts

/* ILAlertView looks great with the Avenir font, but this is only available
 * by default on iOS 6. Feel free to uncomment the bottom 3 lines if you wish.
 */
#define kILAlertViewTitleFont [UIFont boldSystemFontOfSize:20]
#define kILAlertViewMessageFont [UIFont systemFontOfSize:16]
#define kILAlertViewButtonFont [UIFont boldSystemFontOfSize:16]
//#define kILAlertViewTitleFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:20]
//#define kILAlertViewMessageFont [UIFont fontWithName:@"AvenirNext-Regular" size:16]
//#define kILAlertViewButtonFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:16]

#pragma mark - Colors

/* Change kILAlertViewTitleColor to your "theme" color. The rest can be left
 * untouched.
 */
#define kILAlertViewTitleColor [UIColor redColor]
#define kILAlertViewMessageColor [UIColor blackColor]
#define kILAlertViewCloseButtonColor [UIColor blackColor]
#define kILAlertViewCloseButtonColorSelected kILAlertViewTitleColor
#define kILAlertViewSecondButtonColor [UIColor blackColor]
#define kILAlertViewSecondButtonColorSelected kILAlertViewTitleColor

#pragma mark - Internal Constants

#define kMaxWidth 280.0f
#define kMaxHeight 300.0f
#define kTitleOneLineHeight 33.0f
#define kMaxTitleHeight 50.0f
#define kBuffer 5.0f
#define kLabelAutosizeExtra 10.0f
#define kTextViewAutosizeExtra 30.0f

#define kOneButtonMaxWidth (floorf(kMaxWidth/2))
#define kButtonHeight 30.0f
#define kAnimateInDuration 0.4
#define kAnimateOutDuration 0.3
#define kOverlayMaxAlpha 0.2

#define kCloseButtonTag 100
#define kSecondButtonTag 101

#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

@interface ILAlertView() {
    UIImageView *_bkgImg;
    UILabel *_titleLabel;
    UITextView *_messageView;
    UIButton *_closeButton;
    UIButton *_secondButton;
    
    UIWindow *_window;
    UIView *_overlay;
}
@end

@implementation ILAlertView

- (ILAlertView *)initWithTitle:(NSString *)title
                       message:(NSString *)message
              closeButtonTitle:(NSString *)closeTitle
             secondButtonTitle:(NSString *)secondTitle
            tappedSecondButton:(void(^)(void))block;
{
    self = [super init];

    if (self) {
        /* ivars */
        self.title = title;
        self.message = message;
        self.storedBlock = block;

        if (!_window) {
            UIView *winParent = [[UIApplication sharedApplication].windows objectAtIndex:0];
            _window = [winParent.subviews objectAtIndex:0];
        }

        /* self customization */
        UIImage *resizableImg = [kILAlertViewBkgPatternImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        _bkgImg = [[UIImageView alloc] initWithImage:resizableImg];
        [self addSubview:_bkgImg];

        _bkgImg.layer.shadowColor = [UIColor blackColor].CGColor;
        _bkgImg.layer.shadowOffset = CGSizeMake(0, 0);
        _bkgImg.layer.shadowRadius = 5.0f;
        _bkgImg.layer.shadowOpacity = 0.2;
        _bkgImg.layer.shouldRasterize = YES;

        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;

        /* titleLabel */
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = self.title;
        _titleLabel.numberOfLines = 2;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = kILAlertViewTitleFont;
        _titleLabel.textColor = kILAlertViewTitleColor;
        [self addSubview:_titleLabel];

        /* messageView */
        _messageView = [[UITextView alloc] init];
        _messageView.text = self.message;
        _messageView.editable = NO;
        _messageView.backgroundColor = [UIColor clearColor];
        _messageView.textAlignment = NSTextAlignmentCenter;
        _messageView.font = kILAlertViewMessageFont;
        _messageView.textColor = kILAlertViewMessageColor;
        [self addSubview:_messageView];

        /* buttons */
        if (secondTitle) {
            _secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_secondButton setTitle:secondTitle forState:UIControlStateNormal];
            [_secondButton setTitleColor:kILAlertViewSecondButtonColor forState:UIControlStateNormal];
            [_secondButton setTitleColor:kILAlertViewSecondButtonColorSelected forState:UIControlStateHighlighted];
            _secondButton.titleLabel.font = kILAlertViewButtonFont;
            _secondButton.tag = kSecondButtonTag;
            [_secondButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_secondButton];
        }
        else {
            _secondButton = nil;
        }

        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:closeTitle forState:UIControlStateNormal];
        [_closeButton setTitleColor:kILAlertViewCloseButtonColor forState:UIControlStateNormal];
        [_closeButton setTitleColor:kILAlertViewCloseButtonColorSelected forState:UIControlStateHighlighted];
        _closeButton.titleLabel.font = kILAlertViewButtonFont;
        _closeButton.tag = kCloseButtonTag;
        [_closeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }

    return self;
}

- (void)layoutSubviews
{
    self.frame = CGRectMake(floorf((_window.frame.size.width-kMaxWidth)/2),
                            floorf((_window.frame.size.height-kMaxHeight)/2),
                            kMaxWidth,
                            kMaxHeight);
    CGSize mainSize = self.frame.size;
    CGFloat yOffset = kBuffer;

    /* Title */
    if (_title != nil) {
        CGSize actualTitleSize = [self.title sizeWithFont:kILAlertViewTitleFont
                                        constrainedToSize:CGSizeMake(mainSize.width, kMaxTitleHeight)];
        CGFloat titleHeight = MIN(actualTitleSize.height+kLabelAutosizeExtra, kMaxTitleHeight);
        _titleLabel.frame = CGRectMake(0,
                                       yOffset,
                                       mainSize.width,
                                       titleHeight);
    }

    yOffset = CGRectGetMaxY(_titleLabel.frame) + kBuffer;

    /* Message */
    if (_message != nil) {
        CGFloat maxMessageHeight = kMaxHeight - _titleLabel.frame.size.height - 3*kBuffer - kButtonHeight;
        CGSize actualMessageSize = [self.message sizeWithFont:kILAlertViewMessageFont
                                            constrainedToSize:CGSizeMake(mainSize.width, maxMessageHeight)];
        CGFloat messageHeight = MIN(actualMessageSize.height+kTextViewAutosizeExtra, maxMessageHeight);
        _messageView.frame = CGRectMake(0,
                                        yOffset,
                                        mainSize.width,
                                        messageHeight);
        if (messageHeight < maxMessageHeight)
            _messageView.scrollEnabled = NO;

        yOffset = CGRectGetMaxY(_messageView.frame) + kBuffer;
    }

    /* Buttons */
    CGFloat buttonXOffset = floorf((mainSize.width-kOneButtonMaxWidth)/2);

    if (_secondButton != nil) {
        _secondButton.frame = CGRectMake(0,
                                        yOffset,
                                        kOneButtonMaxWidth,
                                        kButtonHeight);
        buttonXOffset = kOneButtonMaxWidth;
    }
    
    _closeButton.frame = CGRectMake(buttonXOffset,
                                    yOffset,
                                    kOneButtonMaxWidth,
                                    kButtonHeight);

    yOffset = CGRectGetMaxY(_closeButton.frame) + kBuffer;

    /* Overall frame */
    CGRect rect = self.frame;
    rect.size.height = yOffset;
    self.frame = rect;
    _bkgImg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self centerWithOrientation];
}

- (void)centerWithOrientation
{
    if (IS_LANDSCAPE) {
        self.center = CGPointMake(_window.center.y, _window.center.x);
    }
    else {
        self.center = _window.center;
    }
}

+ (ILAlertView *)showWithTitle:(NSString *)title
                       message:(NSString *)message
              closeButtonTitle:(NSString *)closeTitle
             secondButtonTitle:(NSString *)secondTitle
            tappedSecondButton:(void(^)(void))block
{
    ILAlertView *alert = [[ILAlertView alloc] initWithTitle:title
                                                    message:message
                                           closeButtonTitle:closeTitle
                                          secondButtonTitle:secondTitle
                                         tappedSecondButton:block];

    [alert showAlertAnimated:YES];

    return alert;
}

- (IBAction)buttonTapped:(id)sender {
    NSInteger tag = ((UIButton *)sender).tag;

    if (tag == kSecondButtonTag) {
        if (self.storedBlock) {
            self.storedBlock();
        }
    }

    [self dismissAlertAnimated:YES];
}

#pragma mark - Animate Alert

- (void)showAlertAnimated:(BOOL)animated {
    [self showOverlayAnimated:animated];

    [_window addSubview:self];
    [_messageView becomeFirstResponder];

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
    _overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window.frame.size.width, _window.frame.size.height)];
    _overlay.backgroundColor = [UIColor blackColor];
    _overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_window addSubview:_overlay];

    if (animated) {
        _overlay.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{
            _overlay.alpha = kOverlayMaxAlpha;
        }];
    }
    else {
        _overlay.alpha = kOverlayMaxAlpha;
    }

}

- (void)dismissOverlayAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            _overlay.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_overlay removeFromSuperview];
        }];
    }
    else {
        [_overlay removeFromSuperview];
    }
}

@end
