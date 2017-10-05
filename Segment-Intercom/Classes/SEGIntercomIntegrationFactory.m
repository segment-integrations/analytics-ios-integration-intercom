#import "SEGIntercomIntegrationFactory.h"
#import "SEGIntercomIntegration.h"


@implementation SEGIntercomIntegrationFactory

+ (instancetype)instance
{
    static dispatch_once_t once;
    static SEGIntercomIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    return self;
}


- (id<SEGIntegration>)createWithSettings:(NSDictionary *)settings
{
    return [[SEGIntercomIntegration alloc] initWithSettings:settings];
}


- (NSString *)key
{
    return @"Intercom";
}

@end
