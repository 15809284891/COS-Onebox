//
//  TestCommonDefine.h
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 2017/7/20.
//  Copyright © 2017年 Tencent. All rights reserved.
//


#ifndef TestCommonDefine_h
#define TestCommonDefine_h
#import "NSString+UINCategory.h"
#define CNNORTH_REGION
#define kTestObejectPrefix @"objectcanbedelete"
#define kTestBucketPrefix  @"bucketcanbedelete"
#define kSecretID [SecretStorage sharedInstance].secretID
#define kSecretKey [SecretStorage sharedInstance].secretKey
#define kAppID [SecretStorage sharedInstance].appID
#define kRegion [SecretStorage sharedInstance].regionName
#define kTestBucket  [SecretStorage sharedInstance].bucket
//#define BUILD_FOR_TEST
#endif /* TestCommonDefine_h */
