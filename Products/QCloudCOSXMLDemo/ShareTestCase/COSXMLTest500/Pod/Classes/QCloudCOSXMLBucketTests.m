//
//  QCloudCOSXMLBucketTests.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/6/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "COSXMLTest500.h"

@implementation QCloudCOSXMLBucketTests


- (void)signatureWithFields:(QCloudSignatureFields *)fileds request:(QCloudBizHTTPRequest *)request urlRequest:(NSMutableURLRequest *)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock {
    
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = kSecretID;
    credential.secretKey = kSecretKey;
    QCloudAuthentationCreator* creator = [[QCloudAuthentationCreator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForCOSXMLRequest:request];
    continueBlock(signature, nil);

}

- (void) setupSpecialCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = kAppID;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = kRegion;
    configuration.endpoint = endpoint;
    
    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:@"aclService"];
}


- (void)setUp {
    [super setUp];
    [self setupSpecialCOSXMLShareService];
//    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
//    self.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    self.bucket = kTestBucket;
    self.appID = kAppID;
    self.authorizedUIN = @"543198902";
    self.ownerUIN = @"1278687956";
}

//- (void)createTestBucket {
//    QCloudPutBucketRequest* request = [QCloudPutBucketRequest new];
//    __block NSString* bucketName = [NSString stringWithFormat:@"bucketcanbedelete%i",arc4random()%1000];
//    request.bucket = bucketName;
//    XCTestExpectation* exception = [self expectationWithDescription:@"Put new bucket exception"];
//    __block NSError* responseError ;
//    __weak typeof(self) weakSelf = self;
//    [request setFinishBlock:^(id outputObject, NSError* error) {
//        XCTAssertNil(error);
//        self.bucket = bucketName;
//        [QCloudTestTempVariables sharedInstance].testBucket = bucketName;
//        responseError = error;
//        [exception fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] PutBucket:request];
//    [self waitForExpectationsWithTimeout:100 handler:nil];
//}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [[QCloudCOSXMLTestUtility sharedInstance] deleteTestBucket:self.bucket];
    [super tearDown];
}



