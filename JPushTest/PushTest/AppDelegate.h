//
//  AppDelegate.h
//  PushTest
//
//  Created by LiDong on 12-8-15.
//  Copyright (c) 2012年 HXHG. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *appKey = @"0e5a4d341cdacb39a50c4218";
static NSString *channel = @"App Store";
static BOOL isProduction = FALSE;

@interface AppDelegate : NSObject<UIApplicationDelegate> {
  UILabel *_infoLabel;
  UILabel *_tokenLabel;
  UILabel *_udidLabel;
}
@property(strong, nonatomic) IBOutlet UITabBarController *rootController;
@property(retain, nonatomic) UIWindow *window;

@end
