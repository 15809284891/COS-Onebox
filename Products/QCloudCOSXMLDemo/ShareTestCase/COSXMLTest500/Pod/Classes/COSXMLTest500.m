//
//  COSXMLTest510.m
//  COSXMLBaseCommon
//
//  Created by karisli(李雪) on 2018/4/6.
//



#import "COSXMLTest500.h"
@implementation COSXMLTest500
+(void)tool{
    
}

- (void)setUp {
    [super setUp];
    [QCloudCOSTransferTests tool];
    [QCloudCOSXMLBucketTests tool];
    [QCloudCOSXMLDemoTests tool];
    [QCloudCOSXMLExceptionCoverage tool];;
    
}

- (void)tearDown {
    [super tearDown];

}



@end
