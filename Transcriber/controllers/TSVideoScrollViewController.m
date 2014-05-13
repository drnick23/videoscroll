//
//  TSVideoScrollViewController.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/6/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSVideoScrollViewController.h"
#import "TSCaptionTableViewCell.h"
#import "TSCaptionList.h"

@interface TSVideoScrollViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) TSCaptionList *captions; // of TSCaption

@property (strong,nonatomic) TSCaptionTableViewCell *prototypeCell;

@end

@implementation TSVideoScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (TSCaptionList *)captions {
    NSLog(@"TSVideoScrollViewController: captions");
    if (!_captions) {
        _captions = [[TSCaptionList alloc] init];
    }
    return _captions;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.captions.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    
    TSCaptionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CaptionTableViewCell" forIndexPath:indexPath];
    
    TSCaption *caption = [self.captions.list objectAtIndex:indexPath.row];
    caption.showImage = YES;
    cell.caption = caption;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.prototypeCell calculateHeightWithCaption:self.captions.list[indexPath.row]];
}

- (TSCaptionTableViewCell *)prototypeCell
{
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"CaptionTableViewCell"];
    }
    return _prototypeCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"We did scroll: %f",scrollView.contentOffset.y);
    
    // get cell at top
   /* NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: CGPointMake(0, 0)];
    TSCaptionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CaptionTableViewCell" forIndexPath:indexPath];
    CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
    
    NSLog(@"Y of Cell %f for cell: %@", rectOfCellInTableView.origin.y, cell.caption);*/
    
    NSArray *visibleCells = [self.tableView visibleCells];
    
    for (TSCaptionTableViewCell *cell in visibleCells) {
        
        [cell adjustToScrollOffset:scrollView.contentOffset.y];
    }
    
    //CGRect rectOfCellInTableView = [tableView rectForRowAtIndexPath:indexPath];
    //CGRect rectOfCellInSuperview = [tableView convertRect:rectOfCellInTableView toView:[tableView superview]];
    
    //NSLog(@"Y of Cell is: %f", rectOfCellInSuperview.origin.y);
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // register our custom cells
    UINib *captionTableViewCellNib = [UINib nibWithNibName:@"TSCaptionTableViewCell" bundle:nil];
    [self.tableView registerNib:captionTableViewCellNib forCellReuseIdentifier:@"CaptionTableViewCell"];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
