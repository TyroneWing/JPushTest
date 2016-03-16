//	            __    __                ________
//	| |    | |  \ \  / /  | |    | |   / _______|
//	| |____| |   \ \/ /   | |____| |  / /
//	| |____| |    \  /    | |____| |  | |   _____
//	| |    | |    /  \    | |    | |  | |  |____ |
//  | |    | |   / /\ \   | |    | |  \ \______| |
//  | |    | |  /_/  \_\  | |    | |   \_________|
//
//	Copyright (c) 2012年 HXHG. All rights reserved.
//	http://www.jpush.cn
//  Created by Zhanghao
//

#import "AppDelegate.h"
#import "JPUSHService.h"
#import "RootViewController.h"

@implementation AppDelegate {
  RootViewController *rootViewController;
}

/*
 
 //极光推送
 http://docs.jpush.io/client/ios_api/（极光官方API）
 http://www.360doc.com/content/15/0615/15/11417867_478293137.shtml
 https://segmentfault.com/q/1010000002447015
 http://bbs.csdn.net/topics/390967316
 http://www.cocoachina.com/bbs/read.php?tid=257390
 
 */


/**
 *  如果 App 状态为未运行，此函数将被调用，如果launchOptions包含UIApplicationLaunchOptionsRemoteNotificationKey表示用户点击apn 通知导致app被启动运行；
    获得推送消息内容。如果[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]为空，程序是点击icon进入,不为空，则说明用户通过推送消息进入
 */

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
      //可以添加自定义categories
      [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound |
                                                        UIUserNotificationTypeAlert)
                                            categories:nil];
  } else {
      //categories 必须为nil
      [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                        UIRemoteNotificationTypeSound |
                                                        UIRemoteNotificationTypeAlert)
                                            categories:nil];
  }
    
  [JPUSHService setupWithOption:launchOptions appKey:appKey
                        channel:channel apsForProduction:isProduction];


    
  [[NSBundle mainBundle] loadNibNamed:@"JpushTabBarViewController"
                                owner:self
                              options:nil];
  self.window.rootViewController = self.rootController;
  [self.window makeKeyAndVisible];
    
    NSDictionary* remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        NSLog(@"通知进入");
        NSLog(@"%@",[NSString stringWithFormat:@"%@",remoteNotification.description]);
    [[[UIAlertView alloc] initWithTitle:[remoteNotification description]
                                    message:nil
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    } else {
        NSLog(@"无通知进入程序");
    }
    
    rootViewController = (RootViewController *)
    [self.rootController.viewControllers objectAtIndex:0];

    
    //获取自定义消息推送内容(只有在前端运行的时候才能收到自定义消息的推送)
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
  return YES;
}


- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    NSLog(@"--------networkDidReceiveMessage---获取自定义推送内容---------");
    /**
     *  content：获取推送的内容
        extras：获取用户自定义参数
        customizeField1：根据自定义key获取自定义的value
     */
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
    
    NSLog(@"content = %@   customizeField1 = %@",content,customizeField1);
}

- (void)applicationWillResignActive:(UIApplication *)application {
  //    [APService stopLogPageView:@"aa"];
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.

  //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
   NSInteger badgeNum = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:--badgeNum];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  [application setApplicationIconBadgeNumber:0];
  [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  rootViewController.deviceTokenValueLabel.text =
      [NSString stringWithFormat:@"%@", deviceToken];
  rootViewController.deviceTokenValueLabel.textColor =
      [UIColor colorWithRed:0.0 / 255
                      green:122.0 / 255
                       blue:255.0 / 255
                      alpha:1];
  NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
  [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:
        (UIUserNotificationSettings *)notificationSettings {
}


- (void)application:(UIApplication *)application
    handleActionWithIdentifier:(NSString *)identifier
          forLocalNotification:(UILocalNotification *)notification
             completionHandler:(void (^)())completionHandler {
}


- (void)application:(UIApplication *)application
    handleActionWithIdentifier:(NSString *)identifier
         forRemoteNotification:(NSDictionary *)userInfo
             completionHandler:(void (^)())completionHandler {
}
#endif

/**
 *  基于iOS 6 及以下的系统版本，如果 App状态为正在前台或者点击通知栏的通知消息，那么此函数将被调用，并且可通过AppDelegate的applicationState是否为UIApplicationStateActive判断程序是否在前台运行
 *
 */
- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [JPUSHService handleRemoteNotification:userInfo];
    
  NSLog(@"收到通知:%@", [self logDic:userInfo]);
  [rootViewController addNotificationCount];
    
    
    [[[UIAlertView alloc] initWithTitle:[userInfo valueForKey:@"title"]
                                message:[userInfo valueForKey:@"alert"]
                               delegate:nil cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    
}
/**
 *   基于iOS 7 及以上的系统版本，如果是使用 iOS 7 的 Remote Notification 特性那么处理函数需要使用
 *   如果 App状态为正在前台或者点击通知栏的通知消息，那么此函数将被调用
 */
- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:
              (void (^)(UIBackgroundFetchResult))completionHandler {
  [JPUSHService handleRemoteNotification:userInfo];
  NSLog(@"收到通知:%@", [self logDic:userInfo]);
    
  [rootViewController addNotificationCount];

  completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification {
  [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
  if (![dic count]) {
    return nil;
  }
  NSString *tempStr1 =
      [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                   withString:@"\\U"];
  NSString *tempStr2 =
      [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
  NSString *tempStr3 =
      [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
  NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
  NSString *str =
      [NSPropertyListSerialization propertyListFromData:tempData
                                       mutabilityOption:NSPropertyListImmutable
                                                 format:NULL
                                       errorDescription:NULL];
  return str;
}
@end
