//
//  Segment-IntercomTests.m
//  Segment-IntercomTests
//
//  Created by ladanazita on 10/04/2017.
//  Copyright (c) 2017 ladanazita. All rights reserved.
//

// https://github.com/Specta/Specta

SpecBegin(InitialSpecs)

describe(@"SEGIntercomIntegration", ^{
    __block Intercom *mockIntercom;
    __block SEGIntercomIntegration *integration;
    
    describe(@"SEGIntercomIntegrationFactory", ^{
        it(@"factory creates integration with basic settings", ^{
            SEGIntercomIntegration *integration = [[SEGIntercomIntegrationFactory instance] createWithSettings:@{@"mobileApiKey" : @"ios_sdk-c499a81c815fdd6943d4ef2fc4e85df78933931b",
                                                                                                                 @"appId": @"mm48vhil"
                                                                                                                   } forAnalytics:nil];
            
            expect(integration.settings).to.equal(@{ @"mobileApiKey" : @"ios_sdk-c499a81c815fdd6943d4ef2fc4e85df78933931b", @"appId": @"mm48vhil" });
        });
    });
    
    beforeEach(^{
        mockIntercom = mockClass([Intercom class]);
        
        integration = [[SEGIntercomIntegration alloc] initWithSettings:@{
                                                                         @"mobileApiKey":@"ios_sdk-c499a81c815fdd6943d4ef2fc4e85df78933931b",
                                                                         @"appId": @"mm48vhil"
                                                                         } andIntercom:mockIntercom];
        
    });
    
    describe(@"track known users", ^{
        beforeEach(^{
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:@"3942084234230" anonymousId:nil traits:@{
                                                                                                                                       @"gender" : @"female",
                                                                                                                                       @"company" : @"segment",
                                                                                                                                       @"name" : @"ladan"
                                                                                                                                       } context:@{}
                                                                                integrations:@{}];
            [integration identify:identifyPayload];
            [verify(mockIntercom) registerUserWithUserId:@"3942084234230"];
        });
        
        it(@"calls track without properties", ^{
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{} context:@{
                                                                                                                       } integrations:@{}];
            
            [integration track:payload];
            [verify(mockIntercom) logEventWithName:@"Event"];
        });

        it(@"calls track with properties", ^{
            NSDictionary *properties = @{
                                         @"name" : @"Bob",
                                         @"gender" : @"male"
                                         };
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:properties context:@{
                                                                                                                       } integrations:@{}];
            
            [integration track:payload];
            [verify(mockIntercom) logEventWithName:@"Event" metaData:properties];
        });
        
        it(@"group updates user with company info", ^{
            NSDictionary *traits = @{
                                     @"name": @"Initech",
                                     @"industry": @"Technology",
                                     @"employees": @329,
                                     @"plan": @"enterprise",
                                     @"total billed": @830,
                                     @"monthly_spend":@1230,
                                     @"address":@{
                                             @"street": @"6th St",
                                             @"city": @"San Francisco",
                                             @"state": @"CA",
                                             @"postalCode": @"94103",
                                             @"country": @"USA"
                                             }
                                     };
            SEGGroupPayload *payload = [[SEGGroupPayload alloc] initWithGroupId:@"1234" traits:traits context:@{} integrations:@{}];
            [integration group:payload];
            
            ICMCompany *company = [ICMCompany new];
            company.companyId = @"1234";
            company.name = @"Initech";
            company.plan = @"enterprise";
            company.monthlySpend = @1230;
            company.customAttributes = @{
                                         @"industry": @"Technology",
                                         @"employees": @329,
                                         @"total billed": @830,
                                         };
            
            ICMUserAttributes *userAttributes = [ICMUserAttributes new];
            userAttributes.companies = @[company];
            
            [verify(mockIntercom) updateUser:userAttributes];
        });
    });
    
    describe(@"track unknown users", ^{
        beforeEach(^{
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:nil anonymousId:@"324908523402" traits:@{
                                                                                                                                       @"gender" : @"female",
                                                                                                                                       @"company" : @"segment",
                                                                                                                                       @"name" : @"ladan"
                                                                                                                                       } context:@{}
                                                                                integrations:@{}];
            [integration identify:identifyPayload];
            [verify(mockIntercom) registerUnidentifiedUser];
        });
        
        it(@"calls track with properties", ^{
            NSDictionary *properties = @{
                                         @"name" : @"Bob",
                                         @"gender" : @"male"
                                         };
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:properties context:@{
                                                                                                                       } integrations:@{}];
            
            [integration track:payload];
        });
        
        it(@"calls track without properties", ^{
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{} context:@{
                                                                                                                       } integrations:@{}];
            
            [integration track:payload];
            [verify(mockIntercom) logEventWithName:@"Event"];
        });
    });
    
    describe(@"identify", ^{
        it(@"identifies an unknown user with traits", ^{
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:nil anonymousId:@"324908523402" traits:@{
                                                                                                                                      @"gender" : @"female",
                                                                                                                                      @"company" : @{
                                                                                                                                              @"id":@"1234",
                                                                                                                                              @"name":@"Initech",
                                                                                                                                              @"industry":@"Technology",
                                                                                                                                              @"employees":@329,
                                                                                                                                              @"plan":@"enterprise"
                                                                                                                                              },
                                                                                                                                      @"name" : @"ladan"
                                                                                                                                      } context:@{}
                                                                                integrations:@{                                                                                                   @"intercom": @{
                                                                                                                                                                                                          @"languageOverride":@"cn-zh"
                                                                                                                                                                                                          }
                                                                                                                                                                                                      }];
            ICMUserAttributes *userAttributes = [ICMUserAttributes new];
            userAttributes.name = @"ladan";
            userAttributes.languageOverride = @"cn-zh";
            userAttributes.customAttributes = @{
                                                @"gender" : @"female"
                                                };
            
            ICMCompany *company = [ICMCompany new];
            company.companyId = @"1234";
            company.name = @"Initech";
            company.plan = @"enterprise";
            company.customAttributes = @{
                                         @"industry": @"Technology",
                                         @"employees": @329
                                         };
            
            userAttributes.companies = @[company];
            
            [integration identify:identifyPayload];
            [verify(mockIntercom) updateUser:userAttributes];
        });
        
        it(@"identfied a known user with traits", ^{
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:@"3942084234230" anonymousId:nil traits:@{
                                                                                                                                       @"email": @"friends@segment.com",
                                                                                                                                       @"gender" : @"female",
                                                                                                                                       @"company" : @"segment",
                                                                                                                                       @"name" : @"ladan",
                                                                                                                                       @"phone":@"555-555-5555",
                                                                                                                                       @"address":@{
                                                                                                                                               @"street": @"6th St",
                                                                                                                                               @"city": @"San Francisco",
                                                                                                                                               @"state": @"CA",
                                                                                                                                               @"postalCode": @"94103",
                                                                                                                                               @"country": @"USA"
                                                                                                                                               }
                                                                                                                                       } context:@{}
                                                                                integrations:@{}];
            ICMUserAttributes *userAttributes = [ICMUserAttributes new];
            userAttributes.email = @"friends@segment.com";
            userAttributes.name = @"ladan";
            userAttributes.phone = @"555-555-5555";
            userAttributes.customAttributes = @{
                                                @"gender" : @"female",
                                                @"company" : @"segment"
                                                };
            
            [integration identify:identifyPayload];
            [verify(mockIntercom) updateUser:userAttributes];
        });
        
        it(@"resets user", ^{
            [integration reset];
            [verify(mockIntercom) reset];
        });
    
    });

});


SpecEnd

