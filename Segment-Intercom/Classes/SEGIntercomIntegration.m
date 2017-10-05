//
//  SEGIntercomIntegration.m
//  Pods
//
//  Created by ladan nasserian on 10/4/17.
//
//

#import "SEGIntercomIntegration.h"
#import <Analytics/SEGIntegration.h>
#import <Analytics/SEGAnalyticsUtils.h>
#import <Analytics/SEGAnalytics.h>

@implementation SEGIntercomIntegration

#pragma mark - Initialization

- (instancetype)initWithSettings:(NSDictionary *)settings
{
    if(self = [super init]) {
        self.settings = settings;
    }
    
    NSString *apiKey = settings[@"apiKey"];
    NSString *iOSAppId = settings[@"iOSAppId"];
    
    [Intercom setApiKey:apiKey forAppId:iOSAppId];
    // For testing
    [Intercom enableLogging];
    return self;
}

-(void)identify:(SEGIdentifyPayload *)payload
{
    
    // Intercom allows users to choose to track only known or only unknown users, as well as both. Segment will support the ability to track both by checking for loggedIn users (determined by the userId) and falling back to setting the user as "Unidentified" if this is not present.
    if(payload.userId) {
        [Intercom registerUserWithUserId:payload.userId];
        SEGLog(@"[Intercom registerUserWithUserId:%@];", payload.userId);
    } else if(payload.anonymousId) {
        [Intercom registerUnidentifiedUser];
        SEGLog(@"[Intercom registerUnidentifiedUser];");
    }
    
    if(payload.traits) {
        [self setUserAttributes:payload];
    }
}

-(void)track:(SEGTrackPayload *)payload
{
    [Intercom logEventWithName:payload.event metaData:payload.properties];
    SEGLog(@"[Intercom logEventWithName:%@ metaData:%@];", payload.event, payload.properties);

}

-(void)group:(SEGGroupPayload *)payload
{
    // id is a required field for adding or modifying a company.
    ICMCompany *company = [ICMCompany new];
    company.companyId = payload.groupId;
    
    NSDictionary *traits = payload.traits;
    NSMutableDictionary *customAttributes = [NSMutableDictionary dictionaryWithDictionary:traits];
    
    if (traits[@"name"]) {
        company.name = traits[@"name"];
        [customAttributes removeObjectForKey:@"name"];
    }
    
    if (traits[@"monthly_spend"]) {
        company.monthlySpend = traits[@"monthly_spend"];
        [customAttributes removeObjectForKey:@"monthly_spend"];

    };
    
    if (traits[@"plan"]) {
        company.plan = traits[@"plan"];
        [customAttributes removeObjectForKey:@"plan"];
    };
    
    // Intercom requires each value must be of type NSString, NSNumber or NSNull.
    for (NSString *key in customAttributes) {
        if (![[customAttributes valueForKey:key] isKindOfClass:[NSString class]] ||
            ![[customAttributes valueForKey:key] isKindOfClass:[NSNumber class]]) {
            [customAttributes removeObjectForKey:key];
        }
    }
    
    company.customAttributes = customAttributes;
    
    ICMUserAttributes *userAttributes = [ICMUserAttributes new];
    userAttributes.companies = @[company];
    [Intercom updateUser:userAttributes];
    SEGLog(@"[Intercom updateUser:%@];", userAttributes);

}

-(void)reset
{
    [Intercom reset];
    SEGLog(@" [Intercom reset];");
}

#pragma mark - Utils

-(void)setUserAttributes:(SEGIdentifyPayload *)payload
{
    
    ICMUserAttributes *userAttributes = [ICMUserAttributes new];
    
    NSDictionary *traits = payload.traits;
    NSMutableDictionary *customAttributes = [NSMutableDictionary dictionaryWithDictionary:traits];
    
    if(traits[@"email"]) {
        userAttributes.email = traits[@"email"];
        [customAttributes removeObjectForKey:@"email"];
    }
    
    if(traits[@"userId"]) {
        userAttributes.email = traits[@"userId"];
        [customAttributes removeObjectForKey:@"userId"];
    }
    
    if(traits[@"name"]) {
        userAttributes.email = traits[@"name"];
        [customAttributes removeObjectForKey:@"name"];
    }
    
    if(traits[@"phone"]) {
        userAttributes.email = traits[@"phone"];
        [customAttributes removeObjectForKey:@"phone"];
    }
    
    NSDictionary *integration = [payload.integrations valueForKey:@"intercom"];
    if(integration[@"languageOverride"]) {
        userAttributes.languageOverride = traits[@"language"];
    }
    
    // Intercom requires each value must be of type NSString, NSNumber or NSNull.
    for (NSString *key in customAttributes) {
        if (![[customAttributes valueForKey:key] isKindOfClass:[NSString class]] ||
            ![[customAttributes valueForKey:key] isKindOfClass:[NSNumber class]]) {
            [customAttributes removeObjectForKey:key];
        }
    }
    
    userAttributes.customAttributes = customAttributes;
    [Intercom updateUser:userAttributes];
    SEGLog(@"[Intercom updateUser:%@];", userAttributes);

}

@end
