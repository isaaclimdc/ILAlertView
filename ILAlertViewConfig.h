//
// ILAlertViewConfig.h
// Version 1.0
// Created by Isaac Lim (isaacl.net) on 1/1/13.
//

#ifndef ILAlertViewDemo_ILAlertViewConfig_h
#define ILAlertViewDemo_ILAlertViewConfig_h

#pragma mark - Background Pattern Image

/* Change this to whatever pattern you want to use. For best results, use
 * use an image that can be seamlessly tiled in multiple directions
 */
#define kILAlertViewBkgPatternImage [UIImage imageNamed:@"alertBkg.png"]

#pragma mark - Fonts

/* ILAlertView looks great with the Avenir font, but this is only available
 * by default on iOS 6. Feel free to uncomment those 3 lines if you're on iOS 6.
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
#define kILAlertViewButtonColorDefault [UIColor blackColor]
#define kILAlertViewButtonColorSelected kILAlertViewTitleColor
#define kILAlertViewSecondButtonColorDefault [UIColor blackColor]

#endif
