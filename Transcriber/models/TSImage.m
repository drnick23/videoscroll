//
//  TSImage.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/16/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSImage.h"

@implementation TSImage

+ (NSString *)imageNameForCMTime:(CMTime) cmTime {
    return [NSString stringWithFormat:@"image%lld",cmTime.value];
}

+ (NSString *)fileForImageNamed:(NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",imageName]];
    return imagePath;
}

+ (BOOL)fileExistsForImageName:(NSString *)imageName {
    NSString *imagePath = [self fileForImageNamed:imageName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:imagePath];
}

+ (void)saveToLocalStoreImage:(UIImage *)image withName:(NSString *)name {
    NSData *imageData = UIImageJPEGRepresentation(image,0.1);
    
    NSString *imagePath = [self fileForImageNamed:name];
    
    //NSLog((@"pre writing to file"));
    if (![imageData writeToFile:imagePath atomically:NO])
    {
        NSLog(@"Failed to cache image data to disk: %@",imagePath);
    }
    else
    {
       // NSLog(@"the cachedImagedPath is %@",imagePath);
    }
}

+ (UIImage *)loadFromLocalStoreImageWithName:(NSString *)name {
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[TSImage fileForImageNamed:name]];
    return image;
}


@end
