//
//  QCloudCOSXMLTestUtility.m
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 01/12/2017.
//  Copyright © 2017 Tencent. All rights reserved.
//
#import "QCloudCOSXMLVersion.h"
#import "QCloudCOSXMLTestUtility.h"
#import "QCloudCOSXML.h"
#define kTestObejectPrefix @"objectcanbedelete"
#define kTestBucketPrefix  @"bucketcanbedelete"
#import "TestCommonDefine.h"
#import "QCloudTestTempVariables.h"
#import "QCloudCOSXMLVersion.h"
@interface QCloudCOSXMLTestUtility()
@property (nonatomic, strong) dispatch_semaphore_t  semaphore;
@end

@implementation QCloudCOSXMLTestUtility

- (instancetype) init {
    self = [super init];
    if (self) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

+ (instancetype)sharedInstance {
    static QCloudCOSXMLTestUtility* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QCloudCOSXMLTestUtility alloc] init];
    });
    return instance;
}

- (NSString*)createTestBucket {
    
    NSMutableString* bucketName = [[NSMutableString alloc] init];
    [bucketName appendString:kTestBucketPrefix];
    [bucketName  appendFormat:@"%i",arc4random()%1000];
    QCloudPutBucketRequest* putBucket = [[QCloudPutBucketRequest alloc] init];
    putBucket.bucket = bucketName;
    [putBucket setFinishBlock:^(id outputObject, NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    
    if ([QCloudCOSXMLService defaultCOSXML] == nil) {
        NSLog(@"sfasf");
    }
    
    [[QCloudCOSXMLService defaultCOSXML] PutBucket:putBucket];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return bucketName;
}


- (void)deleteTestBucket:(NSString*)testBucket {
    QCloudDeleteBucketRequest* request = [[QCloudDeleteBucketRequest alloc] init];
    request.bucket = testBucket;
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucket:request];
}

- (NSString*)uploadTempObjectInBucket:(NSString *)bucket {
    
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = bucket;
    put.body =  [@"1234jdjdjdjjdjdjyuehjshgdytfakjhsghgdhg" dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [put setFinishBlock:^(id outputObject, NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    return put.object;
}
- (NSString*)createCanbeDeleteTestObject {
    NSMutableString* object = [[NSMutableString alloc] init];
    [object appendString:kTestObejectPrefix];
    [object  appendFormat:@"%i",arc4random()%1000];
    QCloudPutObjectRequest* putObject = [[QCloudPutObjectRequest alloc] init];
    putObject.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    putObject.object = object;
    [putObject setFinishBlock:^(id outputObject, NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:putObject];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return object;
}
-(void)deleteAllTestObjects{
    [self deleteAllObjectsWithPrefix:kTestObejectPrefix];
}
- (void)deleteAllObjectsWithPrefix:(NSString*)prefix {
    
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSArray<QCloudBucketContents*>* listBucketContents;
    QCloudGetBucketRequest* getBucketRequest = [[QCloudGetBucketRequest alloc] init];
    getBucketRequest.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    getBucketRequest.maxKeys = 1000;
    [getBucketRequest setFinishBlock:^(QCloudListBucketResult * _Nonnull result, NSError * _Nonnull error) {
        listBucketContents = result.contents;
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:getBucketRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (nil == listBucketContents) {
        return;
    }
    NSMutableArray* deleteObjectInfoArray = [[NSMutableArray alloc] init];
    NSUInteger prefixLength = prefix.length;
    for (QCloudBucketContents* bucketContents in listBucketContents) {
        NSLog(@"tetsttst   ----- %@",bucketContents.key);
        if (bucketContents.key.length < prefixLength) {
            continue;
        }
        NSString* objectNamePrefix = [bucketContents.key substringToIndex:prefixLength];
        
        if ([objectNamePrefix isEqualToString:prefix]) {
            QCloudDeleteObjectInfo* objctInfo = [[QCloudDeleteObjectInfo alloc] init];
            objctInfo.key = bucketContents.key;
            [deleteObjectInfoArray addObject:objctInfo];
        }
    }
    
    QCloudDeleteMultipleObjectRequest* deleteMultipleObjectRequest = [[QCloudDeleteMultipleObjectRequest alloc] init];
    deleteMultipleObjectRequest.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    deleteMultipleObjectRequest.deleteObjects = [[QCloudDeleteInfo alloc] init];
    deleteMultipleObjectRequest.deleteObjects.objects = [deleteObjectInfoArray copy];
    [deleteMultipleObjectRequest setFinishBlock:^(QCloudDeleteResult * _Nonnull result, NSError * _Nonnull error) {
        if (error == nil) {
            NSLog(@"Delete ALL Object Success!");
        } else {
            NSLog(@"Delete all object fail! error:%@",error);
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:deleteMultipleObjectRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

#if QCloudCOSXMLModuleVersionNumber >= 502000
- (void)deleteAllTestBuckets {
    [self deleteAllBucketsWithPrefix:kTestBucketPrefix];
}

- (void)deleteAllBucketsWithPrefix:(NSString*)prefix {
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSArray* allBuckets;
    QCloudGetServiceRequest* getServiceRequest = [[QCloudGetServiceRequest alloc] init];
    [getServiceRequest setFinishBlock:^(QCloudListAllMyBucketsResult * _Nonnull result, NSError * _Nonnull error) {
        if (nil == error) {
            allBuckets = result.buckets;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetService:getServiceRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (allBuckets == nil) {
        return ;
    }
    NSUInteger prefixLength = prefix.length;
    for (QCloudBucket* bucket in allBuckets) {
        if (bucket.name.length < prefixLength) {
            continue;
        }
        NSString* bucketNamePrefix = [bucket.name substringToIndex:prefixLength];
        if ([bucketNamePrefix isEqualToString:prefix]) {
            //This is the bucket should be deleted
            
            __block NSArray<QCloudBucketContents*>* listBucketContents;
            QCloudGetBucketRequest* getBucketRequest = [[QCloudGetBucketRequest alloc] init];
            getBucketRequest.bucket = bucket.name;
            getBucketRequest.maxKeys = 500;
            [getBucketRequest setFinishBlock:^(QCloudListBucketResult * _Nonnull result, NSError * _Nonnull error) {
                listBucketContents = result.contents;
                dispatch_semaphore_signal(semaphore);
            }];
            [[QCloudCOSXMLService defaultCOSXML] GetBucket:getBucketRequest];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            if (listBucketContents == nil ) {
                QCloudDeleteBucketRequest* deleteBucketRequest = [[QCloudDeleteBucketRequest alloc] init];
                deleteBucketRequest.bucket = bucket.name;
                [deleteBucketRequest setFinishBlock:^(id outputObject, NSError *error) {
                    dispatch_semaphore_signal(semaphore);
                }];
                [[QCloudCOSXMLService defaultCOSXML] DeleteBucket:deleteBucketRequest];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            
            
            QCloudDeleteMultipleObjectRequest* deleteMultipleObjectRequest = [[QCloudDeleteMultipleObjectRequest alloc] init];
            deleteMultipleObjectRequest.bucket = bucket.name;
            deleteMultipleObjectRequest.deleteObjects = [[QCloudDeleteInfo alloc] init];
            NSMutableArray* deleteObjectInfoArray = [[NSMutableArray alloc] init];
            for (QCloudBucketContents* bucketContents in listBucketContents) {
                QCloudDeleteObjectInfo* objctInfo = [[QCloudDeleteObjectInfo alloc] init];
                objctInfo.key = bucketContents.key;
                [deleteObjectInfoArray addObject:objctInfo];
            }
            deleteMultipleObjectRequest.deleteObjects.objects = [deleteObjectInfoArray copy];
            [deleteMultipleObjectRequest setFinishBlock:^(QCloudDeleteResult * _Nonnull result, NSError * _Nonnull error) {
                if (error == nil) {
                    NSLog(@"Delete ALL Object Success!");
                } else {
                    NSLog(@"Delete all object fail! error:%@",error);
                }
                dispatch_semaphore_signal(semaphore);
            }];
            [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:deleteMultipleObjectRequest];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            
            QCloudDeleteBucketRequest* deleteBucketRequest = [[QCloudDeleteBucketRequest alloc] init];
            deleteBucketRequest.bucket = bucket.name;
            [deleteBucketRequest setFinishBlock:^(id outputObject, NSError *error) {
                dispatch_semaphore_signal(semaphore);
            }];
            [[QCloudCOSXMLService defaultCOSXML] DeleteBucket:deleteBucketRequest];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
    }
}
#endif
@end
