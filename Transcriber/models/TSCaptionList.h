//
//  TSCaptionList.h
//  Transcriber
//
//  Created by Nicolas Halper on 5/7/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCaption.h"

@interface TSCaptionList : NSObject

@property (strong,nonatomic) NSDictionary *videoChoices;
@property (strong,nonatomic) NSMutableArray *list;

- (void)loadDataWithName:(NSString *)name;

@end
