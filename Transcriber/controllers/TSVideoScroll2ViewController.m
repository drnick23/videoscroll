//
//  TSVideoScrollViewController.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/6/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSVideoScroll2ViewController.h"
#import "TSCaptionTableViewCell.h"
#import "TSCaption.h"
#import "UIImage+ImageEffects.h"


@interface TSVideoScroll2ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSArray *captions; // of TSCaption

@property (strong,nonatomic) TSCaptionTableViewCell *prototypeCell;
@property (weak, nonatomic) IBOutlet UIImageView *foregroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlurImage;
@property (weak, nonatomic) IBOutlet UIImageView *foregroundBlurImage;

@end

@implementation TSVideoScroll2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)captions {
    NSLog(@"TSVideoScroll2ViewController: captions");
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
            caption.showImage = NO;
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
    
    return [self.prototypeCell calculateHeightWithCaption:self.captions[indexPath.row]]-300;
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
    
    // exit if no visible cells
    if (visibleCells.count == 0) {
        return;
    }
    
    TSCaptionTableViewCell *cell1st = visibleCells[0];
    TSCaptionTableViewCell *cell2nd;
    
    TSCaption *caption1st = cell1st.caption;
    self.foregroundImage.image = [UIImage imageNamed:caption1st.imageName];
    
    if (visibleCells.count == 1) {
        NSLog(@"only one visible cell");
        
        cell1st.alpha = 1;
        self.foregroundImage.alpha = 1;
        self.backgroundImage.image = nil;
    }
    else if (visibleCells.count > 1) {
        cell2nd = visibleCells[1];
        CGFloat offset = scrollView.contentOffset.y;
        CGFloat cellStartOffset = cell1st.frame.origin.y - offset;
        CGFloat cellEndOffset = cell1st.frame.origin.y + cell1st.frame.size.height - offset;
        CGFloat imageHeight = self.foregroundImage.frame.size.height;
        CGFloat maxImageOffset = cellEndOffset - cellStartOffset - imageHeight;
        
        CGFloat translateY = 0;
        if (cellStartOffset < 0) {
            translateY = MIN(-cellStartOffset,maxImageOffset);
        }
        //self.foregroundImage.transform = CGAffineTransformMakeTranslation(0,translateY*2);
        //self.backgroundImage.transform = CGAffineTransformMakeTranslation(0,translateY*2);
        
        CGFloat overshoot = -cellStartOffset - translateY;
        NSLog(@"overshoot is: %f",overshoot);
        
        
        if (overshoot > 0) {
            TSCaption *caption2nd = cell2nd.caption;
            self.backgroundImage.image = [UIImage imageNamed:caption2nd.imageName];
            self.backgroundImage.backgroundColor = [UIColor blueColor];
            
            CGFloat overshootPerc = overshoot / imageHeight;
            self.foregroundImage.alpha = 1 - overshootPerc;
            cell1st.alpha = 1 - overshootPerc;
            

        } else {
            cell1st.alpha = 1;
            self.foregroundImage.alpha = 1;
            self.backgroundImage.image = nil;
        }
        self.backgroundBlurImage.hidden = YES;
        self.foregroundBlurImage.hidden = YES;
        
    }
    /*
    for (TSCaptionTableViewCell *cell in visibleCells) {
        
        [self.tableView indexPathForCell:cell];
        
        CGFloat cellStartOffset = cell.frame.origin.y - offset;
        CGFloat cellEndOffset = cell.frame.origin.y + cell.frame.size.height - offset;
        CGFloat imageHeight = self.foregroundImage.frame.size.height;
        CGFloat maxImageOffset = cellEndOffset - cellStartOffset - imageHeight;
        
        
        CGFloat translateY = 0;
        if (cellStartOffset < 0) {
            translateY = MIN(-cellStartOffset,maxImageOffset);
        }
        //self.foregroundImage.transform = CGAffineTransformMakeTranslation(0,translateY*2);
        //self.backgroundImage.transform = CGAffineTransformMakeTranslation(0,translateY*2);
        
        CGFloat overshoot = -cellStartOffset - translateY;
        if (overshoot > 0) {
            CGFloat overshootPerc = overshoot / imageHeight;
            self.foregroundImage.alpha = 1 - 5 * overshootPerc;
        } else {
            self.foregroundImage.alpha = 1;
        }

        
        [cell adjustToScrollOffset:scrollView.contentOffset.y];
    }
    */
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
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor blackColor];
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