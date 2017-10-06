//
//  SEGIntercomIntegration.h
//  Pods
//
//  Created by ladan nasserian on 10/4/17.
//
//

#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegration.h>
#import <Intercom/Intercom.h>


@interface SEGIntercomIntegration : NSObject <SEGIntegration>

@property (nonatomic, strong, nonnull) NSDictionary *settings;
@property (nonatomic, strong) Class intercom;

- (instancetype)initWithSettings:(NSDictionary *_Nonnull)settings;
- (instancetype)initWithSettings:(NSDictionary *)settings andIntercom:(id)intercom;

@end

