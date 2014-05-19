//
//  TSCaption2TableViewCell.h
//  Transcriber
//
//  Created by Nicolas Halper on 5/17/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCaption.h"

@interface TSCaption2TableViewCell : UITableViewCell

@property (nonatomic,strong) TSCaption *caption;

- (void) adjustToScrollOffset:(int)offset;
- (int) calculateHeightWithCaption:(TSCaption *)caption;

@end
