//
//  TSVideoScrollViewController.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/6/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSVideoScrollViewController.h"
#import "TSCaptionTableViewCell.h"
#import "TSCaption.h"

@interface TSVideoScrollViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSArray *captions; // of TSCaption

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

- (NSArray *)captions {
    NSLog(@"TSVideoScrollViewController: captions");
    if (!_captions) {
        NSLog(@"Initiliazing caption data");
        NSArray *dataList = @[
                      @{@"content":@"Something is in here",
                        @"imageName":@"Image1"},
                      @{@"content":@"And something goes in here too",
                        @"imageName":@"Image2"},
                      @{@"content":@"And again in here",
                        @"imageName":@"Image1"},
                      @{@"content":@"This could go on forever",
                        @"imageName":@"Image2"},
                      @{@"content":@"And possibly more",
                        @"imageName":@"Image1"},
                      @{@"content":@"And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list.",
                        @"imageName":@"Image2"},
                      @{@"content":@"Something is in here",
                        @"imageName":@"Image1"},
                      @{@"content":@"And something goes in here too",
                        @"imageName":@"Image2"},
                      @{@"content":@"And again in here",
                        @"imageName":@"Image1"},
                      @{@"content":@"This could go on forever",
                        @"imageName":@"Image2"},
                      @{@"content":@"And possibly more",
                        @"imageName":@"Image1"},
                      @{@"content":@"And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list. And let's add something much bigger to this list.",
                        @"imageName":@"Image2"},
                      ];
        NSMutableArray *captionData = [@[] mutableCopy];
        for (NSDictionary *data in dataList) {
            TSCaption *caption = [[TSCaption alloc] initWithData:data];
            [captionData addObject:caption];
        }
        _captions = [captionData copy];
        NSLog(@"captions:%@",_captions);
    }
    return _captions;
}


- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.captions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    
    TSCaptionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CaptionTableViewCell" forIndexPath:indexPath];
    
    TSCaption *caption = [self.captions objectAtIndex:indexPath.row];
    cell.caption = caption;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.prototypeCell calculateHeightWithCaption:self.captions[indexPath.row]];
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
       /* CGFloat cellStartOffset = cell.frame.origin.y - scrollView.contentOffset.y;
        CGFloat cellEndOffset = cell.frame.origin.y + cell.frame.size.height - scrollView.contentOffset.y;
        CGFloat imageHeight = cell.captionImage.frame.size.height;
        CGFloat maxImageOffset = cellEndOffset - cellStartOffset - imageHeight;
        
        
        CGFloat translateY = 0;
        if (cellStartOffset < 0) {
            translateY = MIN(-cellStartOffset,maxImageOffset);
        }
        cell.captionImage.transform = CGAffineTransformMakeTranslation(0,translateY*2);
        
        CGFloat overshoot = -cellStartOffset - translateY;
        if (overshoot > 0) {
            CGFloat overshootPerc = 1 - overshoot / imageHeight;
            cell.captionImage.alpha = overshootPerc;
        } else {
            cell.captionImage.alpha = 1;
        }
        
        NSLog(@"cell : [%f to %f] image height: %f translate:%f %@",cellStartOffset,cellEndOffset,imageHeight,translateY,cell.caption);
        */
        
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
