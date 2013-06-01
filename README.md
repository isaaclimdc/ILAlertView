ILAlertView
===============
iOS alerts with a customizable appearance.

### Version 1.3

Overview
--------
Sick of the appearance of iOS' default `UIAlertView`? Or have you ever spent so much time **hand-crafting** your own unique UI, only to find that the *pesky* blue `UIAlertView` ruins it? `ILAlertView`, a subclass of `UIView`, is an attempt to alleviate that longing for more control over how alerts in your app look.

`ILAlertView` is meant to be an app-wide replacement of alert views, and thus the customization takes place at compile-time. Simply edit the relevant constants in `ILAlertViewConfig.h` and every instance of `ILAlertView` in your app will have the same streamlined appearance.

Animations are subtle but smooth and they look pretty neat! Just call a single method that configures and displays the alert, and the implementation takes care of the rest.

See `ILAlertView` **in action** in this [short demo on YouTube](http://youtu.be/AkimUM52ULo).

As of v1.0, `ILAlertView` only supports either a single close button that simply closes the alert, or 2 buttons side by side. The second button can be configured by conforming to `ILAlertViewDelegate` to perform an action. More buttons can be added in the future if this is desired.

**An alert with a short message:**  
![Short message](http://isaacl.net/images/libraries/ILAlertView/1.png)

**An alert with a long message:**  
![Long message](http://isaacl.net/images/libraries/ILAlertView/2.png)

**An alert with 2 buttons:**  
![2 buttons](http://isaacl.net/images/libraries/ILAlertView/3.png)

How to use
----------
A demo project `ILAlertViewDemo` is included to show how `ILAlertView` can be integrated into a project.

#### Preparation
1. Copy the following 3 files into your Xcode project. Be sure to check "Copy items into destination's group folder".
    - `ILAlertViewConfig.h`: This is the file with your customization. More on the config constants [below](#Customization).
    - `ILAlertView.h`
    - `ILAlertView.m`
2. To use the default provided background pattern image, also copy `alertBkg.png` and `alertBkg@2x.png` into your project. To use your own image, either rename your images to `alertBkg`, or edit the `kILAlertViewBkgPatternImage` constant in `ILAlertViewConfig.h`.
3. Add the QuartzCore framework to your project by clicking on your project's name at the top of the sidebar in Xcode, then going into "Build Phases". In this tab, expand "Link Binaries With Libraries" and add `QuartzCore.framework`.
4. Add the line `#include "ILAlertView.h"` to the `YourAppName-Prefix.pch` file in the "Supporting Files" group. This way, `ILAlertView` will be available to every file in your project without needing to keep adding a `#include`.

#### Display a simple alert
To initialize and display a simple alert view with just a close button, use the following code:

    [ILAlertView showWithTitle:@"Incorrect Credentials"
                       message:@"Please type a matching username and password."
              closeButtonTitle:@"OK"
             secondButtonTitle:nil
           tappedButtonAtIndex:nil];         

… and that's it!

Note: `-showWithTitle:message:closeButtonTitle:secondButtonTitle:tappedButtonAtIndex:` returns the instance of `ILAlertView` that it displays, but the return value can be ignored if all that is needed is a simple alert.

#### Display an alert with 2 buttons
To initialize and display an alert view with 2 buttons, use the following code:

    [ILAlertView showWithTitle:@"Change background?"
                                            message:@"Are you sure you want to change the background color of this window?"
                                   closeButtonTitle:@"No"
                                  secondButtonTitle:@"Yes"
                                tappedButtonAtIndex:^(NSInteger buttonIndex) {
                                    if (buttonIndex == 1)
                                        [self toggleBackground];
                                  }];

Customization
-------------
The following are the constants defined in `ILAlertViewConfig.h`. Override these to customize `ILAlertView` for your app.

#### Background Pattern Image (`UIImage`)
`kILAlertViewBkgPatternImage`  
The background of the alert view. This should be a pattern image that can be seamlessly tiled in multiple directions.

#### Fonts (`UIFont`)
Defaults are configured to use the system font, but for iOS 6 apps, setting these to use the Avenir font family makes really nice `ILAlertViews`!

`kILAlertViewTitleFont`  
The font of the alert view's title. Preferably a moderately bold font.

`kILAlertViewMessageFont`  
The font of the alert view's message. Preferably a regular font.

`kILAlertViewButtonFont`  
The font of the alert view's buttons. Preferably a moderately bold font, smaller in point size than the title font.

#### Colors (`UIColor`)
`kILAlertViewTitleColor`  
The color of the alert view's title text. Make this the color of your apps' color theme.

`kILAlertViewMessageColor`  
The color of the alert view's message text. This is black by default.

`kILAlertViewButtonColorDefault`
The color of the alert view's button text when not selected. This is black by default.

`kILAlertViewButtonColorSelected`
The color of the alert view's button text when selected. This is set to be the same as `kILAlertViewTitleColor`.

`kILAlertViewSecondButtonColorDefault`
The color of the alert view's second button text when not selected. This is black by default, and can be changed to differentiate between the two buttons.


Requirements
------------
- ARC
- iOS 5.0 or later
- The `QuartzCore` framework

Contact
-------
Isaac Lim   
[isaacl.net](http://isaacl.net)

Credits
-------
- The "Debut light" pattern from [Subtle Patterns](http://subtlepatterns.com) by [Luke McDonald](http://lukemcdonald.com/).  
- [darthpelo](https://github.com/darthpelo) for implementing block callbacks in v1.2.

Version History
---------------
**1.3**  
- Added landscape support

**1.2**  
- Removed delegate methods  
- Added block callbacks to manage button taps ([darthpelo](https://github.com/darthpelo))

**1.1**  
- Slightly rounded edges  
- Alert message text center aligned  
- Bug fixes

**1.0.1**  
- Imported `QuartzCore` into `ILAlertView.h` so the user doesn't have to do that in the prefix header.

**1.0**  
- First publish to Github

License
-------
 ILAlertView is distributed under the terms and conditions of the MIT license.

 Copyright (c) 2013 isaacl.net. All rights reserved.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
