
//
//  SEGIntercomIntegration.h
//  Pods
//
//  Created by ladan nasserian on 10/4/17.
//
//

#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<Analytics/SEGAnalytics.h>)
#import <Analytics/SEGIntegration.h>
#else
#import <Segment/SEGIntegration.h>
#endif
#import <Intercom/Intercom.h>


@interface SEGIntercomIntegration : NSObject <SEGIntegration>

@property (nonatomic, strong, nonnull) NSDictionary *settings;
@property (nonatomic, strong) Class _Nullable intercom;

- (instancetype _Nonnull)initWithSettings:(NSDictionary *_Nonnull)settings;
- (instancetype _Nonnull)initWithSettings:(NSDictionary *_Nonnull)settings andIntercom:(id _Nullable)intercom;

@end
