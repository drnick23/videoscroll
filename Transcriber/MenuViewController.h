//
//  MenuViewController.h
//  twitterclient
//
//  Created by Nicolas Halper on 4/3/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

// subscribe to this NSNotification whenever a menu item gets selected that has a controller
extern NSString *const MenuViewControllerDidSelectControllerNotification;

// subscribe to this to receive action events
extern NSString *const MenuViewControllerDidSelectActionNotification;

enum MenuTypes {
    MT_PROFILE,
    MT_LINK,
    MT_ACTION
};
typedef enum MenuTypes MenuTypes;

// this should be cleaned up to make it less error prone.
- (void)addMenuItemWithParameters:(NSDictionary *)parameters;

@end
