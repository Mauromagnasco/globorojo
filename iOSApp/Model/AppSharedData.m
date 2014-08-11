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

#import "AppSharedData.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AppSharedData {
    
}

@synthesize storeImage;
@synthesize videoStoreImage;
@synthesize facebookInfo;
@synthesize facebookToken;
@synthesize twitterAccount;
@synthesize lastView;
@synthesize profileHistory;
@synthesize scoreRecord;
@synthesize deleteFlag;
@synthesize dHashtagList;

static AppSharedData *sharedInstance = nil;

+(AppSharedData *) sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (id)init {
	if (self = [super init]) {
		
        storeImage = [[NSMutableDictionary alloc] init];
        scoreRecord = [[NSMutableDictionary alloc] init];
        profileHistory = [[NSMutableArray alloc] init];
        dHashtagList = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}


+ (NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

+ (UIImage *)resizeImage:(UIImage *)image {
    
    CGFloat w = 320;
    CGFloat h = image.size.height * w / image.size.width;
    
    CGSize newSize = CGSizeMake(w, h);  //whaterver size
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    NSString *rs = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    return [AppSharedData sha1:rs];
}


@end