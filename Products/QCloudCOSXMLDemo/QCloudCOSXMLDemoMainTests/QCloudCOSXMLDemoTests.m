//
//  QCloudCOSXMLDemoTests.m
//  QCloudCOSXMLDemoTests
//
//  Created by Dong Zhao on 2017/2/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//



#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
#import <QCloudCOSXML/QCloudCOSXMLService.h>
#import <COSXMLToolCommon/COSXMLToolCommon.h>
#import <COSXMLUtilityCommon/COSXMLUtilityCommon.h>
@interface QCloudCOSXMLDemoTests : XCTestCase <QCloudSignatureProvider>
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSString* appID;
@property (nonatomic, strong) NSString* ownerID;
@property (nonatomic, strong) NSString* authorizedUIN;
@property (nonatomic, strong) NSString* ownerUIN;
@end

@implementation QCloudCOSXMLDemoTests
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
    configuration.appID = @"1251950346";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-beijing";
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
    [self setupSpecialCOSXMLShareService];
    
    self.appID =  kAppID;
    self.ownerID = @"1278687956";
    self.authorizedUIN = @"543198902";
    self.ownerUIN = @"1278687956";
//    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
//    self.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    self.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [[QCloudCOSXMLTestUtility sharedInstance] deleteTestBucket:self.bucket];
    [super tearDown];
}



- (void)deleteTestBucket {
    
    XCTestExpectation* exception = [self expectationWithDescription:@"Delete bucket exception"];

    QCloudGetBucketRequest* request = [[QCloudGetBucketRequest alloc] init];
    request.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    request.maxKeys = 500;
    [request setFinishBlock:^(QCloudListBucketResult* result, NSError* error) {

        QCloudDeleteMultipleObjectRequest* deleteMultipleObjectRequest =  [[QCloudDeleteMultipleObjectRequest alloc] init];
        deleteMultipleObjectRequest.bucket  = [QCloudTestTempVariables sharedInstance].testBucket;
        deleteMultipleObjectRequest.deleteObjects = [[QCloudDeleteInfo alloc] init];
        NSMutableArray* deleteObjectInfoArray = [NSMutableArray array];
        deleteMultipleObjectRequest.deleteObjects.objects = deleteObjectInfoArray;
        for (QCloudBucketContents* content in result.contents) {
            QCloudDeleteObjectInfo* info = [[QCloudDeleteObjectInfo alloc] init];
            info.key = content.key;
            [deleteObjectInfoArray addObject:info];
        }
        [deleteMultipleObjectRequest setFinishBlock:^(QCloudDeleteResult* result, NSError* error) {
            if (!error) {
                QCloudDeleteBucketRequest* deleteBucketRequest = [[QCloudDeleteBucketRequest alloc] init];
                deleteBucketRequest.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
                [[QCloudCOSXMLService  defaultCOSXML] DeleteBucket:deleteBucketRequest];
            } else {
                QCloudLogDebug(error.description);
            }
            [exception fulfill];
        }];
        [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:deleteMultipleObjectRequest];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];

}





- (NSString*) uploadTempObject
{
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  [@"1234jdjdjdjjdjdjyuehjshgdytfakjhsghgdhg" dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    [put setFinishBlock:^(id outputObject, NSError *error) {
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    return put.object;
}



- (NSString*) tempFileWithSize:(int)size
{
    NSString* file4MBPath = QCloudPathJoin(QCloudTempDir(), [NSUUID UUID].UUIDString);
    
    if (!QCloudFileExist(file4MBPath)) {
        [[NSFileManager defaultManager] createFileAtPath:file4MBPath contents:[NSData data] attributes:nil];
    }
    NSFileHandle* handler = [NSFileHandle fileHandleForWritingAtPath:file4MBPath];
    [handler truncateFileAtOffset:size];
    [handler closeFile];
    return file4MBPath;
}
- (void) testHeadeObject   {
    NSString* object = [self uploadTempObject];
    QCloudHeadObjectRequest* headerRequest = [QCloudHeadObjectRequest new];
    headerRequest.object = object;
    headerRequest.bucket = self.bucket;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"header"];
    __block id resultError;
    [headerRequest setFinishBlock:^(NSDictionary* result, NSError *error) {
        resultError = error;
        [exp fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] HeadObject:headerRequest];
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    XCTAssertNil(resultError);
}





- (void) testLittleLimitAppendObject {
    QCloudAppendObjectRequest* put = [QCloudAppendObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  [NSURL fileURLWithPath:[self tempFileWithSize:1024*2]];
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block NSDictionary* result = nil;
    __block NSError* error;
    [put setFinishBlock:^(id outputObject, NSError *servererror) {
        result = outputObject;
        error = servererror;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] AppendObject:put];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    XCTAssertNotNil(error);
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


@end
