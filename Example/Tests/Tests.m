//
//  Segment-IntercomTests.m
//  Segment-IntercomTests
//
//  Created by ladanazita on 10/04/2017.
//  Copyright (c) 2017 ladanazita. All rights reserved.
//

// https://github.com/Specta/Specta

SpecBegin(InitialSpecs);

describe(@"SEGIntercomIntegration", ^{
    __block Intercom *mockIntercom;
    __block SEGIntercomIntegration *integration;

    describe(@"SEGIntercomIntegrationFactory", ^{
        it(@"factory creates integration with basic settings", ^{
            SEGIntercomIntegration *integration = [[SEGIntercomIntegrationFactory instance] createWithSettings:@{ @"mobileApiKey" : @"ios_sdk-c499a81c815fdd6943d4ef2fc4e85df78933931b",
                                                                                                                  @"appId" : @"mm48vhil"
            } forAnalytics:nil];

            expect(integration.settings).to.equal(@{ @"mobileApiKey" : @"ios_sdk-c499a81c815fdd6943d4ef2fc4e85df78933931b",
                                                     @"appId" : @"mm48vhil" });
        });
    });

    beforeEach(^{
        mockIntercom = mockClass([Intercom class]);

        integration = [[SEGIntercomIntegration alloc] initWithSettings:@{
            @"mobileApiKey" : @"ios_sdk-c499a81c815fdd6943d4ef2fc4e85df78933931b",
            @"appId" : @"mm48vhil"
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
                @"name" : @"Initech",
                @"industry" : @"Technology",
                @"employees" : @329,
                @"plan" : @"enterprise",
                @"total billed" : @830,
                @"monthly_spend" : @1230,
                @"address" : @{
                    @"street" : @"6th St",
                    @"city" : @"San Francisco",
                    @"state" : @"CA",
                    @"postalCode" : @"94103",
                    @"country" : @"USA"
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
                @"industry" : @"Technology",
                @"employees" : @329,
                @"total billed" : @830,
            };

            ICMUserAttributes *userAttributes = [ICMUserAttributes new];
            userAttributes.companies = @[ company ];

            [verify(mockIntercom) updateUser:userAttributes];
        });

        it(@"calls track with revenue and total", ^{
            NSDictionary *properties = @{
                @"checkout_id" : @"9bcf000000000000",
                @"order_id" : @"50314b8e",
                @"affiliation" : @"App Store",
                @"total" : @30.45,
                @"shipping" : @5.05,
                @"tax" : @1.20,
                @"currency" : @"USD",
                @"category" : @"Games",
                @"revenue" : @8,
                @"products" : @{
                    @"product_id" : @"2013294",
                    @"category" : @"Games",
                    @"name" : @"Monopoly: 3rd Edition",
                    @"brand" : @"Hasbros",
                    @"price" : @"21.99",
                    @"quantity" : @"1"
                }
            };
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Order Completed" properties:properties context:@{} integrations:@{}];
            [integration track:payload];
            NSDictionary *expected = @{
                @"checkout_id" : @"9bcf000000000000",
                @"order_id" : @"50314b8e",
                @"affiliation" : @"App Store",
                @"price" : @{
                    @"amount" : @800,
                    @"currency" : @"USD",
                },
                @"shipping" : @5.05,
                @"tax" : @1.20,
                @"category" : @"Games",
                @"total" : @30.45

            };
            [verify(mockIntercom) logEventWithName:@"Order Completed" metaData:expected];

        });

        it(@"calls track with just total", ^{
            NSDictionary *properties = @{
                @"checkout_id" : @"9bcf000000000000",
                @"order_id" : @"50314b8e",
                @"affiliation" : @"App Store",
                @"shipping" : @5.05,
                @"tax" : @1.20,
                @"currency" : @"USD",
                @"category" : @"Games",
                @"total" : @30.45,
                @"products" : @{
                    @"product_id" : @"2013294",
                    @"category" : @"Games",
                    @"name" : @"Monopoly: 3rd Edition",
                    @"brand" : @"Hasbros",
                    @"price" : @"21.99",
                    @"quantity" : @"1"
                }
            };
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Order Completed" properties:properties context:@{} integrations:@{}];
            [integration track:payload];
            NSDictionary *expected = @{
                @"checkout_id" : @"9bcf000000000000",
                @"order_id" : @"50314b8e",
                @"affiliation" : @"App Store",
                @"price" : @{
                    @"amount" : @3045,
                    @"currency" : @"USD",
                },
                @"shipping" : @5.05,
                @"tax" : @1.20,
                @"category" : @"Games"
            };
            [verify(mockIntercom) logEventWithName:@"Order Completed" metaData:expected];

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

        it(@"calls track with just revenue", ^{
            NSDictionary *properties = @{
                @"order_id" : @"50314b8e9bcf000000000000",
                @"affiliation" : @"Google Store",
                @"value" : @30,
                @"revenue" : @25,
                @"shipping" : @3,
                @"tax" : @2,
                @"discount" : @2.5,
                @"coupon" : @"hasbro",
                @"currency" : @"USD",
                @"products" : @[
                    @{
                       @"product_id" : @"507f1f77bcf86cd799439011",
                       @"sku" : @"45790-32",
                       @"name" : @"Monopoly: 3rd Edition",
                       @"price" : @19,
                       @"quantity" : @1,
                       @"category" : @"Games",
                       @"url" : @"https://www.company.com/product/path",
                       @"image_url" : @"https://www.company.com/product/path.jpg"
                    },
                    @{
                       @"product_id" : @"505bd76785ebb509fc183733",
                       @"sku" : @"46493-3",
                       @"name" : @"Uno Card Game",
                       @"price" : @3,
                       @"quantity" : @"2",
                       @"category" : @"Games"
                    }
                ]
            };
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Checkout Started" properties:properties context:@{} integrations:@{}];
            [integration track:payload];
            NSDictionary *expected = @{
                @"order_id" : @"50314b8e9bcf000000000000",
                @"affiliation" : @"Google Store",
                @"value" : @30,
                @"shipping" : @3,
                @"tax" : @2,
                @"discount" : @2.5,
                @"coupon" : @"hasbro",
                @"price" : @{
                    @"currency" : @"USD",
                    @"amount" : @2500
                }, };
            [verify(mockIntercom) logEventWithName:@"Checkout Started" metaData:expected];

        });
    });

    describe(@"identify", ^{
        it(@"identifies an unknown user with traits", ^{
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:nil anonymousId:@"324908523402" traits:@{
                @"gender" : @"female",
                @"company" : @{
                    @"id" : @"1234",
                    @"name" : @"Initech",
                    @"industry" : @"Technology",
                    @"employees" : @329,
                    @"plan" : @"enterprise"
                },
                @"name" : @"ladan"
            } context:@{}
                                                                                integrations:@{ @"intercom" : @{
                                                                                    @"user_hash" : @"324i2u4209",
                                                                                    @"language_override" : @"cn-zh"
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
                @"industry" : @"Technology",
                @"employees" : @329
            };

            userAttributes.companies = @[ company ];

            [integration identify:identifyPayload];
            [verify(mockIntercom) updateUser:userAttributes];
        });

        it(@"identfied a known user with traits", ^{
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:10];
            [comps setMonth:10];
            [comps setYear:2010];
            NSDate *signedUpDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:@"3942084234230" anonymousId:nil traits:@{
                @"email" : @"friends@segment.com",
                @"gender" : @"female",
                @"company" : @"segment",
                @"name" : @"ladan",
                @"phone" : @"555-555-5555",
                @"created_at" : signedUpDate,
                @"address" : @{
                    @"street" : @"6th St",
                    @"city" : @"San Francisco",
                    @"state" : @"CA",
                    @"postalCode" : @"94103",
                    @"country" : @"USA"
                }
            } context:@{}
                integrations:@{}];
            ICMUserAttributes *userAttributes = [ICMUserAttributes new];
            userAttributes.email = @"friends@segment.com";
            userAttributes.name = @"ladan";
            userAttributes.phone = @"555-555-5555";
            userAttributes.signedUpAt = signedUpDate;
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
