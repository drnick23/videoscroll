//
//  TSCaptionTableViewCell.h
//  Transcriber
//
//  Created by Nicolas Halper on 5/6/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCaption.h"

@interface TSCaptionTableViewCell : UITableViewCell

@property (nonatomic,strong) TSCaption *caption;

- (void) adjustToScrollOffset:(int)offset;
- (int) calculateHeightWithCaption:(TSCaption *)caption;

@end
