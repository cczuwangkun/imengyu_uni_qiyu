//
//  TestModule.h
//  DCTestUniPlugin
//
//  Created by XHY on 2020/4/22.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniModule.h"
#import "QYPOPSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface QiyuModule : DCUniModule

@property (assign, nonatomic) bool isQYConversationManagerDelegateSeted;
@property (assign, nonatomic) int mapId;

/**
 * SessionListChangedListener
 **/
@property (nonatomic, strong) NSMutableDictionary* sessionListChangedListeners;
/**
 * UnreadCountChangedListener
 **/
@property (nonatomic, strong) NSMutableDictionary* unreadCountChangedListeners;
/**
 * 所有已打开的ConsultSource标识
 **/
@property (nonatomic, strong) NSMutableDictionary* openedConsultSource;


@property (nonatomic, strong) UIImageView* sessionBackground;

@end

NS_ASSUME_NONNULL_END
