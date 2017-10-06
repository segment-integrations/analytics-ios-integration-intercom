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
    
    beforeEach(^{
        NSString *apiKey = @"ios_sdk-c499a81c815fdd6943d4ef2fc4e85df78933931b";
        NSString *iOSAppId = @"mm48vhil";
        mockIntercom = mockClass([Intercom class]);
        
        integration = [[SEGIntercomIntegration alloc] initWithSettings:@{
                                                                         @"apiKey":apiKey,
                                                                         @"iOSAppId": iOSAppId
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
//            [verify(mockIntercom) registerUserWithUserId:@"3942084234230"];
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

});


SpecEnd

