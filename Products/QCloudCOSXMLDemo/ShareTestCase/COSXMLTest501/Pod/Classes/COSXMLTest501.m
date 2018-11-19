//
//  COSXMLTest501.m
//  COSXMLBaseCommon
//
//  Created by karisli(李雪) on 2018/4/6.
//


#import "COSXMLTest501.h"
#import "COSXMLBaseCommon.h"
@implementation COSXMLTest501
+(void)tool{
    
}

+ (void)setUp {
    //    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
    [QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER].configuration.endpoint.regionName =  [QCloudCOSXMLService defaultCOSXML].configuration.endpoint.regionName =[QCloudRegionAdapter adapteRegionName:kRegion];
}


+ (void)tearDown {
    //    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestBuckets];
}

- (void)setUp {
    [super setUp];
    self.bucket = kTestBucket;
    self.appID = kAppID;
    self.authorizedUIN = @"543198902";
    self.ownerUIN = @"1278687956";
    [COSXMLBaseCommon tool];
    [QCloudCOSXMLExceptionCoverage tool];
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

# pragma mark - transfer
- (void)testChineseFileNameSmallFileUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:200+randomNumber unit:QCLOUD_TEMP_FILE_UNIT_KB]];
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
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}

//- (void)testSpecialCharacterFileNameBigFileUpoload {
//    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
//    int randomNumber = arc4random()%100;
//    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:15+randomNumber unit:QCLOUD_TEMP_FILE_UNIT_MB]];
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
//    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:100 unit:QCLOUD_TEMP_FILE_UNIT_KB]];
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
#ifndef BUILD_FOR_TEST
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
#endif

- (void) testChineseObjectName {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:1 unit:QCLOUD_TEMP_FILE_UNIT_KB]];
    put.object = @"一个文件名→↓←→↖↗↙↘! \"#$%&'()*+,-./0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_";
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}
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
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:100 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
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



#ifndef BUILD_FOR_TEST
//- (void) testMultiUpload {
//    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
//    int randomNumber = arc4random()%100;
//    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:20 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
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
//        XCTAssertNil(error);
//        [exp fulfill];
//    }];
//    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
//    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
//    }];
//    XCTAssertNotNil(result);
//    
//}
#endif
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

@end