- (void) testGetBucket {
    QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
    request.bucket = self.bucket;
    request.maxKeys = 1000;
    request.prefix = @"0";
    request.delimiter = @"0";
    request.encodingType = @"url";
    
    request.prefix = request.delimiter = request.encodingType = nil;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block QCloudListBucketResult* listResult;
    [request setFinishBlock:^(QCloudListBucketResult * _Nonnull result, NSError * _Nonnull error) {
        listResult = result;
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    XCTAssertNotNil(listResult);
    NSString* listResultName = listResult.name;
    NSString* expectListResultName = [NSString stringWithFormat:@"%@-%@",self.bucket,self.appID];
//    XCTAssert([listResultName isEqualToString:expectListResultName]);
}


- (void) testCORS2Put_Get_DeleteBucketCORS {
    
    QCloudPutBucketCORSRequest* putCORS = [QCloudPutBucketCORSRequest new];
    QCloudCORSConfiguration* putCors = [QCloudCORSConfiguration new];
    
    QCloudCORSRule* rule = [QCloudCORSRule new];
    rule.identifier = @"sdk";
    rule.allowedHeader = @[@"origin",@"accept",@"content-type",@"authorization"];
    rule.exposeHeader = @"ETag";
    rule.allowedMethod = @[@"GET",@"PUT",@"POST", @"DELETE", @"HEAD"];
    rule.maxAgeSeconds = 3600;
    rule.allowedOrigin = @"*";
    
    putCors.rules = @[rule];
    
    putCORS.corsConfiguration = putCors;
    putCORS.bucket = self.bucket;
    __block NSError* localError1;
    
    
    __block QCloudCORSConfiguration* cors;
    __block XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    
    [putCORS setFinishBlock:^(id outputObject, NSError *error) {
        
        XCTAssertNil(error,@"Put Bucket CORS fail! error detail is %@",error);
        
        QCloudGetBucketCORSRequest* corsReqeust = [QCloudGetBucketCORSRequest new];
        corsReqeust.bucket = self.bucket;
        
        [corsReqeust setFinishBlock:^(QCloudCORSConfiguration * _Nonnull result, NSError * _Nonnull error) {
            
            XCTAssertNil(error);
            cors = result;
            
            
            QCloudDeleteBucketCORSRequest* deleteCORSRequest = [[QCloudDeleteBucketCORSRequest alloc] init];
            deleteCORSRequest.bucket = self.bucket;
            [deleteCORSRequest setFinishBlock:^(id outputObject, NSError *error) {
                XCTAssertNil(error, @"delete bucket cors fail! error is %@",error);
                [exp fulfill];
            }];
            
            
            [exp fulfill];
        }];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_wait(semaphore, 3*NSEC_PER_SEC);
        [[QCloudCOSXMLService defaultCOSXML] GetBucketCORS:corsReqeust];

        
    }];
    
    
    [[QCloudCOSXMLService defaultCOSXML] PutBucketCORS:putCORS];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNotNil(cors);
    XCTAssert([[[cors.rules firstObject] identifier] isEqualToString:@"sdk"]);
    XCTAssertEqual(1, cors.rules.count);
    XCTAssertEqual([cors.rules.firstObject.allowedMethod count], 5);
    XCTAssert([cors.rules.firstObject.allowedMethod containsObject:@"PUT"]);
    XCTAssert([cors.rules.firstObject.allowedHeader count] == 4);
    XCTAssert([cors.rules.firstObject.exposeHeader isEqualToString:@"ETag"]);
}



//- (void)testCORS3_OpetionObject {
//    QCloudOptionsObjectRequest* request = [[QCloudOptionsObjectRequest alloc] init];
//    request.bucket = self.bucket;
//    request.origin = @"http://www.qcloud.com";
//    request.accessControlRequestMethod = @"GET";
//    request.accessControlRequestHeaders = @"origin";
//    request.object = [[QCloudCOSXMLTestUtility sharedInstance] uploadTempObjectInBucket:self.bucket];
//    XCTestExpectation* exp = [self expectationWithDescription:@"option object"];
//
//    __block id resultError;
//    [request setFinishBlock:^(id outputObject, NSError* error) {
//        resultError = error;
//        [exp fulfill];
//    }];
//
//    [[QCloudCOSXMLService defaultCOSXML] OptionsObject:request];
//
//    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
//
//    }];
//    XCTAssertNil(resultError);
//
//
//}



- (void) testGetBucketLocation {
    QCloudGetBucketLocationRequest* locationReq = [QCloudGetBucketLocationRequest new];
    locationReq.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudBucketLocationConstraint* location;
    
    
    [locationReq setFinishBlock:^(QCloudBucketLocationConstraint * _Nonnull result, NSError * _Nonnull error) {
        location = result;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketLocation:locationReq];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNotNil(location);
    NSString* currentLocation = kRegion;
    XCTAssert([location.locationConstraint isEqualToString:currentLocation]);
}










- (void)testHeadBucket {
    QCloudHeadBucketRequest* request = [QCloudHeadBucketRequest new];
    request.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    __block NSError* resultError;
    [request setFinishBlock:^(id outputObject, NSError* error) {
        resultError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] HeadBucket:request];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertNil(resultError);
}



//- (void)testListMultipartUpload {
//
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    QCloudCOSXMLUploadObjectRequest* uploadObjectRequest = [[QCloudCOSXMLUploadObjectRequest alloc] init];
//    uploadObjectRequest.bucket = self.bucket;
//    uploadObjectRequest.object = @"object-aborted";
//    uploadObjectRequest.body = [NSURL URLWithString:[QCloudTestUtility tempFileWithSize:5 unit:QCLOUD_TEST_FILE_UNIT_MB]];
//    __weak QCloudCOSXMLUploadObjectRequest* weakRequest = uploadObjectRequest;
//    __block NSString* uploadID ;
//    [uploadObjectRequest setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
//        if (totalBytesSent > totalBytesExpectedToSend*0.5 ) {
//            [weakRequest cancel];
//        }
//    }];
//    uploadObjectRequest.initMultipleUploadFinishBlock = ^(QCloudInitiateMultipartUploadResult *multipleUploadInitResult, QCloudCOSXMLUploadObjectResumeData resumeData) {
//        uploadID = multipleUploadInitResult.uploadId;
//    };
//    [uploadObjectRequest setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
//        dispatch_semaphore_signal(semaphore);
//    }];
//    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:uploadObjectRequest];
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//
//
//
//    QCloudListMultipartRequest* request = [[QCloudListMultipartRequest alloc] init];
//    request.bucket = self.bucket;
//    request.object = uploadObjectRequest.object;
//    request.uploadId = uploadID;
//
//    XCTestExpectation* expectation = [self expectationWithDescription:@"test" ];
//    [request setFinishBlock:^(QCloudListPartsResult * _Nonnull result, NSError * _Nonnull error) {
//        XCTAssertNil(error);
//        XCTAssert(result);
//        [expectation fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] ListMultipart:request];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//}


- (void) testListBucketUploads {
    QCloudListBucketMultipartUploadsRequest* uploads = [QCloudListBucketMultipartUploadsRequest new];
    uploads.bucket = self.bucket;
    uploads.maxUploads = 1000;
    __block NSError* localError;
    __block QCloudListMultipartUploadsResult* multiPartUploadsResult;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    [uploads setFinishBlock:^(QCloudListMultipartUploadsResult* result, NSError *error) {
        multiPartUploadsResult = result;
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] ListBucketMultipartUploads:uploads];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    
    XCTAssertNil(localError);
    XCTAssert(multiPartUploadsResult.maxUploads==1000);
    NSString* expectedBucketString = [NSString stringWithFormat:@"%@-%@",self.bucket,self.appID];
//    XCTAssert([multiPartUploadsResult.bucket isEqualToString:expectedBucketString]);
    XCTAssert(multiPartUploadsResult.maxUploads == 1000);
    if (multiPartUploadsResult.uploads.count) {
//        QCloudListMultipartUploadContent* firstContent = [multiPartUploadsResult.uploads firstObject];
//        XCTAssert([firstContent.owner.displayName isEqualToString:@"1278687956"]);
//        XCTAssert([firstContent.initiator.displayName isEqualToString:@"1278687956"]);
//        XCTAssertNotNil(firstContent.uploadID);
//        XCTAssertNotNil(firstContent.key);
    }
}




//- (void)testPut_And_Get_BucketVersioning {
//    QCloudPutBucketVersioningRequest* request = [[QCloudPutBucketVersioningRequest alloc] init];
//    request.bucket = self.bucket;
//    QCloudBucketVersioningConfiguration* configuration = [[QCloudBucketVersioningConfiguration alloc] init];
//    request.configuration = configuration;
//    configuration.status = QCloudCOSBucketVersioningStatusEnabled;
//    XCTestExpectation* expectation = [self expectationWithDescription:@"Put Bucket Versioning"];
//    [request setFinishBlock:^(id outputObject, NSError* error) {
//            XCTAssertNil(error);
//
//
//            QCloudGetBucketVersioningRequest* request = [[QCloudGetBucketVersioningRequest alloc] init];
//            request.bucket = self.bucket;
//            [request setFinishBlock:^(QCloudBucketVersioningConfiguration* result, NSError* error) {
//                XCTAssert(result);
//                XCTAssertNil(error);
//                [expectation fulfill];
//            }];
//            [[QCloudCOSXMLService defaultCOSXML] GetBucketVersioning:request];
//
//
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//
//    //
//    QCloudPutBucketVersioningRequest* suspendRequest = [[QCloudPutBucketVersioningRequest alloc] init];
//    suspendRequest.bucket = self.bucket;
//    QCloudBucketVersioningConfiguration* suspendConfiguration = [[QCloudBucketVersioningConfiguration alloc] init];
//    request.configuration = suspendConfiguration;
//    suspendConfiguration.status = QCloudCOSBucketVersioningStatusSuspended;
//    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
//}

//- (void)testPut_Get_Delte_BucketReplication {
//    //enable bucket versioning first
//    QCloudPutBucketVersioningRequest* request = [[QCloudPutBucketVersioningRequest alloc] init];
//    request.bucket = @"xiaodaxiansource";
//    QCloudBucketVersioningConfiguration* configuration = [[QCloudBucketVersioningConfiguration alloc] init];
//    request.configuration = configuration;
//    configuration.status = QCloudCOSBucketVersioningStatusEnabled;
//    XCTestExpectation* expectation = [self expectationWithDescription:@"Put Bucket Versioning"];
//    [request setFinishBlock:^(id outputObject, NSError* error) {
//        XCTAssertNil(error);
//        
//        // put bucket replication
//        QCloudPutBucketReplicationRequest* request = [[QCloudPutBucketReplicationRequest alloc] init];
//        request.bucket = @"xiaodaxiansource";
//        QCloudBucketReplicationConfiguation* configuration = [[QCloudBucketReplicationConfiguation alloc] init];
//        configuration.role = [NSString identifierStringWithID:@"543198902" :@"543198902"];
//        QCloudBucketReplicationRule* rule = [[QCloudBucketReplicationRule alloc] init];
//        
//        rule.identifier = [NSUUID UUID].UUIDString;
//        rule.status = QCloudCOSXMLStatusEnabled;
//        
//        QCloudBucketReplicationDestination* destination = [[QCloudBucketReplicationDestination alloc] init];
//        //qcs:id/0:cos:[region]:appid/[AppId]:[bucketname]
//        NSString* destinationBucket = @"xy3";
//        NSString* region = @"ap-guangzhou";
//        destination.bucket = [NSString stringWithFormat:@"qcs:id/0:cos:%@:appid/%@:%@",@"ap-guangzhou",self.appID,destinationBucket];
//        rule.destination = destination;
//        configuration.rule = @[rule];
//        request.configuation = configuration;
//        [request setFinishBlock:^(id outputObject, NSError* error) {
//            XCTAssertNil(error);
//            // get bucket replication
//            QCloudGetBucketReplicationRequest* request = [[QCloudGetBucketReplicationRequest alloc] init];
//            request.bucket = self.bucket;
//            [request setFinishBlock:^(QCloudBucketReplicationConfiguation* result, NSError* error) {
//                XCTAssertNil(error);
//                XCTAssertNotNil(result);
//                
//                
//                //delete bucket replication
//                QCloudDeleteBucketReplicationRequest* request = [[QCloudDeleteBucketReplicationRequest alloc] init];
//                request.bucket = self.bucket;
//                [request setFinishBlock:^(id outputObject, NSError* error) {
//                    XCTAssertNil(error);
//                    [expectation fulfill];
//                }];
//                [[QCloudCOSXMLService defaultCOSXML] DeleteBucketReplication:request];
//                //delete bucket replication end
//                
//                
//            }];
//            [[QCloudCOSXMLService defaultCOSXML] GetBucketReplication:request];
//            
//            
//            // get bucket replication end
//            
//            
//            
//            
//            
//        }];
//        [[QCloudCOSXMLService defaultCOSXML] PutBucketRelication:request];
//        // put bucket replication end
//        
//        
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//    
//    //
//    QCloudPutBucketVersioningRequest* suspendRequest = [[QCloudPutBucketVersioningRequest alloc] init];
//    suspendRequest.bucket = self.bucket;
//    QCloudBucketVersioningConfiguration* suspendConfiguration = [[QCloudBucketVersioningConfiguration alloc] init];
//    request.configuration = suspendConfiguration;
//    suspendConfiguration.status = QCloudCOSBucketVersioningStatusSuspended;
//    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
// 
//}

//- (void)testBucketReplication2_GetBucektReplication {
//    QCloudGetBucketReplicationRequest* request = [[QCloudGetBucketReplicationRequest alloc] init];
//    request.bucket = @"xiaodaxiansource";
//
//    XCTestExpectation* expectation = [self expectationWithDescription:@"Get bucke replication" ];
//    [request setFinishBlock:^(QCloudBucketReplicationConfiguation* result, NSError* error) {
//        XCTAssertNil(error);
//        XCTAssertNotNil(result);
//        [expectation fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] GetBucketReplication:request];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//}
//
//- (void)testBucketReplication3_DeleteBucketReplication {
//    QCloudDeleteBucketReplicationRequest* request = [[QCloudDeleteBucketReplicationRequest alloc] init];
//    request.bucket = @"xiaodaxiansource";
//    XCTestExpectation* expectation = [self expectationWithDescription:@"delete bucket replication" ];
//    [request setFinishBlock:^(id outputObject, NSError* error) {
//        XCTAssertNil(error);
//        [expectation fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketReplication:request];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//
//}
#pragma mark - karis

#pragma mark - tool
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
#pragma mark - bucketLifeCycle
////put bucket lifecycle，请求body中不指定filter
//- (void)testPutBucketLifeCycleWithNoFilter {
//    QCloudPutBucketLifecycleRequest* request = [QCloudPutBucketLifecycleRequest new];
//    request.bucket = self.bucket;
//    __block QCloudLifecycleConfiguration* configuration = [[QCloudLifecycleConfiguration alloc] init];
//    QCloudLifecycleRule* rule = [[QCloudLifecycleRule alloc] init];
//    rule.identifier = @"identifier";
//    rule.status = QCloudLifecycleStatueEnabled;
//    QCloudLifecycleTransition* transition = [[QCloudLifecycleTransition alloc] init];
//    transition.days = 100;
//    transition.storageClass = QCloudCOSStorageNearline;
//    rule.transition = transition;
//    request.lifeCycle = configuration;
//    request.lifeCycle.rules = @[rule];
//    XCTestExpectation* exception = [self expectationWithDescription:@"Put Bucket Life cycle exception"];
//    [request setFinishBlock:^(id outputObject, NSError* putLifecycleError) {
//        XCTAssertNil(putLifecycleError);
//        [exception fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] PutBucketLifecycle:request];
//    [self waitForExpectationsWithTimeout:100 handler:nil];
//}



#pragma mark - bucket



////get bucket,bucket为空
//- (void)testGetEmptyBucket{
//    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
//    getBucket.bucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
//    XCTestExpectation* exception = [self expectationWithDescription:@"get empty bucket exception"];
//    __block NSError* responseError ;
//    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
//        //error occucs if error != nil
//        XCTAssertNil(error);
//        responseError = error;
//        [exception fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
//    [self waitForExpectationsWithTimeout:100 handler:nil];
//}

//get bucket，bucket不存在
- (void)testGetNotExistBucket{
    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
    getBucket.bucket = @"buncunzai930490";
    XCTestExpectation* exception = [self expectationWithDescription:@"get not Exist bucket exception"];
    __block NSError* responseError ;
    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNotNil(error);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

//get bucket,请求带prefix,但是prefix值为空，即prefix=
- (void)testGetBucketWithNilPrefix{
    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
    getBucket.bucket = self.bucket;
    getBucket.prefix = nil;
    XCTestExpectation* exception = [self expectationWithDescription:@"get bucket with empty Prefix exception"];
    __block NSError* responseError ;
    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

//get bucket，请求带prefix
- (void)testGetBucketWithPrefix{
    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
    getBucket.bucket = self.bucket;
    getBucket.prefix = @"tttt";
    XCTestExpectation* exception = [self expectationWithDescription:@"get bucket with Prefix exception"];
    __block NSError* responseError ;
    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}


// get bucket，请求参数带Encode-Type
- (void)testGetBucketWithEncodingType{
    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
    getBucket.bucket = self.bucket;
    getBucket.encodingType = @"url";
    XCTestExpectation* exception = [self expectationWithDescription:@"get bucket with Prefix exception"];
    __block NSError* responseError ;
    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

//get bucket，请求参数带Encode-Type，但是值为空
- (void)testGetBucketWithNilEncodingType{
    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
    getBucket.bucket = self.bucket;
    getBucket.encodingType = nil;
    XCTestExpectation* exception = [self expectationWithDescription:@"get bucket with Prefix exception"];
    __block NSError* responseError ;
    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

//get bucket，请求参数带delimiter,值为空
- (void)testGetBucketWithNilDelimiter{
    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
    getBucket.bucket = self.bucket;
    getBucket.delimiter = nil;
    XCTestExpectation* exception = [self expectationWithDescription:@"get bucket with Prefix exception"];
    __block NSError* responseError ;
    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

//get bucket，请求参数带delimiter,非空
- (void)testGetBucketWithDelimiter{
    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
    getBucket.bucket = self.bucket;
    getBucket.delimiter = @"";
    XCTestExpectation* exception = [self expectationWithDescription:@"get bucket with Prefix exception"];
    __block NSError* responseError ;
    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

//get bucket，请求参数带Marker，值为空
- (void)testGetBucketWithNilMarker{
    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
    getBucket.bucket = self.bucket;
    getBucket.marker = nil;
    XCTestExpectation* exception = [self expectationWithDescription:@"get bucket with Prefix exception"];
    __block NSError* responseError ;
    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        XCTAssertNotNil(outputObject);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

//get bucket，请求参数带Marker，非空
- (void)testGetBucketWithMarker{
    QCloudGetBucketRequest *getBucket = [QCloudGetBucketRequest new];
    getBucket.bucket = self.bucket;
    getBucket.marker = @"marker";
    XCTestExpectation* exception = [self expectationWithDescription:@"get bucket with Prefix exception"];
    __block NSError* responseError ;
    [getBucket setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        XCTAssertNotNil(outputObject);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucket:getBucket];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}




#pragma mark - bucket acl test

- (void)testPutBucktAclWithPrivate{
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    NSString* appID = kAppID;
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", appID, appID];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.accessControlList = @"private";
    putACL.grantFullControl = grantString;
    __block NSString* bucketName = self.bucket;
    putACL.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put bucket private acl exception"];
    __block NSError* responseError ;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}
- (void)testPutBucktAclWithPublicread{
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    NSString* appID = kAppID;
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", appID, appID];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.accessControlList = @"public-read";
    putACL.grantFullControl = grantString;
    __block NSString* bucketName = self.bucket;
    putACL.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put bucket public-read acl exception"];
    __block NSError* responseError ;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testPutBucktAclWithIllegal{
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    NSString* appID = kAppID;
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", appID, appID];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.accessControlList = @"public-write";
    putACL.grantFullControl = grantString;
    __block NSString* bucketName = self.bucket;
    putACL.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put bucket Illegal acl exception"];
    __block NSError* responseError ;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNotNil(error);
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}
- (void)testPutBucktAclWithIllegalGrant{
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    NSString* appID = kAppID;
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcsm::uin/%@:uin/%@", appID, appID];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.accessControlList = @"public-write";
    putACL.grantFullControl = grantString;
    __block NSString* bucketName = self.bucket;
    putACL.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put bucket Illegal grant acl exception"];
    __block NSError* responseError ;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNotNil(error);
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}
- (void)testPutBucktAclWithGrantWrite{
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    NSString* appID = kAppID;
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", appID, appID];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.grantWrite = grantString;
    __block NSString* bucketName = self.bucket;
    putACL.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put bucket grant-Write acl exception"];
    __block NSError* responseError ;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}
- (void)testPutBucktAclWithGrantRead{
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    NSString* appID = kAppID;
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", appID, appID];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.grantRead = grantString;
    __block NSString* bucketName = self.bucket;
    putACL.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put bucket grant-read acl exception"];
    __block NSError* responseError ;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testPutBucktAclWithGrantFullControl{
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    NSString* appID = kAppID;
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", appID, appID];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.grantFullControl = grantString;
    __block NSString* bucketName = self.bucket;
    putACL.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put bucket grant-full-control acl exception"];
    __block NSError* responseError ;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}
-(void)testPutBucktAclWithReadAndWriteAndGrantFullControl{
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    NSString* appID = kAppID;
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", appID, appID];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.grantFullControl = grantString;
    putACL.grantWrite = grantString;
    putACL.grantRead = grantString;
    __block NSString* bucketName = self.bucket;
    putACL.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put bucket read write grant-full-control acl exception"];
    __block NSError* responseError ;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNil(error);
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

// get bucket acl，bucket不存在
- (void)testGetACLForNotExistBucket{
    QCloudGetBucketACLRequest* getBucketACl   = [QCloudGetBucketACLRequest new];
    getBucketACl.bucket = @"wobuzaiai";
    XCTestExpectation* exception = [self expectationWithDescription:@"Get not exist bucket acl exception"];
    __block NSError* responseError ;
    [getBucketACl setFinishBlock:^(id outputObject, NSError *error) {
        //error occucs if error != nil
        XCTAssertNotNil(error);
        XCTAssert(error.code == 404,@"error code is not equal to 404,it is %lu",error.code);
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketACL:getBucketACl];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}


#pragma mark - head bucket
//head bucket，bucket不存在
-(void)testHeadNotBucket{
    XCTestExpectation* exception = [self expectationWithDescription:@"get bucket with Prefix exception"];
    QCloudHeadBucketRequest* request = [QCloudHeadBucketRequest new];
    request.bucket = @"bucnzia12343434";
    [request setFinishBlock:^(id outputObject, NSError* error) {
        //设置完成回调。如果没有error，则可以正常访问bucket。如果有error，可以从error code和messasge中获取具体的失败原因。
        XCTAssertNotNil(error);
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] HeadBucket:request];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

#pragma mark bucket location test
//正常get bucket location
- (void)testGetBucketLoaction {
    QCloudGetBucketLocationRequest* locationReq = [QCloudGetBucketLocationRequest new];
    locationReq.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"get bucket location"];
    __block QCloudBucketLocationConstraint* location;
    
    [locationReq setFinishBlock:^(QCloudBucketLocationConstraint * _Nonnull result, NSError * _Nonnull error) {
        location = result;
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketLocation:locationReq];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNotNil(location);
    NSString* currentLocation;
    currentLocation = kRegion;
    XCTAssert([location.locationConstraint isEqualToString:currentLocation]);
}

//bucket不存在，发送get bucket location请求
- (void)testGetNotExistBucketLoaction {
    QCloudGetBucketLocationRequest* locationReq = [QCloudGetBucketLocationRequest new];
    locationReq.bucket = @"bucunzai123425--222bb";
    XCTestExpectation* exp = [self expectationWithDescription:@"get not exist bucket location"];
    __block QCloudBucketLocationConstraint* location;
    
    [locationReq setFinishBlock:^(QCloudBucketLocationConstraint * _Nonnull result, NSError * _Nonnull error) {
        location = result;
        XCTAssertNotNil(error);
        XCTAssert(error.code == 404,"error.code not equal to 404 it is %lu",error.code);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketLocation:locationReq];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNil(location);
    NSString* currentLocation;
    
#ifdef CNNORTH_REGION
    currentLocation = @"ap-beijing-1";
#else
    currentLocation = @"ap-guangzhou";
#endif
    XCTAssert(![location.locationConstraint isEqualToString:currentLocation]);
}


#pragma mark - cors
//put bucket cors，cors规则包含多条
-(void)testPutBucketCors{
    QCloudPutBucketCORSRequest* putCORS = [QCloudPutBucketCORSRequest new];
    QCloudCORSConfiguration* cors = [QCloudCORSConfiguration new];
    QCloudCORSRule* rule1 = [QCloudCORSRule new];
    rule1.identifier = @"sdk";
    rule1.allowedHeader = @[@"origin",@"content-type",@"authorization"];
    rule1.exposeHeader = @"ETag";
    rule1.allowedMethod = @[@"GET",@"PUT",@"POST", @"DELETE", @"HEAD"];
    rule1.maxAgeSeconds = 3600;
    rule1.allowedOrigin = @"*";
    
    QCloudCORSRule* rule2 = [QCloudCORSRule new];
    rule2.identifier = @"sdk";
    rule2.allowedHeader = @[@"origin",@"host",@"accept",@"content-type",@"authorization"];
    rule2.exposeHeader = @"ETag";
    rule2.allowedMethod = @[@"GET", @"DELETE", @"HEAD"];
    rule2.maxAgeSeconds = 3600;
    rule2.allowedOrigin = @"*";
    
    QCloudCORSRule* rule3 = [QCloudCORSRule new];
    rule3.identifier = @"sdk";
    rule3.allowedHeader = @[@"origin",@"host",@"accept",@"content-type",@"authorization"];
    rule3.exposeHeader = @"ETag";
    rule3.allowedMethod = @[@"GET",@"PUT",@"POST", @"HEAD"];
    rule3.maxAgeSeconds = 3600;
    rule3.allowedOrigin = @"*";
    
    
    cors.rules = @[rule1,rule2,rule3];
    
    putCORS.corsConfiguration = cors;
    putCORS.bucket = self.bucket;
    __block NSError* localError;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    [putCORS setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(outputObject);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketCORS:putCORS];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertNil(localError);
}
//bucket不存在，发送get bucket cors
-(void)testGetNonExistenBucketcors{
    XCTestExpectation* exp = [self expectationWithDescription:@"get not exist bucket location"];
    QCloudGetBucketLocationRequest* locationReq = [QCloudGetBucketLocationRequest new];
    locationReq.bucket = @"bucunzai123333";
    __block QCloudBucketLocationConstraint* location;
    [locationReq setFinishBlock:^(QCloudBucketLocationConstraint * _Nonnull result, NSError * _Nonnull error) {
        XCTAssertNotNil(error);
        XCTAssert(error.code == 404,@"error.code != 404,it is %lu",error.code);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketLocation:locationReq];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}
@end
