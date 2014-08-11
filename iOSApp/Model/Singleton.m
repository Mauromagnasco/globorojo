#import "Singleton.h"

@implementation Singleton

static NSMutableDictionary* instances = nil;

///Return instance of Singleton

+ (instancetype) instance
{
	if (!instances) {
		instances = [[NSMutableDictionary alloc] init];
	}
	NSString *key = NSStringFromClass(self);
	id instance = [instances objectForKey:key];
	if (!instance) {
		instance = [[self alloc] init];
		[instances setObject:instance forKey:key];
	}
	
	return instance;
}

///Destroy the instance
+ (void) destroyInstance
{
    NSLog(@"DESTROY CONTROLLER : %@", NSStringFromClass([self class]));
	[instances removeObjectForKey:self];
}
///Destroy all intances
+ (void) destroyAllSingletons
{
	[instances removeAllObjects];
}

@end
