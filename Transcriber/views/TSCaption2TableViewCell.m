//
//  TSCaption2TableViewCell.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/17/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSCaption2TableViewCell.h"
#import "UIImage+ImageEffects.h"
#import "TSImage.h"
#import <QuartzCore/QuartzCore.h>

@interface TSCaption2TableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@end

@implementation TSCaption2TableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    
    self.captionLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.captionLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);

    self.captionLabel.layer.shadowRadius = 3.0;
    self.captionLabel.layer.shadowOpacity = 0.8;
    self.captionLabel.layer.masksToBounds = NO;
}


- (void)setCaption:(TSCaption *)caption {
    _caption = caption;
    self.captionLabel.text = caption.content;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (int) calculateHeightWithCaption:(TSCaption *)caption {
    
    UIFont *font = [UIFont systemFontOfSize: 17];
    CGRect rect = [caption.content boundingRectWithSize:CGSizeMake(self.captionLabel.bounds.size.width, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName: font} context:nil];
    CGFloat height = rect.size.height+50;
    
    
    //NSLog(@"Calculate hieght of %@ for width %f is %f:",caption.content,self.captionLabel.bounds.size.width,height);
    return height;
}

- (void) adjustToScrollOffset:(int)offset {
    CGFloat cellStartOffset = self.frame.origin.y - offset;
    CGFloat cellEndOffset = self.frame.origin.y + self.frame.size.height - offset;    
    
}

@end
