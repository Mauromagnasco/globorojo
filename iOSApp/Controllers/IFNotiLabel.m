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

#import "IFNotiLabel.h"
#import "RegexKitLite.h"
#import "RKLMatchEnumerator.h"
#import "Constants.h"

#define DRAW_DEBUG_FRAMES 0


@implementation IFNotiLabel

@synthesize normalColor;
@synthesize highlightColor;

@synthesize normalImage;
@synthesize highlightImage;

@synthesize label;

@synthesize linksEnabled;
@synthesize buttonFontColor;
@synthesize buttonFontSize;
@synthesize videoId;
@synthesize data;
@synthesize rb_type;


NSString *IFNotiLabelURLNotification = @"IFNotiLabelURLNotification";


static NSArray *expressions = nil;

+ (void)initialize
{
	// setup regular expressions that define where buttons will be created
//	expressions = [[NSArray alloc] initWithObjects:
//                   @"(\\+)?([0-9]{8,}+)", // phone numbers, 8 or more
//                   @"(@[a-zA-Z0-9_]+)", // screen names
//                   @"(#[a-zA-Z0-9_-]+)", // hash tags
//                   @"post",
//                   @"mentioned",
//                   @"([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])", // hyperlinks with http://
//                   @"[wW][wW][wW].([a-z]|[A-Z]|[0-9]|[/.]|[~])*", // hyperlinks like www.something.tld
//                   nil];
    
	expressions = [[NSArray alloc] initWithObjects:
                   @"(@[a-zA-Z0-9óíñ_]+)", // screen names
                   @"(#[a-zA-Z0-9óíñ_-]+)", // hash tags
                   @"post",
                   @"mentioned",
                   nil];
}

- (void)handleButton:(id)sender
{
	NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
	//NSLog(@"IFTweetLabel: handleButton: sender = %@, title = %@", sender, buttonTitle);
    
	// NOTE: It's possible that the button title only includes the beginning of screen name or hyperlink.
	// This code collects all possible links in the current label text and gets a full match that can be passed
	// with the notification.
	
    NSString *firstCharacter = [buttonTitle substringToIndex:1];
    
    NSString *currentView = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentView"];
    
    if ([firstCharacter isEqualToString:@"@"]) {
        [[NSUserDefaults standardUserDefaults] setObject:buttonTitle forKey:IFNotiLabelButtonTitle];

        if ([currentView isEqualToString:@"FindFriend"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelFindUserNotification object:nil];
        }else if ([currentView isEqualToString:@"Followers"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelFollowUserNotification object:Nil];
        }else if ([currentView isEqualToString:@"Following"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelFollowingUserNotification object:Nil];
        }else if ([currentView isEqualToString:@"Notification"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelUserNotification object:Nil];
        }
        
    }
    
    if ([buttonTitle isEqualToString:@"post"] || [buttonTitle isEqualToString:@"mentioned"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]] forKey:@"PostVideoId"];
        
        if ([currentView isEqualToString:@"Notification"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelPostNotification object:Nil];
        }
    }
    
}

- (void)createButtonWithText:(NSString *)text withFrame:(CGRect)frame
{
	UIButton *button = nil;

    button = [UIButton buttonWithType:UIButtonTypeCustom]; // autoreleased

	[button setFrame:CGRectMake(frame.origin.x - 0.2, frame.origin.y+1, frame.size.width, frame.size.height)];
    
    
	[button.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:buttonFontSize]];
//    button.titleLabel.font =  [UIFont boldSystemFontOfSize:button.titleLabel.font.pointSize];
	[button setTitle:[NSString stringWithFormat:@"%@", text] forState:UIControlStateNormal];
	[button.titleLabel setLineBreakMode:[self.label lineBreakMode]];
	[button setTitleColor:self.normalColor forState:UIControlStateNormal];
	[button setTitleColor:self.highlightColor forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
//    [button setBackgroundColor:[UIColor colorWithRed:(215.f/255.f) green:(215.f/255.f) blue:(215.f/255.f) alpha:1.0]];
    [button setBackgroundColor:[UIColor clearColor]];
    [button.titleLabel setTextColor:buttonFontColor];
    if (![videoId isEqual:[NSNull null]]) {
        button.tag = [videoId intValue];
    }
	[self addSubview:button];
}


