//
//  COSXMLTest513.m
//  COSXMLCommon
//
//  Created by karisli(李雪) on 2018/4/5.
//

#import "COSXMLTest513.h"
#import "COSXMLCommon.h"
@implementation COSXMLTest513

+ (void)setUp {
    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
    
}


+ (void)tearDown {
    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestObjects];
    [[QCloudCOSXMLTestUtility sharedInstance]deleteTestBucket: [QCloudTestTempVariables sharedInstance].testBucket];
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
+(void)tool{
    
}
@end
