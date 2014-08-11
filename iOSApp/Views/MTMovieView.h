//
//  MTMovieView.h
//  Momentage
//
//  Created by Rens Verhoeven on 25-10-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class MTMovieView;

@protocol MTMovieViewProtocol <NSObject>

@optional

-(void)movieView:(MTMovieView *)movieView didStopPlayingVideo:(MPMoviePlayerController *)player;
-(void)movieView:(MTMovieView *)movieView didStartPlayingVideo:(MPMoviePlayerController *)player;

@end

@interface MTMovieView : UIView

@property (assign) NSUInteger index;

@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic,strong) UIImageView *thumbnailImageView;
@property (nonatomic,weak) id <MTMovieViewProtocol> movieViewDelegate;

-(void)setMovieWithURL:(NSURL *)url;
-(void)stop;
-(void)setMovieThumbnailWithURL:(NSURL *)url;

- (void)playVideo;
- (void)stopVideo;

@end
