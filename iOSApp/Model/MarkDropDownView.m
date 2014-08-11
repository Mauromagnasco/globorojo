/**
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 */
#import "MarkDropDownView.h"

@implementation MarkDropDownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        _mainButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,frame.size.width, 40)];
        [_mainButton setBackgroundImage:[[UIImage imageNamed:@"MTDropDownViewBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 5, 4)] forState:UIControlStateNormal];
        [[_mainButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]];

        [[_mainButton titleLabel] setTextAlignment:NSTextAlignmentCenter];
        
        [[_mainButton titleLabel] setNumberOfLines:15];
        [_mainButton setTitleColor:[UIColor colorWithRed:0.525 green:0.439 blue:0.239 alpha:1.000] forState:UIControlStateNormal];
        [_mainButton addTarget:self action:@selector(cancelTimer:) forControlEvents:UIControlEventTouchDown];
        [_mainButton addTarget:self action:@selector(resumeTimer:) forControlEvents:UIControlEventTouchUpOutside];
        [_mainButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        [_mainButton setAdjustsImageWhenHighlighted:NO];
        [_mainButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_mainButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 27, 0, 57)];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 30, 10, 20, 20)];
        
        [_imageView setImage:[UIImage imageNamed:@"btnClose.png"]];
        [self addSubview:_imageView];
        [self addSubview:_mainButton];
    }
    return self;
}

+(MarkDropDownView *)showDropDownViewInView:(UIView *)view text:(NSString *)text animated:(BOOL)animated target:(id)target selector:(SEL)selector hideAfter:(float)hideAfter {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    MarkDropDownView *dropDownView = [[MarkDropDownView alloc] initWithFrame:CGRectMake(40, -44, screenSize.width - 40, 44)];
    [view addSubview:dropDownView];
    [[dropDownView mainButton] setTitle:text forState:UIControlStateNormal];
    [[dropDownView mainButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dropDownView setBackgroundColor:[UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0]];
    [[dropDownView mainButton] addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [dropDownView setTimeHideAfter:hideAfter];
    [dropDownView setTimer:hideAfter];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [[dropDownView imageView] addGestureRecognizer:singleTap];
    
    UIFont *font = [[[dropDownView mainButton] titleLabel] font];
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(view.bounds.size.width-120, 250)];
    [dropDownView setFrame:CGRectMake(40, 0 - size.height, screenSize.width - 40, size.height+22)];
    
    [dropDownView show:animated];
    
    
    
    return dropDownView;
}

-(void)cancelTimer:(id)sender {
    if(_hideTimer) {
        if([_hideTimer isValid]) {
            [_hideTimer invalidate];
            _hideTimer = nil;
        }
    }
    
}

-(void)resumeTimer:(id)sender {
    if(_timeHideAfter != 0) {
     _hideTimer = [NSTimer timerWithTimeInterval:_timeHideAfter target:self selector:@selector(timeDone:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_hideTimer forMode:NSRunLoopCommonModes];
    }
}

-(void)timeDone:(NSTimer *)timer {
    if(_timeHideAfter != 0) {
        [self hide:YES];
    }
}

-(void)setTimer:(float)time {
    if(time != 0) {
        _hideTimer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(timeDone:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_hideTimer forMode:NSRunLoopCommonModes];
    }
}

-(void)hide:(BOOL)animated {
    [UIView animateWithDuration:0.32 animations:^{
        [self setAlpha:0];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y-self.frame.size.height, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }];
}

-(void)tapped:(id)sender {
    [self hide:YES];
}

-(void)show:(BOOL)animated {
    
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if(animated) {
        [self setHidden:NO];
        [self setAlpha:0];
        [UIView animateWithDuration:0.32 animations:^{
            [self setAlpha:1];
            if ([[vComp objectAtIndex:0] intValue] >= 7) {
                [self setFrame:CGRectMake(self.frame.origin.x, 20, self.frame.size.width, 40)];
            }else {
                [self setFrame:CGRectMake(self.frame.origin.x, 0, self.frame.size.width, 40)];
            }
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self setHidden:NO];
        [self setAlpha:1];
        
        if ([[vComp objectAtIndex:0] intValue] >= 7) {
            [self setFrame:CGRectMake(self.frame.origin.x, 20, self.frame.size.width, 40)];
        }else {
            [self setFrame:CGRectMake(self.frame.origin.x, 0, self.frame.size.width, 40)];
        }
    }
}



@end
