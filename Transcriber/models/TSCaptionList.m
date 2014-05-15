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

@interface TSCaptionList ()

@property (strong,nonatomic) AVPlayerItem *playerItem;
@property (copy) void (^readyBlock)(void);

@end

@implementation TSCaptionList

-(id)init {
    self = [super init];
    if (self) {
        self.list = [self snowdenData];
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
    NSArray *timeValues = [subtitles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"startFloat > 0"]];
    NSLog(@"Time values: %@",timeValues);
    for (NSDictionary *subtitle in subtitles) {
        
    }
    
    [self loadVideoWithURL:videoURL ready:^{
        
        NSLog(@"Video loaded: %@",videoURL);
        [self framesAtTimeWithSeconds:@[@(60.0)] done:^(NSError *error, CGImageRef imageRef) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            NSLog(@"Got thumbnail %@ %f %f",image,image.size.width,image.size.height);
            
            //[self updateThumbWithImage:image];
            [self saveToLocalStoreImage:image];
            //self.thumbImageView.image = image;
            //self.thumbImageView.backgroundColor = [UIColor redColor];
            
        }];
    }];

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
            
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:timeInSeconds], @"startFloat",
                                        indexString, @"index",
                                        startString, @"start",
                                        endString , @"end",
                                        textString , @"text",
                                        nil];
            
            [subtitles addObject:dictionary];
            
            NSLog(@"%@", dictionary);
        }
    }
    return subtitles;
}


- (void)saveToLocalStoreImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image,0.1);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"cached"]];
    
    NSLog((@"pre writing to file"));
    if (![imageData writeToFile:imagePath atomically:NO])
    {
        NSLog(@"Failed to cache image data to disk");
    }
    else
    {
        NSLog(@"the cachedImagedPath is %@",imagePath);
    }
    
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


- (NSMutableArray *)snowdenData {
    NSArray *captions = @[@"The rights of citizens, the future of the Internet. So I would like to welcome to the TED stage the man behind those revelations, Ed Snowden. Ed is in a remote location somewhere in Russia controlling this bot from his laptop, so he can see what the bot can see. Ed, welcome to the TED stage. What can you see, as a matter of fact?",
                           @"Ha, I can see everyone. This is amazing.\nEd, some questions for you. You've been called many things in the last few months. You've been called a whistleblower, a traitor, a hero. What words would you describe yourself with?",
                           @"You know, everybody who is involved with this debate has been struggling over me and my personality and how to describe me. But when I think about it, this isn't the question that we should be struggling with. Who I am really doesn't matter at all. If I'm the worst person in the world, you can hate me and move on.",
                           @"What really matters here are the issues. What really matters here is the kind of government we want, the kind of Internet we want, the kind of relationship between people and societies. And that's what I'm hoping the debate will move towards, and we've seen that increasing over time. If I had to describe myself, I wouldn't use words like \"hero.\" I wouldn't use \"patriot,\" and I wouldn't use \"traitor.\" I'd say I'm an American and I'm a citizen, just like everyone else.",
                           @"So just to give some context for those who don't know the whole story this time a year ago, you were stationed in Hawaii working as a consultant to the NSA. As a sysadmin, you had access to their systems, and you began revealing certain classified documents to some handpicked journalists leading the way to June's revelations. Now, what propelled you to do this?",
                           @"You know, when I was sitting in Hawaii, and the years before, when I was working in the intelligence community, I saw a lot of things that had disturbed me. We do a lot of good things in the intelligence community, things that need to be done, and things that help everyone. But there are also things that go too far. There are things that shouldn't be done, and decisions that were being made in secret without the public's awareness, without the public's consent, and without even our representatives in government having knowledge of these programs.",
                           @"When I really came to struggle with these issues, I thought to myself, how can I do this in the most responsible way, that maximizes the public benefit while minimizing the risks? And out of all the solutions that I could come up with, out of going to Congress, when there were no laws, there were no legal protections for a private employee, a contractor in intelligence like myself, there was a risk that I would be buried along with the information and the public would never find out.",
                           @"But the First Amendment of the United States Constitution guarantees us a free press for a reason, and that's to enable an adversarial press, to challenge the government, but also to work together with the government, to have a dialogue and debate about how we can inform the public about matters of vital importance without putting our national security at risk.",
                           @"And by working with journalists, by giving all of my information back to the American people, rather than trusting myself to make the decisions about publication, we've had a robust debate with a deep investment by the government that I think has resulted in a benefit for everyone. And the risks that have been threatened, the risks that have been played up by the government have never materialized.",
                           @"We've never seen any evidence of even a single instance of specific harm, and because of that, I'm comfortable with the decisions that I made. So let me show the audience a couple of examples of what you revealed. If we could have a slide up, and Ed, I don't know whether you can see, the slides are here."
                           @"This is a slide of the PRISM program, and maybe you could tell the audience what that was that was revealed. The best way to understand PRISM because there's been a little bit of controversy, is to first talk about what PRISM isn't. Much of the debate in the U.S. has been about metadata. They've said it's just metadata, it's just metadata, and they're talking about a specific legal authority called Section 215 of the Patriot Act. That allows sort of a warrantless wiretapping, mass surveillance of the entire country's phone records, things like that -- who you're talking to, when you're talking to them, where you traveled. These are all metadata events.",
                           @"PRISM is about content. It's a program through which the government could compel corporate America, it could deputize corporate America to do its dirty work for the NSA. And even though some of these companies did resist, even though some of them -- I believe Yahoo was one of them challenged them in court, they all lost, because it was never tried by an open court. They were only tried by a secret court."
                           ];

    NSMutableArray *data = [@[] mutableCopy];
    int i = 0;
    for (NSString *caption in captions) {
        i++;
        TSCaption *tscaption = [[TSCaption alloc] initWithData:@{@"content":caption,@"imageName":[NSString stringWithFormat:@"Image%d",(i % 10)+1]}];
        [data addObject:tscaption];
    }
    return data;
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
