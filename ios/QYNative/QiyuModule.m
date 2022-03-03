
#import "QiyuModule.h"
#import "QYPOPSDK.h"
#import "ConsultInstance.h"
#import "QYUtils.h"


@interface QiyuModule()<QYConversationManagerDelegate>

@end

@implementation QiyuModule

- init {
    
    self.isQYConversationManagerDelegateSeted = false;
    self.mapId = false;
    self.sessionListChangedListeners = [[NSMutableDictionary alloc] init];
    self.unreadCountChangedListeners = [[NSMutableDictionary alloc] init];
    self.openedConsultSource = [[NSMutableDictionary alloc] init];
    
    return [super init];
}

UNI_EXPORT_METHOD(@selector(setUserInfo:callback:))

/**
 * 设置七鱼SDK当前咨询用户的信息
 * @param options 参数
 *                {
 *                    userId: string,
 *                    data: string,
 *                    authToken: string
 *                }
 */
- (void)setUserInfo:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    
    QYUserInfo* userInfo = [[QYUserInfo alloc] init];
    userInfo.userId = [[options objectForKey:@"userId"] stringValue];
    
    NSDictionary* dataO = [options objectForKey:@"data"];
    if(dataO) {
        NSData *data = nil;
        if ([dataO count])
            data = [NSJSONSerialization dataWithJSONObject:dataO options:0 error:nil];
        if (data)
            userInfo.data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    
    //authToken
    NSString* authToken = [options objectForKey:@"authToken"];
    if(authToken && [authToken compare:@""] != NSOrderedSame)
       [[QYSDK sharedSDK] setAuthToken:authToken];
    
    
    //setUserInfo
    [[QYSDK sharedSDK] setUserInfo:userInfo userInfoResultBlock:^(BOOL success, NSError *error) {
        if(error) {
            NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
                @"",
                error.description
            ] forKeys:@[
                @"success",
                @"errMsg"
            ]];
            callback(result, NO);
        } else {
            NSDictionary *result = [NSDictionary dictionaryWithObject:(success ? @"true" : @"") forKey:@"success"];
            callback(result, NO);
        }
    }];
    
}

UNI_EXPORT_METHOD(@selector(clearUserInfo:callback:))

/**
 * 清除七鱼SDK当前咨询用户的信息
 */
- (void)clearUserInfo:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    [[QYSDK sharedSDK] logout:^(BOOL success) {
        if(callback) {
            NSDictionary *result = [NSDictionary dictionaryWithObject:(success ? @"true" : @"") forKey:@"success"];
            callback(result, NO);
        }
    }];
}


UNI_EXPORT_METHOD(@selector(isInit:callback:))

/**
 * 获取七鱼SDK当前是否已初始化
 * @param options 参数
 * @param callback 回调
 */
- (void)isInit:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if(callback) {
        NSDictionary *result = [NSDictionary dictionaryWithObject:@"true" forKey:@"isInit"];
        callback(result, NO);
    }
}


UNI_EXPORT_METHOD_SYNC(@selector(toggleNotification:))

/**
 * 七鱼消息提醒开关(IOS没有这个方法)
 * @param options
 * {
 *     on: boolean 是否开启
 * }
 */
- (NSString*)toggleNotification:(NSDictionary *)options {
    return @"No this method for iOS";
}

UNI_EXPORT_METHOD(@selector(getUnreadCount:callback:))

/**
 * 七鱼获取总的未读数
 * @param options {}
 * @param callback
 * {
 *     unreadCount: number
 * }
 */
- (void)getUnreadCount:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if(callback) {
        NSDictionary *result = [NSDictionary dictionaryWithObject:
                                [NSNumber numberWithInteger:([[QYSDK sharedSDK] conversationManager].allUnreadCount)]
                                forKey:@"unreadCount"];
        callback(result, NO);
    }
}

UNI_EXPORT_METHOD_SYNC(@selector(clearUnreadCount:))

/**
 * 七鱼清除全部未读数
 */
- (NSString *)clearUnreadCount:(NSDictionary *)options {
    [[[QYSDK sharedSDK] conversationManager] clearUnreadCount];
    return @"success";
}

UNI_EXPORT_METHOD_SYNC(@selector(POPClearUnreadCount:))

/**
 * 七鱼平台清除未读数
 * @param options
 * {
 *     shopId: string //商家ID
 * }
 */
- (NSString *)POPClearUnreadCount:(NSDictionary *)options {
    NSString* shopId = [options objectForKey:@"shopId"];
    if (shopId) {
        [[[QYSDK sharedSDK] conversationManager] clearUnreadCount:shopId ];
        return @"Success";
    }
    else
        return @"No shopId!";
}

UNI_EXPORT_METHOD_SYNC(@selector(POPDeleteRecentSessionByShopId:))

/**
 * 七鱼平台删除会话项, 删除会话列表中的会话（IOS）
 * @param options
 * {
 *     shopId: string,  //商家ID
 *     deleteMessages: boolean, //是否删除消息记录
 * }
 */
- (NSString *)POPDeleteRecentSessionByShopId:(NSDictionary *)options {
    NSString* shopId = [options objectForKey:@"shopId"];
    NSNumber* deleteMessages = [options objectForKey:@"deleteMessages"];
    if (shopId) {
        [[[QYSDK sharedSDK] conversationManager] deleteRecentSessionByShopId:shopId
                                                 deleteMessages: [deleteMessages boolValue]
        ];
        
        return @"Success";
    }
    else
        return @"No shopId!";
}

UNI_EXPORT_METHOD(@selector(getSessionList:callback:))

/**
 * 七鱼获取最近联系商家列表(主动获取会话列表)
 * @param options {}
 * @param callback
 * {
 *     list: {
 *         contactId: string,
 *         content: string,
 *         msgStatus: string,
 *         time: number,
 *         unreadCount: number,
 *     }[]
 * }
 */
- (void)getSessionList:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if(callback) {
        NSArray<QYSessionInfo *> * sessionList = [[[QYSDK sharedSDK] conversationManager] getSessionList];
        callback(getSessionListJSON(sessionList), NO);
    }
}

UNI_EXPORT_METHOD(@selector(POPAddSessionListChangedListener:callback:))

- (void)checkQYConversationManagerDelegateDelete{
    if(self.isQYConversationManagerDelegateSeted && self.unreadCountChangedListeners.count == 0 && self.sessionListChangedListeners.count == 0) {
        [[[QYSDK sharedSDK] conversationManager] setDelegate:NULL];
        self.isQYConversationManagerDelegateSeted = false;
    }
}
- (void)checkQYConversationManagerDelegateSetedAndSet {
    if(!self.isQYConversationManagerDelegateSeted) {
        [[[QYSDK sharedSDK] conversationManager] setDelegate:self];
        self.isQYConversationManagerDelegateSeted = true;
    }
}

/**
 *  会话未读数变化
 *
 *  @param count 未读数
 */
