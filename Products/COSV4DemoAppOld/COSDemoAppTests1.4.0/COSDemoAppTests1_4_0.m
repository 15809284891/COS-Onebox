//
//  COSDemoAppTests.m
//  COSDemoAppTests
//
//  Created by 贾立飞 on 16/8/23.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QCloudCore.h"
#import <QCloudCOSV4/COSTask.h>
#import <QCloudCOSV4/COSClient.h>
@interface COSDemoAppTests : XCTestCase
{
    NSString* _appId;
    NSString* _bucket;
}
@property (nonatomic, strong) COSClient* client;
@property (nonatomic, strong) NSString* sign;
@end

@implementation COSDemoAppTests

- (void)setUp {
    [super setUp];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"key" ofType:@"json"];
    NSData* jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    _appId = dict[@"appID"];
    _bucket = dict[@"bucket"];
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = dict[@"secretID"];
    credential.secretKey = dict[@"secretKey"];
    
    QCloudAuthentationV4Creator* creator = [[QCloudAuthentationV4Creator alloc] initWithCredential:credential];
    
    QCloudSignatureFields* fields = [QCloudSignatureFields new];
    fields.appID = _appId;
    fields.bucket = _bucket;
    
    QCloudSignature* sign = [creator signatureForData:fields];
    
    self.sign = sign.signature;
    if (dict[@"region"]) {
        _client = [[COSClient alloc] initWithAppId:_appId withRegion:dict[@"region"]];
    } else {
    _client = [[COSClient alloc] initWithAppId:_appId withRegion:@"sh"];
    }
    [_client openHTTPSrequset:NO];
}
- (NSString*) tempFileWithSize:(int64_t)size
{
    NSString* file4MBPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:file4MBPath]) {
        [[NSFileManager defaultManager] createFileAtPath:file4MBPath contents:[NSData data] attributes:nil];
    }
    NSFileHandle* handler = [NSFileHandle fileHandleForWritingAtPath:file4MBPath];
    int64_t aimMem = size;
    for (int64_t writedMem = 0; writedMem <= aimMem; ) {
        int64_t aimSlice = 512;
        aimSlice = MIN(aimSlice, aimMem - writedMem);
        if (aimSlice == 0) {
            break;
        }
        char* mem = (char* )malloc(sizeof(char)*aimSlice);
        NSData* data = [NSData dataWithBytes:mem length:aimSlice];
        [handler writeData:data];
        free(mem);
        writedMem += aimSlice;
    }
    [handler closeFile];
    return file4MBPath;
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) showFilePathInfos:(NSString*)path
{
    NSDictionary* dic = [[NSFileManager defaultManager] fileSystemAttributesAtPath:path];
    NSLog(@"ATTRIBHTES File Exist:%d", (int)[[NSFileManager defaultManager] fileExistsAtPath:path]);
    NSLog(@"ATTRIBUTES DIC:%@", dic);
    NSLog(@"ATTRIBUTES HANDLER:%@", [NSFileHandle fileHandleForReadingAtPath:path]);
}



- (void)testCreate_Get_List_Delete_directory {
    COSCreateDirCommand* createDirCommand = [[COSCreateDirCommand alloc] init];
    __block NSString* directoryName = @"testDirectory";
    createDirCommand.bucket = _bucket;
    createDirCommand.directory = directoryName;
    createDirCommand.sign = _sign;
    __weak typeof(self) weakSelf = self;
    XCTestExpectation* expectation = [self expectationWithDescription:@"Directory related"];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context) {
        XCTAssertNotNil(resp,@"creating directory returns nil");
        XCTAssert(resp.retCode == 0,@"creating directory ret code is not equal to zero, it is %llu actually.",resp.retCode);
        [expectation fulfill];
    };
    [self.client createDir:createDirCommand];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    //
    //    COSListDirCommand* listDirectoryCommand = [[COSListDirCommand alloc] init];
    //    listDirectoryCommand.bucket = _bucket;
    //    listDirectoryCommand.num = 100;
    //    listDirectoryCommand.sign = _sign;
    //    listDirectoryCommand.directory = directoryName;
    //    XCTestExpectation* listExpectation = [self expectationWithDescription:@"Directory related"];
    //
    //    weakSelf.client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context) {
    //        XCTAssertNotNil(resp,@"listing directory returns nil");
    //        XCTAssert(resp.retCode == 0,@"listing directory ret code is not equal to zero, it is %llu actually.",resp.retCode);
    //        [listExpectation fulfill];
    //    };
    //    [weakSelf.client listDir:listDirectoryCommand];
    //    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    
    
    
    COSDeleteDirCommand* deleteDirectoryCommand = [[COSDeleteDirCommand alloc] init];
    deleteDirectoryCommand.bucket = _bucket;
    deleteDirectoryCommand.directory = directoryName;
    deleteDirectoryCommand.sign = _sign;
    XCTestExpectation* deleteExpectation = [self expectationWithDescription:@"Delete Directory"];
    
    
    weakSelf.client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context) {
        XCTAssertNotNil(resp,@"deleting directory returns nil");
        XCTAssert(resp.retCode == 0,@"delete diretroy ret code is not equal to zero, it is %llu actually.",resp.retCode);
        [deleteExpectation fulfill];
    };
    [weakSelf.client removeDir:deleteDirectoryCommand];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
}




