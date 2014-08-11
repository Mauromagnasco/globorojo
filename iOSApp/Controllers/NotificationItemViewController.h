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
#import "IFNotiLabel.h"

@interface NotificationItemViewController : UIViewController {
    
    NSDictionary *data;
    IFNotiLabel *contentLabel;
}

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *timeagoLabel;
@property (strong, nonatomic) IBOutlet IFNotiLabel *titleLabel;

@property (nonatomic, retain) IFNotiLabel *contentLabel;
@property (nonatomic, retain) NSDictionary *data;

- (IBAction)onBodyButton:(id)sender;
- (IBAction)onThumbButton:(id)sender;





@end
