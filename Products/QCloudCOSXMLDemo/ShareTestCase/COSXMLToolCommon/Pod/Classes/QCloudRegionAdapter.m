//
//  QCloudRegionAdapter.m
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 15/03/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "QCloudRegionAdapter.h"

@implementation QCloudRegionAdapter

+ (NSString*) adapteRegionName:(NSString*)regionName {
     NSDictionary* regionNamePair = @{@"ap-beijing-1":@"cn-north",@"ap-guangzhou":@"cn-sourth",@"ap-shanghai":@"cn-east"};
    if (regionNamePair[regionName]) {
      return regionNamePair[regionName];
    } else {
        return regionName;
    }
}

+ (NSString*) adapterV4RegionNameToV5:(NSString*)region {
    NSDictionary* regionNamePair = @{@"tj":@"ap-beijing-1",@"gz":@"ap-guangzhou",@"sh":@"ap-shanghai"};
    if (regionNamePair[region]) {
        return regionNamePair[region];
    } else {
        return region;
    }
}
@end