- (void)onUnreadCountChanged:(NSInteger)count {
    
    NSDictionary *result = [NSDictionary dictionaryWithObject:
                            [NSNumber numberWithLong:count]
                            forKey:@"count"];
    
    NSEnumerator *enumerator = [self.unreadCountChangedListeners objectEnumerator];
    id value;
    while ((value = [enumerator nextObject])) {
        ((UniModuleKeepAliveCallback)value)(result, YES);
    }
}
/**
 *  会话列表变化；非平台电商用户，只有一个会话项，平台电商用户，有多个会话项
 */
- (void)onSessionListChanged:(NSArray<QYSessionInfo *> *)sessionList {
    NSDictionary* result = getSessionListJSON(sessionList);
    
    NSEnumerator *enumerator = [self.sessionListChangedListeners objectEnumerator];
    id value;
    while ((value = [enumerator nextObject])) {
        ((UniModuleKeepAliveCallback)value)(result, YES);
    }
    
    NSEnumerator *enumerator2 = [result objectEnumerator];
    QYSessionInfo* session;
    while ((session = [enumerator2 nextObject])) {
        if(session.shopId) {
            ConsultInstance* instance = [self findConsultInstanceByShopId:session.shopId];
            if(instance) {
                NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
                    session.shopId,
                    session.lastMessageText,
                    [NSNumber numberWithLong:session.unreadCount],
                    [NSNumber numberWithLong:session.lastMessageTimeStamp],
                    @"SessionUpdate",
                    @"true",
                ] forKeys:@[
                    @"shopId",
                    @"content",
                    @"unreadCount",
                    @"time",
                    @"type",
                    @"success",
                ]];
                instance.eventBus (result, YES);
            }
        }
    }
}
/**
 *  接收消息
 */
- (void)onReceiveMessage:(QYMessageInfo *)message {
    if(message.shopId) {
        ConsultInstance* instance = [self findConsultInstanceByShopId:message.shopId];
        if(instance) {
            NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
                getQYMessageInfoJSON(message),
                @"ReceiveMessage",
                @"true",
            ] forKeys:@[
                @"message",
                @"type",
                @"success",
            ]];
            instance.eventBus (result, YES);
        }
    }
}

/**
 * 注册最近联系商家更新监听器（添加、删除、新消息等）
 * @param options {}
 * @param callback
 * {
 *     id: number, //ID，可使用 POPRemoveSessionListChangedListener 删除回调监听。
 *     type: 'AddSuccess'|'SessionUpdate'|'SessionDelete'
 * }
 */
- (void)POPAddSessionListChangedListener:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if(callback) {
        self.mapId++;
        
        [self checkQYConversationManagerDelegateSetedAndSet];
        [self.sessionListChangedListeners setValue:callback forKey:[ NSString stringWithFormat:@"%d",self.mapId]];
    }
}

UNI_EXPORT_METHOD_SYNC(@selector(POPRemoveSessionListChangedListener:))

/**
 * 注销最近联系商家更新监听器（添加、删除、新消息等）
 * @param options
 * {
 *     id: number
 * }
 */
- (void)POPRemoveSessionListChangedListener:(NSDictionary *)options {
    NSString* idstr = [options objectForKey:@"id"];
    if(idstr) {
        [self.sessionListChangedListeners removeObjectForKey:idstr];
        [self checkQYConversationManagerDelegateDelete];
    }
}

UNI_EXPORT_METHOD(@selector(addUnreadCountChangeListener:callback:))

/**
 * 七鱼添加未读数变化监听
 * @param callback
 * {
 *     id: number, //ID，可使用 POPRemoveSessionListChangedListener 删除回调监听。
 *     type: 'AddSuccess'|'SessionUpdate'|'SessionDelete'
 * }
 */
- (void)addUnreadCountChangeListener:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if(callback) {
        self.mapId++;
        [self checkQYConversationManagerDelegateSetedAndSet];
        [self.unreadCountChangedListeners setValue:callback forKey:[ NSString stringWithFormat:@"%d",self.mapId]];
    }
}

UNI_EXPORT_METHOD_SYNC(@selector(removeUnreadCountChangeListener:))

/**
 * 七鱼移除未读数变化监听
 * @param options
 * {
 *     id: number
 * }
 */
- (void)removeUnreadCountChangeListener:(NSDictionary *)options {
    NSString* idstr = [options objectForKey:@"id"];
    if(idstr) {
        [self.unreadCountChangedListeners removeObjectForKey:idstr];
        [self checkQYConversationManagerDelegateDelete];
    }
}

UNI_EXPORT_METHOD_SYNC(@selector(sendProductMessage:))

/**
 * 发送商品信息
 * @param options
 * {
 * }
 */
- (NSString *)sendProductMessage:(NSDictionary *)options {
    
   NSString* shopId = [options objectForKey:@"shopId"];
    if (!shopId)
        shopId = @"-1";
    
    ConsultInstance* instance = [self findConsultInstanceByShopId:shopId];
    if (!instance)
        return @"Not found ConsultInstance";
    
    if(instance.controller) {
        QYCommodityInfo* info = createCommodityInfo(options);
        [ instance.controller sendCommodityInfo:info ];
        return @"success";
    }
    
    return @"No controller";
}

UNI_EXPORT_METHOD_SYNC(@selector(sendMessage:))

/**
 * 发送消息
 * @param options {}
 */
- (NSString *)sendMessage:(NSDictionary *)options {
    NSString* shopId = [options objectForKey:@"shopId"];
    if (!shopId)
        shopId = @"-1";
    
    ConsultInstance* instance = [self findConsultInstanceByShopId:shopId];
    if (!instance)
        return @"Not found ConsultInstance";
    
    if(instance.controller) {
        
        NSString* type = [options objectForKey:@"type"];
        if ([type isEqualToString:@"file"]) {
            [instance.controller
             sendFileName:[[options objectForKey:@"displayName"] stringValue]
             filePath:[[options objectForKey:@"filePath"] stringValue]];
        } else if ([type isEqualToString:@"text"]) {
            [instance.controller sendText:[[options objectForKey:@"text"] stringValue]];
        } else if ([type isEqualToString:@"video"]) {
            [instance.controller sendVideo:[[options objectForKey:@"filePath"] stringValue]];
        } else if ([type isEqualToString:@"image"]) {
            [instance.controller sendPicture:
              [UIImage imageWithContentsOfFile:
               [[options objectForKey:@"filePath"] stringValue]]];
        }
        
        return @"success";
    }
    
    return @"No controller";
}

//========================================================


//========================================================

UNI_EXPORT_METHOD_SYNC(@selector(createConsultSource:))

