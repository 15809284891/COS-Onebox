//
//  QCloudCOSXMLDemoTests.m
//  QCloudCOSXMLDemoTests
//
//  Created by Dong Zhao on 2017/2/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//



#import "COSXMLTest500.h"


@implementation QCloudCOSXMLDemoTests
+(void)tool{
    
}
- (void)signatureWithFields:(QCloudSignatureFields *)fileds request:(QCloudBizHTTPRequest *)request urlRequest:(NSMutableURLRequest *)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock {
    
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = @"AKIDTmqfJivoU6XllcsfroX3KNBl7JGzvt0s";
    credential.secretKey = @"mR1eJvUvKi2EDyWu40kHZdYJrBHApGUV";
    QCloudAuthentationCreator* creator = [[QCloudAuthentationCreator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForCOSXMLRequest:request];
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


//+ (void)setUp {
//    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
//
//}
//
//
//+ (void)tearDown {
//    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestBuckets];
//}

- (void)setUp {
    [super setUp];
    [self setupSpecialCOSXMLShareService];
    
    self.appID =  kAppID;
    self.ownerID = @"1278687956";
    self.authorizedUIN = @"543198902";
    self.ownerUIN = @"1278687956";
//    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
//    self.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    self.bucket = kTestBucket;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [[QCloudCOSXMLTestUtility sharedInstance] deleteTestBucket:self.bucket];
    [super tearDown];
}



//- (void)deleteTestBucket {
//
//    XCTestExpectation* exception = [self expectationWithDescription:@"Delete bucket exception"];
//
//    QCloudGetBucketRequest* request = [[QCloudGetBucketRequest alloc] init];
//    request.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
//    request.maxKeys = 500;
//    [request setFinishBlock:^(QCloudListBucketResult* result, NSError* error) {
//
//        QCloudDeleteMultipleObjectRequest* deleteMultipleObjectRequest =  [[QCloudDeleteMultipleObjectRequest alloc] init];
//        deleteMultipleObjectRequest.bucket  = [QCloudTestTempVariables sharedInstance].testBucket;
//        deleteMultipleObjectRequest.deleteObjects = [[QCloudDeleteInfo alloc] init];
//        NSMutableArray* deleteObjectInfoArray = [NSMutableArray array];
//        deleteMultipleObjectRequest.deleteObjects.objects = deleteObjectInfoArray;
//        for (QCloudBucketContents* content in result.contents) {
//            QCloudDeleteObjectInfo* info = [[QCloudDeleteObjectInfo alloc] init];
//            info.key = content.key;
//            [deleteObjectInfoArray addObject:info];
//        }
//        [deleteMultipleObjectRequest setFinishBlock:^(QCloudDeleteResult* result, NSError* error) {
//            if (!error) {
//                QCloudDeleteBucketRequest* deleteBucketRequest = [[QCloudDeleteBucketRequest alloc] init];
//                deleteBucketRequest.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
//                [[QCloudCOSXMLService  defaultCOSXML] DeleteBucket:deleteBucketRequest];
//            } else {
//                QCloudLogDebug(error.description);
//            }
//            [exception fulfill];
//        }];
//        [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:deleteMultipleObjectRequest];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
//
//    [self waitForExpectationsWithTimeout:100 handler:nil];
//
//}

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





- (void) testAppendObject {
    QCloudAppendObjectRequest* put = [QCloudAppendObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  [NSURL fileURLWithPath:[self tempFileWithSize:1024*1024*1]];
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

- (void) testGetObject {
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    NSString* object =  [NSUUID UUID].UUIDString;
    put.object =object;
    put.bucket = self.bucket;
    NSURL* fileURL = [NSURL fileURLWithPath:[self tempFileWithSize:1024*1024*3]];
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
    NSURL* fileURL = [NSURL fileURLWithPath:[self tempFileWithSize:1024*1024*3]];
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


//- (void)testPutObjectCopy {
//    NSString* copyObjectSourceName = [NSUUID UUID].UUIDString;
//    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
//    put.object = copyObjectSourceName;
//    put.bucket = self.bucket;
//    put.body =  [@"4324ewr325" dataUsingEncoding:NSUTF8StringEncoding];
//    __block XCTestExpectation* exception = [self expectationWithDescription:@"Put Object Copy Exception"];
//    __block NSError* putObjectCopyError;
//    __block NSError* resultError;
//    __block QCloudCopyObjectResult* copyObjectResult;
//    [put setFinishBlock:^(id outputObject, NSError *error) {
//        NSURL* serviceURL = [[QCloudCOSXMLService defaultCOSXML].configuration.endpoint serverURLWithBucket:self.bucket appID:self.appID];
//        NSMutableString* objectCopySource = [serviceURL.absoluteString mutableCopy] ;
//        [objectCopySource appendFormat:@"/%@",copyObjectSourceName];
//        objectCopySource = [[objectCopySource substringFromIndex:7] mutableCopy];
//        QCloudPutObjectCopyRequest* request = [[QCloudPutObjectCopyRequest alloc] init];
//        request.bucket = self.bucket;
//        request.object = [NSUUID UUID].UUIDString;
//        request.objectCopySource = objectCopySource;
//
//        [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
//            putObjectCopyError = result;
//            resultError = error;
//            [exception fulfill];
//        }];
//        [[QCloudCOSXMLService defaultCOSXML] PutObjectCopy:request];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
//    [self waitForExpectationsWithTimeout:100 handler:nil];
//    XCTAssertNil(resultError);
//
//}


//- (void)testMultiplePutObjectCopy {
//    QCloudCOSXMLCopyObjectRequest* request = [[QCloudCOSXMLCopyObjectRequest alloc] init];
//    request.bucket = self.bucket;
//    request.object = @"copy-result-test";
//    request.sourceBucket = @"xy3";
//    request.sourceObject = @"Frameworks.zip";
//    request.sourceAPPID = [QCloudCOSXMLService defaultCOSXML].configuration.appID;
//    request.sourceRegion= @"ap-guangzhou";
//    
//    XCTestExpectation* expectation = [self expectationWithDescription:@"Put Object Copy"];
//    [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
//        XCTAssertNil(error);
//        [expectation fulfill];
//    }];
//    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] CopyObject:request];
//    [self waitForExpectationsWithTimeout:10000 handler:nil];
//    
//    
//}

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


//- (void)testGetObjectURL {
//    NSString* objectDownloadURL = [[QCloudCOSXMLService defaultCOSXML] getURLWithBucket:@"ios-v2-test" object:@"005HSIzAjw1f9lpbftcy0j31hc0xct9m.jpg" withAuthorization:YES];
//    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:objectDownloadURL]];
//    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
//    XCTestExpectation* expectation = [self expectationWithDescription:@"get object url"];
//    [[[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        XCTAssertNil(error);
//        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
//        XCTAssert(statusCode>199&&statusCode<300,@"StatusCode not equal to 2xx! statu code is %ld, response is %@",(long)statusCode,response);
//        XCTAssert(QCloudFileExist(location.path),@"File not exist!");
//        [expectation fulfill];
//    }] resume];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//}

//- (void)testGetPresignedURL {
//    QCloudGetPresignedURLRequest* getPresignedURLRequest = [[QCloudGetPresignedURLRequest alloc] init];
//    getPresignedURLRequest.bucket = @"ios-v2-test";
//    getPresignedURLRequest.object = @"005HSIzAjw1f9lpbftcy0j31hc0xct9m.jpg";
//    getPresignedURLRequest.HTTPMethod = @"GET";
//    XCTestExpectation* expectation = [self expectationWithDescription:@"GET PRESIGNED URL"];
//    [getPresignedURLRequest setFinishBlock:^(QCloudGetPresignedURLResult *result, NSError *error) {
//        XCTAssertNil(error,@"error occured in getting presigned URL ! details:%@",error);
//        XCTAssertNotNil(result.presienedURL,@"presigned url is nil!");
//        NSString* objectDownloadURL = result.presienedURL;
//        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:objectDownloadURL]];
//        [request setHTTPMethod:@"GET"];
//        [[[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            XCTAssertNil(error);
//            NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
//            XCTAssert(statusCode>199&&statusCode<300,@"StatusCode not equal to 2xx! statu code is %ld, response is %@",(long)statusCode,response);
//            XCTAssert(QCloudFileExist(location.path),@"File not exist!");
//            [expectation fulfill];
//        }] resume];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] getPresignedURL:getPresignedURLRequest];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//}
//



//- (void)testListObjectVersions {
//    QCloudPutBucketVersioningRequest* putBucketVersioningRequest = [[QCloudPutBucketVersioningRequest alloc] init];
//    putBucketVersioningRequest.bucket = self.bucket;
//    putBucketVersioningRequest.configuration = [[QCloudBucketVersioningConfiguration alloc] init];
//    putBucketVersioningRequest.configuration.status = QCloudCOSBucketVersioningStatusEnabled;
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    [putBucketVersioningRequest setFinishBlock:^(id outputObject, NSError *error) {
//        dispatch_semaphore_signal(semaphore);
//    }];
//    NSString* tempObject = [self uploadTempObject];
//    NSString* tempObject2 = [self uploadTempObject];
//    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:putBucketVersioningRequest];
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    XCTestExpectation* expectation = [self expectationWithDescription:@"haha"];
//
//
//    QCloudListObjectVersionsRequest* listObjectRequest = [[QCloudListObjectVersionsRequest alloc] init];
//    listObjectRequest.maxKeys = 100;
//    listObjectRequest.bucket = self.bucket;
//    [listObjectRequest setFinishBlock:^(QCloudListVersionsResult * _Nonnull result, NSError * _Nonnull error) {
//        XCTAssertNil(error);
//        XCTAssertNotNil(result);
//
//        [expectation fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] ListObjectVersions:listObjectRequest];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//    putBucketVersioningRequest.configuration.status = QCloudCOSBucketVersioningStatusSuspended;
//    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:putBucketVersioningRequest];
//}

#pragma mark - karis


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

//head object，object包含x-cos-meta元数据\put object，请求头部携带自定义头部x-cos-meta-，该版本没有customHeaders属性
//-(void)testPutObjectWithSetMetaAndHeadObject{
//    XCTestExpectation* exp = [self expectationWithDescription:@"put object"];
//    QCloudPutObjectRequest *putObject = [QCloudPutObjectRequest new];
//    putObject.bucket = self.bucket;
//    putObject.body =  [@"4324ewr325" dataUsingEncoding:NSUTF8StringEncoding];
//    putObject.customHeaders = @{@"x-cos-meta":@"metaTest"};
//    __block NSString *objectName = [NSString stringWithFormat:@"objectcanbedelete%i",arc4random()%1000];
//    putObject.object = objectName;
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
//
////head object，object元数据x-cos-meta长度达到2K
//-(void)testHeadObjectWithSetMetaIsOver{
//    XCTestExpectation* exp = [self expectationWithDescription:@"put object"];
//    QCloudPutObjectRequest *putObject = [QCloudPutObjectRequest new];
//    putObject.bucket = self.bucket;
//    putObject.body =  [@"4324ewr325" dataUsingEncoding:NSUTF8StringEncoding];
//    NSMutableString *str = [NSMutableString string];
//    for (int i = 0; i<10000; i++) {
//        [str appendString:@"hello"];
//    }
//    putObject.customHeaders = @{@"x-cos-meta":str};
//    __block NSString *objectName = [NSString stringWithFormat:@"objectcanbedelete%i",arc4random()%1000];
//    putObject.object = objectName;;
//    [putObject setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNotNil(error);
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





////upload part copy，请求指定Range------该版本没有这个类
//- (void)testMultiplePutObjectCopyWithSameRegion {
//
//    QCloudPutObjectRequest * putRequst = [QCloudPutObjectRequest new];
//    putRequst.bucket = self.bucket;
//    __block NSString *objectName = [NSString stringWithFormat:@"objectcanbedelete%i**object",arc4random()%1000];
//    __weak typeof (self)weakSelf = self;
//    putRequst.object = objectName;
//    putRequst.body =  [NSURL fileURLWithPath:[self tempFileWithSize:5*1024*1024]];
//    XCTestExpectation* exp = [self expectationWithDescription:@"part copy object from the same region"];
//    [putRequst setFinishBlock:^(id outputObject, NSError *error) {
//        __strong typeof(weakSelf)strongSelf = weakSelf;
//        XCTAssertNil(error);
//        if (!error) {
//            QCloudCOSXMLCopyObjectRequest* request = [[QCloudCOSXMLCopyObjectRequest alloc] init];
//            request.bucket = [[QCloudCOSXMLTestUtility sharedInstance]createTestBucket];
//            request.object = @"copy-result-test";
//            request.sourceBucket = strongSelf.bucket;
//            request.sourceObject = objectName;
//            request.sourceAPPID = kAppID;
//            request.sourceRegion= kRegion;
//            [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
//                XCTAssertNil(error);
//                [exp fulfill];
//            }];
//            [[QCloudCOSTransferMangerService defaultCOSTransferManager] CopyObject:request];
//        }else{
//            [exp fulfill];
//        }
//    }];
//    [[QCloudCOSXMLService defaultCOSXML]PutObject:putRequst];
//    [self waitForExpectationsWithTimeout:1000 handler:nil];
//
//
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
