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
#import <CoreText/CoreText.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@protocol AMAttributedHighlightLabelDelegate
- (void)selectedMention:(NSString *)string;
- (void)selectedHashtag:(NSString *)string;
- (void)selectedLink:(NSString *)string;
@end

@interface AMAttributedHighlightLabel : UILabel {
    NSMutableArray *touchableWords;
    NSMutableArray *touchableWordsRange;
    NSMutableArray *touchableLocations;
    
    NSRange currentSelectedRange;
    NSString *currentSelectedString;
    
}

@property(strong,nonatomic) UIColor *textColor;
@property(strong,nonatomic) UIColor *buttonFontColor;
@property(nonatomic) CGFloat buttonFontSize;
@property(strong,nonatomic) UIColor *mentionTextColor;
@property(strong,nonatomic) UIColor *hashtagTextColor;
@property(strong,nonatomic) UIColor *linkTextColor;
@property(strong,nonatomic) UIColor *selectedMentionTextColor;
@property(strong,nonatomic) UIColor *selectedHashtagTextColor;
@property(strong,nonatomic) UIColor *selectedLinkTextColor;

@property (nonatomic, weak) id <AMAttributedHighlightLabelDelegate> delegate;

- (void)setString:(NSString *)string;

@end
