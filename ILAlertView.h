//
// ILAlertView
// Version 1.4.1
// Created by Isaac Lim (isaacl.net) on 1/1/13.
//

// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2013 isaacl.net. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

@interface ILAlertView : UIView

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) void (^storedBlock)(void);

/**
 * Creates a new alert view with appearance according to the user's settings
 * @param title The top title of the alert view. Should be a summary of the main message or a question. Limited to 2 lines long, and not scrollable.
 * @param message The main body of the alert view's message. This will be scrollable, so can be as long as desired.
 * @param closeTitle The text on the button that closes the alert view with no side effects.
 * @param secondTitle The text on an optional button that can be configured to cause side effects. Set to nil to not show a second button.
 * @param block The tapped action block. Set to nil for just the default close action.
 *
 * @return The configured instance of the alert view.
 */
+ (ILAlertView *)showWithTitle:(NSString *)title
                       message:(NSString *)message
              closeButtonTitle:(NSString *)closeTitle
             secondButtonTitle:(NSString *)secondTitle
            tappedSecondButton:(void(^)(void))block;

@end
