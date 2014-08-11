/**
 * This class will behave as a singleton base for creation and destruction
 */

#import <Foundation/Foundation.h>

@interface Singleton : NSObject {
	
}

+ (instancetype) instance;
+ (void) destroyInstance;
+ (void) destroyAllSingletons;

@end