- (void)testPut_Get_DeleteSimpleObject {
    
    NSString* path = [self tempFileWithSize:(int64_t)1024*1024*1];
    __block double progress = 0.0f;
    COSObjectPutTask *task = [[COSObjectPutTask alloc] init];
    task.multipartUpload = YES;
    
    task.filePath = path;
    task.fileName = [NSString stringWithFormat:@"测试%@",[NSUUID UUID].UUIDString];
    task.directory = @"sdf";
    task.bucket = _bucket;
    task.attrs = @"customAttribute";
    task.insertOnly = YES;
    task.multipartUpload = YES;
    task.sign = _sign;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block COSObjectUploadTaskRsp* response = nil;
    _client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
        response = rsp;
        if (rsp.retCode == 0) {
            NSLog(@"sourceURL = %@",rsp.sourceURL);
            NSLog(@"https = %@",rsp.httpsURL);
        }else{
            
        }
        [exp fulfill];
    };
    _client.progressHandler = ^(int64_t bytesWritten,int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite){
        progress = (double)totalBytesWritten/totalBytesExpectedToWrite;
        NSLog(@"进度展示：bytesWritten %0.2f",(float)totalBytesWritten/totalBytesExpectedToWrite);
    };
    [_client putObject:task];
    [self waitForExpectationsWithTimeout:600 handler:^(NSError * _Nullable error) {
        XCTAssert(response.retCode == 0);
        XCTAssertNotNil(response.acessURL);
        XCTAssertNotNil(response.sourceURL);
        //        XCTAssertNotNil(response.objectURL);        NSLog(@"%@ %@",response.acessURL, response.httpsURL);
    }];
    
    
    //    XCTestExpectation* getObjectExpectation = [self expectationWithDescription:@"getObjectExpectation"];
    //    COSObjectGetTask* getObjectRequset = [[COSObjectGetTask alloc] initWithUrl:response.objectURL];
    //    self.client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context) {
    //        XCTAssert(resp.retCode == 0,@"get object ret code is not equal to zero! response retcode is %d",resp.retCode);
    //        COSGetObjectTaskRsp* getObjectResponse = (COSGetObjectTaskRsp*)resp;
    //        XCTAssertNotNil(getObjectResponse.object,@"get object success but no file data downloaded!");
    //        [getObjectExpectation fulfill];
    //    };
    //    [self.client getObject:getObjectRequset];
    //    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    XCTestExpectation* deleteObjectExpectation = [self expectationWithDescription:@"getObjectExpectation"];
    COSObjectDeleteCommand* delete = [[COSObjectDeleteCommand alloc] init];
    delete.bucket = _bucket;
    delete.directory = task.directory;
    delete.fileName = task.fileName;
    delete.sign = _sign;
    self.client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context) {
        XCTAssert(resp.retCode == 0,@"delete object ret code is not equal to zero! response retcode is %d",resp.retCode);
        [deleteObjectExpectation fulfill];
    };
    [_client deleteObject:delete];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
}




