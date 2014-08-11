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

#import "MTHTTPClient.h"

@implementation MTHTTPClient


static MTHTTPClient *sharedClient = nil;

+(MTHTTPClient *) sharedClient {
    if (!sharedClient) {
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.balloonred.com"]];
    }
    
    return sharedClient;
}


@end
