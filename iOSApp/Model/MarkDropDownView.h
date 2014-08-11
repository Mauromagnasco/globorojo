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

#import <UIKit/UIKit.h>

@interface MarkDropDownView : UIView

@property (nonatomic,strong) UIButton *mainButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic,strong) NSTimer *hideTimer;
@property (nonatomic,assign) float timeHideAfter;

+(MarkDropDownView *)showDropDownViewInView:(UIView *)view
                                       text:(NSString *)text
                                   animated:(BOOL)animated
                                     target:(id)target
                                   selector:(SEL)selector
                                  hideAfter:(float)hideAfter;

-(void)hide:(BOOL)animated;

@end
