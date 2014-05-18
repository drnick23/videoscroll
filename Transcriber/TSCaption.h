//
//  TSCaption.h
//  Transcriber
//
//  Created by Nicolas Halper on 5/7/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCaption : NSObject

@property (strong,nonatomic) NSString *imageName;
@property (strong,nonatomic) NSString *content;
@property (assign,nonatomic) BOOL showImage;

-(UIImage *)loadImage;

-(id)initWithData:(NSDictionary *)data;


@end
