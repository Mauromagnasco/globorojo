//
//  MTMovieView.m
//

//
//  Created by Rens Verhoeven on 25-10-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import "MTMovieView.h"
#import "Flurry.h"
#import <SDWebImage/UIButton+WebCache.h>

#define DEAD_BUTTON_SIZE 35
#define DEAD_BUTTON_OFFSET 10

@interface MTMovieView ()

@end

@implementation MTMovieView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_thumbnailImageView setBackgroundColor:[UIColor blackColor]];
        [_thumbnailImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_thumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_thumbnailImageView];
        
        _moviePlayer = [[MPMoviePlayerController alloc] init];
        [_moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
        [_moviePlayer.view setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
        [_moviePlayer.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self addSubview:_moviePlayer.view];
        _moviePlayer.view.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateDidChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
        
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width-70)/2, (frame.size.height-70)/2, 70, 70)];
        [_playButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_playButton setBackgroundColor:[UIColor clearColor]];
        [_playButton setAdjustsImageWhenHighlighted:YES];
        [_playButton setImage:[UIImage imageNamed:@"MoviePlayButton.png"] forState:UIControlStateNormal];
        
        [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
        
        //this button will intercept/disable the click over full screen button.
        UIButton *deadButtonOverFullScreenButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - (DEAD_BUTTON_OFFSET+DEAD_BUTTON_SIZE),
                                                                                              frame.size.height-DEAD_BUTTON_SIZE, 
                                                                                              DEAD_BUTTON_SIZE,
                                                                                              DEAD_BUTTON_SIZE)];
        [deadButtonOverFullScreenButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
        [deadButtonOverFullScreenButton setBackgroundColor:[UIColor clearColor]];
        [self addSubview:deadButtonOverFullScreenButton];
    }
    return self;
}

-(void)dealloc {
    [self.moviePlayer stop];
}

-(void)setMovieThumbnailWithURL:(NSURL *)url {
    [_thumbnailImageView setImageWithURL:url];
}

-(void)setMovieWithURL:(NSURL *)url {
    if(url != self.moviePlayer.contentURL) {
        [self.moviePlayer stop];
        [self.moviePlayer setContentURL:url];
        [self.moviePlayer setShouldAutoplay:NO];
    }
}

-(IBAction)play:(id)sender {
    [_moviePlayer.view setBackgroundColor:[UIColor blackColor]];
    [_moviePlayer play];
    [self.moviePlayer setShouldAutoplay:YES];
    _moviePlayer.view.hidden = NO;
    _playButton.hidden = YES;
}

-(void)stop {
    [_moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [_moviePlayer stop];
    [_playButton setImage:[UIImage imageNamed:@"MoviePlayButton.png"] forState:UIControlStateNormal];
}

-(void)playVideo {
    [self play:nil];
}

-(void)stopVideo {
    [self stop];
}

-(void)playbackDidFinish:(NSNotification *)notification {
    if([notification object] == _moviePlayer) {
        [_moviePlayer.view setBackgroundColor:[UIColor clearColor]];
        [_playButton setImage:[UIImage imageNamed:@"MoviePlayButton.png"] forState:UIControlStateNormal];
        [_playButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
}

-(void)playbackStateDidChange:(NSNotification *)notification {
    if([notification object] == _moviePlayer) {
        if (_moviePlayer.playbackState != MPMoviePlaybackStatePlaying) {
            if([_movieViewDelegate respondsToSelector:@selector(movieView:didStopPlayingVideo:)]) {
                [_movieViewDelegate movieView:self didStopPlayingVideo:_moviePlayer];
            }
        } else {
            if([_movieViewDelegate respondsToSelector:@selector(movieView:didStartPlayingVideo:)]) {
                [_movieViewDelegate movieView:self didStartPlayingVideo:_moviePlayer];
            }
        }
    }
}

@end
