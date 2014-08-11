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

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>


@interface AppSharedData : NSObject {
    
    NSDictionary *facebookInfo;
    NSString *facebookToken;
    NSString *lastView;
    
    ACAccount *twitterAccount;
    
    NSMutableDictionary *storeImage;
    NSMutableDictionary *videoStoreImage;
    NSMutableDictionary *scoreRecord;
    NSMutableArray *profileHistory;
}

@property (nonatomic, retain) NSDictionary *facebookInfo;
@property (nonatomic, retain) NSMutableDictionary *storeImage;
@property (nonatomic, retain) NSMutableDictionary *videoStoreImage;
@property (nonatomic, retain) NSString *facebookToken;
@property (nonatomic, retain) ACAccount *twitterAccount;
@property (nonatomic, retain) NSString *lastView;
@property (nonatomic, retain) NSMutableArray *profileHistory;
@property (nonatomic, retain) NSMutableDictionary *scoreRecord;
@property (nonatomic) BOOL deleteFlag;
@property (nonatomic, retain) NSMutableDictionary *dHashtagList;

+ (AppSharedData *) sharedInstance;
+ (NSString*) sha1:(NSString*)input;
+ (NSString *)base64String:(NSString *)str;
+ (UIImage *)resizeImage:(UIImage *)image;


@end
