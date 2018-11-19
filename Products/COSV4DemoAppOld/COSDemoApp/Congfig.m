//
//  Congfig.m
//  COSDemoApp
//
//  Created by 贾立飞 on 16/9/12.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "Congfig.h"

@implementation Congfig

+ (Congfig *)instance {
    
    static Congfig *g_instance = nil;
    
    static  dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        g_instance =[[Congfig alloc] init];
    });
    
    return g_instance;
}





@end