- (void)createButtonsWithText:(NSString *)text atPoint:(CGPoint)point
{
	//NSLog(@"output = '%@', point = %@", text, NSStringFromCGPoint(point));
    
	UIFont *font = self.label.font;
    
    // keep an array of already parsed substrings of the current line of text
    // (if we get more than 16 matches this is going to crash)
    NSRange parsedRanges[16];
    NSInteger parsedRangesLength = 0;
    
    // take each of the regular expressions that we defined and try to match it within the text
	for (NSString *expression in expressions)
	{
		NSString *match;
		NSEnumerator *enumerator = [text matchEnumeratorWithRegex:expression];
        
        // go through all the matches and weed out overlapping ones in the process
		while (match = [enumerator nextObject])
		{
            // compute the size of the matched string
			CGSize matchSize = [match sizeWithFont:font];
            
            NSRange matchRange;
            NSInteger startingLocation = 0;
            BOOL matchAlreadyHandled = NO;
            
            // in a gist, the while below will keep trying to match a substring if it hasn't been matched yet
            // this prevents double-matching an url like www.a.com if http://www.a.com was already matched
            // this also allows the engine to match a string like 'www.a.com www.a.com'
            while (true) {
                // find the first match in our text
                matchRange = [text rangeOfString:match options:0 range:NSMakeRange(startingLocation, [text length] - startingLocation)];
                
                // check if the match's range overlaps any of the previously handled matches
                BOOL isOverlapping = NO;
                for (int i=0; i < parsedRangesLength; i++)
                {
                    NSRange aRange = parsedRanges[i];
                    if (NSIntersectionRange(aRange, matchRange).length != 0)
                    {
                        // the match overlaps, therefore move the caret to the right
                        startingLocation = matchRange.location + matchRange.length;
                        isOverlapping = YES;
                        break;
                    }
                }
                if (isOverlapping)
                {
                    if (startingLocation >= [text length])
                    {
                        // we are at the end of our string therefore we have exhausted all chances to match it
                        matchAlreadyHandled = YES;
                        break;
                    }
                }
                else
                {
                    break;
                }
            }
            if (matchAlreadyHandled)
            {
                continue;
            }
			
			NSRange measureRange = NSMakeRange(0, matchRange.location);
            // take the string that precedes the match
			NSString *measureText = [text substringWithRange:measureRange];
            // compute the size of the string that precedes the match
			CGSize measureSize = [measureText sizeWithFont:font];
			
            // compute the frame of the matched text
			CGRect matchFrame = CGRectMake(measureSize.width - 3.0f, point.y + 2, matchSize.width + 6.0f, matchSize.height);
			[self createButtonWithText:match withFrame:matchFrame];
			
            parsedRanges[parsedRangesLength] = matchRange;
            parsedRangesLength++;
			//NSLog(@"match = %@", match);
		}
	}
}

// NOTE: It seems that UILabel doesn't break at whitespace if it's at the beginning of the line. This value is a total fricken' guess.
#define MIN_WHITESPACE_LOCATION 5

