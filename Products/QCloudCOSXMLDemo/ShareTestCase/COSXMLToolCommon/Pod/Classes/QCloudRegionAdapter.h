//
//  QCloudRegionAdapter.h
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 15/03/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCloudRegionAdapter : NSObject

+ (NSString*) adapteRegionName:(NSString*)regionName;

+ (NSString*) bucketNameWithRegion:(NSString*)region;

@end
