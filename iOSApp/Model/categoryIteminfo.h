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

@interface categoryIteminfo : NSObject {

    NSString *rbHashtag;
    float score;
    int cnt;
}

@property (nonatomic, retain) NSString *rbHashtag;
@property (nonatomic) float score;
@property (nonatomic) int cnt;

@end
