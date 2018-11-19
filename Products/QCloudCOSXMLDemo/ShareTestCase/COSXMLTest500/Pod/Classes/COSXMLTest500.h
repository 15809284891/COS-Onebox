//
//  COSXMLTest500.h
//  <POD_NAME
//
//  Created by tencent
//
//  QCloudTerminalLab --- service for developers
//  eamil: g_pdtc_storage_terminallab@tencent.com


#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <COSXMLToolCommon/COSXMLToolCommon.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
#import  "NSObject+QCloudModel.h"
#import "QCloudCOSAccountTypeEnum.h"
#import "QCloudCompleteMultipartUploadInfo.h"
#import "QCloudDeleteInfo.h"
#import "QCloudDeleteObjectInfo.h"
#import "QCloudListMultipartRequest.h"
#import "QCloudCompleteMultipartUploadRequest.h"
#import "QCloudAbortMultipfartUploadRequest.h"
#import "QCloudListMultipartUploadsResult.h"
#import "QCloudUploadPartRequest.h"
#import "QCloudAppendObjectRequest.h"
@interface COSXMLTest500 : XCTestCase 
+(void)tool;
@end


@interface QCloudCOSTransferTests : XCTestCase<QCloudSignatureProvider>
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSMutableArray* tempFilePathArray;
+(void)tool;
@end
@interface QCloudCOSXMLBucketTests : XCTestCase<QCloudSignatureProvider>
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSString* authorizedUIN;
@property (nonatomic, strong) NSString* ownerUIN;
@property (nonatomic, strong) NSString* appID;
+(void)tool;
@end

@interface QCloudCOSXMLDemoTests : XCTestCase <QCloudSignatureProvider>
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSString* appID;
@property (nonatomic, strong) NSString* ownerID;
@property (nonatomic, strong) NSString* authorizedUIN;
@property (nonatomic, strong) NSString* ownerUIN;
+(void)tool;
@end
@interface QCloudCOSXMLExceptionCoverage : XCTestCase
+(void)tool;
@end