- (void)testUpload_deleteChineseFileNameFile {
    
    NSString* path = [self tempFileWithSize:(int64_t)1024*1024*20];
    NSDate* dateBegin = [NSDate date];
    
    /*第二种初始化的方式*/
    COSObjectPutTask *task = [[COSObjectPutTask alloc] init];
    task.multipartUpload = YES;
    
    task.filePath = path;
    task.fileName = [NSString stringWithFormat:@"测试%@",[NSUUID UUID]];
    task.directory = @"sdf";
    task.bucket = _bucket;
    task.attrs = @"customAttribute";
    task.insertOnly = YES;
    task.multipartUpload = YES;
    
    task.sign = _sign;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block COSObjectUploadTaskRsp* response = nil;
    _client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
        response = rsp;
        if (rsp.retCode == 0) {
            NSLog(@"sourceURL = %@",rsp.sourceURL);
            NSLog(@"https = %@",rsp.httpsURL);
        }else{
            
        }
        [exp fulfill];
    };
    _client.progressHandler = ^(int64_t bytesWritten,int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite){
        NSLog(@"进度展示：bytesWritten %0.2f",(float)totalBytesWritten/totalBytesExpectedToWrite);
    };
    [_client putObject:task];
    [self waitForExpectationsWithTimeout:900 handler:^(NSError * _Nullable error) {
        
    }];
    XCTAssert(response.retCode == 0,@"upload chinese name big file fail! ret code returned is %d",response.retCode);
    XCTAssertNotNil(response.acessURL);
    XCTAssertNotNil(response.sourceURL);
    //    XCTAssertNotNil(response.objectURL);
    NSLog(@"%@ %@",response.acessURL, response.httpsURL);
    NSLog(@"SPEND TIME: %f", [[NSDate date] timeIntervalSinceDate:dateBegin]);
    XCTestExpectation* deleteExpectation = [self expectationWithDescription:@"delete object"];
    
    
    COSObjectDeleteCommand* delete = [[COSObjectDeleteCommand alloc] init];
    delete.bucket = _bucket;
    delete.directory = task.directory;
    delete.fileName = task.fileName;
    delete.sign = _sign;
    self.client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context) {
        XCTAssert(resp.retCode == 0, @"delete file with chinese name failed! ret code is %d",resp.retCode);
        [deleteExpectation fulfill];
    };
    [_client deleteObject:delete];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}



- (void)testGetFileAttribute {
    COSObjectPutTask* putObjectRequest = [[COSObjectPutTask alloc] init];
    putObjectRequest.bucket = _bucket;
    putObjectRequest.fileName = [NSUUID UUID].UUIDString;
    putObjectRequest.sign = _sign;
    putObjectRequest.filePath = [self tempFileWithSize:(int64_t)1024*1024*1];
    __block NSString* customAttributes = @"CustomAttributes";
    putObjectRequest.attrs = customAttributes;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context) {
        COSObjectUploadTaskRsp* response = resp;
        XCTAssert(response.retCode == 0,@"upload file fail! ret code is %d",response.retCode);
        dispatch_semaphore_signal(semaphore);
    };
    dispatch_semaphore_wait(semaphore,10*NSEC_PER_SEC);
}

//- (void)testUpdateFileAttribute {
//
//}
//
//- (void)testCopyFile {
//
//
//}


- (void) listAllItemsByDirctory:(NSString*)dirPath
{
    NSString *path=dirPath;
    
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator;
    
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:path];
    
    //列举目录内容，可以遍历子目录
    NSLog(@"用enumeratorAtPath:显示目录%@的内容：",path);
    while((path=[myDirectoryEnumerator nextObject])!=nil)
    {
        NSLog(@"%@",path);
    }
}




- (void)testUploadFileWithMultipleSlash
{
    
    NSString* path = [self tempFileWithSize:(int64_t)1024*1024*5];
    NSDate* dateBegin = [NSDate date];
    
    /*第二种初始化的方式*/
    COSObjectPutTask *task = [[COSObjectPutTask alloc] init];
    task.multipartUpload = YES;
    
    task.filePath = path;
    task.fileName = [NSString stringWithFormat:@"测试%@",[NSUUID UUID].UUIDString];
    task.directory = @"/sdf/";
    task.bucket = _bucket;
    task.attrs = @"customAttribute";
    task.insertOnly = YES;
    task.multipartUpload = YES;
    
    task.sign = _sign;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block COSObjectUploadTaskRsp* response = nil;
    _client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
        response = rsp;
        if (rsp.retCode == 0) {
            NSLog(@"sourceURL = %@",rsp.sourceURL);
            NSLog(@"https = %@",rsp.httpsURL);
        }else{
            
        }
        [exp fulfill];
    };
    _client.progressHandler = ^(int64_t bytesWritten,int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite){
        NSLog(@"进度展示：bytesWritten %0.2f",(float)totalBytesWritten/totalBytesExpectedToWrite);
    };
    [_client putObject:task];
    [self waitForExpectationsWithTimeout:1000 handler:^(NSError * _Nullable error) {
        
    }];
    XCTAssert(response.retCode == 0);
    XCTAssertNotNil(response.acessURL);
    XCTAssertNotNil(response.sourceURL);
    //    XCTAssertNotNil(response.objectURL);
    NSLog(@"%@ %@",response.acessURL, response.httpsURL);
    NSLog(@"SPEND TIME: %f", [[NSDate date] timeIntervalSinceDate:dateBegin]);
    COSObjectDeleteCommand* delete = [[COSObjectDeleteCommand alloc] init];
    delete.bucket = _bucket;
    delete.fileName = task.fileName;
    delete.sign = _sign;
    [_client deleteObject:delete];
}

