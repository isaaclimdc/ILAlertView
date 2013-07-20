//
//  ViewController.m
//  ILAlertViewDemo
//
//  Created by Isaac Lim on 1/5/13.
//  Copyright (c) 2013 isaacl.net. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)alert1:(id)sender {
    [ILAlertView showWithTitle:@"Incorrect Credentials"
                       message:@"Please type a matching username and password."
              closeButtonTitle:@"OK"
             secondButtonTitle:nil
            tappedSecondButton:nil];
}

- (IBAction)alert2:(id)sender {
    NSString *longMessage = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus id vehicula massa. Donec condimentum malesuada nulla, tempor fringilla purus tincidunt nec. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Suspendisse potenti. Etiam in tempus sapien. Phasellus laoreet lobortis turpis ut tristique. Praesent nec rhoncus tortor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque tristique sollicitudin metus, ut accumsan quam rhoncus nec. Proin facilisis faucibus tellus sit amet bibendum. Phasellus eu eros sed lorem ultrices commodo. Phasellus massa sapien, auctor feugiat fermentum ut, eleifend ultricies arcu.\n\nAliquam congue est vitae nibh eleifend a venenatis lacus vestibulum. Donec ut neque felis, et interdum arcu. Aenean et elit et magna bibendum mollis ut ac velit. Etiam blandit nunc quis turpis aliquet lobortis. Nulla quis est purus. Cras in sem quis dolor consequat semper. Nulla pellentesque suscipit ipsum, eget volutpat nisi vulputate vitae. Donec facilisis leo sed ipsum venenatis eget pellentesque nisl elementum.";
    
    [ILAlertView showWithTitle:@"Here is a long message"
                       message:longMessage
              closeButtonTitle:@"Close"
             secondButtonTitle:nil
            tappedSecondButton:nil];
}

- (IBAction)alert3:(id)sender {
    [ILAlertView showWithTitle:@"Change background?"
                       message:@"Are you sure you want to change the background color of this window?"
              closeButtonTitle:@"No"
             secondButtonTitle:@"Yes"
            tappedSecondButton:^{
                [self toggleBackground];
            }];
}

- (void)toggleBackground {
    UIColor *blackBkg = [UIColor blackColor];
    UIColor *grayBkg = [UIColor scrollViewTexturedBackgroundColor];

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{

        self.view.alpha = 0.0;

    } completion:^(BOOL finished) {

        if (self.view.backgroundColor == blackBkg)
            self.view.backgroundColor = grayBkg;
        else
            self.view.backgroundColor = blackBkg;

        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{

            self.view.alpha = 1.0;

        } completion:nil];
        
    }];
}

@end
