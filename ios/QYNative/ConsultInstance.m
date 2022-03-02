//
//  ConsultInstance.m
//  YDTNative
//
//  Created by roger on 2022/2/23.
//

#import <Foundation/Foundation.h>
#import "ConsultInstance.h"

@interface ConsultInstance()<QYSessionViewDelegate>
@end

@implementation ConsultInstance

/**
 *  点击右上角按钮回调（对于平台电商来说，这里可以考虑放“商铺入口”）
 */
- (void)onTapShopEntrance {
    NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
        @"ShopEntranceClick",
        @"true",
    ] forKeys:@[
        @"type",
        @"success",
    ]];
    self.eventBus (result, YES);
}

/**
 *  点击聊天内容区域的按钮回调（对于平台电商来说，这里可以考虑放置“会话列表入口“）
 */
- (void)onTapSessionListEntrance {
    NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
        @"SessionListEntranceClick",
        @"true",
    ] forKeys:@[
        @"type",
        @"success",
    ]];
    self.eventBus (result, YES);
}


- (void)onQYCompletion:(BOOL)success err:(NSError *)error {
    NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
        @"QYCompletion",
        success ? @"true" : @"",
        success ? @"OK" : error.description
    ] forKeys:@[
        @"type",
        @"success",
        @"errMsg",
    ]];
    self.eventBus (result, YES);
}

/**
 *  工具栏内按钮点击回调定义
 */
- (void)onButtonClickBlock:(QYButtonInfo *)action {
    NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
        action.title,
        action.buttonId,
        [NSNumber numberWithUnsignedLong:action.actionType],
        [NSNumber numberWithUnsignedLong:action.index],
        @"QuickEntryClick",
        @"true",
        @"OK"
    ] forKeys:@[
        @"title",
        @"id",
        @"actionType",
        @"index",
        @"type",
        @"success",
        @"errMsg",
    ]];
    self.eventBus (result, YES);
}

@end
