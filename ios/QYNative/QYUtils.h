//
//  YDTUtils.h
//  YDTNative
//
//  Created by roger on 2022/2/23.
//

#ifndef YDTUtils_h
#define YDTUtils_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QYPOPSDK.h"

#ifdef __cplusplus
extern "C"{
#endif

//string to UIColor
UIColor*hexStrToUIColor(NSString *str) ;
//Create json for QYSessionInfo
NSDictionary * getSessionListJSON(NSArray<QYSessionInfo *> * sessionList);
//Get string for QYEvaluation
NSString*getQYEvaluationStateString(QYEvaluationState state);
//Create QYCommodityInfo from json
QYCommodityInfo* createCommodityInfo(NSDictionary * options);
//Create QYEvaluactionResult from json
QYEvaluactionResult* createQYEvaluactionResult(NSDictionary * options);
//Get json for QYEvaluationOptionData
QYEvaluationOptionData * createQYEvaluationOptionDataJSON(NSDictionary* data);
//Get json forQYMessageInfo
NSDictionary * getQYMessageInfoJSON(QYMessageInfo* message) ;
//Get json forQYMessageInfo
NSDictionary * getQYEvaluactionDataJSON(QYEvaluactionData* data) ;
//Get json for QYEvaluationOptionData
NSDictionary * getQYEvaluationOptionDataJSON(QYEvaluationOptionData* data);

NSDictionary * makeErrorJsonResult(NSString* errmsg);

NSDictionary * makeEmptySuccessJsonResult(void);

#ifdef __cplusplus
}
#endif

#endif /* YDTUtils_h */
