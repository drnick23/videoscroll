//
//  TSImage.h
//  Transcriber
//
//  Created by Nicolas Halper on 5/16/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TSImage : NSObject

+ (NSString *)imageNameForCMTime:(CMTime) cmTime;
+ (NSString *)fileForImageNamed:(NSString *)imageName;
+ (BOOL)fileExistsForImageName:(NSString *)imageName;
+ (void)saveToLocalStoreImage:(UIImage *)image withName:(NSString *)name;
+ (UIImage *)loadFromLocalStoreImageWithName:(NSString *)name;

@end
