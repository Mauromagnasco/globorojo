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

// NOTE: Yeah, it would make more sense to subclass UILabel to do this. But all the
// the UIButtons that got placed on top of the UILabel were not tappable. No amount of
// tinkering with userInteractionEnabled and the responder chain could be found to
// work around this issue.
//
// Instead, a normal view is used and an UILabel methods are supported through forward
// invocation.

@interface IFNotiLabel : UIView
{
	UIColor *normalColor;
	UIColor *highlightColor;
    
	UIImage *normalImage;
	UIImage *highlightImage;
    
	UILabel *label;
	
	BOOL linksEnabled;
    
    UIColor *buttonFontColor;
    float buttonFontSize;
    
    NSString *videoId;
}

@property (nonatomic, retain) UIColor *normalColor;
@property (nonatomic, retain) UIColor *highlightColor;

@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *highlightImage;

@property (nonatomic, retain) UILabel *label;

@property (nonatomic, assign) BOOL linksEnabled;

@property (nonatomic, retain) UIColor *buttonFontColor;
@property (nonatomic) float buttonFontSize;
@property (nonatomic, retain) NSString *videoId;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic) int rb_type;

- (void)setBackgroundColor:(UIColor *)backgroundColor;
- (void)setFrame:(CGRect)frame;

@end


@interface IFNotiLabel (ForwardInvocation)

@property(nonatomic, copy) NSString *text;
@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic, retain) UIColor *textColor;
@property(nonatomic, retain) UIFont *font;

@end