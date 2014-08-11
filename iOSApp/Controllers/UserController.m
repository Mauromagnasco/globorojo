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

#import "UserController.h"

@implementation UserController

-(NSString *)userUserID {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"RBUserID"]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"RBUserID"];
    } else {
        return nil;
    }
}

-(BOOL)setUserUserID:(NSString *)userID {
    [[NSUserDefaults standardUserDefaults] setValue:userID forKey:@"RBUserID"];
    BOOL success = [[NSUserDefaults standardUserDefaults] synchronize];
    return success;
}

@end
