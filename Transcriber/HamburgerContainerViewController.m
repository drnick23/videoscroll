//
//  HamburgerContainerViewController.m
//  twitterclient
//
//  Created by Nicolas Halper on 4/5/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "HamburgerContainerViewController.h"
#import "MenuViewController.h"

@interface HamburgerContainerViewController ()

- (IBAction)onPan:(UIPanGestureRecognizer *)sender;

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (assign,nonatomic) BOOL menuOpen;
@property (assign,nonatomic) CGAffineTransform menuOriginTransform;
@property (assign,nonatomic) CGPoint startPanPoint;

@end

@implementation HamburgerContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter]
         addObserverForName:MenuViewControllerDidSelectControllerNotification
         object:nil
         queue:nil
         usingBlock:^(NSNotification *notification) {
             NSLog(@"Hamburger Container received notification: %@",notification.userInfo[@"controller"]);
             [self switchContentWithViewController:notification.userInfo[@"controller"]];
             [UIView animateWithDuration:0.5 animations:^{
                 [self setMenuWithOpen:NO];
             }];
         }
         ];
        // Custom initialization
        [[NSNotificationCenter defaultCenter]
         addObserverForName:MenuViewControllerDidSelectActionNotification
         object:nil
         queue:nil
         usingBlock:^(NSNotification *notification) {
             NSLog(@"Hamburger Container received action: %@",notification.userInfo);
             [UIView animateWithDuration:0.5 animations:^{
                 [self setMenuWithOpen:NO];
             }];
         }
         ];
    }
    return self;
}

- (void)switchContentWithViewController:(UIViewController *)viewController {
    NSLog(@"switching content view to new view controller %@",viewController);
    if (self.contentViewController) {
        [self.contentViewController removeFromParentViewController];
        [self.contentViewController.view removeFromSuperview];
        
        [self addChildViewController:viewController];
        [self.contentView addSubview:viewController.view];
        
        viewController.view.frame = self.contentView.superview.frame;
        [self.view bringSubviewToFront:self.contentView];
        
    }
    [self.view bringSubviewToFront:self.menuView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    if (self.contentViewController) {
        
        self.contentViewController.view.frame = self.contentView.frame;

        [self addChildViewController:self.contentViewController];
        [self.contentView addSubview:self.contentViewController.view];
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.backgroundColor = [UIColor redColor];
    } else {
        NSLog(@"BUG WARNING: should add contentViewController");
        self.contentView.backgroundColor = [UIColor greenColor];
    }
    
    if (self.menuViewController) {
        [self addChildViewController:self.menuViewController];
        [self.menuView addSubview:self.menuViewController.view];
        self.menuViewController.view.frame = self.menuView.frame;
    } else {
        self.menuView.backgroundColor = [UIColor blueColor];
    }
    [self.view bringSubviewToFront:self.menuView];
    
    [self setMenuWithOpen:NO];
    
}

- (void)setMenuWithOpen:(BOOL)open {
    CGRect menuFrame = self.menuView.frame;
    self.menuOpen = open;
    if (open) {
        self.menuOriginTransform = CGAffineTransformIdentity;
        self.contentView.transform = CGAffineTransformMakeScale(0.9,0.9);
        self.contentView.alpha = 0.45;
    } else {
        self.menuOriginTransform = CGAffineTransformMakeTranslation(-menuFrame.size.width+0,0);
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.alpha = 1.0;
    }
    self.menuView.transform = self.menuOriginTransform;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    CGPoint point = [panGestureRecognizer locationInView:self.view];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"Start point: %f",point.x);
        self.startPanPoint = point;
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"changed transform point: %f distance:%f",point.x, point.x - self.startPanPoint.x);
        CGFloat travelled = MAX(-self.menuView.frame.size.width,MIN(self.menuView.frame.size.width,point.x - self.startPanPoint.x));

        CGFloat scale;
        if (self.menuOpen) {
            if (travelled > 0) {
                travelled = 0;
            }
            scale = 0.9 + 0.1 * ABS(travelled/320.0);
        } else {
            if (travelled < 0) {
                travelled = 0;
            }
            scale = 1.0 - 0.1 * ABS(travelled/320.0);
        }
        
        CGFloat dest_perc = 0.0 + ABS(travelled/320.0);
        
        //NSLog(@"travelled: %f scale: %f",travelled,scale);
        
        self.menuView.transform = CGAffineTransformTranslate(self.menuOriginTransform, travelled, 0);
        self.contentView.transform = CGAffineTransformMakeScale(scale,scale);
        self.contentView.alpha = 1 - 5*(1 - scale);
        
        if (self.menuOpen==NO) {
            CALayer *layer = self.contentView.layer;
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 140*dest_perc, 0, -180*dest_perc);
            rotationAndPerspectiveTransform.m34 = 1.0 / -500;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -dest_perc * 45.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            layer.transform = rotationAndPerspectiveTransform;
        }

        
        //self.menuView.transform = CGAffineTransformMakeTranslation(point.x - self.startPanPoint.x, 0);
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
        
        // todo: upgrade to ui view dynamics
        // http://www.teehanlax.com/blog/introduction-to-uikit-dynamics/
        [UIView animateWithDuration:0.4 animations:^{
            //NSLog(@"Do anaimtiong");
            if (velocity.x <= 0) {
                [self setMenuWithOpen:NO];
            } else {
                [self setMenuWithOpen:YES];
            }
            
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
        
    }
}


@end
