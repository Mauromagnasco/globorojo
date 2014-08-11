//
// Copyright 2013 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "NSString+Validations.h"

@implementation NSString (Validations)

- (BOOL)isValidUsername {
    if (self.length < 3) {
        return NO;
    }
    
    NSString *usernameRegex = @"(?:[a-z0-9A-Z_-]"
    @"*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f]))";
    
    NSPredicate *usernamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", usernameRegex];
    
    return [usernamePredicate evaluateWithObject:self];
}

- (BOOL)isValidEmail {
    NSString*emailRegex =@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

    NSPredicate*emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    NSString *emailToCheck = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return[emailTest evaluateWithObject:emailToCheck];
}

@end