- (void)createButtons
{
	CGRect frame = self.frame;
	if (frame.size.width == 0.0f || frame.size.height == 0.0f)
	{
		return;
	}
	
	UIFont *font = self.label.font;
    
	
	NSString *text = self.label.text;
	NSUInteger textLength = [text length];
    
	// by default, the output starts at the top of the frame
	CGPoint outputPoint = CGPointZero;
	CGSize textSize = [text sizeWithFont:font constrainedToSize:frame.size];
	CGRect bounds = [self bounds];
	if (textSize.height < bounds.size.height)
	{
		// the lines of text are centered in the bounds, so adjust the output point
		CGFloat boundsMidY = CGRectGetMidY(bounds);
		CGFloat textMidY = textSize.height / 2.0;
		outputPoint.y = ceilf(boundsMidY - textMidY);
	}
    
	
	//NSLog(@"****** text = '%@'", text);
	
	// initialize whitespace tracking
	BOOL scanningWhitespace = NO;
	NSRange whitespaceRange = NSMakeRange(NSNotFound, 0);
	
	// scan the text
	NSRange scanRange = NSMakeRange(0, 1);
	while (NSMaxRange(scanRange) < textLength)
	{
		NSRange tokenRange = NSMakeRange(NSMaxRange(scanRange) - 1, 1);
		NSString *token = [text substringWithRange:tokenRange];
        
#if 0
		// debug bytes in token
		char buffer[10];
		NSUInteger usedLength;
		[token getBytes:&buffer maxLength:10 usedLength:&usedLength encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, [token length]) remainingRange:NULL];
		NSUInteger index;
		for (index = 0; index < usedLength; index++)
		{
			NSLog(@"token: %3d 0x%02x", tokenRange.location, buffer[index] & 0xff);
		}
#endif
		
		if ([token isEqualToString:@" "] || [token isEqualToString:@"?"] || [token isEqualToString:@"-"])
		{
			//NSLog(@"------ whitespace: token = '%@'", token);
			
			// handle whitespace
			if (! scanningWhitespace)
			{
				// start of whitespace
				whitespaceRange.location = tokenRange.location;
				whitespaceRange.length = 1;
			}
			else
			{
				// continuing whitespace
				whitespaceRange.length += 1;
			}
            
			scanningWhitespace = YES;
			
			// scan the next position
			scanRange.length += 1;
		}
		else
		{
			// end of whitespace
			scanningWhitespace = NO;
            
			NSString *scanText = [text substringWithRange:scanRange];
			CGSize currentSize = [scanText sizeWithFont:font];
			
			BOOL breakLine = NO;
			if ([token isEqualToString:@"\r"] || [token isEqualToString:@"\n"])
			{
				// carriage return or newline caused line to break
				//NSLog(@"------ scanText = '%@', token = '%@'", scanText, token);
				breakLine = YES;
			}
			BOOL breakWidth = NO;
			if (currentSize.width > frame.size.width)
			{
				// the width of the text in the frame caused the line to break
				//NSLog(@"------ scanText = '%@', currentSize = %@", scanText, NSStringFromCGSize(currentSize));
				breakWidth = YES;
			}
			
			if (breakLine || breakWidth)
			{
				// the line broke, compute the range of text we want to output
				NSRange outputRange;
				
				if (breakLine)
				{
					// output before the token that broke the line
					outputRange.location = scanRange.location;
					outputRange.length = tokenRange.location - scanRange.location;
				}
				else
				{
					if (whitespaceRange.location != NSNotFound && whitespaceRange.location > MIN_WHITESPACE_LOCATION)
					{
						// output before beginning of the last whitespace
						outputRange.location = scanRange.location;
						outputRange.length = whitespaceRange.location - scanRange.location;
					}
					else
					{
						// output before the token that cause width overflow
						outputRange.location = scanRange.location;
						outputRange.length = tokenRange.location - scanRange.location;
					}
				}
				
				// make the buttons in this line of text
				[self createButtonsWithText:[text substringWithRange:outputRange] atPoint:outputPoint];
                
				if (breakLine)
				{
					// start scanning after token that broke the line
					scanRange.location = NSMaxRange(tokenRange);
					scanRange.length = 1;
				}
				else
				{
					if (whitespaceRange.location != NSNotFound && whitespaceRange.location > MIN_WHITESPACE_LOCATION)
					{
						// start scanning at end of last whitespace
						scanRange.location = NSMaxRange(whitespaceRange);
						scanRange.length = 1;
					}
					else
					{
						// start scanning at token that cause width overflow
						scanRange.location = NSMaxRange(tokenRange) - 1;
						scanRange.length = 1;
					}
				}
                
				// reset whitespace
				whitespaceRange.location = NSNotFound;
				whitespaceRange.length = 0;
				
				// move output to next line
				outputPoint.y += currentSize.height;
			}
			else
			{
				// the line did not break, scan the next position
				scanRange.length += 1;
			}
		}
	}
	
	// output to end
	[self createButtonsWithText:[text substringFromIndex:scanRange.location] atPoint:outputPoint];;
}