/**
 * 创建七鱼ConsultSource
 * @param options 参数:
 *                {
 *                    key: string, //标识
 *                    staffId: number, //客服ID
 *                    groupId: number, //客服组ID
 *                    shopId: string, //商家ID
 *                    robotFirst: boolean, //先由机器人接待
 *                    quickEntryList: {
 *                        {
 *                            id: number, //快捷入口ID
 *                            title: string, //快捷入口文字
 *                        }
 *                    }[], //快捷入口
 *                    title: string,
 *                    sourceUrl: string,
 *                    sourceTitle: string,
 *                }
 */
- (NSString *)createConsultSource:(NSDictionary *)options {
    NSString* key = [options objectForKey:@"key"];
    if (!key)
        return @"Param key required";
    
    ConsultInstance* instance = [self.openedConsultSource objectForKey:key];
    if (instance)
        return @"ConsultInstance already exists";
    
    instance = [[ConsultInstance alloc] init];
    instance.options = options;
    instance.title = [options objectForKey:@"title"];
    instance.shopId = [options objectForKey:@"shopId"];
    instance.key = key;
    
    [ self.openedConsultSource setObject:instance forKey:key];
    return @"success";
}

/**
 qiyu page back
 */
- (void)onQiyuBack:(id)sender {
    UIViewController *rootViewController = [UIApplication    sharedApplication].keyWindow.rootViewController;
    [rootViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
/**
    find ConsultInstance By ShopId
 */
- (ConsultInstance*)findConsultInstanceByShopId:(NSString*)shopId {
    NSEnumerator *enumerator = [self.openedConsultSource objectEnumerator];
    ConsultInstance* value;
     
    while ((value = [enumerator nextObject])) {
        if(value.shopId && [shopId isEqualToString:value.shopId] ) {
            return value;
        }
    }
    return nil;
}


UNI_EXPORT_METHOD_SYNC(@selector(deleteConsultSource:))

/**
 * 删除已经创建的ConsultSource
 * @param options
 *            {
 *                key: string, //标识
 *            }
 */
- (NSString *)deleteConsultSource:(NSDictionary *)options {
    NSString* key = [options objectForKey:@"key"];
    if (!key)
        return @"Param key required";
    ConsultInstance* instance = [self.openedConsultSource objectForKey:key];
    if (!instance)
        return @"Not found ConsultInstance";
    
    //Send delete
    NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
        @"SessionDelete",
        instance.shopId,
        @"true",
    ] forKeys:@[
        @"type",
        @"shopId",
        @"success",
    ]];
    instance.eventBus (result, YES);
    
    if(instance.controller)
        [ instance.controller closeSession:YES completion:nil ];
    
    [ self.openedConsultSource removeObjectForKey:key ];
    return @"success";
}

UNI_EXPORT_METHOD(@selector(isConsultSourceExists:callback:))

/**
 * 获取七鱼ConsultSource是否存在
 * @param options
 *            {
 *                key: string, //标识
 *            }
 */
- (void)isConsultSourceExists:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if(callback) {
        BOOL exists = FALSE;
        NSString* key = [options objectForKey:@"key"];
        if(key)
            exists = [self.openedConsultSource objectForKey:key] != NULL;
         
        NSDictionary *result = [NSDictionary dictionaryWithObject:(exists ? @"true" : @"") forKey:@"exists"];
        callback(result, NO);
    }
}

UNI_EXPORT_METHOD(@selector(getOpenedConsultSourceKeys:callback:))

/**
 * 获取所有已打开的ConsultSource标识
 * @param options {}
 */
- (void)getOpenedConsultSourceKeys:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if(callback) {
        NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.openedConsultSource.count];
        
        NSEnumerator *enumerator = [self.openedConsultSource keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            ConsultInstance* instance = [self.openedConsultSource objectForKey:key ];
            NSDictionary *value = [NSDictionary dictionaryWithObjects: @[
                instance.title,
            ]
                                                             forKeys: @[
                @"title",
            ]];
            NSDictionary *item = [NSDictionary dictionaryWithObjects: @[
                key,
                value,
            ]
                                                             forKeys: @[
                @"key",
                @"value",
            ]];
            
            [array addObject:item];
        }
        
        NSDictionary *result = [NSDictionary dictionaryWithObject:
                                array
                                forKey:@"list"];
        callback(result, NO);
    }
}

UNI_EXPORT_METHOD(@selector(findConsultSourceKeyByShopId:callback:))

/**
 * 通过 shopId 查找已打开的ConsultSource标识
 * @param options
 *            {
 *                shopId: string, //商户ID
 *            }
 */
- (void)findConsultSourceKeyByShopId:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if(callback) {
        NSString* shopId = [options objectForKey:@"shopId"];
        ConsultInstance* instance = shopId ? [self findConsultInstanceByShopId:shopId ] : nil;
        if (!shopId || !instance) {
            NSDictionary *result = [NSDictionary dictionaryWithObject:@"" forKey:@"key"];
            callback(result, NO);
            return;
        }
        
        NSDictionary *result = [NSDictionary dictionaryWithObject:instance.key forKey:@"key"];
        callback(result, NO);
    }
}

UNI_EXPORT_METHOD(@selector(openService:callback:))
UNI_EXPORT_METHOD(@selector(POPOpenService:callback:))
UNI_EXPORT_METHOD(@selector(closeService:callback:))

