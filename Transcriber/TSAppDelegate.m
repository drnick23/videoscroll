//
//  TSAppDelegate.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/5/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSAppDelegate.h"
#import "MenuViewController.h"
#import "HamburgerContainerViewController.h"
#import "TSVideoScrollViewController.h"
#import "TSVideoScroll2ViewController.h"
#import "TSCaptionList.h"
#import "YouTubeVideo.h"

@interface TSAppDelegate()

@property (nonatomic,strong) MenuViewController *menuViewController;

@end

@implementation TSAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    // testing youtube
    NSLog(@"Searching youtube");
    [YouTubeVideo searchVideosWithQuery:@"Edward Snowden" completionHandler:^(NSArray *videos, NSError *error) {
        if (error) {
            NSLog(@"Error searching videos ---------------------- !\n%@", error);
        } else {
            NSLog(@"Found youtube videos %@",videos);
            for (YouTubeVideo *video in videos) {
                NSLog(@"Video [%@] title: %@",video.videoId, video.title);
            }
        }
    }];
    
    // TODO:
    // 1) top video space. Captions with blurred background that passes under and goes into focus.
    // 2) top video space with sidebar thumbnails that stack. When you scroll the text the sidebar thumbnails move up, and the top one scales up into and behind the existing video in a single animation. You can tap the thumbnails to skip to the text there or scroll them faster.
    // 3) top video space, and zoom in on image for the talker. So you get static image animation at hotspots of what the captions are talking about.
    
    TSCaptionList *list = [[TSCaptionList alloc] init];
    [list loadDataWithName:@"Ideas"];
    
    //TSVideoScrollViewController *videoScroll = [[TSVideoScrollViewController alloc] init];
    TSVideoScroll2ViewController *videoScroll2 = [[TSVideoScroll2ViewController alloc] initWithCaptionList:list];

    self.menuViewController = [[MenuViewController alloc] init];
    //[self.menuViewController addMenuItemWithParameters:@{@"type":@(MT_LINK),@"name":@"Medium-style", @"controller":videoScroll}];
    [self.menuViewController addMenuItemWithParameters:@{@"type":@(MT_ACTION),@"name":@"Edward Snowden",@"loadData":@"Snowden"}];
    [self.menuViewController addMenuItemWithParameters:@{@"type":@(MT_ACTION),@"name":@"Ideas Worth Spreading",@"loadData":@"Ideas"}];
    [self.menuViewController addMenuItemWithParameters:@{@"type":@(MT_ACTION),@"name":@"Obama Mandella Memorial",@"loadData":@"Obama"}];
    [self.menuViewController addMenuItemWithParameters:@{@"type":@(MT_ACTION),@"name":@"Portobello steaks",@"loadData":@"Portobello"}];
    [self.menuViewController addMenuItemWithParameters:@{@"type":@(MT_ACTION),@"name":@"The Expert (comedy)",@"loadData":@"Expert"}];
    [self.menuViewController addMenuItemWithParameters:@{@"type":@(MT_ACTION),@"name":@"Hexaflexagons",@"loadData":@"Hexaflexagons"}];

    [[NSNotificationCenter defaultCenter]
     addObserverForName:MenuViewControllerDidSelectActionNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification *notification) {
         NSLog(@"AppDelegate received notification: %@",notification.userInfo[@"name"]);
         NSDictionary *userInfo = notification.userInfo;
         if (userInfo[@"loadData"]) {
             NSLog(@"Should load data: %@",userInfo[@"loadData"]);
             [list loadDataWithName:userInfo[@"loadData"]];
             [videoScroll2 resetToCaptionList:list];
             
         }
     }];

    
    HamburgerContainerViewController *hamburgerContainerViewController = [[HamburgerContainerViewController alloc] init];
    hamburgerContainerViewController.menuViewController = self.menuViewController;
    hamburgerContainerViewController.contentViewController = videoScroll2;
    
    
    
    self.window.rootViewController = hamburgerContainerViewController;


    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
