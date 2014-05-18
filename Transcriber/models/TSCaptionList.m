//
//  TSCaptionList.m
//  Transcriber
//
//  Created by Nicolas Halper on 5/7/14.
//  Copyright (c) 2014 Nicolas Halper. All rights reserved.
//

#import "TSCaptionList.h"
#import <AVFoundation/AVFoundation.h>
//#import <MediaPlayer/MediaPlayer.h>
#import "HCYoutubeParser.h"
#import "TSImage.h"

@interface TSCaptionList ()

@property (strong,nonatomic) AVPlayerItem *playerItem;
@property (copy) void (^readyBlock)(void);

@end

@implementation TSCaptionList

-(id)init {
    self = [super init];
    if (self) {
        NSLog(@"TSCaptionList:init");
        [self loadData];
        //NSLog(@"TSCaptionList:init read %u subtitles",[self.list count]);
    }
    return self;
}

- (void) loadData {
    // Gets an dictionary with each available youtube url
    NSURL *url = [NSURL URLWithString:@"https://www.youtube.com/watch?v=yVwAodrjZMY"];
    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:url];
    NSLog(@"got video medium data: %@",videos[@"medium"]);
    NSURL *videoURL = [NSURL URLWithString:videos[@"medium"]];
    
    NSArray *subtitles = [self readSubtitles];

    self.list = [@[] mutableCopy];
    for (NSDictionary *data in subtitles) {
        TSCaption *caption = [[TSCaption alloc] initWithData:data];
        [self.list addObject:caption];
    }
    NSLog(@"setup %d captions in list",[self.list count]);

    
    NSArray *cmValues = [subtitles valueForKey:@"startCMTime"];
    NSMutableArray *filteredCMValues = [@[] mutableCopy];
    //CMTime cmTime = [cmValues[0] CMTimeValue];
    for (NSValue *value in cmValues) {
        CMTime cmTime = [value CMTimeValue];
        
        NSString *imageName = [TSImage imageNameForCMTime:cmTime];
        if (![TSImage fileExistsForImageName:imageName]) {
            [filteredCMValues addObject:value];
        }
    }
    
    [self loadVideoWithURL:videoURL ready:^{
        NSLog(@"Video loaded: %@",videoURL);
        
        [self preprocessImagesToStore:filteredCMValues done:^(NSError *error, UIImage *image, CMTime cmTime) {
            NSLog(@"Got thumbnail %@ %f %f",image,image.size.width,image.size.height);
        }];
    }];

}

- (void)preprocessImagesToStore:(NSArray *)cmTimes done:(void (^)(NSError *error, UIImage *image, CMTime cmTime))done;
{
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.playerItem.asset];
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:cmTimes completionHandler:^(CMTime requestedTime, CGImageRef imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            NSString *imageName = [TSImage imageNameForCMTime:requestedTime];
            [TSImage saveToLocalStoreImage:image withName:imageName];
            NSLog(@"generateCGImagesAsyncchrounouse imageName:%@",imageName);
            done(nil, image,requestedTime);
        } else if (result == AVAssetImageGeneratorFailed) {
            done(error, nil, CMTimeMake(0,0));
        } else if (result == AVAssetImageGeneratorCancelled) {
            NSError *canceledError = [NSError errorWithDomain:@"VideoPlayerViewController: frame capture canceled" code:1 userInfo:nil];
            done(canceledError, nil, CMTimeMake(0,0));
        }
    }];
}


- (void) loadDataFromDisk {
    //NSString *theImagePath = [yourDictionary objectForKey:@"cachedImagePath"];
    //UIImage *customImage = [UIImage imageWithContentsOfFile:theImagePath];
}

- (NSArray *) readSubtitles {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"srt"];
    
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    NSMutableArray *subtitles = [@[] mutableCopy];
   
    
    while (![scanner isAtEnd])
    {
        @autoreleasepool
        {
            NSString *indexString;
            (void) [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&indexString];
            
            NSString *startString;
            (void) [scanner scanUpToString:@" --> " intoString:&startString];
            
            // My string constant doesn't begin with spaces because scanners
            // skip spaces and newlines by default.
            (void) [scanner scanString:@"-->" intoString:NULL];
            
            NSString *endString;
            (void) [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&endString];
            
            NSString *textString;
            // (void) [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&textString];
            // BEGIN EDIT
            (void) [scanner scanUpToString:@"\r\n\r\n" intoString:&textString];
            textString = [textString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
            // Addresses trailing space added if CRLF is on a line by itself at the end of the SRT file
            textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            // END EDIT
            
            NSArray *split = [startString componentsSeparatedByString:@":"];
            
            int hours = [split[0] intValue];
            int minutes = [split[1] intValue];
            NSArray *secondsplit = [split[2] componentsSeparatedByString:@","];
            int seconds = [secondsplit[0] intValue];
            int microseconds = [secondsplit[1] intValue];
            
            float timeInSeconds = microseconds/1000.0 + seconds + minutes * 60 + hours * 3600;
            
            CMTime cmTime = CMTimeMake((int)(timeInSeconds*1000.0), 1000);
            
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:timeInSeconds], @"startFloat",
                                        [NSValue valueWithCMTime:cmTime],@"startCMTime",
                                        [TSImage imageNameForCMTime:cmTime],@"imageName",
                                        indexString, @"index",
                                        startString, @"start",
                                        endString , @"end",
                                        textString , @"content",
                                        nil];
            [subtitles addObject:dictionary];
            
           // NSLog(@"%@", dictionary);
        }
    }
    NSLog(@"Loaded %d subtitles",[subtitles count]);
    return subtitles;
}



- (void)loadVideoWithURL:(NSURL *)url ready:(void (^)(void))readyBlock
{
    self.readyBlock = readyBlock;
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:@"loadVideo"];
}

- (void)framesAtTimeWithSeconds:(NSArray *)floatTimes done:(void (^)(NSError *error, CGImageRef image))done;
{
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.playerItem.asset];
    
    NSMutableArray *timesArray = [@[] mutableCopy];
    
    for (NSNumber *time in floatTimes) {
        CMTime cmTime = CMTimeMake((int)([time floatValue]*1000.0), 1000);
        [timesArray addObject:[NSValue valueWithCMTime:cmTime]];
        //NSLog(@"added for time %f success %f %f %f!",[time floatValue],[cmTime.value floatVal],[[cmTime.timescale floatVal],[cmTime.value floatVal]/[cmTime.timescale floatVal]);
    }
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:timesArray completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            NSLog(@"generateCGImagesAsyncchrounouse for time success %lld %u!",requestedTime.value,requestedTime.timescale);
            done(nil, image);
        } else if (result == AVAssetImageGeneratorFailed) {
            done(error, nil);
        } else if (result == AVAssetImageGeneratorCancelled) {
            NSError *canceledError = [NSError errorWithDomain:@"VideoPlayerViewController: frame capture canceled" code:1 userInfo:nil];
            done(canceledError, nil);
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == @"loadVideo") {
        NSLog(@"Video is loaded");
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"Video ready to play");
            
        }
        
        self.readyBlock();
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
