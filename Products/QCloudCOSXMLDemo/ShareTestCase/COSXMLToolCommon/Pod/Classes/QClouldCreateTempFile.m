//
//  QClouldCreateTempFile.m
//  COSXMLCommon
//
//  Created by karisli(李雪) on 2018/4/6.
//

#import "QClouldCreateTempFile.h"
#import "QCloudCOSXML.h"
@implementation QClouldCreateTempFile
+ (NSString* )tempFileWithSize:(NSInteger)size unit:(QCloudTempFileUnit)unit {
    NSString* file4MBPath = QCloudPathJoin(QCloudTempDir(), [NSUUID UUID].UUIDString);
    if (!QCloudFileExist(file4MBPath)) {
        [[NSFileManager defaultManager] createFileAtPath:file4MBPath contents:[NSData data] attributes:nil];
    }
    NSFileHandle* handler = [NSFileHandle fileHandleForWritingAtPath:file4MBPath];
    [handler truncateFileAtOffset:size*unit];
    [handler closeFile];
    return file4MBPath;
}


+ (void)removeFileAtPath:(NSString*)path {
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
