//
//  NLImageCropperView.m
//  NLImageCropper
//
// Copyright © 2012, Mirza Bilal (bilal@mirzabilal.com)
// All rights reserved.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 1.	Redistributions of source code must retain the above copyright notice,
//       this list of conditions and the following disclaimer.
// 2.	Redistributions in binary form must reproduce the above copyright notice,
//       this list of conditions and the following disclaimer in the documentation
//       and/or other materials provided with the distribution.
// 3.	Neither the name of Mirza Bilal nor the names of its contributors may be used
//       to endorse or promote products derived from this software without specific
//       prior written permission.
// THIS SOFTWARE IS PROVIDED BY MIRZA BILAL "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MIRZA BILAL BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NLImageCropperView.h"
#import <QuartzCore/QuartzCore.h>

#define MIN_IMG_SIZE 10
#define EDGE_THRESHOLD 30

@implementation NLImageCropperView


- (void)setCropRegionRect:(CGRect)cropRect
{
    _cropRect = cropRect;
    _translatedCropRect =CGRectMake(cropRect.origin.x/_scalingFactor, cropRect.origin.y/_scalingFactor, cropRect.size.width/_scalingFactor, cropRect.size.height/_scalingFactor);
    [_cropView setCropRegionRect:_translatedCropRect];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _image = nil;
    if (self) {
        // Initialization code
    }
    [self setBackgroundColor:[UIColor darkGrayColor]];
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _cropView = [[NLCropViewLayer alloc] initWithFrame:_imageView.bounds];
    [_cropView setBackgroundColor:[UIColor clearColor]];

    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    
    
    [self addSubview:_imageView];
    [self addSubview:_cropView];
    [self setCropRegionRect:CGRectMake(10, 10, 100, 100)];
    _scalingFactor = 1.0;
    _movePoint = NoPoint;
    _lastMovePoint = CGPointMake(0, 0);
    
#ifdef ARC
    [_imageView release];
    [_cropView release];
#endif
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_image != nil) {
        [self reLayoutView];
    }
    NSLog(@"Set Frame Called");
}
- (void) setImage:(UIImage*)image
{
    _image = image;

    [self reLayoutView];
    
    [_imageView setImage:_image];    
}

