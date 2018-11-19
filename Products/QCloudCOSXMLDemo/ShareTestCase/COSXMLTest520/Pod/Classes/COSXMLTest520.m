//
//  COSXMLTest520.m
//  COSXMLCommon
//
//  Created by karisli(李雪) on 2018/4/5.
//

#import "COSXMLTest520.h"
#import "COSXMLCommon.h"

@implementation COSXMLTest520

+ (void)setUp {
    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
    
}


+ (void)tearDown {
    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestObjects];
    [[QCloudCOSXMLTestUtility sharedInstance]deleteTestBucket: [QCloudTestTempVariables sharedInstance].testBucket];
//    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestBuckets];
}

- (void)setUp {
    [super setUp];
    [COSXMLTest tool];
    [QCloudCOSXMLExceptionCoverage tool];
    self.tempFilePathArray = [[NSMutableArray alloc] init];
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

#pragma mark - transfer
- (void) testChineseFileNameBigfileUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:15+randomNumber unit:QCLOUD_TEMP_FILE_UNIT_MB]];
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
    NSURL* url = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:30 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
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








- (void)testPut_And_Get_BucketVersioning {
    QCloudPutBucketVersioningRequest* request = [[QCloudPutBucketVersioningRequest alloc] init];
    request.bucket = self.bucket;
    QCloudBucketVersioningConfiguration* configuration = [[QCloudBucketVersioningConfiguration alloc] init];
    request.configuration = configuration;
    configuration.status = QCloudCOSBucketVersioningStatusEnabled;
    XCTestExpectation* expectation = [self expectationWithDescription:@"Put Bucket Versioning"];
    [request setFinishBlock:^(id outputObject, NSError* error) {
        XCTAssertNil(error);
        
        
        QCloudGetBucketVersioningRequest* request = [[QCloudGetBucketVersioningRequest alloc] init];
        request.bucket = self.bucket;
        [request setFinishBlock:^(QCloudBucketVersioningConfiguration* result, NSError* error) {
            XCTAssert(result);
            XCTAssertNil(error);
            [expectation fulfill];
        }];
        [[QCloudCOSXMLService defaultCOSXML] GetBucketVersioning:request];
        
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    //
    QCloudPutBucketVersioningRequest* suspendRequest = [[QCloudPutBucketVersioningRequest alloc] init];
    suspendRequest.bucket = self.bucket;
    QCloudBucketVersioningConfiguration* suspendConfiguration = [[QCloudBucketVersioningConfiguration alloc] init];
    request.configuration = suspendConfiguration;
    suspendConfiguration.status = QCloudCOSBucketVersioningStatusSuspended;
    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
}

#pragma mark - demo

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
