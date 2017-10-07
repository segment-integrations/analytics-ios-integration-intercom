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
        self.intercom = [Intercom class];
        
        NSString *apiKey = settings[@"apiKey"];
        NSString *iOSAppId = settings[@"iOSAppId"];
        
        [self.intercom setApiKey:apiKey forAppId:iOSAppId];
        SEGLog(@"[self.intercom setApiKey:%@ forAppId:%@];",apiKey, iOSAppId);
        
        // For testing
        [self.intercom enableLogging];
    }
    

    return self;
}

- (instancetype)initWithSettings:(NSDictionary *)settings andIntercom:(Class)intercom
{
    if (self = [super init]) {
        self.settings = settings;
        self.intercom = intercom;
    }
    return self;
}

-(void)identify:(SEGIdentifyPayload *)payload
{
    
    // Intercom allows users to choose to track only known or only unknown users, as well as both. Segment will support the ability to track both by checking for loggedIn users (determined by the userId) and falling back to setting the user as "Unidentified" if this is not present.
    if(payload.userId) {
        [self.intercom registerUserWithUserId:payload.userId];
        SEGLog(@"[Intercom registerUserWithUserId:%@];", payload.userId);
    } else if(payload.anonymousId) {
        [self.intercom registerUnidentifiedUser];
        SEGLog(@"[Intercom registerUnidentifiedUser];");
    }
    
    if(payload.traits) {
        [self setUserAttributes:payload];
    }
}

-(void)track:(SEGTrackPayload *)payload
{
    //'customAttributes' must be a non empty NSDictionary
    if([payload.properties count] == 0) {
        [self.intercom logEventWithName:payload.event];
        SEGLog(@"[Intercom logEventWithName:%@];", payload.event);
        return;
    }
    [self.intercom logEventWithName:payload.event metaData:payload.properties];
    SEGLog(@"[Intercom logEventWithName:%@ metaData:%@];", payload.event, payload.properties);
}

-(void)group:(SEGGroupPayload *)payload
{
    // id is a required field for adding or modifying a company.
    ICMCompany *company = [ICMCompany new];
    company.companyId = payload.groupId;

    [self setCompanyAttributes:payload.traits andCompany:company];
    company = [self setCompanyAttributes:payload.traits andCompany:company];
    
    ICMUserAttributes *userAttributes = [ICMUserAttributes new];
    userAttributes.companies = @[company];
    
    [self.intercom updateUser:userAttributes];
    SEGLog(@"[Intercom updateUser:%@];", userAttributes);
}

-(void)reset
{
    [self.intercom reset];
    SEGLog(@" [Intercom reset];");
}

#pragma mark - Utils

-(void)setUserAttributes:(SEGIdentifyPayload *)payload
{
    
    ICMUserAttributes *userAttributes = [ICMUserAttributes new];
    
    NSDictionary *traits = payload.traits;
    NSMutableDictionary *customAttributes = [NSMutableDictionary dictionaryWithDictionary:[traits copy]];
    
    if(traits[@"email"]) {
        userAttributes.email = traits[@"email"];
        [customAttributes removeObjectForKey:@"email"];
    }
    
    if(traits[@"userId"]) {
        userAttributes.userId = traits[@"userId"];
        [customAttributes removeObjectForKey:@"userId"];
    }
    
    if(traits[@"name"]) {
        userAttributes.name = traits[@"name"];
        [customAttributes removeObjectForKey:@"name"];
    }
    
    if(traits[@"phone"]) {
        userAttributes.phone = traits[@"phone"];
        [customAttributes removeObjectForKey:@"phone"];
    }
    
    //TODO: determine if we should guard for this
    if(traits[@"company"] && [traits[@"company"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *companyTraits = traits[@"company"];
        // id is a required field for adding or modifying a company.
        ICMCompany *company = [ICMCompany new];
        company.companyId = companyTraits[@"id"];
        
        company = [self setCompanyAttributes:companyTraits andCompany:company];
        userAttributes.companies = @[company];
    }
    
    NSDictionary *integration = [payload.integrations valueForKey:@"intercom"];
    if(integration[@"languageOverride"]) {
        userAttributes.languageOverride = integration[@"languageOverride"];
    }
    
    // Intercom requires each value must be of type NSString, NSNumber or NSNull.
    for (NSString *key in traits) {
        if (![[traits valueForKey:key] isKindOfClass:[NSString class]] &&
            ![[traits valueForKey:key] isKindOfClass:[NSNumber class]]) {
            [customAttributes removeObjectForKey:key];
        }
    }
    
    userAttributes.customAttributes = customAttributes;
    [self.intercom updateUser:userAttributes];
    SEGLog(@"[Intercom updateUser:%@];", userAttributes);

}

-(ICMCompany *)setCompanyAttributes:(NSDictionary *)companyTraits andCompany:(ICMCompany *)company
{
    NSMutableDictionary *customAttributes = [NSMutableDictionary dictionaryWithDictionary:[companyTraits copy]];
    [customAttributes removeObjectForKey:@"id"];

    if (companyTraits[@"name"]) {
        company.name = companyTraits[@"name"];
        [customAttributes removeObjectForKey:@"name"];
    }
    
    if (companyTraits[@"monthly_spend"]) {
        company.monthlySpend = companyTraits[@"monthly_spend"];
        [customAttributes removeObjectForKey:@"monthly_spend"];
        
    };
    
    if (companyTraits[@"plan"]) {
        company.plan = companyTraits[@"plan"];
        [customAttributes removeObjectForKey:@"plan"];
    };
    
    // Intercom requires each value must be of type NSString, NSNumber or NSNull.
    for (NSString *key in companyTraits) {
        if (![[companyTraits valueForKey:key] isKindOfClass:[NSString class]] &&
            ![[companyTraits valueForKey:key] isKindOfClass:[NSNumber class]]) {
            [customAttributes removeObjectForKey:key];
        }
    }
    
    company.customAttributes = customAttributes;
    
    return company;
}

@end
