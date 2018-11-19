//
//  SecretStorage.h
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 27/01/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecretStorage : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString* appID;
@property (nonatomic, copy) NSString* bucket;
@property (nonatomic, copy) NSString* secretID;
@property (nonatomic, copy) NSString* secretKey;
@property (nonatomic, copy) NSString* regionName;
@end
