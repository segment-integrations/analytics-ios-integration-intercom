//
//  SEGIntercomAppDelegate.m
//  Segment-Intercom
//
//  Created by ladanazita on 10/04/2017.
//  Copyright (c) 2017 ladanazita. All rights reserved.
//

#import "SEGIntercomAppDelegate.h"

#import <Analytics/SEGAnalytics.h>
#import "SEGIntercomAppDelegate.h"
#import "SEGIntercomIntegrationFactory.h"


@implementation SEGIntercomAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // https://segment.com/ladanazita/sources/ios_test/overview
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:@"ACIG3kwqCUsWZBfYxZDu0anuGwP3XtWW"];
    configuration.trackApplicationLifecycleEvents = YES;
    configuration.recordScreenViews = YES;
    [SEGAnalytics debug:YES];


    [configuration use:[SEGIntercomIntegrationFactory instance]];
    [SEGAnalytics setupWithConfiguration:configuration];
    [[SEGAnalytics sharedAnalytics] track:@"Testing second event from anony user"];
    [[SEGAnalytics sharedAnalytics] identify:nil traits:@{
        @"gender" : @"male",
        @"company" : @"self",
        @"name" : @"troy"
    }];


    return YES;
}

@end
