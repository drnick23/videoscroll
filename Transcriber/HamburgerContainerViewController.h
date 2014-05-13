//
//  HamburgerContainerViewController.h
//  twitterclient
//
//  Created by Nicolas Halper on 4/5/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HamburgerContainerViewController : UIViewController

@property (strong,nonatomic) UIViewController *menuViewController;
@property (strong,nonatomic) UIViewController *contentViewController;
@property (strong,nonatomic) NSArray *contentViewControllers;

@end
