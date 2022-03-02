//
//  YDTUtils.m
//  YDTNative
//
//  Created by roger on 2022/2/23.
//
#import "QYUtils.h"

#ifdef __cplusplus
extern "C"{
#endif

    //string to UIColor
    UIColor*hexStrToUIColor(NSString *color) {
        NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
            
        // String should be 6 or 8 characters
        if ([cString length] < 6) {
            return [UIColor clearColor];
        }
        // 判断前缀
        if ([cString hasPrefix:@"0X"])
            cString = [cString substringFromIndex:2];
        if ([cString hasPrefix:@"#"])
            cString = [cString substringFromIndex:1];
        if ([cString length] != 6)
            return [UIColor clearColor];
        // 从六位数值中找到RGB对应的位数并转换
        NSRange range;
        range.location = 0;
        range.length = 2;
        //R、G、B
        NSString *rString = [cString substringWithRange:range];
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        // Scan values
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
    }
    
    //Create json for QYSessionInfo
    NSDictionary * getSessionListJSON(NSArray<QYSessionInfo *> * sessionList) {
        
        NSMutableArray * array = [NSMutableArray arrayWithCapacity:sessionList.count];
        for (int i = 0; i < sessionList.count; i++) {
            QYSessionInfo * sessionItem = sessionList[i];
            
            NSString *status = NULL;
            switch (sessionItem.status) {
                case QYSessionStatusNone:
                default: status = @"None"; break;
                case QYSessionStatusWaiting: status = @"Waiting"; break;
                case QYSessionStatusInSession: status = @"InSession"; break;
            }
                
            NSDictionary *item = [NSDictionary dictionaryWithObjects: @[
                sessionItem.shopId,
                sessionItem.avatarImageUrlString,
                sessionItem.sessionName,
                sessionItem.lastMessageText,
                sessionItem.lastMessageText,
                [NSNumber numberWithLong:sessionItem.lastMessageTimeStamp],
                [NSNumber numberWithLong:sessionItem.unreadCount],
                sessionItem.hasTrashWords ? @"true" : @"",
                status,
            ]
                                                             forKeys: @[
                @"contactId",
                @"avatarImageUrlString",
                @"sessionName",
                @"lastMessageText",
                @"content",
                @"time",
                @"unreadCount",
                @"hasTrashWords",
                @"status",
            ]];
            
            [array addObject:item];
        }
        
        
        NSDictionary *result = [NSDictionary dictionaryWithObject:
                                array
                                forKey:@"list"];
        return result;
    }

    //Create QYCommodityInfo from json
    QYCommodityInfo* createCommodityInfo(NSDictionary * options) {
        QYCommodityInfo * qycommodityInfo = [[QYCommodityInfo alloc] init];
        
        NSString* pictureUrlString = [options objectForKey:@"pictureUrlString"];
        if(pictureUrlString) qycommodityInfo.pictureUrlString = pictureUrlString;
        NSString* title = [options objectForKey:@"title"];
        if(title) qycommodityInfo.title = title;
        NSString* desc = [options objectForKey:@"desc"];
        if(desc) qycommodityInfo.desc = desc;
        NSString* note = [options objectForKey:@"note"];
        if(note) qycommodityInfo.note = note;
        NSString* urlString = [options objectForKey:@"urlString"];
        if(urlString) qycommodityInfo.urlString = urlString;
        NSString* tagsString = [options objectForKey:@"tagsString"];
        if(tagsString) qycommodityInfo.tagsString = tagsString;
        NSString* actionText = [options objectForKey:@"actionText"];
        if(actionText) qycommodityInfo.pictureUrlString = actionText;
        NSString* ext = [options objectForKey:@"ext"];
        if(ext) qycommodityInfo.ext = ext;
        NSString* actionTextColor = [options objectForKey:@"actionTextColor"];
        if(actionTextColor) qycommodityInfo.actionTextColor = hexStrToUIColor(actionTextColor);
        NSNumber* show = [options objectForKey:@"show"];
        if(show) qycommodityInfo.show = [show boolValue];
        NSNumber* isPictureLink = [options objectForKey:@"isPictureLink"];
        if(isPictureLink) qycommodityInfo.isPictureLink = [isPictureLink boolValue];
        NSNumber* sendByUser = [options objectForKey:@"sendByUser"];
        if(sendByUser) qycommodityInfo.sendByUser = [sendByUser boolValue];
        NSArray* tagsArray = [options objectForKey:@"tagsArray"];
        if(tagsArray) {
            NSMutableArray* ntagsArray = [NSMutableArray arrayWithCapacity:32 ];
            for(int i = 0; i < tagsArray.count; i++){
                NSDictionary * item = [tagsArray objectAtIndex:i];
                if(item) {
                    QYCommodityTag*tag = [[QYCommodityTag alloc] init];
                    
                    NSString* label = [item objectForKey:@"label"];
                    if(label) tag.label = label;
                    NSString* url = [item objectForKey:@"url"];
                    if(url) tag.url = url;
                    NSString* focusIframe = [item objectForKey:@"focusIframe"];
                    if(focusIframe) tag.focusIframe = actionText;
                    NSString* data = [item objectForKey:@"data"];
                    if(data) tag.data = data;
                    
                    [ntagsArray addObject:tag];
                }
            }
            qycommodityInfo.tagsArray = ntagsArray;
        }
        return qycommodityInfo;
    }
    
    //Get string for QYEvaluation
    NSString*getQYEvaluationStateString(QYEvaluationState state) {
        NSString *modes = NULL;
        switch (state) {
            case QYEvaluationStateSuccessFirst: modes = @"QYEvaluationStateSuccessFirst"; break;
            case QYEvaluationStateSuccessRevise: modes = @"QYEvaluationStateSuccessRevise"; break;
            case QYEvaluationStateFailParamError: modes = @"QYEvaluationStateFailParamError"; break;
            case QYEvaluationStateFailNetError: modes = @"QYEvaluationStateFailNetError"; break;
            case QYEvaluationStateFailNetTimeout: modes = @"QYEvaluationStateFailNetTimeout"; break;
            case QYEvaluationStateFailTimeout: modes = @"QYEvaluationStateFailTimeout"; break;
            default:
            case QYEvaluationStateFailUnknown: modes = @"QYEvaluationStateFailUnknown"; break;
        }
        return modes;
    }
    
    //Create QYEvaluactionResult from json
    QYEvaluactionResult* createQYEvaluactionResult(NSDictionary * options) {
        QYEvaluactionResult* result = [[QYEvaluactionResult alloc] init];
        
        NSNumber* sessionId = [options objectForKey:@"sessionId"];
        if(sessionId) result.sessionId = [sessionId longLongValue];
        
        QYEvaluationMode modes = 0;
        NSString* mode = [options objectForKey:@"mode"];
        if(mode) {
            if([mode isEqualToString:@"QYEvaluationModeTwoLevel"]) modes = QYEvaluationModeTwoLevel;
            else if([mode isEqualToString:@"QYEvaluationModeThreeLevel"]) modes = QYEvaluationModeThreeLevel;
            else if([mode isEqualToString:@"QYEvaluationModeFourLevel"]) modes = QYEvaluationModeFourLevel;
            else if([mode isEqualToString:@"QYEvaluationModeFiveLevel"]) modes = QYEvaluationModeFiveLevel;
            result.mode = modes;
        }
        QYEvaluationResolveStatus statuss = QYEvaluationResolveStatusNone;
        NSString* status = [options objectForKey:@"resolveStatus"];
        if(status) {
            if([mode isEqualToString:@"QYEvaluationResolveStatusNone"]) statuss = QYEvaluationResolveStatusNone;
            else if([mode isEqualToString:@"QYEvaluationResolveStatusResolved"]) statuss = QYEvaluationResolveStatusResolved;
            else if([mode isEqualToString:@"QYEvaluationResolveStatusUnsolved"]) statuss = QYEvaluationResolveStatusUnsolved;
            result.resolveStatus = statuss;
        }
        NSString* remarkString = [options objectForKey:@"remarkString"];
        if(remarkString)
            result.remarkString = remarkString;
        NSArray* selectTags = [options objectForKey:@"selectTags"];
        if(selectTags)
            result.selectTags = selectTags;
        
        NSDictionary* selectOption = [options objectForKey:@"selectOption"];
        if(selectOption)
            result.selectOption = createQYEvaluationOptionDataJSON(selectOption);
        
        
        return result;
    }
    
    //Get json for QYMessageInfo
    NSDictionary * getQYEvaluactionDataJSON(QYEvaluactionData* data)  {
        
        NSString *modes = NULL;
        switch (data.mode) {
            default: modes = @"None"; break;
            case QYEvaluationModeTwoLevel: modes = @"QYEvaluationModeTwoLevel"; break;
            case QYEvaluationModeThreeLevel: modes = @"QYEvaluationModeThreeLevel"; break;
            case QYEvaluationModeFourLevel: modes = @"QYEvaluationModeFourLevel"; break;
            case QYEvaluationModeFiveLevel: modes = @"QYEvaluationModeFiveLevel"; break;
        }
        
        NSMutableArray*optionList = [[NSMutableArray alloc]init];
        for (int i = 0; i < data.optionList.count; i++)
            [ optionList addObject:getQYEvaluationOptionDataJSON([data.optionList objectAtIndex:i]) ];
        
        NSDictionary *item = [ NSDictionary dictionaryWithObjects: @[
            data.urlString,
            [NSNumber numberWithLongLong:data.sessionId],
            optionList,
            modes,
            data.resolvedEnabled ? @"true" : @"",
            data.resolvedRequired ? @"true" : @""
        ]
                                                         forKeys: @[
            @"urlString",
            @"sessionId",
            @"optionList",
            @"mode",
            @"resolvedEnabled",
            @"resolvedRequired"
        ] ];
        return item;
    }
    
    //Get json for QYEvaluationOptionData
    NSDictionary * getQYEvaluationOptionDataJSON(QYEvaluationOptionData* data) {
        
        NSString *options = NULL;
        switch (data.option) {
            default: options = @"None"; break;
            case QYEvaluationOptionVerySatisfied: options = @"QYEvaluationOptionVerySatisfied"; break;
            case QYEvaluationOptionSatisfied: options = @"QYEvaluationOptionSatisfied"; break;
            case QYEvaluationOptionOrdinary: options = @"QYEvaluationOptionOrdinary"; break;
            case QYEvaluationOptionDissatisfied: options = @"QYEvaluationOptionDissatisfied"; break;
            case QYEvaluationOptionVeryDissatisfied: options = @"QYEvaluationOptionVeryDissatisfied"; break;
        }
        
        NSDictionary *item = [NSDictionary dictionaryWithObjects: @[
            options,
            data.name,
            [ NSNumber numberWithLong:data.score ],
            data.tagList,
            data.tagRequired ? @"true" : @"",
            data.remarkRequired ? @"true" : @""
        ]
                                                         forKeys: @[
            @"option",
            @"name",
            @"score",
            @"tagList",
            @"tagRequired",
            @"remarkRequired"
        ]];
        return item;
        
    }
    
    //Get json for QYEvaluationOptionData
    QYEvaluationOptionData * createQYEvaluationOptionDataJSON(NSDictionary* data) {
        QYEvaluationOptionData * result = [[QYEvaluationOptionData alloc] init];
        
        NSString *options = [data objectForKey:@"selectOption"];
        if(options) {
            if([options isEqualToString:@"QYEvaluationOptionVerySatisfied"])result.option = QYEvaluationOptionVerySatisfied;
            else if([options isEqualToString:@"QYEvaluationOptionSatisfied"])result.option = QYEvaluationOptionSatisfied;
            else if([options isEqualToString:@"QYEvaluationOptionOrdinary"])result.option = QYEvaluationOptionOrdinary;
            else if([options isEqualToString:@"QYEvaluationOptionDissatisfied"])result.option = QYEvaluationOptionDissatisfied;
            else if([options isEqualToString:@"QYEvaluationOptionVeryDissatisfied"])result.option = QYEvaluationOptionVeryDissatisfied;
        }
        NSString *name = [data objectForKey:@"name"];
        if(name)
            result.name = name;
        NSNumber *score = [data objectForKey:@"score"];
        if(score)
            result.score = [score intValue];
        NSArray *tagList = [data objectForKey:@"tagList"];
        if(tagList)
            result.tagList = tagList;
        NSNumber *remarkRequired = [data objectForKey:@"remarkRequired"];
        if(remarkRequired)
            result.remarkRequired = [score boolValue];
        NSNumber *tagRequired = [data objectForKey:@"tagRequired"];
        if(tagRequired)
            result.tagRequired = [tagRequired boolValue];

        return result;
        
    }
    
    //Get json forQYMessageInfo
    NSDictionary * getQYMessageInfoJSON(QYMessageInfo* message) {
        
        NSString *type = NULL;
        switch (message.type) {
            default: type = @"None"; break;
            case QYMessageTypeText: type = @"Text"; break;
            case QYMessageTypeImage: type = @"Image"; break;
            case QYMessageTypeAudio: type = @"Audio"; break;
            case QYMessageTypeVideo: type = @"Video"; break;
            case QYMessageTypeFile: type = @"File"; break;
            case QYMessageTypeCustom: type = @"ustom"; break;
        }
        
        NSDictionary *item = [NSDictionary dictionaryWithObjects: @[
            message.text,
            type,
            [NSNumber numberWithLong:message.timeStamp],
            message.text,
        ]
                                                         forKeys: @[
            @"text",
            @"type",
            @"time",
            @"content",
        ]];
        return item;
    }
    
    NSDictionary * makeEmptySuccessJsonResult(void) {
        NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
            @"true",
            @"ok"
        ] forKeys:@[
            @"success",
            @"errMsg",
        ]];
        return result;
    }

    NSDictionary * makeErrorJsonResult(NSString* errmsg) {
        NSDictionary *result = [NSDictionary dictionaryWithObjects:@[
            @"",
            errmsg
        ] forKeys:@[
            @"success",
            @"errMsg",
        ]];
        return result;
    }
    
#ifdef __cplusplus
}
#endif
