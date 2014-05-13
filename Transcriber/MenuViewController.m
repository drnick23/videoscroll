//
//  MenuViewController.m
//  twitterclient
//
//  Created by Nicolas Halper on 4/3/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *menu;
@end

@implementation MenuViewController

NSString *const MenuViewControllerDidSelectControllerNotification = @"MenuViewControllerDidSelectControllerNotification";
NSString *const MenuViewControllerDidSelectActionNotification = @"MenuViewControllerDidSelectActionNotification";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *) menu {
    if (!_menu) _menu = [@[] mutableCopy];
    return _menu;
}

- (void)addMenuItemWithParameters:(NSDictionary *)parameters {
    [self.menu addObject:parameters];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"getting menu rows: %d",[self.menu count]);
    return [self.menu count];
}

/*- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.menu[indexPath.row];
    return 75.0f;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.menu[indexPath.row];
    NSLog(@"Cell at %d %@",indexPath.row,item);
    
    static NSString *CellIdentifier = @"DefaultCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = item[@"name"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.menu[indexPath.row];
    NSLog(@"Selected Cell at %d %@",indexPath.row,item);
    if (item[@"controller"]) {
        NSLog(@"Posting notification for selected controller for %@",item[@"name"]);
        [[NSNotificationCenter defaultCenter] postNotificationName:MenuViewControllerDidSelectControllerNotification object:self userInfo:item];
        
    }
    if ([item[@"type"] isEqualToValue:@(MT_ACTION)]) {
        NSLog(@"Posting notification for action for %@",item[@"name"]);
        [[NSNotificationCenter defaultCenter] postNotificationName:MenuViewControllerDidSelectActionNotification object:self userInfo:item];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
