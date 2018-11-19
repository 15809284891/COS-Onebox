//
//  QClouldCreateTempFile.h
//  COSXMLCommon
//
//  Created by karisli(李雪) on 2018/4/6.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,QCloudTempFileUnit) {
    QCLOUD_TEMP_FILE_UNIT_BYTES = 1,
    QCLOUD_TEMP_FILE_UNIT_KB = 1024,
    QCLOUD_TEMP_FILE_UNIT_MB = 1024*1024,
    QCLOUD_TEMP_FILE_UNIT_GB = 1024*1024*1024
};


@interface QClouldCreateTempFile : NSObject
/**
 从硬盘中截取一段生成临时文件
 
 @param size 文件大小
 @param unit 文件单位，bytes, kb, 等
 @return 文件地址
 */
+ (NSString* )tempFileWithSize:(NSInteger)size unit:(QCloudTempFileUnit)unit;


+ (void)removeFileAtPath:(NSString*)path;

@end
