//
//  ConsultInstance.h
//  YDTNative
//
//  Created by roger on 2022/2/23.
//

#ifndef ConsultInstance_h
#define ConsultInstance_h

#import "QYPOPSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConsultInstance : NSObject

@property (nonatomic, strong) NSString * title;

@property (nonatomic, strong) NSString * shopId;

@property (nonatomic, strong) NSString * key;

@property (nonatomic, strong) NSDictionary * options;

@property (nonatomic, strong) QYSessionViewController * controller;

@property (nonatomic, copy) void (^eventBus)(id result, BOOL keepAlive);

- (void)onQYCompletion:(BOOL)success err:(NSError *)error;
- (void)onButtonClickBlock:(QYButtonInfo *)action;

@end

NS_ASSUME_NONNULL_END

#endif /* ConsultInstance_h */
