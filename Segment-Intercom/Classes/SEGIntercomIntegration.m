//
//  SEGIntercomIntegration.m
//  Pods
//
//  Created by ladan nasserian on 10/4/17.
//
//

#import "SEGIntercomIntegration.h"

#if defined(__has_include) && __has_include(<Analytics/SEGAnalytics.h>)
#import <Analytics/SEGIntegration.h>
#import <Analytics/SEGAnalyticsUtils.h>
#import <Analytics/SEGAnalytics.h>
#else
#import <Segment/SEGIntegration.h>
#import <Segment/SEGAnalyticsUtils.h>
#import <Segment/SEGAnalytics.h>
#endif



@implementation SEGIntercomIntegration

#pragma mark - Initialization

- (instancetype)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        self.settings = settings;
        self.intercom = [Intercom class];

        NSString *mobileApiKey = settings[@"mobileApiKey"];
        NSString *appId = settings[@"appId"];

        [self.intercom setApiKey:mobileApiKey forAppId:appId];
        SEGLog(@"[self.intercom setApiKey:%@ forAppId:%@];", mobileApiKey, appId);
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

- (void)identify:(SEGIdentifyPayload *)payload
{
    // Intercom allows users to choose to track only known or only unknown users, as well as both. Segment will support the ability to track both by checking for loggedIn users (determined by the userId) and falling back to setting the user as "Unidentified" if this is not present.
    if (payload.userId) {
        [self.intercom registerUserWithUserId:payload.userId];
        SEGLog(@"[Intercom registerUserWithUserId:%@];", payload.userId);
    } else if (payload.anonymousId) {
        [self.intercom registerUnidentifiedUser];
        SEGLog(@"[Intercom registerUnidentifiedUser];");
    }

    NSDictionary *integration = [payload.integrations valueForKey:@"intercom"];
    if (integration[@"user_hash"]) {
        NSString *userHash = integration[@"user_hash"];
        [self.intercom setUserHash:userHash];
    }

    if ([payload.traits count] == 0) {
        return;
    }

    [self setUserAttributes:payload];
}

- (void)track:(SEGTrackPayload *)payload
{
    //'customAttributes' must be a non empty NSDictionary
    if ([payload.properties count] == 0) {
        [self.intercom logEventWithName:payload.event];
        SEGLog(@"[Intercom logEventWithName:%@];", payload.event);
        return;
    }

    NSMutableDictionary *output = [NSMutableDictionary dictionaryWithCapacity:payload.properties.count];
    NSMutableDictionary *price = [NSMutableDictionary dictionaryWithCapacity:0];
    __block BOOL isAmountSet = false;

    [payload.properties enumerateKeysAndObjectsUsingBlock:^(id key, id data, BOOL *stop) {
        [output setObject:data forKey:key];
        if ([key isEqual:@"revenue"] || ([key isEqual:@"total"] && !isAmountSet)) {
            double dataValue = [data doubleValue];
            int amountInCents = dataValue * 100;
            NSNumber *finalAmount = [[NSNumber alloc] initWithInt:amountInCents];
            [price setObject:finalAmount forKey:@"amount"];

            [output removeObjectForKey:key];
            isAmountSet = @YES;
        }

        if ([key isEqual:@"currency"]) {
            [price setObject:data forKey:@"currency"];
            [output removeObjectForKey:key];
        }

        if (price.count > 0) {
            [output setObject:price forKey:@"price"];
        }

        if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]]) {
            [output removeObjectForKey:key];
        }
    }];

    [self.intercom logEventWithName:payload.event metaData:output];
    SEGLog(@"[Intercom logEventWithName:%@ metaData:%@];", payload.event, output);
}


- (void)group:(SEGGroupPayload *)payload
{
    // id is a required field for adding or modifying a company.
    ICMCompany *company = [ICMCompany new];
    company.companyId = payload.groupId;

    [self setCompanyAttributes:payload.traits andCompany:company];
    company = [self setCompanyAttributes:payload.traits andCompany:company];

    ICMUserAttributes *userAttributes = [ICMUserAttributes new];
    userAttributes.companies = @[ company ];

    [self.intercom updateUser:userAttributes];
    SEGLog(@"[Intercom updateUser:%@];", userAttributes);
}

- (void)reset
{
    [self.intercom reset];
    SEGLog(@" [Intercom reset];");
}

#pragma mark - Utils

- (void)setUserAttributes:(SEGIdentifyPayload *)payload
{
    ICMUserAttributes *userAttributes = [ICMUserAttributes new];

    NSDictionary *traits = payload.traits;
    NSMutableDictionary *customAttributes = [NSMutableDictionary dictionaryWithDictionary:[traits copy]];

    if (traits[@"email"]) {
        userAttributes.email = traits[@"email"];
        [customAttributes removeObjectForKey:@"email"];
    }

    if (traits[@"user_id"]) {
        userAttributes.userId = [NSString stringWithFormat:@"%@", traits[@"user_id"]];
        [customAttributes removeObjectForKey:@"user_id"];
    }

    if (traits[@"name"]) {
        userAttributes.name = traits[@"name"];
        [customAttributes removeObjectForKey:@"name"];
    }

    if (traits[@"phone"]) {
        userAttributes.phone = traits[@"phone"];
        [customAttributes removeObjectForKey:@"phone"];
    }

    if (traits[@"created_at"]) {
        userAttributes.signedUpAt = traits[@"created_at"];
        [customAttributes removeObjectForKey:@"created_at"];
    };

    //TODO: determine if we should guard for this
    if (traits[@"company"] && [traits[@"company"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *companyTraits = traits[@"company"];
        // id is a required field for adding or modifying a company.
        ICMCompany *company = [ICMCompany new];
        company.companyId = companyTraits[@"id"];

        company = [self setCompanyAttributes:companyTraits andCompany:company];
        userAttributes.companies = @[ company ];
    }

    NSDictionary *integration = [payload.integrations valueForKey:@"intercom"];
    if (integration[@"language_override"]) {
        userAttributes.languageOverride = integration[@"language_override"];
    }

    if (integration[@"unsubscribed"]) {
        userAttributes.unsubscribedFromEmails = [integration[@"unsubscribed"] boolValue];
    }

    // Intercom requires each value must be of type NSString, NSNumber or NSNull.
    for (NSString *key in traits) {
        if (![[traits valueForKey:key] isKindOfClass:[NSString class]] &&
            ![[traits valueForKey:key] isKindOfClass:[NSNumber class]] &&
            ![[traits valueForKey:key] isKindOfClass:[NSNull class]]) {
            [customAttributes removeObjectForKey:key];
        }
    }

    userAttributes.customAttributes = customAttributes;
    [self.intercom updateUser:userAttributes];
    SEGLog(@"[Intercom updateUser:%@];", userAttributes);
}

- (ICMCompany *)setCompanyAttributes:(NSDictionary *)companyTraits andCompany:(ICMCompany *)company
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

    if (companyTraits[@"created_at"]) {
        company.createdAt = companyTraits[@"created_at"];
        [customAttributes removeObjectForKey:@"created_at"];
    };

    // Intercom requires each value must be of type NSString, NSNumber or NSNull.
    for (NSString *key in companyTraits) {
        if (![[companyTraits valueForKey:key] isKindOfClass:[NSString class]] &&
            ![[companyTraits valueForKey:key] isKindOfClass:[NSNumber class]] &&
            ![[companyTraits valueForKey:key] isKindOfClass:[NSNull class]]) {
            [customAttributes removeObjectForKey:key];
        }
    }

    company.customAttributes = customAttributes;

    return company;
}

@end
