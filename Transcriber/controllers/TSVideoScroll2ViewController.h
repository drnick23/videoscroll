//
//  TSVideoScroll2ViewController.h
//  Transcriber
//
//  Created by Nicolas Halper on 5/8/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCaptionList.h"

@interface TSVideoScroll2ViewController : UIViewController

-(id)initWithCaptionList:(TSCaptionList *)captionList;
-(void)resetToCaptionList:(TSCaptionList *)captionList;

@end