- (void) reLayoutView
{
    float imgWidth = _image.size.width;
    float imgHeight = _image.size.height;
    float viewWidth = self.bounds.size.width - 2*IMAGE_BOUNDRY_SPACE;
    float viewHeight = self.bounds.size.height - 2*IMAGE_BOUNDRY_SPACE;
    
    float widthRatio = imgWidth / viewWidth;
    float heightRatio = imgHeight / viewHeight;
    _scalingFactor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    _imageView.bounds = CGRectMake(0, 0, imgWidth / _scalingFactor, imgHeight/_scalingFactor);
    _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    _cropView.bounds = _imageView.bounds;
    _cropView.frame = _imageView.frame;
    
    [self setCropRegionRect:_cropRect];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        NSLog(@"Touch Begins");
    [super touchesBegan:touches withEvent:event];

    CGPoint locationPoint = [[touches anyObject] locationInView:_imageView];
    if(locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > _imageView.bounds.size.width || locationPoint.y > _imageView.bounds.size.height)
    {
        _movePoint = NoPoint;
        return;
    }
    _lastMovePoint = locationPoint;
    
    if(((locationPoint.x - EDGE_THRESHOLD) <= _translatedCropRect.origin.x) &&
       ((locationPoint.x + EDGE_THRESHOLD) >= _translatedCropRect.origin.x))
    {
        if(((locationPoint.y - EDGE_THRESHOLD) <= _translatedCropRect.origin.y) &&
           ((locationPoint.y + EDGE_THRESHOLD) >= _translatedCropRect.origin.y))
            _movePoint = LeftTop;
        else if ((locationPoint.y - EDGE_THRESHOLD) <= (_translatedCropRect.origin.y + _translatedCropRect.size.height) &&
                 (locationPoint.y + EDGE_THRESHOLD) >= (_translatedCropRect.origin.y + _translatedCropRect.size.height))
            _movePoint = LeftBottom;
        else
            _movePoint = NoPoint;
    }
    else if(((locationPoint.x - EDGE_THRESHOLD) <= (_translatedCropRect.origin.x + _translatedCropRect.size.width)) &&
            ((locationPoint.x + EDGE_THRESHOLD) >= (_translatedCropRect.origin.x + _translatedCropRect.size.width)))
    {
        if(((locationPoint.y - EDGE_THRESHOLD) <= _translatedCropRect.origin.y) &&
           ((locationPoint.y + EDGE_THRESHOLD) >= _translatedCropRect.origin.y))
            _movePoint = RightTop;
        else if ((locationPoint.y - EDGE_THRESHOLD) <= (_translatedCropRect.origin.y + _translatedCropRect.size.height) &&
                 (locationPoint.y + EDGE_THRESHOLD) >= (_translatedCropRect.origin.y + _translatedCropRect.size.height))
            _movePoint = RightBottom;
        else
            _movePoint = NoPoint;
    }
    else if ((locationPoint.x > _translatedCropRect.origin.x) && (locationPoint.x < (_translatedCropRect.origin.x + _translatedCropRect.size.width)) &&
             (locationPoint.y > _translatedCropRect.origin.y) && (locationPoint.y < (_translatedCropRect.origin.y + _translatedCropRect.size.height)))
    {
        _movePoint = MoveCenter;
    }
    else
        _movePoint = NoPoint;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

    CGPoint locationPoint = [[touches anyObject] locationInView:_imageView];

    NSLog(@"Location Point: (%f,%f)", locationPoint.x, locationPoint.y);
    if(locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > _imageView.bounds.size.width || locationPoint.y > _imageView.bounds.size.height)
    {
        _movePoint = NoPoint;
        return;
    }
    
    float sv;
    float x,y;
    
    CGPoint sp;
    
    switch (_movePoint) {
        case LeftTop:
            if(((locationPoint.x + MIN_IMG_SIZE) >= (_translatedCropRect.origin.x + _translatedCropRect.size.width)) ||
               ((locationPoint.y + MIN_IMG_SIZE)>= (_translatedCropRect.origin.y + _translatedCropRect.size.height)))
                return;
            
            sp = CGPointMake(_translatedCropRect.origin.x + _translatedCropRect.size.width, _translatedCropRect.origin.y + _translatedCropRect.size.height);
            
            
            sv = sp.x - locationPoint.x;
            if (sv < sp.y - locationPoint.y) {
                sv = sp.y - locationPoint.y;
            }
            
            if (sp.x - sv < 0) {
                sv = sp.x;
            }
            
            if (sp.y - sv < 0) {
                sv = sp.y;
            }
            
            _translatedCropRect = CGRectMake(sp.x - sv, sp.y - sv,
                                             sv,
                                             sv);
            break;
        case LeftBottom:
            if(((locationPoint.x + MIN_IMG_SIZE) >= (_cropRect.origin.x + _translatedCropRect.size.width)) ||
               ((locationPoint.y - _translatedCropRect.origin.y) <= MIN_IMG_SIZE))
                return;
            
            sp = CGPointMake(_translatedCropRect.origin.x + _translatedCropRect.size.width, _translatedCropRect.origin.y);
            
            
            sv = sp.x - locationPoint.x;
            if (sv < locationPoint.y - sp.y) {
                sv = locationPoint.y - sp.y;
            }
            
            if (locationPoint.x < 0) {
                sv = sp.x;
            }
            
            if (sp.y + sv > 240) {
                sv = 240 - sp.y;
            }
            
            _translatedCropRect = CGRectMake(sp.x - sv, sp.y,
                                   sv,
                                   sv);
            break;
        case RightTop:
            if(((locationPoint.x - _translatedCropRect.origin.x) <= MIN_IMG_SIZE) ||
               ((locationPoint.y + MIN_IMG_SIZE)>= (_translatedCropRect.origin.y + _translatedCropRect.size.height)))
                return;
            
            sp = CGPointMake(_translatedCropRect.origin.x , _translatedCropRect.origin.y + _translatedCropRect.size.height);
            
            
            sv = locationPoint.x - sp.x;
            if (sv < sp.y - locationPoint.y) {
                sv = sp.y - locationPoint.y;
            }
            
            if (locationPoint.x > 240) {
                sv = 240 - sp.x;
            }
            
            if (sp.y - sv < 0) {
                sv = sp.y;
            }
            
            _translatedCropRect = CGRectMake(sp.x, sp.y - sv,
                                             sv,
                                             sv);
            break;
        case RightBottom:
            if(((locationPoint.x - _translatedCropRect.origin.x) <= MIN_IMG_SIZE) ||
               ((locationPoint.y - _translatedCropRect.origin.y) <= MIN_IMG_SIZE))
                return;
            
            sp = CGPointMake(_translatedCropRect.origin.x , _translatedCropRect.origin.y);
            
            
            sv = locationPoint.x - sp.x;
            if (sv < locationPoint.y - sp.y) {
                sv = locationPoint.y - sp.y;
            }
            
            if (locationPoint.x > 240) {
                sv = 240 - sp.x;
            }
            
            if (sp.y + sv > 240) {
                sv = 240 - sp.y;
            }
            
            _translatedCropRect = CGRectMake(sp.x, sp.y,
                                             sv,
                                             sv);
            break;
        case MoveCenter:

            x = _lastMovePoint.x - locationPoint.x;
            y = _lastMovePoint.y - locationPoint.y;
            if(((_translatedCropRect.origin.x-x) > 0) && ((_translatedCropRect.origin.x + _translatedCropRect.size.width - x) <
                                                          _cropView.bounds.size.width) &&
               ((_translatedCropRect.origin.y-y) > 0) && ((_translatedCropRect.origin.y + _translatedCropRect.size.height - y) < _cropView.bounds.size.height))
            {
                
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x - x, _translatedCropRect.origin.y - y, _translatedCropRect.size.width, _translatedCropRect.size.height);
            }
            _lastMovePoint = locationPoint;
            break;
        default: //NO Point
            return;
            break;
    }
    [_cropView setNeedsDisplay];
    _cropRect = CGRectMake(_translatedCropRect.origin.x*_scalingFactor, _translatedCropRect.origin.y*_scalingFactor, _translatedCropRect.size.width*_scalingFactor, _translatedCropRect.size.height*_scalingFactor);
    [self setCropRegionRect:_cropRect];
    
}

- (UIImage *)getCroppedImage {
    
    CGRect imageRect = CGRectMake(_cropRect.origin.x*_image.scale,
                      _cropRect.origin.y*_image.scale,
                      _cropRect.size.width*_image.scale,
                      _cropRect.size.height*_image.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([_image CGImage], imageRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:_image.scale
                                    orientation:_image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (CGRect) getCropRect {
    return _translatedCropRect;
}

@end