- (void)createServiceInstanceController:(NSDictionary *)options instance:(ConsultInstance*)instance {
    QYSource* source = [[QYSource alloc] init];
    NSString* sourceTitle = [[options objectForKey:@"sourceTitle"] stringValue];
    if(sourceTitle) source.title = sourceTitle;
    NSString* sourceUrl = [[options objectForKey:@"sourceUrl"] stringValue];
    if(sourceUrl) source.urlString = sourceUrl;
    NSString* custom = [[options objectForKey:@"custom"] stringValue];
    if(custom) source.customInfo = custom;
    NSString* shopId = [[options objectForKey:@"shopId"] stringValue];
    
    QYSessionViewController *sessionViewController = [[QYSDK sharedSDK] sessionViewController];
    sessionViewController.sessionTitle = instance.title ? instance.title : @"客服";
    sessionViewController.source = source;
    sessionViewController.hidesBottomBarWhenPushed = YES;
    
    if(shopId) {
        sessionViewController.shopId = instance.shopId;
        sessionViewController.delegate = (id<QYSessionViewDelegate>)instance;
        instance.shopId = shopId;
    }
    
    NSNumber* robotId = [options objectForKey:@"robotId"];
    if(robotId) sessionViewController.robotId = [robotId longValue];
    
    NSNumber* commonQuestionTemplateId = [options objectForKey:@"commonQuestionTemplateId"];
    if(commonQuestionTemplateId) sessionViewController.commonQuestionTemplateId = [commonQuestionTemplateId longValue];
    
    NSNumber* robotWelcomeTemplateId = [options objectForKey:@"robotWelcomeTemplateId"];
    if(robotWelcomeTemplateId) sessionViewController.robotWelcomeTemplateId = [robotWelcomeTemplateId longValue];
    
    NSNumber* staffId  = [options objectForKey:@"staffId"];
    if(staffId ) sessionViewController.staffId  = [staffId  longValue];
    
    NSNumber* groupId = [options objectForKey:@"groupId"];
    if(groupId) sessionViewController.groupId  = [groupId longValue];
    
    NSNumber* shuntTemplateId = [options objectForKey:@"shuntTemplateId"];
    if(shuntTemplateId) sessionViewController.shuntTemplateId = [shuntTemplateId longValue];
    
    NSNumber* robotFirst = [options objectForKey:@"robotFirst"];
    if(robotFirst) sessionViewController.openRobotInShuntMode = [robotFirst boolValue];
    
    NSNumber* vipLevel = [options objectForKey:@"vipLevel"];
    if(vipLevel) sessionViewController.vipLevel = [vipLevel longValue];
    
    NSNumber* messagePageLimit = [options objectForKey:@"messagePageLimit"];
    if(messagePageLimit) sessionViewController.messagePageLimit = [messagePageLimit intValue];
    
    NSNumber* autoSendInRobot = [options objectForKey:@"autoSendInRobot"];
    if(autoSendInRobot) sessionViewController.autoSendInRobot = [autoSendInRobot boolValue];
    
    NSNumber* hideHistoryMessages = [options objectForKey:@"hideHistoryMessages"];
    if(hideHistoryMessages) sessionViewController.hideHistoryMessages = [hideHistoryMessages boolValue];
    
    NSString* historyMessagesTip = [options objectForKey:@"historyMessagesTip"];
    if(historyMessagesTip) sessionViewController.historyMessagesTip = historyMessagesTip;
    
    NSNumber* canCopyCommodityInfo = [options objectForKey:@"canCopyCommodityInfo"];
    if(canCopyCommodityInfo) sessionViewController.canCopyCommodityInfo = [canCopyCommodityInfo boolValue];
    
    NSDictionary* commodityInfo = [options objectForKey:@"commodityInfo"];
    if(commodityInfo) sessionViewController.commodityInfo = createCommodityInfo(commodityInfo);
    
    NSArray* quickEntryList = [options objectForKey:@"quickEntryList"];
    if(quickEntryList) {
        NSMutableArray* buttonInfoArray = [NSMutableArray arrayWithCapacity:32 ];
        for(int i = 0; i < quickEntryList.count; i++){
            NSDictionary * item = [quickEntryList objectAtIndex:i];
            if(item) {
                QYButtonInfo*button = [[QYButtonInfo alloc] init];
                
                NSString* title = [item objectForKey:@"title"];
                if(title) button.title = title;
                NSNumber* buttonId = [item objectForKey:@"id"];
                if(buttonId) button.buttonId = buttonId;
                
                [buttonInfoArray addObject:button];
            }
        }
        sessionViewController.buttonInfoArray = buttonInfoArray;
    }
    
    NSDictionary* staffInfo = [options objectForKey:@"staffInfo"];
    if(staffInfo) {
        QYStaffInfo* info = [[QYStaffInfo alloc] init];
        
        NSString* staffId = [options objectForKey:@"staffId"];
        if(staffId) info.staffId = staffId;
        NSString* nickName = [options objectForKey:@"nickName"];
        if(nickName) info.nickName = nickName;
        NSString* iconURL = [options objectForKey:@"iconURL"];
        if(iconURL) info.iconURL = iconURL;
        NSString* accessTip = [options objectForKey:@"accessTip"];
        if(accessTip) info.accessTip = accessTip;
        NSString* infoDesc = [options objectForKey:@"focusIframe"];
        if(infoDesc) info.infoDesc = infoDesc;
        
        sessionViewController.staffInfo = info;
    }
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onQiyuBack:) ];
    
    sessionViewController.navigationItem.leftBarButtonItem = leftItem;
    sessionViewController.buttonClickBlock = ^(QYButtonInfo *action) {
        [instance onButtonClickBlock:action ];
    };
        
    instance.controller = sessionViewController;
}

// 打开聊天界面
- (void)openServiceByKey:(NSString*)key callback:(UniModuleKeepAliveCallback)callback {
    ConsultInstance* instance = [self.openedConsultSource objectForKey:key];
    if (!instance) {
        NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
            @"OpenServiceResult",
            @"",
            @"Not found ConsultInstance"
        ] forKeys:@[
            @"type",
            @"success",
            @"errMsg",
        ]];
        callback(result, NO);
        return;
    }
    
    //set callback
    instance.eventBus = callback;
    //Create
    [self createServiceInstanceController:instance.options instance: instance ];
    
    //Show qiyu
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:instance.controller];
    UIViewController *rootViewController = [UIApplication    sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:nav animated:YES completion:nil];
    
    //return
    NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
        @"OpenServiceResult",
        @"true",
        @"OK"
    ] forKeys:@[
        @"type",
        @"success",
        @"errMsg",
    ]];
    callback(result, YES);
}

/**
 * 普通版打开七鱼SDK客服窗口
 * @param options 参数同 createConsultSource
 * @param callback 回调
 */
- (void)openService:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if ([self.openedConsultSource objectForKey:@"InnXCS"] == NULL) {
        [self createConsultSource:options];
    }
    
    [self openServiceByKey:@"InnXCS" callback:callback];
}

/**
 * 打开七平台版打开七鱼SDK客服窗口SDK客服窗口
 * @param options 参数:
 *                {
 *                    key: string, //createConsultSource创建的key
 *                }
 * @param callback 回调
 */
- (void)POPOpenService:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if(callback) {
        
        NSString* key = [options objectForKey:@"key"];
        if(!key) {
            NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
                @"OpenServiceResult",
                @"",
                @"Param key must provide"
            ] forKeys:@[
                @"type",
                @"success",
                @"errMsg",
            ]];
            callback(result, NO);
            return;
        }
        
        [self openServiceByKey:key callback:callback];
    }
}

/**
 * 普通版关闭七鱼SDK客服窗口
 * @param options 参数
 * @param callback 回调
 */
- (void)closeService:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    
    ConsultInstance* instance = [self.openedConsultSource objectForKey:@"InnXCS"];
    if (instance) {
        
        if(instance.controller)
            [ instance.controller closeSession:YES completion:^(BOOL success, NSError *error) {} ];
        
        [ self.openedConsultSource removeObjectForKey:@"InnXCS" ];
        
        NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
            @"true",
            @"ok"
        ] forKeys:@[
            @"success",
            @"errMsg",
        ]];
        callback(result, NO);
    } else {
        callback(makeErrorJsonResult(@"Not open"), NO);
    }
}

UNI_EXPORT_METHOD_SYNC(@selector(requestStaff:))

/**
 * 请求客服
 * @param options 参数
 *                {
 *                    shopId: string, //平台版是你需要请求的商家ID，普通版可以为空
 *                }
 */
