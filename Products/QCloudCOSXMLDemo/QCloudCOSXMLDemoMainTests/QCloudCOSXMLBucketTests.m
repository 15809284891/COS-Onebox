//
//  QCloudCOSXMLBucketTests.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/6/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//


#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
#import <QCloudCore/QCloudCore.h>
#import <COSXMLToolCommon/COSXMLToolCommon.h>
#import <COSXMLUtilityCommon/COSXMLUtilityCommon.h>
#import "QCloudCOSXMLServiceUtilities.h"
#import "QCloudListMultipartRequest.h"
@interface QCloudCOSXMLBucketTests : XCTestCase<QCloudSignatureProvider>
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSString* authorizedUIN;
@property (nonatomic, strong) NSString* ownerUIN;
@property (nonatomic, strong) NSString* appID;
@end






@implementation QCloudCOSXMLBucketTests


- (void)signatureWithFields:(QCloudSignatureFields *)fileds request:(QCloudBizHTTPRequest *)request urlRequest:(NSMutableURLRequest *)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock {

    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = @"AKIDTmqfJivoU6XllcsfroX3KNBl7JGzvt0s";
    credential.secretKey = @"mR1eJvUvKi2EDyWu40kHZdYJrBHApGUV";
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
    continueBlock(signature, nil);

}

- (void) setupSpecialCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = kAppID;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";
    configuration.endpoint = endpoint;

    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:@"aclService"];
}

+ (void)setUp {
        [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
}


+ (void)tearDown {
    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestObjects];
    [[QCloudCOSXMLTestUtility sharedInstance]deleteTestBucket: [QCloudTestTempVariables sharedInstance].testBucket];
    
}

- (void)setUp {
    [super setUp];
//    [self setupSpecialCOSXMLShareService];
//    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
//    self.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    self.bucket =  [QCloudTestTempVariables sharedInstance].testBucket;
    self.appID = kAppID;
    self.authorizedUIN = @"543198902";
    self.ownerUIN = @"1278687956";
}


- (NSString*)tempFileWithSize:(int64_t)size {
    NSString* file4MBPath = QCloudPathJoin(QCloudTempDir(), [NSUUID UUID].UUIDString);
    
    if (!QCloudFileExist(file4MBPath)) {
        [[NSFileManager defaultManager] createFileAtPath:file4MBPath contents:[NSData data] attributes:nil];
    }
    NSFileHandle* handler = [NSFileHandle fileHandleForWritingAtPath:file4MBPath];
    [handler truncateFileAtOffset:size];
    [handler closeFile];
    return file4MBPath;
}


- (void)createTestBucket {
    QCloudPutBucketRequest* request = [QCloudPutBucketRequest new];
    __block NSString* bucketName = [NSString stringWithFormat:@"bucketcanbedelete%i",arc4random()%1000];
    request.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put new bucket exception"];
    __block NSError* responseError ;
    __weak typeof(self) weakSelf = self;
    [request setFinishBlock:^(id outputObject, NSError* error) {
        XCTAssertNil(error);
        self.bucket = bucketName;
        [QCloudTestTempVariables sharedInstance].testBucket = bucketName;
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucket:request];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [[QCloudCOSXMLTestUtility sharedInstance] deleteTestBucket:self.bucket];
    [super tearDown];
}

@end
