//
//  Congfig.h
//  COSDemoApp
//
//  Created by 贾立飞 on 16/9/12.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Congfig : NSObject

@property (nonatomic,strong)  NSString * appid;
@property (nonatomic, strong) NSString   *bucket;
@property (nonatomic, strong) NSString   *dir;

@property (nonatomic, strong) NSString   *region;
@property (nonatomic, strong) NSString   *fileName;

@property (nonatomic,assign) int timeOut;
@property (nonatomic,assign) int maxConcurrentCount;
@property (nonatomic,assign) int64_t  sliceSize;

+ (Congfig *)instance;
@end