- (NSString *)requestStaff:(NSDictionary *)options {
    NSString* shopId = [options objectForKey:@"shopId"];
    if (!shopId)
        shopId = @"-1";
    
    ConsultInstance* instance = [self findConsultInstanceByShopId:shopId];
    if (!instance)
        return @"Not found ConsultInstance";
    if(instance.controller)
        [ instance.controller requestHumanStaff ];
    
    return @"success";
}

UNI_EXPORT_METHOD(@selector(changeHumanStaffWithStaffId:callback:))

/**
 * 切换人工客服
 * @param options 参数
 *                {
 *                    shopId: string, //平台版是你需要请求的商家ID，普通版可以为空
 *                    staffId: number, //想要转接的客服 id
 *                    groupId: number, //想要转接的分组 id 如果同时设置 staffId 和 groupId 那么以 staffId 为主
 *                    closetip: string, //关闭客服的提示语
 *                    isHuman: boolean, //转接客服是否只请求人工
 *                }
 */
- (void)changeHumanStaffWithStaffId:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSString* shopId = [options objectForKey:@"shopId"];
    if (!shopId)
        shopId = @"-1";
    
    ConsultInstance* instance = [self findConsultInstanceByShopId:shopId];
    if (!instance) {
        callback(makeErrorJsonResult(@"Not found ConsultInstance"), NO);
        return;
    }
    
    long staffId = [[options objectForKey:@"staffId"] longValue];
    long groupId = [[options objectForKey:@"groupId"] longValue];
    NSString* closetip = [[options objectForKey:@"closetip"] stringValue];
    
    if(instance.controller)
        [ instance.controller changeHumanStaffWithStaffId:staffId groupId:groupId closetip:closetip closeCompletion:^(BOOL success, NSError *error) {
            if(!success)
                callback(makeErrorJsonResult(error.description), NO);
            else
                callback(makeEmptySuccessJsonResult(), NO);
        } requestCompletion:^(BOOL success, NSError *error) {
            if(!success)
                callback(makeErrorJsonResult(error.description), NO);
            else
                callback(makeEmptySuccessJsonResult(), NO);
        } ];
    
}

UNI_EXPORT_METHOD_SYNC(@selector(presentWorkOrderViewControllerWithTemplateID:))

/**
 * 弹出工单页面自助提工单
 * @param options
 * {
 *    shopId: string, //平台版是你需要请求的商家ID，普通版可以为空
 *    templateID: number, 工单模板 id
 * }
 */
- (NSString *)presentWorkOrderViewControllerWithTemplateID:(NSDictionary *)options {
    NSString* shopId = [options objectForKey:@"shopId"];
    if (!shopId)
        shopId = @"-1";
    ConsultInstance* instance = [self findConsultInstanceByShopId:shopId];
   if (!instance)
       return @"Not found ConsultInstance";
   
   if(instance.controller)
       [ instance.controller presentWorkOrderViewControllerWithTemplateID:[[options objectForKey:@"templateID"] longLongValue] ];

   return @"success";
}

UNI_EXPORT_METHOD_SYNC(@selector(openUserWorkSheetActivity:))

/**
 * 自助启动查询工单界面
 * @param options
 * {
 *    shopId: string, //平台版是你需要请求的商家ID，普通版可以为空
 *    templateIds: number[], 工单模板 id
 *    isOpenUrge: boolean, //是否打开催单功能
 * }
*/
- (NSString *)openUserWorkSheetActivity:(NSDictionary *)options {
    
    NSArray* templateIdsJson = [options objectForKey:@"templateIds"];
    NSMutableArray* templateIds = [[NSMutableArray alloc] init];
    for(int i = 0; i < templateIdsJson.count; i++){
        NSNumber * item = [templateIdsJson objectAtIndex:i];
        if(item)
            [templateIds addObject:item];
    }
    
    QYWorkOrderListViewController *listVC = [[QYWorkOrderListViewController alloc]
                                             initWithTemplateIDList:templateIds
                                             canReminder:[[options objectForKey:@"isOpenUrge"] boolValue]
                                             shopId:[options objectForKey:@"shopId"]];
    
    //校验
    if (listVC.verifyError) {
        if (listVC.verifyError.code == QYWorkOrderErrorCodeInvalidAccount)
            return @"当前访客帐号有误";
        else if (listVC.verifyError.code == QYWorkOrderErrorCodeInvalidParam)
            return @"模板ID有误";
        else
            return @"未知错误";
    } else {
        //open view
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootViewController presentViewController:listVC animated:YES completion:nil];
    }

   return @"success";
}

UNI_EXPORT_METHOD(@selector(sendEvaluationResult:callback:))
UNI_EXPORT_METHOD(@selector(sendRobotEvaluationResult:callback:))

/**
* 发送人工满意度评价结果
* @param options {}
* @param callback {}
*/
- (void)sendEvaluationResult:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSString* shopId = [options objectForKey:@"shopId"];
    if (!shopId)
        shopId = @"-1";
    ConsultInstance* instance = [self findConsultInstanceByShopId:shopId];
    if (!instance) {
        callback(makeErrorJsonResult(@"Not found ConsultInstance"), NO);
        return;
    }
    if(instance.controller) {
        [instance.controller sendEvaluationResult:createQYEvaluactionResult(options)
                    completion:^(QYEvaluationState state) {
                        NSDictionary *item = [NSDictionary dictionaryWithObjects: @[
                            getQYEvaluationStateString(state),
                            @"true",
                            @"ok",
                        ]
                                                                         forKeys: @[
                            @"state",
                            @"success",
                            @"errMsg",
                        ]];
            callback(item, NO);
        }];
    }

}

/**
 * 发送机器人满意度评价结果
 * @param options {
 *    shopId: string, //平台版是你需要请求的商家ID，普通版可以为空
 * }
 * @param callback {}
*/
- (void)sendRobotEvaluationResult:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSString* shopId = [options objectForKey:@"shopId"];
    if (!shopId)
        shopId = @"-1";
    ConsultInstance* instance = [self findConsultInstanceByShopId:shopId];
    
    if (!instance) {
        callback(makeErrorJsonResult(@"Not found ConsultInstance"), NO);
        return;
    }
    if(instance.controller) {
        [instance.controller sendRobotEvaluationResult:createQYEvaluactionResult(options)
                    completion:^(QYEvaluationState state) {
                        NSDictionary *item = [NSDictionary dictionaryWithObjects: @[
                            getQYEvaluationStateString(state),
                            @"true",
                            @"ok",
                        ]
                                                                         forKeys: @[
                            @"state",
                            @"success",
                            @"errMsg",
                        ]];
            callback(item, NO);
        }];
    }

}

UNI_EXPORT_METHOD(@selector(setCustomEvaluation:callback:))

