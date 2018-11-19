//
//  COSXMLTest510.m
//  COSXMLCommon
//
//  Created by karisli(李雪) on 2018/4/5.
//

#import "COSXMLTest510.h"
#import "COSXMLCommon.h"
@implementation COSXMLTest510

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

+(void)tool{
    
}
@end
