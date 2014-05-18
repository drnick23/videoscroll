//
//  TSCaption.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/7/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSCaption.h"
#import "TSImage.h"

@implementation TSCaption

-(id)initWithData:(NSDictionary *)data {
    
    /*
     [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithFloat:timeInSeconds], @"startFloat",
     [NSValue valueWithCMTime:cmTime],@"startCMTime",
     [TSImage imageNameForCMTime:cmTime],@"imageName",
     indexString, @"index",
     startString, @"start",
     endString , @"end",
     textString , @"content",
     nil];
     */
    self = [super init];
    if (self) {
        if (data[@"imageName"]) {
            self.imageName = data[@"imageName"];
        }
        self.content = data[@"content"];
    }
    return self;
}

-(UIImage *)loadImage {
    return [TSImage loadFromLocalStoreImageWithName:self.imageName];
}

@end
