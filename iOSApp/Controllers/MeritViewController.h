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

@interface MeritViewController : UIViewController {

    NSDictionary *data;
    NSMutableArray *categoryItemArray;
    NSMutableArray *labelArray;
    
    NSString *rbUserName;
    NSString *rbCred;
    NSString *rbName;
}

@property (strong, nonatomic) IBOutlet UILabel *meritNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *meritUsernameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *meritUserscoreImageView;
@property (strong, nonatomic) IBOutlet UILabel *meritUserscoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *meritDescriptionLabel;

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSString *rbUserName;
@property (nonatomic, retain) NSString *rbCred;
@property (nonatomic, retain) NSString *rbName;
@property (nonatomic, retain) NSMutableArray *categoryItemArray;
@property (nonatomic, retain) NSMutableArray *labelArray;



@end
