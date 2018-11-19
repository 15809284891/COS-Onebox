//
//  QCloudCOSXMLTestUtility.h
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 01/12/2017.
//  Copyright © 2017 Tencent. All rights reserved.
//

#import <QCloudCore/QCloudCore.h>
@interface QCloudCOSXMLTestUtility : NSObject

+ (instancetype)sharedInstance;
- (NSString*)createTestBucket;
- (void)deleteTestBucket:(NSString*)bucket;
- (NSString*)uploadTempObjectInBucket:(NSString*)bucket;
- (NSString*)createCanbeDeleteTestObject;
- (void)deleteAllTestObjects;

/**
 5.2.0开始批量删除bucket
 */
- (void)deleteAllTestBuckets;
@end