/**
 * 设置自定义评价接口，只能设置一次，可使用deleteCustomEvaluation删除
 * @param options {
 *    shopId: string, //平台版是你需要请求的商家ID，普通版可以为空
 }
 * @param callback
 * {
 *     type: 'Evaluation'|'RobotEvaluation',
 *     data?: QYEvaluactionData,
 *     errMsg: string,
 *     success: boolean,
 * }
 */
- (void)setCustomEvaluation:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSString* shopId = [options objectForKey:@"shopId"];
    if (!shopId)
        shopId = @"-1";
    
    ConsultInstance* instance = [self findConsultInstanceByShopId:shopId];
    if (!instance) {
        callback(makeErrorJsonResult(@"Not found ConsultInstance"), NO);
        return;
    }
    if(instance.controller) {
        instance.controller.evaluationBlock = ^(QYEvaluactionData *data) {
            NSDictionary *item = [NSDictionary dictionaryWithObjects: @[
                @"Evaluation",
                getQYEvaluactionDataJSON(data),
                @"true",
                @"ok",
            ]
                                                             forKeys: @[
                @"type",
                @"data",
                @"success",
                @"errMsg",
            ]];
            
            callback(item, YES);
        };
        instance.controller.robotEvaluationBlock = ^(QYEvaluactionData *data) {
            NSDictionary *item = [NSDictionary dictionaryWithObjects: @[
                @"RobotEvaluation",
                getQYEvaluactionDataJSON(data),
                @"true",
                @"ok",
            ]
                                                             forKeys: @[
                @"type",
                @"data",
                @"success",
                @"errMsg",
            ]];
            
            callback(item, YES);
        };
    }
}

UNI_EXPORT_METHOD_SYNC(@selector(deleteCustomEvaluation:))

/**
* 删除 setCustomEvaluation 设置的评价接口
 * @param options
 * {
 *                    shopId: string, //平台版是你需要请求的商家ID，普通版可以为空
 * }
*/
- (NSString*)deleteCustomEvaluation:(NSDictionary *)options {
    NSString* shopId = [options objectForKey:@"shopId"];
    if (!shopId)
        shopId = @"-1";
    
    ConsultInstance* instance = [self findConsultInstanceByShopId:shopId];
    if (!instance)
        return @"Not found ConsultInstance";
    if(instance.controller) {
        instance.controller.evaluationBlock = nil;
        instance.controller.robotEvaluationBlock = nil;
    }
    
    return @"success";
}

UNI_EXPORT_METHOD(@selector(setCustomEventsHandler:callback:))
UNI_EXPORT_METHOD_SYNC(@selector(resetCustomEventsHandlerToDefault:))

/**
 * 设置自定义事件接收
 * @param options {}
 * @param callback
 * {
 *     type: string,
 *     ...
 * }
 */
- (void)setCustomEventsHandler:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    QYCustomActionConfig * config = [QYSDK sharedSDK].customActionConfig;
    config.linkClickBlock = ^QYLinkClickActionPolicy(NSString *linkAddress) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"LinkClick",
            linkAddress,
        ]
                                                         forKeys: @[
            @"type",
            @"linkAddress",
        ]];
        callback(data, YES);
        return QYLinkClickActionPolicyCancel;
    };
    config.botClick = ^(NSString *target, NSString *params) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"BotClick",
            target,
            params,
        ]
                                                         forKeys: @[
            @"type",
            @"target",
            @"params",
        ]];
        callback(data, YES);
    };
    config.pushMessageClick =^(NSString *linkAddress) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"PushMessageClick",
            linkAddress,
        ]
                                                         forKeys: @[
            @"type",
            @"linkAddress"
        ]];
        callback(data, YES);
    };
    config.showBotCustomInfoBlock = ^(NSArray *array) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"ShowBotCustomInfo",
            array,
        ]
                                                         forKeys: @[
            @"type",
            @"array"
        ]];
        callback(data, YES);
    };
    config.commodityActionBlock = ^(QYSelectedCommodityInfo *commodityInfo) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"CommodityAction",
            commodityInfo,
        ]
                                                         forKeys: @[
            @"type",
            @"commodityInfo"
        ]];
        callback(data, YES);
    };
    config.extraClickBlock = ^(NSString *extInfo) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"ExtraClick",
            extInfo,
        ]
                                                         forKeys: @[
            @"type",
            @"extInfo"
        ]];
        callback(data, YES);
    };
    config.notificationClickBlock = ^(id message) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"NotificationClick",
            message,
        ]
                                                         forKeys: @[
            @"type",
            @"message"
        ]];
        callback(data, YES);
    };
    config.eventClickBlock = ^(NSString *eventName, NSString *eventData, NSString *messageId) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"EventClick",
            eventName,
            eventData,
            messageId
        ]
                                                         forKeys: @[
            @"type",
            @"eventName",
            @"eventData",
            @"messageId",
        ]];
        callback(data, YES);
    };
    config.customButtonClickBlock = ^(NSDictionary* params) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"CustomButtonClick",
            params,
        ]
                                                         forKeys: @[
            @"type",
            @"params"
        ]];
        callback(data, YES);
    };
    config.avatarClickBlock = ^(QYAvatarType type, NSString *accountID) {
        NSDictionary *data = [NSDictionary dictionaryWithObjects: @[
            @"AvatarClick",
            [ NSNumber numberWithLong:type ],
            accountID
        ]
                                                         forKeys: @[
            @"type",
            @"avatarType",
            @"accountID"
        ]];
        callback(data, YES);
    };
}
/**
 * 重置自定义事件接收
 * @param options {}
 */
- (NSString*)resetCustomEventsHandlerToDefault:(NSDictionary *)options {
    QYCustomActionConfig * config = [QYSDK sharedSDK].customActionConfig;
    config.actionBlock = nil;
    config.linkClickBlock = nil;
    config.botClick = nil;
    config.pushMessageClick = nil;
    config.showBotCustomInfoBlock = nil;
    config.commodityActionBlock = nil;
    config.extraClickBlock = nil;
    config.notificationClickBlock = nil;
    config.eventClickBlock = nil;
    config.customButtonClickBlock = nil;
    config.avatarClickBlock = nil;
    return @"success";
}
    
    
UNI_EXPORT_METHOD_SYNC(@selector(resetUICustomizationToDefault:))
UNI_EXPORT_METHOD_SYNC(@selector(changeUICustomization:))

/**
 * 重置界面自定义至默认
 * @param options {}
 */
- (NSString*)resetUICustomizationToDefault:(NSDictionary *)options {
    [[QYSDK sharedSDK].customUIConfig restoreToDefault];
    return @"success";
}

/**
 * 更改界面自定义方法
 * 参考 http://qiyukf.com/docs/guide/ios/5-%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A0%B7%E5%BC%8F.html#%E5%B1%9E%E6%80%A7%E5%88%97%E8%A1%A8
 * @param options {}
 */
