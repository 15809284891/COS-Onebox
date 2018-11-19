//
//  ViewController.h
//  COSDemoApp
//
//  Created by 贾立飞 on 16/8/23.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

#define  kScreenWidth   ([UIScreen mainScreen].bounds.size.width)
#define  kScreenHeight  ([UIScreen mainScreen].bounds.size.height)
#define DECLARE_WEAK_SELF __typeof(&*self) __weak weakSelf = self


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define  SIGN_URL @"http://127.0.0.1/Sign.php?sign_type=appSign&expired=1490847742&bucketName=sodalogtest"
#define  ONE_SIGN_URL @"http://127.0.0.1/Sign.php?sign_type=appSign_once&expired=1454083200&bucketName=weixintest&path="




@interface ViewController : BaseViewController


@end

