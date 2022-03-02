//
//  DCTestPluginProxy.m
//  DCTestUniPlugin
//
//  Created by XHY on 2020/5/19.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import "QYPluginProxy.h"
#import "QYPOPSDK.h"

@implementation QYPluginProxy

- (void)onCreateUniPlugin {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (BOOL)application:(UIApplication *_Nullable)application didFinishLaunchingWithOptions:(NSDictionary *_Nullable)launchOptions {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
    
    NSDictionary * plistDic = [[NSBundle mainBundle] infoDictionary];
    NSDictionary * pImengyuQiyukf = [plistDic objectForKey:@"ImengyuQiyukf"];
    if(pImengyuQiyukf) {
        NSString * appKey = [pImengyuQiyukf objectForKey:@"appKey"];
        if(appKey) {
            QYSDKOption *option = [QYSDKOption optionWithAppKey:appKey];
            
            NSString * appName = [pImengyuQiyukf objectForKey:@"appName"];
            if(appName) option.appName = appName;
            
            [[QYSDK sharedSDK] registerWithOption:option];
        } else {
            NSLog(@"未配置七鱼appKey，无法正常使用七鱼客服功能！");
        }
    } else {
        NSLog(@"未配置七鱼appKey，无法正常使用七鱼客服功能！");
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication * _Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (void)applicationDidBecomeActive:(UIApplication *_Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (void)applicationDidEnterBackground:(UIApplication *_Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (void)applicationWillEnterForeground:(UIApplication *_Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (void)applicationWillTerminate:(UIApplication *_Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

@end
