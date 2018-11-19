//
//  COSXMLBaseCommon.h
//  <POD_NAME
//
//  Created by tencent
//
//  QCloudTerminalLab --- service for developers
//  eamil: g_pdtc_storage_terminallab@tencent.com




#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import "QCloudCoreVersion.h"
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <COSXMLToolCommon/COSXMLToolCommon.h>

#import <QCloudCore/QCloudCore.h>
#import "QCloudCOSXMLServiceUtilities.h"
#import "QCloudListMultipartRequest.h"


#import <QCloudCOSXML/QCloudCOSXMLService.h>
#define kHTTPServiceKey @"HTTPService"

@interface COSXMLBaseCommon : XCTestCase<QCloudSignatureProvider>
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSString* authorizedUIN;
@property (nonatomic, strong) NSString* ownerUIN;
@property (nonatomic, strong) NSString* appID;
@property (nonatomic, strong) NSMutableArray* tempFilePathArray;
+(void)tool;
@end
