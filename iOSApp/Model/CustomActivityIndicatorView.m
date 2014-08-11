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

#import "CustomActivityIndicatorView.h"

@implementation CustomActivityIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageview.image = [UIImage imageNamed:@"loading.png"];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        
        [self addSubview:imageview];
    }
    return self;
}


- (void) startAnimation {
    
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:MAXFLOAT];
    fullRotation.duration = MAXFLOAT * 0.2;
    fullRotation.removedOnCompletion = YES;
    
    [self.layer addAnimation:fullRotation forKey:nil];
}

- (void) stopAnimation {
    [self.layer removeAllAnimations];
}

@end
