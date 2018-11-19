//
//  COSXMLTest532.m
//  COSXMLCommon
//
//  Created by karisli(李雪) on 2018/4/5.
//

#import "COSXMLTest532.h"
#import "COSXMLCommon.h"
@implementation COSXMLTest532

+ (void)setUp {
    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
    
}


+ (void)tearDown {
    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestObjects];
    [[QCloudCOSXMLTestUtility sharedInstance]deleteTestBucket: [QCloudTestTempVariables sharedInstance].testBucket];
    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestBuckets];
}

- (void)setUp {
    [super setUp];
    [COSXMLTest tool];
    [QCloudCOSXMLExceptionCoverage tool];
    self.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    [QCloudCOSXMLExceptionCoverage tool];
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

#pragma mark - transefer
- (void) testChineseFileNameBigfileUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:50 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
    put.object = @"中文名大文件";
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
    [put setInitMultipleUploadFinishBlock:^(QCloudInitiateMultipartUploadResult* result,QCloudCOSXMLUploadObjectResumeData resumeData) {
        NSString* uploadID = result.uploadId;
        NSLog(@"UploadID%@",uploadID);
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}


- (void) testPauseAndResume {
    
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:15 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    
    __block QCloudUploadObjectResult* result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
    }];
    
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    
    
    __block QCloudCOSXMLUploadObjectResumeData resumeData = nil;
    XCTestExpectation* resumeExp = [self expectationWithDescription:@"delete2"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError* error;
        resumeData = [put cancelByProductingResumeData:&error];
        if (resumeData) {
            QCloudCOSXMLUploadObjectRequest* request = [QCloudCOSXMLUploadObjectRequest requestWithRequestData:resumeData];
            [request setFinishBlock:^(QCloudUploadObjectResult* outputObject, NSError *error) {
                result = outputObject;
                [resumeExp fulfill];
            }];
            
            [request setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
            }];
            [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
        } else {
            [resumeExp fulfill];
        }
    });
    
    
    [self waitForExpectationsWithTimeout:80000 handler:nil];
    XCTAssertNotNil(result);
    XCTAssertNotNil(result.location);
    XCTAssertNotNil(result.eTag);
}



#pragma mark - bucket

- (void)testGetService {
    QCloudGetServiceRequest* request = [[QCloudGetServiceRequest alloc] init];
    XCTestExpectation* expectation = [self expectationWithDescription:@"Get service"];
    [request setFinishBlock:^(QCloudListAllMyBucketsResult* result, NSError* error) {
        XCTAssertNil(error);
        XCTAssert(result);
        XCTAssert(result.owner);
        XCTAssert(result.buckets);
        [expectation fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetService:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

//head object，object包含x-cos-meta元数据\put object，请求头部携带自定义头部x-cos-meta-
-(void)testPutObjectWithSetMetaAndHeadObject{
    XCTestExpectation* exp = [self expectationWithDescription:@"put object"];
    QCloudPutObjectRequest *putObject = [QCloudPutObjectRequest new];
    putObject.bucket = self.bucket;
    putObject.body =  [@"4324ewr325" dataUsingEncoding:NSUTF8StringEncoding];
    __block NSString *metaTest = @"metaTest";
    putObject.customHeaders = @{@"x-cos-meta-test":metaTest};
    __block NSString *objectName = [NSString stringWithFormat:@"objectcanbedelete%i",arc4random()%1000];
    putObject.object = objectName;
    [putObject setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        if (!error) {
            QCloudHeadObjectRequest* headerRequest = [QCloudHeadObjectRequest new];
            headerRequest.object = objectName;
            headerRequest.bucket = self.bucket;
            __block id resultError;
            [headerRequest setFinishBlock:^(NSDictionary* result, NSError *error) {
                NSLog(@"hhh %@",result);
                XCTAssertNil(error);
                XCTAssertNotNil(result);
                XCTAssert([result[@"x-cos-meta-test"] isEqualToString:metaTest],@"不相等");
                [exp fulfill];
            }];
            
            [[QCloudCOSXMLService defaultCOSXML] HeadObject:headerRequest];
        }else {
            [exp fulfill];
        }
    }];
    [[QCloudCOSXMLService defaultCOSXML]PutObject:putObject];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

//head object，object元数据x-cos-meta长度达到2K
-(void)testHeadObjectWithSetMetaIsOver{
    XCTestExpectation* exp = [self expectationWithDescription:@"put object"];
    QCloudPutObjectRequest *putObject = [QCloudPutObjectRequest new];
    putObject.bucket = self.bucket;
    putObject.body =  [@"4324ewr325" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i<10000; i++) {
        [str appendString:@"hello"];
    }
    putObject.customHeaders = @{@"x-cos-meta":str};
    __block NSString *objectName = [NSString stringWithFormat:@"objectcanbedelete%i",arc4random()%1000];
    putObject.object = objectName;;
    [putObject setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNotNil(error);
        if (!error) {
            QCloudHeadObjectRequest* headerRequest = [QCloudHeadObjectRequest new];
            headerRequest.object = objectName;
            headerRequest.bucket = self.bucket;
            __block id resultError;
            [headerRequest setFinishBlock:^(NSDictionary* result, NSError *error) {
                XCTAssertNil(error);
                XCTAssertNotNil(result);
                [exp fulfill];
            }];
            
            [[QCloudCOSXMLService defaultCOSXML] HeadObject:headerRequest];
        }else {
            [exp fulfill];
        }
    }];
    [[QCloudCOSXMLService defaultCOSXML]PutObject:putObject];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}


#pragma mark - object acl


//upload part copy，请求指定Range
- (void)testMultiplePutObjectCopyWithSameRegion {
    
    QCloudPutObjectRequest * putRequst = [QCloudPutObjectRequest new];
    putRequst.bucket = self.bucket;
    __block NSString *objectName = [NSString stringWithFormat:@"objectcanbedelete%i**object",arc4random()%1000];
    __weak typeof (self)weakSelf = self;
    putRequst.object = objectName;
    putRequst.body =  [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:5 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
    XCTestExpectation* exp = [self expectationWithDescription:@"part copy object from the same region"];
    [putRequst setFinishBlock:^(id outputObject, NSError *error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        XCTAssertNil(error);
        if (!error) {
            QCloudCOSXMLCopyObjectRequest* request = [[QCloudCOSXMLCopyObjectRequest alloc] init];
            request.bucket = [[QCloudCOSXMLTestUtility sharedInstance]createTestBucket];
            request.object = @"copy-result-test";
            request.sourceBucket = strongSelf.bucket;
            request.sourceObject = objectName;
            request.sourceAPPID = kAppID;
            request.sourceRegion= kRegion;
            [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
                XCTAssertNil(error);
                [exp fulfill];
            }];
            [[QCloudCOSTransferMangerService defaultCOSTransferManager] CopyObject:request];
        }else{
            [exp fulfill];
        }
    }];
    [[QCloudCOSXMLService defaultCOSXML]PutObject:putRequst];
    [self waitForExpectationsWithTimeout:1000 handler:nil];
    
    
}
+(void)tool{
    
}
@end