- (void)testUpdateDirectoryAttribute {
    COSUpdateDirCommand* command = [[COSUpdateDirCommand alloc] init];
    command.bucket = _bucket;
    command.directory = @"dir3";
    command.attrs = @"testtest";
    command.sign = _sign;
    XCTestExpectation* expecation = [self expectationWithDescription:@"update command"];
    _client.completionHandler = ^(COSTaskRsp* response, NSDictionary* context) {
        XCTAssertNotNil(response);
        XCTAssert(response.retCode >= 0,@"ret code is not equal to zero! it is %d actually",response.retCode);
        [expecation fulfill];
    };
    [_client updateDir:command];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

//- (void) testCancel
//{
//    NSString* path = [self tempFileWithSize:(int64_t)1024*1024*10];
//
//    /*第二种初始化的方式*/
//    COSObjectPutTask *task = [[COSObjectPutTask alloc] init];
//    task.multipartUpload = YES;
//
//    task.filePath = path;
//    task.fileName = path.lastPathComponent;
//    task.directory = @"sdf";
//    task.bucket = _bucket;
//    task.attrs = @"customAttribute";
//    task.insertOnly = YES;
//    task.multipartUpload = YES;
//
//    task.sign = _sign;
//    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
//
//    __block COSObjectUploadTaskRsp* response = nil;
//    _client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
//        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
//        response = rsp;
//        if (rsp.retCode == 0) {
//            NSLog(@"sourceURL = %@",rsp.sourceURL);
//            NSLog(@"https = %@",rsp.httpsURL);
//        }else{
//
//        }
//        [exp fulfill];
//    };
//    _client.progressHandler = ^(int64_t bytesWritten,int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite){
//        NSLog(@"进度展示：bytesWritten %0.2f",(float)totalBytesWritten/totalBytesExpectedToWrite);
//    };
//    [_client putObject:task];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_client cancel:task.taskId];
//    });
//    [self waitForExpectationsWithTimeout:400 handler:^(NSError * _Nullable error) {
//
//    }];
//    XCTAssert(response.retCode == 0);
//
//}

- (void)testDownloadExistedFile {
    COSObjectGetTask* downloadObjectTask = [[COSObjectGetTask alloc] initWithUrl:@"http://v4-test-bucket-1253653367.cossh.myqcloud.com/2017100413565200-F1C11A22FAEE3B82F21B330E1B786A39.JPG"];
    __block id objectDownloaded;
    XCTestExpectation* exp = [self expectationWithDescription:@"download exist file"];
    _client.completionHandler = ^(COSTaskRsp* response, NSDictionary* outputObject) {
        COSGetObjectTaskRsp* getObjectResponse = (COSGetObjectTaskRsp*)response;
        objectDownloaded = getObjectResponse.object;
        [exp fulfill];
    };
    [_client getObject:downloadObjectTask];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNotNil(objectDownloaded);
}


- (void)testDownloadNotFoundFile {
    COSObjectGetTask* downloadObjectTask = [[COSObjectGetTask alloc] initWithUrl:@"http://tjtest-1253653367.costj.myqcloud.com/notfounndnotfoundblablablablala"];
    __block id objectDownloaded;
    XCTestExpectation* exp = [self expectationWithDescription:@"download exist file"];
    _client.completionHandler = ^(COSTaskRsp* response, NSDictionary* outputObject) {
        COSGetObjectTaskRsp* getObjectResponse = (COSGetObjectTaskRsp*)response;
        XCTAssert(response.retCode == -46629,@"Download not exist object response with code that is different from 404, it is %d actually",response.retCode);
        objectDownloaded = getObjectResponse.object;
        [exp fulfill];
    };
    [_client getObject:downloadObjectTask];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNil(objectDownloaded);
}

//- (void)testDownloadJSONContentFile {
//    COSObjectGetTask* downloadObjectTask = [[COSObjectGetTask alloc] initWithUrl:@"http://v4-test-bucket-1253653367.cossh.myqcloud.com/JSONFile"];
//    __block id objectDownloaded;
//    XCTestExpectation* exp = [self expectationWithDescription:@"download exist file"];
//    _client.completionHandler = ^(COSTaskRsp* response, NSDictionary* outputObject) {
//        COSGetObjectTaskRsp* getObjectResponse = (COSGetObjectTaskRsp*)response;
//        objectDownloaded = getObjectResponse.object;
//        [exp fulfill];
//    };
//    [_client getObject:downloadObjectTask];
//    [self waitForExpectationsWithTimeout:100 handler:nil];
//    XCTAssertNotNil(objectDownloaded);
//}

@end