- (NSString*)changeUICustomization:(NSDictionary *)options {
    QYCustomUIConfig * config = [QYSDK sharedSDK].customUIConfig;
    
    NSString* sessionBackground = [options objectForKey:@"sessionBackground"];
    if (sessionBackground) {
        if(!self.sessionBackground) {
            self.sessionBackground = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.sessionBackground.image = [UIImage imageWithContentsOfFile:sessionBackground];
            self.sessionBackground.backgroundColor = UIColor.grayColor;
            
            NSNumber* sessionBackgroundContentMode = [options objectForKey:@"sessionBackgroundContentMode"];
            if(sessionBackgroundContentMode)
                self.sessionBackground.contentMode = [sessionBackgroundContentMode intValue];
            else
                self.sessionBackground.contentMode = UIViewContentModeScaleAspectFill;
        }
        config.sessionBackground = self.sessionBackground;
    }
    else
        config.sessionBackground = nil;
    
    NSString* themeColor = [options objectForKey:@"themeColor"];
    if (themeColor)
        config.themeColor = hexStrToUIColor(themeColor);
    
    NSString* customerHeadImage = [options objectForKey:@"customerHeadImage"];
    if (customerHeadImage)
        config.customerHeadImage = [UIImage imageWithContentsOfFile:customerHeadImage];
    
    NSNumber* rightItemStyleGrayOrWhite = [options objectForKey:@"rightItemStyleGrayOrWhite"];
    if (rightItemStyleGrayOrWhite)
        config.rightItemStyleGrayOrWhite = [rightItemStyleGrayOrWhite boolValue];
    else
        config.rightItemStyleGrayOrWhite = YES;
    
    NSNumber* showCloseSessionEntry = [options objectForKey:@"showCloseSessionEntry"];
    if (showCloseSessionEntry)
        config.showCloseSessionEntry = [showCloseSessionEntry boolValue];
    else
        config.showCloseSessionEntry = NO;
    
    NSNumber* showHeadImage = [options objectForKey:@"showHeadImage"];
    if (showHeadImage)
        config.showHeadImage = [showHeadImage boolValue];
    else
        config.showHeadImage = YES;
    
    NSNumber* showTopHeadImage = [options objectForKey:@"showTopHeadImage"];
    if (showTopHeadImage)
        config.showTopHeadImage = [showTopHeadImage boolValue];
    else
        config.showTopHeadImage = NO;
    
    NSString* customerHeadImageUrl = [options objectForKey:@"customerHeadImageUrl"];
    if (customerHeadImageUrl)
        config.customerHeadImageUrl = customerHeadImageUrl;
    else
        config.customerHeadImageUrl = nil;
    
    NSString* customerMessageBubbleNormalImage = [options objectForKey:@"customerMessageBubbleNormalImage"];
    if (customerMessageBubbleNormalImage)
        config.customerMessageBubbleNormalImage = [UIImage imageWithContentsOfFile:customerMessageBubbleNormalImage];
    
    NSString* customerMessageBubblePressedImage = [options objectForKey:@"customerMessageBubblePressedImage"];
    if (customerMessageBubblePressedImage)
        config.customerMessageBubblePressedImage = [UIImage imageWithContentsOfFile:customerMessageBubblePressedImage];
    
    NSString* customMessageTextColor = [options objectForKey:@"customMessageTextColor"];
    if (customMessageTextColor)
        config.customMessageTextColor = hexStrToUIColor(customMessageTextColor);
    else
        config.customMessageTextColor = UIColor.whiteColor;
    
    NSString* customMessageHyperLinkColor = [options objectForKey:@"customMessageHyperLinkColor"];
    if (customMessageHyperLinkColor)
        config.customMessageHyperLinkColor = hexStrToUIColor(customMessageHyperLinkColor);
    else
        config.customMessageHyperLinkColor = UIColor.whiteColor;
    
    NSNumber* customMessageTextFontSize = [options objectForKey:@"customMessageTextFontSize"];
    if (customMessageTextFontSize)
        config.customMessageTextFontSize = [customMessageTextFontSize floatValue];
    else
        config.customMessageTextFontSize = 16.0f;
    
    NSString* serviceHeadImage = [options objectForKey:@"serviceHeadImage"];
    if (serviceHeadImage)
        config.serviceHeadImage = [UIImage imageWithContentsOfFile:serviceHeadImage];
    
    NSString* serviceMessageBubbleNormalImage = [options objectForKey:@"serviceMessageBubbleNormalImage"];
    if (serviceMessageBubbleNormalImage)
        config.serviceMessageBubbleNormalImage = [UIImage imageWithContentsOfFile:serviceMessageBubbleNormalImage];
    
    NSString* serviceMessageBubblePressedImage = [options objectForKey:@"serviceMessageBubblePressedImage"];
    if (serviceMessageBubblePressedImage)
        config.serviceMessageBubblePressedImage = [UIImage imageWithContentsOfFile:serviceMessageBubblePressedImage];
    
    NSString* serviceMessageTextColor = [options objectForKey:@"serviceMessageTextColor"];
    if (serviceMessageTextColor)
        config.serviceMessageTextColor = hexStrToUIColor(serviceMessageTextColor);
    else
        config.serviceMessageTextColor = UIColor.darkGrayColor;
    
    NSString* serviceMessageHyperLinkColor = [options objectForKey:@"serviceMessageHyperLinkColor"];
    if (serviceMessageHyperLinkColor)
        config.serviceMessageHyperLinkColor = hexStrToUIColor(serviceMessageHyperLinkColor);

    
    NSNumber* serviceMessageTextFontSize = [options objectForKey:@"serviceMessageTextFontSize"];
    if (serviceMessageTextFontSize)
        config.serviceMessageTextFontSize = [serviceMessageTextFontSize floatValue];
    else
        config.serviceMessageTextFontSize = 16.0f;
    
    NSString* tipMessageTextColor = [options objectForKey:@"tipMessageTextColor"];
    if (tipMessageTextColor)
        config.tipMessageTextColor = hexStrToUIColor(tipMessageTextColor);
    else
        config.tipMessageTextColor = UIColor.whiteColor;
    
    NSNumber* tipMessageTextFontSize = [options objectForKey:@"tipMessageTextFontSize"];
    if (tipMessageTextFontSize)
        config.tipMessageTextFontSize = [tipMessageTextFontSize floatValue];
    else
        config.tipMessageTextFontSize = 12.0f;
    
    NSNumber* bypassDisplayMode = [options objectForKey:@"bypassDisplayMode"];
    if (bypassDisplayMode)
        config.bypassDisplayMode = [bypassDisplayMode intValue];
    
    NSNumber* sessionMessageSpacing = [options objectForKey:@"sessionMessageSpacing"];
    if (sessionMessageSpacing)
        config.sessionMessageSpacing = [sessionMessageSpacing floatValue];
    else
        config.sessionMessageSpacing = 0;
    
    NSNumber* headMessageSpacing = [options objectForKey:@"headMessageSpacing"];
    if (headMessageSpacing)
        config.headMessageSpacing = [headMessageSpacing floatValue];
    else
        config.headMessageSpacing = 4;
    
    NSString* messageButtonTextColor = [options objectForKey:@"messageButtonTextColor"];
    if (messageButtonTextColor)
        config.messageButtonTextColor = hexStrToUIColor(messageButtonTextColor);
    else
        config.messageButtonTextColor = UIColor.whiteColor;
    
    NSString* messageButtonBackColor = [options objectForKey:@"messageButtonBackColor"];
    if (messageButtonBackColor)
        config.messageButtonBackColor = hexStrToUIColor(messageButtonBackColor);
    
    NSString* actionButtonTextColor = [options objectForKey:@"actionButtonTextColor"];
    if (actionButtonTextColor)
        config.actionButtonTextColor = hexStrToUIColor(actionButtonTextColor);
    else
        config.actionButtonTextColor = UIColor.grayColor;
    
    NSString* actionButtonBorderColor = [options objectForKey:@"actionButtonBorderColor"];
    if (actionButtonBorderColor)
        config.actionButtonBorderColor = hexStrToUIColor(actionButtonBorderColor);
    else
        config.actionButtonBorderColor = UIColor.grayColor;
    
    NSString* inputTextColor = [options objectForKey:@"inputTextColor"];
    if (inputTextColor)
        config.inputTextColor = hexStrToUIColor(inputTextColor);
    else
        config.inputTextColor = UIColor.darkGrayColor;
    
    NSNumber* inputTextFontSize = [options objectForKey:@"inputTextFontSize"];
    if (inputTextFontSize)
        config.inputTextFontSize = [inputTextFontSize floatValue];
    else
        config.inputTextFontSize = 14;
    
    NSString* inputTextPlaceholder = [options objectForKey:@"inputTextPlaceholder"];
    if (inputTextPlaceholder)
        config.inputTextPlaceholder = inputTextPlaceholder;
    
    NSNumber* showAudioEntry = [options objectForKey:@"showAudioEntry"];
    if (showAudioEntry)
        config.showAudioEntry = [showAudioEntry boolValue];
    
    NSNumber* showAudioEntryInRobotMode = [options objectForKey:@"showAudioEntryInRobotMode"];
    if (showAudioEntryInRobotMode)
        config.showAudioEntryInRobotMode = [showAudioEntryInRobotMode boolValue];
    
    NSNumber* showEmoticonEntry = [options objectForKey:@"showEmoticonEntry"];
    if (showEmoticonEntry)
        config.showEmoticonEntry = [showEmoticonEntry boolValue];
    
    NSNumber* showImageEntry = [options objectForKey:@"showImageEntry"];
    if (showImageEntry)
        config.showImageEntry = [showImageEntry boolValue];
    
    NSNumber* autoShowKeyboard = [options objectForKey:@"autoShowKeyboard"];
    if (autoShowKeyboard)
        config.autoShowKeyboard = [autoShowKeyboard boolValue];
    
    NSString* imagePickerColor = [options objectForKey:@"imagePickerColor"];
    if (imagePickerColor)
        config.imagePickerColor = hexStrToUIColor(imagePickerColor);
    
    NSNumber* bottomMargin = [options objectForKey:@"bottomMargin"];
    if (bottomMargin)
        config.bottomMargin = [bottomMargin floatValue];
    
    NSNumber* showShopEntrance = [options objectForKey:@"showShopEntrance"];
    if (showShopEntrance)
        config.showShopEntrance = [showShopEntrance boolValue];
    
    NSNumber* showSessionListEntrance = [options objectForKey:@"showSessionListEntrance"];
    if (showSessionListEntrance)
        config.showSessionListEntrance = [showSessionListEntrance boolValue];
    
    NSString* sessionListEntranceImage = [options objectForKey:@"sessionListEntranceImage"];
    if (sessionListEntranceImage)
        config.sessionListEntranceImage = [UIImage imageWithContentsOfFile:sessionListEntranceImage];
    else
        config.sessionListEntranceImage = nil;
    
    NSNumber* sessionListEntrancePosition = [options objectForKey:@"sessionListEntrancePosition"];
    if (sessionListEntrancePosition)
        config.sessionListEntrancePosition = [sessionListEntrancePosition boolValue];
    
    NSString* sessionTipTextColor = [options objectForKey:@"sessionTipTextColor"];
    if (sessionTipTextColor)
        config.sessionTipTextColor = hexStrToUIColor(sessionTipTextColor);
    else
        config.sessionTipTextColor = UIColor.orangeColor;
    
    NSNumber* sessionTipTextFontSize = [options objectForKey:@"sessionTipTextFontSize"];
    if (sessionTipTextFontSize)
        config.sessionTipTextFontSize = [sessionTipTextFontSize floatValue];
    
    NSString* sessionTipBackgroundColor = [options objectForKey:@"sessionTipBackgroundColor"];
    if (sessionTipBackgroundColor)
        config.sessionTipBackgroundColor = hexStrToUIColor(sessionTipBackgroundColor);
    else
        config.sessionTipBackgroundColor = UIColor.yellowColor;
    
    NSArray* customInputItems = [options objectForKey:@"customInputItems"];
    if(!customInputItems)
        config.customInputItems = nil;
    else {
        NSMutableArray* customInputItemsRs = [NSMutableArray arrayWithCapacity:customInputItems.count];
        for(int i = 0; i < customInputItems.count; i++) {
            NSDictionary* item = [ customInputItems objectAtIndex:i ];
            if(item) {
                QYCustomInputItem *inputItem = [[QYCustomInputItem alloc] init];
                
                NSString* normalImage = [item objectForKey:@"normalImage"];
                if (normalImage)
                    inputItem.normalImage = [UIImage imageWithContentsOfFile:normalImage];
                
                NSString* selectedImage = [item objectForKey:@"selectedImage"];
                if (selectedImage)
                    inputItem.selectedImage = [UIImage imageWithContentsOfFile:selectedImage];
                
                NSString* key = [item objectForKey:@"key"];
                if (!key)
                    key = @"unknow key";
                
                NSString* text = [item objectForKey:@"text"];
                if (text)
                    inputItem.text = text;
                
                //event
                inputItem.block = ^() {
                    NSDictionary *detail = [ NSDictionary dictionaryWithObjects: @[
                        key,
                    ]
                                                                     forKeys: @[
                        @"key",
                    ] ];
                    
                    [self.uniInstance fireGlobalEvent:@"QiyuCustomInputItemClick"
                                               params:[ NSDictionary dictionaryWithObject:detail forKey:@"detail" ]];
                };
                
                
                [ customInputItemsRs addObject:inputItem ];
            }
        }
        config.customInputItems = customInputItemsRs;
    }
    return @"success";
}

@end
