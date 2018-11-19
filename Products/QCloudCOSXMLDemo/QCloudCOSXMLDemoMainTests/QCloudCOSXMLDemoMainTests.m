//
//  QCloudCOSXMLDemoMainTests.m
//  QCloudCOSXMLDemoMainTests
//
//  Created by karisli(李雪) on 2018/3/30.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <COSXMLTest532/COSXMLTest532.h>
@interface QCloudCOSXMLDemoMainTests : XCTestCase

@end

@implementation QCloudCOSXMLDemoMainTests

- (void)setUp {
    [super setUp];
    [COSXMLTest532 tool];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)tearDown{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
