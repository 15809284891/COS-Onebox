//
//  QCloudCOSTransferTests.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "COSXMLTest500.h"
#define kHTTPServiceKey @"HTTPService"
#import "QCloudCOSXMLVersion.h"
@implementation QCloudCOSTransferTests
+(void)tool{
    
}
- (void)signatureWithFields:(QCloudSignatureFields *)fileds request:(QCloudBizHTTPRequest *)request urlRequest:(NSMutableURLRequest *)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock {
    
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = kSecretID;
    credential.secretKey = kSecretKey;
    QCloudAuthentationCreator* creator = [[QCloudAuthentationCreator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForCOSXMLRequest:request];
    continueBlock(signature, nil);
    
}
+ (void)setUp {
    //    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
    [QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER].configuration.endpoint.regionName =  [QCloudCOSXMLService defaultCOSXML].configuration.endpoint.regionName =[QCloudRegionAdapter adapteRegionName:kRegion];
}
- (void) setupSpecialCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = [SecretStorage sharedInstance].appID;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
#ifdef CNNORTH_REGION
    endpoint.regionName = @"cn-north";
#else
    endpoint.regionName = @"ap-guangzhou";
#endif
    configuration.endpoint = endpoint;
    
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];

    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
}

+ (void)tearDown {
    //    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestBuckets];
}

- (void)setUp {
    [super setUp];
    self.tempFilePathArray = [[NSMutableArray alloc] init];

    [self setupSpecialCOSXMLShareService];
    self.bucket = kTestBucket;
    //    [self registerHTTPTransferManager];
    [QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER].configuration.endpoint.regionName = @"cn-north";
    [QCloudCOSXMLService defaultCOSXML].configuration.endpoint.regionName = @"cn-north";
}



- (void)tearDown {
    [super tearDown];
    NSFileManager* manager = [NSFileManager defaultManager];
    
    for (NSString* tempFilePath in self.tempFilePathArray) {
        if ([manager fileExistsAtPath:tempFilePath]) {
            [manager removeItemAtPath:tempFilePath error:nil];
        }
    }
}
- (void) testRegisterCustomManagerService
{
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1251668577";
    configuration.signatureProvider = self;
    
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"cn-south";
    configuration.endpoint = endpoint;
    
    NSString* serviceKey = @"test";
    [QCloudCOSTransferMangerService registerCOSTransferMangerWithConfiguration:configuration withKey:serviceKey];
    
    QCloudCOSTransferMangerService* service = [QCloudCOSTransferMangerService costransfermangerServiceForKey:serviceKey];
    XCTAssertNotNil(service);
}

//- (void)registerHTTPTransferManager {
//    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
//    configuration.appID = @"1253653367";
//    configuration.signatureProvider = self;
//    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
//    endpoint.useHTTPS = YES;
//    endpoint.regionName = @"cn-north";
//    configuration.endpoint = endpoint;
//
//    [QCloudCOSTransferMangerService registerCOSTransferMangerWithConfiguration:configuration withKey:kHTTPServiceKey];
//    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:kHTTPServiceKey];
//}





//- (void) testHTTPSMultipleUpload {
//    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
//    int randomNumber = arc4random()%100;
//    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:10*1024*1024 + randomNumber]];
//    put.object = [NSUUID UUID].UUIDString;
//    put.bucket = self.bucket;
//    put.body =  url;
//    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
//    }];
//    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
//    __block id result;
//    [put setFinishBlock:^(id outputObject, NSError *error) {
//        result = outputObject;
//        [exp fulfill];
//    }];
//    [[QCloudCOSTransferMangerService costransfermangerServiceForKey:kHTTPServiceKey] UploadObject:put];
//    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
//    }];
//    XCTAssertNotNil(result);
//}


//- (void) testChineseFileNameBigfileUpload {
//    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
//    int randomNumber = arc4random()%100;
//    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:15*1024*1024 + randomNumber]];
//    put.object = @"中文名大文件";
//    put.bucket = self.bucket;
//    put.body =  url;
//    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
//    }];
//    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
//    __block id result;
//    [put setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error);
//        result = outputObject;
//        [exp fulfill];
//    }];
//    [put setInitMultipleUploadFinishBlock:^(QCloudInitiateMultipartUploadResult* result,QCloudCOSXMLUploadObjectResumeData resumeData) {
//        NSString* uploadID = result.uploadId;
//        NSLog(@"UploadID%@",uploadID);
//    }];
//    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
//    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
//    }];
//    XCTAssertNotNil(result);
//}

