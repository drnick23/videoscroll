//
//  TSVideoScrollViewController.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/6/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSVideoScroll2ViewController.h"
#import "TSCaption2TableViewCell.h"
#import "TSCaptionList.h"
#import "UIImage+ImageEffects.h"


@interface TSVideoScroll2ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) TSCaptionList *captions;

@property (strong,nonatomic) TSCaption2TableViewCell *prototypeCell;
@property (weak, nonatomic) IBOutlet UIImageView *foregroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlurImage;
@property (weak, nonatomic) IBOutlet UIImageView *foregroundBlurImage;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
- (IBAction)onTap:(UITapGestureRecognizer *)sender;
@property (nonatomic,assign) int tapToScrollToPos;

@end

@implementation TSVideoScroll2ViewController

-(id)initWithCaptionList:(TSCaptionList *)captionList
{
    self = [super init];
    if (self) {
        [self resetToCaptionList:captionList];
    }
    return self;
}

-(void)resetToCaptionList:(TSCaptionList *)captionList {
    self.captions = captionList;
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:NO];
    TSCaption *caption1st = self.captions.list[0];
    self.foregroundImage.image = [caption1st loadImage];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (TSCaptionList *)captions {
    if (!_captions) {
        _captions = [[TSCaptionList alloc] init];
    }
    return _captions;
}


- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"number of captions: %d",[self.captions.list count]);
    return [self.captions.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"cellForRowAtIndexPath");
    
    TSCaption2TableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Caption2TableViewCell" forIndexPath:indexPath];
    
    TSCaption *caption = [self.captions.list objectAtIndex:indexPath.row];
    
    cell.caption = caption;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return [self.prototypeCell calculateHeightWithCaption:self.captions.list[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 300.0f;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didDeselectRowAtIndexPath");
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.tapToScrollToPos = indexPath.row;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
}

- (TSCaption2TableViewCell *)prototypeCell
{
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"Caption2TableViewCell"];
    }
    return _prototypeCell;
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"We did scroll: %f",scrollView.contentOffset.y);
    
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
    
    TSCaption2TableViewCell *cell1st = visibleCells[0];
    TSCaption2TableViewCell *cell2nd;
    
    TSCaption *caption1st = cell1st.caption;
    //self.foregroundImage.image = [UIImage imageNamed:caption1st.imageName];
    self.foregroundImage.image = [caption1st loadImage];
    
    if (visibleCells.count == 1) {
        //NSLog(@"only one visible cell");
        
        cell1st.alpha = 1;
        self.foregroundImage.alpha = 1;
        self.backgroundImage.image = nil;
    }
    else if (visibleCells.count > 1) {
        CGFloat offset = scrollView.contentOffset.y;
        cell2nd = visibleCells[1];
        
        CGFloat cellEndLinePos = cell1st.frame.origin.y + cell1st.frame.size.height - offset;
        //NSLog(@"cellEndLinePos %f",cellEndLinePos);

        if (cellEndLinePos < 50) {
            TSCaption *caption2nd = cell2nd.caption;
            // start blending last 50 pixels.
             CGFloat overshootPerc = cellEndLinePos / 50;
            self.foregroundImage.alpha = overshootPerc;
            self.backgroundImage.image = [caption2nd loadImage];
            cell1st.alpha = overshootPerc;
        } else {
            self.backgroundImage.image = nil;
            self.foregroundImage.alpha = 1;
            cell1st.alpha = 1;
        }
        
        
        /*
        
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
            //self.backgroundImage.image = [UIImage imageNamed:caption2nd.imageName];
            self.backgroundImage.image = [caption2nd loadImage];
            self.backgroundImage.backgroundColor = [UIColor blueColor];
            
            CGFloat overshootPerc = overshoot / imageHeight;
            self.foregroundImage.alpha = 1 - overshootPerc;
            //cell1st.alpha = 1 - overshootPerc;
            
            NSLog(@"overshoot perc is: %f",overshootPerc);
            

        } else {
            cell1st.alpha = 1;
            self.foregroundImage.alpha = 1;
            self.backgroundImage.image = nil;
        }
         */
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
    UINib *captionTableViewCellNib = [UINib nibWithNibName:@"TSCaption2TableViewCell" bundle:nil];
    [self.tableView registerNib:captionTableViewCellNib forCellReuseIdentifier:@"Caption2TableViewCell"];
    
    self.tapToScrollToPos = 0; // set to nothing (ready for tap to index pos)
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndScrollingAnimation");
    //self.tapToScrollToPos = 0; // tapping to scroll resets to index pos now.
    // get indexPath for cell at top of tableview
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexPath = indexPaths[0];
    int row = indexPath.row;
    if (self.tapToScrollToPos != row) {
        NSLog(@"tapScrollpos %d != row %d so scrolling more",self.tapToScrollToPos,row);
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.tapToScrollToPos inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    } else {
        self.tapToScrollToPos = 0;
    }
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    NSLog(@"Tapped! %d",self.tapToScrollToPos);
    int row;
    
    if (self.tapToScrollToPos == 0) {
        // get indexPath for cell at top of tableview
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        NSIndexPath *indexPath = indexPaths[0];
        row = indexPath.row + 1;
        self.tapToScrollToPos = row;
        NSLog(@"tapping to position of scroll for row: %d",row);
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.tapToScrollToPos inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
        
    } else {
        self.tapToScrollToPos++;
        NSLog(@"tapping to next (multi-tap) position of scroll : %d",self.tapToScrollToPos);
    }
   
    if (self.tapToScrollToPos > [self.captions.list count]-1) {
        self.tapToScrollToPos = [self.captions.list count]-1;
    }
   
    

    
}
@end
