//
//  COOSXMLBaseCommon.m
//  COSXMLBaseCommon
//
//  Created by karisli(李雪) on 2018/4/6.
//

#import "COSXMLBaseCommon.h"
#import "QCloudCOSXMLVersion.h"
@implementation COSXMLBaseCommon
+(void)tool{
    
}
//- (void) signatureWithFields:(QCloudSignatureFields*)fileds
//                     request:(QCloudBizHTTPRequest*)request
//                  urlRequest:(NSMutableURLRequest*)urlRequst
//                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
//{
//    QCloudCredential* credential = [QCloudCredential new];
//    credential.secretID = kSecretID;
//    credential.secretKey = kSecretKey;
//    QCloudAuthentationCreator* creator = [[QCloudAuthentationCreator alloc] initWithCredential:credential];
//    QCloudSignature* signature =  [creator signatureForCOSXMLRequest:request];
//    continueBlock(signature, nil);
//}
//
//- (void) setupSpecialCOSXMLShareService {
//    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
//    configuration.appID = kAppID;
//    configuration.signatureProvider = self;
//    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
//    endpoint.regionName = kRegion;
//    configuration.endpoint = endpoint;
//
//    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:@"aclService"];
//}



- (void)setUp {
    [super setUp];
    self.tempFilePathArray = [[NSMutableArray alloc] init];
    self.bucket = kTestBucket;
    self.appID = kAppID;
    self.authorizedUIN = @"543198902";
    self.ownerUIN = @"1278687956";
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

#pragma mark - bucket

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



#pragma mark - bucket




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

#pragma mark - demo


- (void) testRegisterCustomService
{
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1253653367";
    configuration.signatureProvider = self;
    
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";
    configuration.endpoint = endpoint;
    
    NSString* serviceKey = @"test";
    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:serviceKey];
    QCloudCOSXMLService* service = [QCloudCOSXMLService cosxmlServiceForKey:serviceKey];
    XCTAssertNotNil(service);
}

