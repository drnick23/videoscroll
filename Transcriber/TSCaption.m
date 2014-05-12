//
//  TSCaption.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/7/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSCaption.h"

@implementation TSCaption

-(id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        if (data[@"imageName"]) {
            self.imageName = data[@"imageName"];
        }
        self.content = data[@"content"];
    }
    return self;
}

@end