- (void)testChineseFileNameSmallFileUpload {
    NSLog(@"hahahah%@",kTestBucket);
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:200 unit:QCLOUD_TEMP_FILE_UNIT_KB]];
    put.object = @"中文名小文件";
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}

//
//- (void)testSpecialCharacterFileNameBigFileUpoload {
//    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
//    int randomNumber = arc4random()%100;
//    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:15*1024*1024 + randomNumber]];
//    put.object = @"→↓←→↖↗↙↘! \"#$%&'()*+,-.0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
//    put.bucket = self.bucket;
//    put.body =  url;
//    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
//    }];
//
//    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
//    __block id result;
//    [put setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error);
//        result = outputObject;
//        [exp fulfill];
//    }];
//    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
//    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
//    }];
//    XCTAssertNotNil(result);
//}


//- (void)testSpecialCharacterFileSmallFileUpload {
//    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
//    int randomNumber = arc4random()%100;
//    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:100 + randomNumber]];
//    put.object = @"→↓←→↖↗↙↘! \"#$%&'()*+,-.0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
//    put.bucket = self.bucket;
//    put.body =  url;
//    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
//    }];
//    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
//    __block id result;
//    [put setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error);
//        result = outputObject;
//        [exp fulfill];
//    }];
//    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
//    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
//    }];
//    XCTAssertNotNil(result);
//}


- (void)testIntegerTimesSliceMultipartUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:10 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}


//- (void) testChineseObjectName {
//    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
//    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:1024 ]];
//    put.object = @"一个文件名→↓←→↖↗↙↘! \"#$%&'()*+,-./0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_";
//    put.bucket = self.bucket;
//    put.body =  url;
//    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
//    }];
//    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
//    __block id result;
//    [put setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error);
//        result = outputObject;
//        [exp fulfill];
//    }];
//    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
//    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
//    }];
//    XCTAssertNotNil(result);
//}


- (void)testSmallSizeUpload {
    
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:1 unit:QCLOUD_TEMP_FILE_UNIT_KB]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
    
}
- (void) testAbortMultiUpload{
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:20+randomNumber unit:QCLOUD_TEMP_FILE_UNIT_MB]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudUploadObjectResult* result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    XCTestExpectation* hintExp = [self expectationWithDescription:@"abort"];
    
    __block id abortResult = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [put abort:^(id outputObject, NSError *error) {
            abortResult = outputObject;
            [hintExp fulfill];
        }];
        
    });
    [self waitForExpectationsWithTimeout:80000 handler:nil];
    XCTAssertNotNil(abortResult);
}
- (void) testAbortMultiNotExistUpload{
    XCTestExpectation* exp = [self expectationWithDescription:@"abort part"];
    QCloudAbortMultipfartUploadRequest *abortRequest = [QCloudAbortMultipfartUploadRequest new];
    abortRequest.bucket = self.bucket;
    abortRequest.object = self.bucket;
    abortRequest.uploadId = @"wobuzai";
    [abortRequest setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNotNil(error);
        XCTAssert(error.code == 404,@"error.code != 404 it is %ld",error.code);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]AbortMultipfartUpload:abortRequest];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}
//- (void) testPauseAndResume {
//
//    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
//    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:30*1024*1024]];
//    put.object = [NSUUID UUID].UUIDString;
//    put.bucket = self.bucket;
//    put.body =  url;
//
//    __block QCloudUploadObjectResult* result;
//    [put setFinishBlock:^(id outputObject, NSError *error) {
//        result = outputObject;
//    }];
//
//    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
//    }];
//    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
//
//
//    __block QCloudCOSXMLUploadObjectResumeData resumeData = nil;
//    XCTestExpectation* resumeExp = [self expectationWithDescription:@"delete2"];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        NSError* error;
//        resumeData = [put cancelByProductingResumeData:&error];
//        if (resumeData) {
//            QCloudCOSXMLUploadObjectRequest* request = [QCloudCOSXMLUploadObjectRequest requestWithRequestData:resumeData];
//            [request setFinishBlock:^(QCloudUploadObjectResult* outputObject, NSError *error) {
//                result = outputObject;
//                [resumeExp fulfill];
//            }];
//
//            [request setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
//                NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
//            }];
//            [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:request];
//        } else {
//            [resumeExp fulfill];
//        }
//    });
//
//
//    [self waitForExpectationsWithTimeout:80000 handler:nil];
//    XCTAssertNotNil(result);
//    XCTAssertNotNil(result.location);
//    XCTAssertNotNil(result.eTag);
//}

@end