- (void) testGetACL {
    
    QCloudGetObjectACLRequest* request = [QCloudGetObjectACLRequest new];
    request.bucket = self.bucket;
    request.object =[self uploadTempObject];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    [request setFinishBlock:^(QCloudACLPolicy * _Nonnull policy, NSError * _Nonnull error) {
        XCTAssertNil(error);
        XCTAssertNotNil(policy);
        //        NSString* expectedIdentifier = [NSString identifierStringWithID:self.ownerID :self.ownerID];
        //        XCTAssert([policy.owner.identifier isEqualToString:expectedIdentifier]);
        //        XCTAssert(policy.accessControlList.count == 1);
        //        XCTAssert([[policy.accessControlList firstObject].grantee.identifier isEqualToString:[NSString identifierStringWithID:@"1278687956" :@"1278687956"]]);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetObjectACL:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
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
- (void) testDeleteObject
{
    NSString* object = [self uploadTempObject];
    QCloudDeleteObjectRequest* deleteObjectRequest = [QCloudDeleteObjectRequest new];
    deleteObjectRequest.bucket = self.bucket;
    deleteObjectRequest.object = object;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block NSError* localError;
    [deleteObjectRequest setFinishBlock:^(id outputObject, NSError *error) {
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteObject:deleteObjectRequest];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    
    XCTAssertNil(localError);
}



- (void) testDeleteObjects
{
    NSString* object1 = [self uploadTempObject];
    NSString* object2 = [self uploadTempObject];
    
    QCloudDeleteMultipleObjectRequest* delteRequest = [QCloudDeleteMultipleObjectRequest new];
    delteRequest.bucket = self.bucket;
    
    QCloudDeleteObjectInfo* object = [QCloudDeleteObjectInfo new];
    object.key = object1;
    
    QCloudDeleteObjectInfo* deleteObject2 = [QCloudDeleteObjectInfo new];
    deleteObject2.key = object2;
    
    QCloudDeleteInfo* deleteInfo = [QCloudDeleteInfo new];
    deleteInfo.quiet = NO;
    deleteInfo.objects = @[ object,deleteObject2];
    
    delteRequest.deleteObjects = deleteInfo;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block NSError* localError;
    __block QCloudDeleteResult* deleteResult = nil;
    [delteRequest setFinishBlock:^(QCloudDeleteResult* outputObject, NSError *error) {
        localError = error;
        deleteResult = outputObject;
        [exp fulfill];
    }];
    
    
    [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:delteRequest];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    
    XCTAssertNotNil(deleteResult);
    XCTAssertEqual(2, deleteResult.deletedObjects.count);
    QCloudDeleteResultRow* firstrow =  deleteResult.deletedObjects[0];
    QCloudDeleteResultRow* secondRow = deleteResult.deletedObjects[1];
    XCTAssert([firstrow.key isEqualToString:object1]);
    XCTAssert([secondRow.key isEqualToString:object2]);
    XCTAssertNil(localError);
    
}

- (void) testPutObject {
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket =self.bucket;
    put.body =  [@"1234jdjdjdjjdjdjyuehjshgdytfakjhsghgdhg" dataUsingEncoding:NSUTF8StringEncoding];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block NSError* resultError;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        resultError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    XCTAssertNil(resultError);
    QCloudDeleteObjectRequest* deleteObjectRequest = [[QCloudDeleteObjectRequest alloc] init];
    deleteObjectRequest.bucket = self.bucket;
    deleteObjectRequest.object = put.object;
    [[QCloudCOSXMLService defaultCOSXML] DeleteObject:deleteObjectRequest];
}




- (void) testInitMultipartUpload {
    QCloudInitiateMultipartUploadRequest* initrequest = [QCloudInitiateMultipartUploadRequest new];
    initrequest.bucket = self.bucket;
    initrequest.object = [NSUUID UUID].UUIDString;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudInitiateMultipartUploadResult* initResult;
    [initrequest setFinishBlock:^(QCloudInitiateMultipartUploadResult* outputObject, NSError *error) {
        initResult = outputObject;
        [exp fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] InitiateMultipartUpload:initrequest];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
    }];
    NSString* expectedBucketString = [NSString stringWithFormat:@"%@-%@",self.bucket,self.appID];
    //    XCTAssert([initResult.bucket isEqualToString:expectedBucketString]);
    XCTAssert([initResult.key isEqualToString:initrequest.object]);
    
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





- (void) testAppendObject {
    QCloudAppendObjectRequest* put = [QCloudAppendObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:1 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
    XCTestExpectation* exp = [self expectationWithDescription:@"append Object"];
    __block NSDictionary* result = nil;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] AppendObject:put];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    XCTAssertNotNil(result);
}




- (void) testLittleLimitAppendObject {
    QCloudAppendObjectRequest* put = [QCloudAppendObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:2 unit:QCLOUD_TEMP_FILE_UNIT_KB]];
    
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

- (void) testGetObject {
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    NSString* object =  [NSUUID UUID].UUIDString;
    put.object =object;
    put.bucket = self.bucket;
    NSURL* fileURL = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:3 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
    put.body = fileURL;
    
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudGetObjectRequest* request = [QCloudGetObjectRequest new];
    request.downloadingURL = [NSURL URLWithString:QCloudTempFilePathWithExtension(@"downding")];
    
    [put setFinishBlock:^(id outputObject, NSError *error) {
        request.bucket = self.bucket;
        request.object = object;
        
        [request setFinishBlock:^(id outputObject, NSError *error) {
            XCTAssertNil(error);
            [exp fulfill];
        }];
        [request setDownProcessBlock:^(int64_t bytesDownload, int64_t totalBytesDownload, int64_t totalBytesExpectedToDownload) {
            NSLog(@"⏬⏬⏬⏬DOWN [Total]%lld  [Downloaded]%lld [Download]%lld", totalBytesExpectedToDownload, totalBytesDownload, bytesDownload);
        }];
        [[QCloudCOSXMLService defaultCOSXML] GetObject:request];
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    XCTAssertEqual(QCloudFileSize(request.downloadingURL.path), QCloudFileSize(fileURL.path));
    
}

- (void)testGetObjectWithMD5Verification {
    
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    NSString* object =  [NSUUID UUID].UUIDString;
    put.object =object;
    put.bucket = self.bucket;
    NSURL* fileURL = [NSURL fileURLWithPath:[QClouldCreateTempFile tempFileWithSize:3 unit:QCLOUD_TEMP_FILE_UNIT_MB]];
    put.body = fileURL;
    
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudGetObjectRequest* request = [QCloudGetObjectRequest new];
    request.downloadingURL = [NSURL URLWithString:QCloudTempFilePathWithExtension(@"downding")];
    
    [put setFinishBlock:^(id outputObject, NSError *error) {
        request.bucket = self.bucket;
        request.object = object;
        //        request.enableMD5Verification = YES;
        [request setFinishBlock:^(id outputObject, NSError *error) {
            XCTAssertNil(error);
            [exp fulfill];
        }];
        [request setDownProcessBlock:^(int64_t bytesDownload, int64_t totalBytesDownload, int64_t totalBytesExpectedToDownload) {
            NSLog(@"⏬⏬⏬⏬DOWN [Total]%lld  [Downloaded]%lld [Download]%lld", totalBytesExpectedToDownload, totalBytesDownload, bytesDownload);
        }];
        [[QCloudCOSXMLService defaultCOSXML] GetObject:request];
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    XCTAssertEqual(QCloudFileSize(request.downloadingURL.path), QCloudFileSize(fileURL.path));
    
    
}




#pragma mark - object
- (void) testPutNilObject {
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    put.object = nil;
    put.bucket = self.bucket;
    put.body =  [@"1234jdjdjdjjdjdjyuehjshgdytfakjhsghgdhg" dataUsingEncoding:NSUTF8StringEncoding];
    XCTestExpectation* exp = [self expectationWithDescription:@"put nil object"];
    __block NSError* resultError;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNotNil(error);
        resultError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}
- (void) testPutExistObject {
    NSString *existObject = [self uploadTempObject];
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    put.object = existObject;
    put.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"put nil object"];
    __block NSError* resultError;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

//get object，object不存在
-(void)testGetNoExistObject{
    QCloudGetObjectRequest* request = [[QCloudGetObjectRequest alloc] init];
    request.bucket = self.bucket;
    request.object = @"bucnzaiooooo";
    XCTestExpectation* exp = [self expectationWithDescription:@"get not exist object"];
    [request setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNotNil(error);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetObject:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

//get object，请求参数带response-content-type
-(void)testGetObjectWithSetResponseContentType{
    
    QCloudGetObjectRequest* request = [[QCloudGetObjectRequest alloc] init];
    request.bucket = self.bucket;
    request.object = [self uploadTempObject];
    request.responseContentType = @"text/xml";
    XCTestExpectation* exp = [self expectationWithDescription:@"put nil object"];
    [request setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetObject:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}


//get object，object名称包含特殊字符
-(void)testGetObjectWithSpecial{
    QCloudPutObjectRequest * putRequst = [QCloudPutObjectRequest new];
    putRequst.bucket = self.bucket;
    __block NSString *objectName = [NSString stringWithFormat:@"objectcanbedelete%i**object",arc4random()%1000];
    __weak typeof (self)weakSelf = self;
    putRequst.object = objectName;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete not exist object"];
    [putRequst setFinishBlock:^(id outputObject, NSError *error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        XCTAssertNil(error);
        if (!error) {
            QCloudGetObjectRequest *getRequst = [QCloudGetObjectRequest new];
            getRequst.object = objectName;
            getRequst.bucket = strongSelf.bucket;
            [getRequst setFinishBlock:^(id outputObject, NSError *error) {
                XCTAssertNil(error);
                [exp fulfill];
            }];
            [[QCloudCOSXMLService defaultCOSXML]GetObject:getRequst];
        }else{
            [exp fulfill];
        }
    }];
    [[QCloudCOSXMLService defaultCOSXML]PutObject:putRequst];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

//get object，object包含特殊字符
-(void)testGetObjectContenWithSpecial{
    QCloudPutObjectRequest * putRequst = [QCloudPutObjectRequest new];
    putRequst.bucket = self.bucket;
    putRequst.body = [@"'→↓←→↖↗↙↘! \"#$%&\'()*+,-./0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~" dataUsingEncoding:NSUTF8StringEncoding];
    __block NSString *objectName = [NSString stringWithFormat:@"objectcanbedelete%i",arc4random()%1000];
    __weak typeof (self)weakSelf = self;
    putRequst.object = objectName;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete not exist object"];
    __block id resultObject;
    [putRequst setFinishBlock:^(id outputObject, NSError *error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        XCTAssertNil(error);
        if (!error) {
            QCloudGetObjectRequest *getRequst = [QCloudGetObjectRequest new];
            getRequst.object = objectName;
            getRequst.bucket = strongSelf.bucket;
            [getRequst setFinishBlock:^(id outputObject, NSError *error) {
                XCTAssertNil(error);
                XCTAssertNotNil(outputObject);
                resultObject = outputObject;
                [exp fulfill];
            }];
            [[QCloudCOSXMLService defaultCOSXML]GetObject:getRequst];
        }else{
            [exp fulfill];
        }
    }];
    [[QCloudCOSXMLService defaultCOSXML]PutObject:putRequst];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
}

//delete object,object不存在
-(void)testDeleteNoExistObjejct{
    QCloudDeleteObjectRequest* request = [[QCloudDeleteObjectRequest alloc] init];
    request.bucket = self.bucket;
    request.object = @"bucnzaiooooo";
    XCTestExpectation* exp = [self expectationWithDescription:@"delete not exist object"];
    [request setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteObject:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}


#pragma mark - head object

//head object，object上传时指定了cache-control
//-(void)testHeadObjectWithSetCacheControl{
//    XCTestExpectation* exp = [self expectationWithDescription:@"put object"];
//    QCloudPutObjectRequest *putObject = [QCloudPutObjectRequest new];
//    putObject.bucket = self.bucket;
//    putObject.body =  [@"4324ewr325" dataUsingEncoding:NSUTF8StringEncoding];
//    __block NSString *objectName = [NSString stringWithFormat:@"objectcanbedelete%i",arc4random()%1000];
//    putObject.object = objectName;
//    putObject.cacheControl = @"no-cache";
//    [putObject setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error);
//        if (!error) {
//            QCloudHeadObjectRequest* headerRequest = [QCloudHeadObjectRequest new];
//            headerRequest.object = objectName;
//            headerRequest.bucket = self.bucket;
//            __block id resultError;
//            [headerRequest setFinishBlock:^(NSDictionary* result, NSError *error) {
//                XCTAssertNil(error);
//                XCTAssertNotNil(result);
//                [exp fulfill];
//            }];
//
//            [[QCloudCOSXMLService defaultCOSXML] HeadObject:headerRequest];
//        }else {
//            [exp fulfill];
//        }
//    }];
//    [[QCloudCOSXMLService defaultCOSXML]PutObject:putObject];
//    [self waitForExpectationsWithTimeout:100 handler:nil];
//}


#pragma mark - multipart objects

//正常delete multiple objects
-(void)testDeleteMutipleObjects{
    
    NSString *obj1Name = [self uploadTempObject];
    NSString *obj2Name = [self uploadTempObject];
    NSString *obj3Name = [self uploadTempObject];
    
    QCloudDeleteMultipleObjectRequest* delteRequest = [QCloudDeleteMultipleObjectRequest new];
    delteRequest.bucket = self.bucket;
    
    QCloudDeleteObjectInfo* deletedObject0 = [QCloudDeleteObjectInfo new];
    deletedObject0.key = obj1Name;
    
    QCloudDeleteObjectInfo* deleteObject1 = [QCloudDeleteObjectInfo new];
    deleteObject1.key = obj2Name;
    
    QCloudDeleteObjectInfo* deleteObject2 = [QCloudDeleteObjectInfo new];
    deleteObject2.key = obj3Name;
    
    QCloudDeleteInfo* deleteInfo = [QCloudDeleteInfo new];
    deleteInfo.quiet = NO;
    deleteInfo.objects = @[ deletedObject0,deleteObject1,deleteObject2];
    
    delteRequest.deleteObjects = deleteInfo;
    
    XCTestExpectation* exception = [self expectationWithDescription:@"Delete mutiple bucket exception"];
    [delteRequest setFinishBlock:^(QCloudDeleteResult* outputObject, NSError *error) {
        XCTAssertNil(error);
        [exception fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:delteRequest];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}
//delete multiple objects,部分object不存在
-(void)testDeleteMutipleObjectsAndPartNotExist{
    
    QCloudDeleteMultipleObjectRequest* delteRequest = [QCloudDeleteMultipleObjectRequest new];
    delteRequest.bucket = self.bucket;
    
    QCloudDeleteObjectInfo* deletedObject1 = [QCloudDeleteObjectInfo new];
    deletedObject1.key =[self uploadTempObject];
    
    QCloudDeleteObjectInfo* deleteObject2 = [QCloudDeleteObjectInfo new];
    deleteObject2.key = @"wobuzaiaaaaaaaa121212";
    
    QCloudDeleteObjectInfo* deleteObject3 = [QCloudDeleteObjectInfo new];
    deleteObject3.key = [self uploadTempObject];
    
    QCloudDeleteObjectInfo* deleteObject4 = [QCloudDeleteObjectInfo new];
    deleteObject4.key = @"woyebuzaiaaa2222";
    
    QCloudDeleteInfo* deleteInfo = [QCloudDeleteInfo new];
    deleteInfo.quiet = NO;
    deleteInfo.objects = @[ deletedObject1,deleteObject2,deleteObject3,deleteObject4];
    
    delteRequest.deleteObjects = deleteInfo;
    
    XCTestExpectation* exception = [self expectationWithDescription:@"Delete mutiple bucket and part not exist exception"];
    [delteRequest setFinishBlock:^(QCloudDeleteResult* outputObject, NSError *error) {
        XCTAssertNil(error);
        [exception fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:delteRequest];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}
//get object acl，通过header方式设置公共权限为private
- (void) testPut_GetObjectACLWithPrivte
{
    QCloudPutObjectACLRequest* request = [QCloudPutObjectACLRequest new];
    __block NSString *testObject = [self uploadTempObject];
    request.object = testObject;
    request.bucket = self.bucket;
    request.accessControlList = @"private";
    XCTestExpectation* exp = [self expectationWithDescription:@"acl"];
    __block NSError* localError;
    [request setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        QCloudGetObjectACLRequest *getRequest = [QCloudGetObjectACLRequest new];
        getRequest.bucket = self.bucket;
        getRequest.object = testObject;
        [getRequest setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
            XCTAssertNil(error);
        }];
        [[QCloudCOSXMLService defaultCOSXML]GetObjectACL:getRequest];
        [exp fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] PutObjectACL:request];
    [self waitForExpectationsWithTimeout:1000 handler:nil];
    
}
////get object acl，通过header方式设置x-cos-grant-read权限
//- (void) testPut_GetObjectACLWithgrantread
//{
//    QCloudPutObjectACLRequest* request = [QCloudPutObjectACLRequest new];
//    __block NSString *testObject = [self uploadTempObject];
//    request.object = testObject;
//    request.bucket = self.bucket;
//    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@",@"1030872851", @"1030872851"];
//    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
//    request.grantRead= grantString;
//    XCTestExpectation* exp = [self expectationWithDescription:@"acl"];
//    __block NSError* localError;
//    [request setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error);
//        QCloudGetObjectACLRequest *getRequest = [QCloudGetObjectACLRequest new];
//        getRequest.bucket = self.bucket;
//        getRequest.object = testObject;
//        [getRequest setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
//            XCTAssertNil(error);
//        }];
//        [[QCloudCOSXMLService defaultCOSXML]GetObjectACL:getRequest];
//        [exp fulfill];
//    }];
//
//    [[QCloudCOSXMLService defaultCOSXML] PutObjectACL:request];
//    [self waitForExpectationsWithTimeout:1000 handler:nil];
//
//}
//
////get object acl，通过header方式设置x-cos-grant-write权限
//- (void) testPut_GetObjectACLWithgrantwrite
//{
//    QCloudPutObjectACLRequest* request = [QCloudPutObjectACLRequest new];
//    __block NSString *testObject = [self uploadTempObject];
//    request.object = testObject;
//    request.bucket = self.bucket;
//    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@",@"1030872851", @"1030872851"];
//    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
//    request.grantWrite = grantString;
//    XCTestExpectation* exp = [self expectationWithDescription:@"acl"];
//    __block NSError* localError;
//    [request setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error);
//        QCloudGetObjectACLRequest *getRequest = [QCloudGetObjectACLRequest new];
//        getRequest.bucket = self.bucket;
//        getRequest.object = testObject;
//        [getRequest setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
//            XCTAssertNil(error);
//        }];
//        [[QCloudCOSXMLService defaultCOSXML]GetObjectACL:getRequest];
//        [exp fulfill];
//    }];
//
//    [[QCloudCOSXMLService defaultCOSXML] PutObjectACL:request];
//    [self waitForExpectationsWithTimeout:1000 handler:nil];
//
//}
//
////get object acl，通过header方式设置x-cos-grant-full-control权限
//- (void) testPut_GetObjectACLWithgrantFullControl
//{
//    QCloudPutObjectACLRequest* request = [QCloudPutObjectACLRequest new];
//    __block NSString *testObject = [self uploadTempObject];
//    request.object = testObject;
//    request.bucket = self.bucket;
//    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@",@"1030872851", @"1030872851"];
//    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
//    request.grantFullControl = grantString;
//    XCTestExpectation* exp = [self expectationWithDescription:@"acl"];
//    __block NSError* localError;
//    [request setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error);
//        QCloudGetObjectACLRequest *getRequest = [QCloudGetObjectACLRequest new];
//        getRequest.bucket = self.bucket;
//        getRequest.object = testObject;
//        [getRequest setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
//            XCTAssertNil(error);
//        }];
//        [[QCloudCOSXMLService defaultCOSXML]GetObjectACL:getRequest];
//        [exp fulfill];
//    }];
//
//    [[QCloudCOSXMLService defaultCOSXML] PutObjectACL:request];
//    [self waitForExpectationsWithTimeout:1000 handler:nil];
//
//}
////get object acl，通过header方式设置所有权限
//- (void) testPut_GetObjectACLWithAll
//{
//    QCloudPutObjectACLRequest* request = [QCloudPutObjectACLRequest new];
//    __block NSString *testObject = [self uploadTempObject];
//    request.object = testObject;
//    request.bucket = self.bucket;
//    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@",@"1030872851", @"1030872851"];
//    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
//    request.grantFullControl = grantString;
//    request.grantWrite = grantString;
//    request.grantRead = grantString;
//    XCTestExpectation* exp = [self expectationWithDescription:@"acl"];
//    __block NSError* localError;
//    [request setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error);
//        QCloudGetObjectACLRequest *getRequest = [QCloudGetObjectACLRequest new];
//        getRequest.bucket = self.bucket;
//        getRequest.object = testObject;
//        [getRequest setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
//            XCTAssertNil(error);
//        }];
//        [[QCloudCOSXMLService defaultCOSXML]GetObjectACL:getRequest];
//        [exp fulfill];
//    }];
//
//    [[QCloudCOSXMLService defaultCOSXML] PutObjectACL:request];
//    [self waitForExpectationsWithTimeout:1000 handler:nil];
//
//}
-(void)testPutObjectWithSecertParamer{
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  [@"1234jdjdjdjjdjdjyuehjshgdytfakjhsghgdhg" dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    [put setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
}
@end
