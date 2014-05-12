//
//  TSCaptionTableViewCell.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/6/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSCaptionTableViewCell.h"
#import "UIImage+ImageEffects.h"

@interface TSCaptionTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *foregroundImage;

@end

@implementation TSCaptionTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)setCaptionImage:(UIImage *)captionImage {
    
   
    
}


- (void)setCaption:(TSCaption *)caption {
    _caption = caption;
    self.captionLabel.text = caption.content;
    
    if (caption.imageName && caption.showImage) {
        UIImage *image = [UIImage imageNamed:caption.imageName];
        self.foregroundImage.image = image;
        self.backgroundImage.image = [image applyDarkEffect];
    }
    
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
    CGFloat height = rect.size.height+520;

    
    NSLog(@"Calculate hieght of %@ for width %f is %f:",caption.content,self.captionLabel.bounds.size.width,height);
    return height;
}

- (void) adjustToScrollOffset:(int)offset {
    CGFloat cellStartOffset = self.frame.origin.y - offset;
    CGFloat cellEndOffset = self.frame.origin.y + self.frame.size.height - offset;
    CGFloat imageHeight = self.foregroundImage.frame.size.height;
    CGFloat maxImageOffset = cellEndOffset - cellStartOffset - imageHeight;
    
    
    CGFloat translateY = 0;
    if (cellStartOffset < 0) {
        translateY = MIN(-cellStartOffset,maxImageOffset);
    }
    self.foregroundImage.transform = CGAffineTransformMakeTranslation(0,translateY*2);
    self.backgroundImage.transform = CGAffineTransformMakeTranslation(0,translateY*2);
    
    CGFloat overshoot = -cellStartOffset - translateY;
    if (overshoot > 0) {
        CGFloat overshootPerc = overshoot / imageHeight;
        self.foregroundImage.alpha = 1 - 5 * overshootPerc;
    } else {
        self.foregroundImage.alpha = 1;
    }
    
    //self.foregroundImage.alpha = 0.2;
    
   // NSLog(@"cell : [%f to %f] image height: %f translate:%f %@",cellStartOffset,cellEndOffset,imageHeight,translateY,self.caption);
    

}

@end