- (void)removeButtons
{
	UIView *view;
	for (view in [self subviews])
	{
		if ([view isKindOfClass:[UIButton class]])
		{
			[view removeFromSuperview];
		}
	}
}


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		self.clipsToBounds = YES;
		
		self.normalColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
		self.highlightColor = [UIColor redColor];
		
		self.normalImage = nil;
		self.highlightImage = nil;
        
		self.label = [[[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)] autorelease];
        self.label.lineBreakMode = UILineBreakModeWordWrap;
        self.label.numberOfLines = 3;
        
		[self addSubview:self.label];
        
		self.linksEnabled = NO;
    }
	
    return self;
}

- (void)dealloc
{
	self.normalColor = nil;
	self.highlightColor = nil;
    
	self.normalImage = nil;
	self.highlightImage = nil;
	
	[self removeButtons];
	
	[super dealloc];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
	[self removeButtons];
	if (linksEnabled)
	{
		[self createButtons];
	}
    
#if DRAW_DEBUG_FRAMES
	[self setNeedsDisplay];
#endif
}

#if DRAW_DEBUG_FRAMES
- (void)drawRect:(CGRect)rect
{
	[[UIColor whiteColor] set];
	UIRectFrame([self bounds]);
    
	UIView *view;
	for (view in [self subviews])
	{
		if ([view isKindOfClass:[UIButton class]])
		{
			[[UIColor redColor] set];
			UIRectFrame([view frame]);
		}
		else if ([view isKindOfClass:[UILabel class]])
		{
			[[UIColor greenColor] set];
			UIRectFrame([view frame]);
		}
	}
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (rb_type != 3 && rb_type != 5) {
        [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:TAG_RES_RB_VIDEO] forKey:@"PostVideoId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelPostNotification object:Nil];
    }else {
        NSString *username = [data objectForKey:TAG_RES_RB_SENDER_USERNAME];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"@%@", username] forKey:IFNotiLabelButtonTitle];
        [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelUserNotification object:Nil];
    }
}


- (void)setText:(NSString *)text
{
	[self.label setText:text];
    
    [self setFrame:[self setDynamicHieghtForLabel:self.label andMaxWidth:220]];
    
	[self setNeedsLayout];
}

- (void)setLinksEnabled:(BOOL)state
{
	if (linksEnabled != state)
	{
		linksEnabled = state;
        
		[self setNeedsLayout];
	}
}

// handle methods that affect both this view and label view

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor];
	[self.label setBackgroundColor:backgroundColor];
}

- (void)setFrame:(CGRect)frame;
{
	[super setFrame:frame];
	[self.label setFrame:CGRectMake(0.0, 0.0f, frame.size.width, frame.size.height + 6)];
}

// forward methods that are not handled by the super class to the label view

- (void)forwardInvocation:(NSInvocation*)invocation
{
	SEL aSelector = [invocation selector];
    
	//NSLog(@"forwardInvocation: selector = %@", NSStringFromSelector(aSelector));
    
	if ([self.label respondsToSelector:aSelector])
	{
		[invocation invokeWithTarget:self.label];
	}
	else
	{
		[self doesNotRecognizeSelector:aSelector];
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	//NSLog(@"methodSignatureForSelector: selector = %@", NSStringFromSelector(aSelector));
    
	NSMethodSignature* methodSignature = [super methodSignatureForSelector:aSelector];
	if (methodSignature == nil)
	{
		methodSignature = [self.label methodSignatureForSelector:aSelector];
	}
	
	return methodSignature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	//NSLog(@"respondsToSelector: selector = %@", NSStringFromSelector(aSelector));
	
	return [super respondsToSelector:aSelector] || [self.label respondsToSelector:aSelector];
}


-(CGRect)setDynamicHieghtForLabel:(UILabel*)_lbl andMaxWidth:(float)_width{
    CGSize maximumLabelSize = CGSizeMake(_width, FLT_MAX);
    
    CGSize expectedLabelSize = [_lbl.text sizeWithFont:_lbl.font constrainedToSize:maximumLabelSize lineBreakMode:_lbl.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = _lbl.frame;
    newFrame.size.height = expectedLabelSize.height + 12;
    if (newFrame.size.height > 45) {
        newFrame.size.height = 45;
    }
    newFrame.size.width = _width;
    return newFrame;
}
@end
