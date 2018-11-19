//
//  ViewController.m
//  COSDemoApp
//
//  Created by 贾立飞 on 16/8/23.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "ViewController.h"
#import "COSClient.h"
#import "COSTask.h"
#import "FileBrowserController.h"
#import "RegisterViewController.h"
#import "Congfig.h"
#import "QCloudUtils.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QCloudCore/QCloudCore.h>

@interface ViewController ()<SelectFileProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UILabel *bucketLable;
    UILabel *dirLable;
    int64_t currentTaskid;
    UILabel *regionLable;
    UILabel *appidLable;
    __block UITextView *imgUrl;
    UILabel *imgFileID;
    NSString *appId;
    NSString *bucket;
    NSString *dir;
    NSString *fileName;
    NSString *imgSavepath;
    long long slcieCount;
    long long  lastSlice ;
    UIImageView *imageV;
    NSString *sesssion;
    UIButton *dele;
    COSClient *myClient;
    
    CFAbsoluteTime          startTime;
   __block CFAbsoluteTime          finishTime;
}

@property (nonatomic,copy) NSString *sign;
@property (nonatomic,copy) NSString *oneSign;
@property (nonatomic, strong) NSString* uploadFilePath;
@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    bucketLable.text = bucket;
    dirLable.text = dir;
    regionLable.text= [Congfig instance].region;
    appidLable .text= [Congfig instance].fileName;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //页面布局
    [self setUI];
    
    bucket = @"dynamictest";
    [Congfig instance].region = @"sh";
    appId = @"1253653367";

    //网络请求工具类
    self.client = [[HttpClient alloc] init];
    self.client.vc = self;
    
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = @"";
    credential.secretKey = @"";
    
    QCloudAuthentationV4Creator* creator = [[QCloudAuthentationV4Creator alloc] initWithCredential:credential];
    
    QCloudSignatureFields* fields = [QCloudSignatureFields new];
    fields.appID = appId;
    fields.bucket = bucket;
    
    QCloudSignature* sign = [creator signatureForData:fields];
    
    self.sign = sign.signature;
    
    myClient= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    [myClient openHTTPSrequset:YES];
}
#pragma mark - SDK method
-(void)uploadFileWithPath:(NSString *)path
{

#ifdef DEBUG
    
    path = [NSTemporaryDirectory() stringByAppendingString:@"8A7C01F1-4B8C-4458-A26C-4C251446ED72"];
    NSString* oldPath = [NSTemporaryDirectory() stringByAppendingString:@"755E191A-2AD5-4E57-BE0F-E87599569929"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldPath]) {
        path = oldPath;
    } else {
        path = [self tempFileWithSize:(int64_t)1024*1024*1000];
    }
    
#endif
    
    /*第二种初始化的方式*/
    COSObjectPutTask *task = [[COSObjectPutTask alloc] init];
    task.multipartUpload = YES;
    
    currentTaskid = task.taskId;
    task.filePath = path;
    task.fileName = path.lastPathComponent;
    task.bucket = bucket;
    task.attrs = @"customAttribute";
    task.directory = dir;
    task.insertOnly = YES;
    task.multipartUpload = YES;
    
    task.sign = _sign;
    __weak UITextView *temp = imgUrl;
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
        UITextView *strong = temp;
        if (rsp.retCode == 0) {
           strong.text = rsp.sourceURL;
            NSLog(@"sourceURL = %@",rsp.sourceURL);
            NSLog(@"https = %@",rsp.httpsURL);
        }else{
            strong.text = [NSString stringWithFormat:@"%d -- %@",rsp.retCode ,rsp.descMsg];
        }
        finishTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"上传用时%f",finishTime- startTime);
    };
    myClient.progressHandler = ^(int64_t bytesWritten,int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite){
        UITextView *strong = temp;
        strong.text = [NSString stringWithFormat:@"进度展示：bytesWritten %ld.totalBytesWritten %ld.totalBytesExpectedToWrite %ld",(long)bytesWritten,(long)totalBytesWritten,(long)totalBytesExpectedToWrite];
        Float64 a = totalBytesWritten;
        Float64 b=totalBytesExpectedToWrite;
        strong.text = [NSString stringWithFormat:@"进度展示：bytesWritten %0.2f",a/b];
    };
    
    startTime = CFAbsoluteTimeGetCurrent();
    [myClient putObject:task];
    NSLog(@"upload start!%f",CFAbsoluteTimeGetCurrent() -startTime);
    imgUrl.text = @"upload start!";
}

-(void)uploadFileMultipartWithPath:(NSString *)path
{

    COSObjectPutTask *task = [[COSObjectPutTask alloc] init];

    NSLog(@"-send---taskId---%lld",task.taskId);
    task.multipartUpload = YES;
    currentTaskid = task.taskId;
    task.fileName = [QCloudUtils getPathFileName:path];
    task.filePath = path;
   // task.fileName = fileName;
    task.bucket = bucket;
    task.attrs = @"customAttribute";
    task.directory = dir;
    task.insertOnly = YES;
    task.sign = _sign;
    
     __weak UITextView *temp = imgUrl;
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
         UITextView *strong = temp;
        if (rsp.retCode == 0) {
            strong.text = rsp.sourceURL;
        }else{
            strong.text = [NSString stringWithFormat:@"%d--%@",resp.retCode, rsp.descMsg];
        }
    };
    myClient.progressHandler = ^(int64_t bytesWritten,int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite){
        UITextView *strong = temp;
        strong.text = [NSString stringWithFormat:@"进度展示：bytesWritten %ld.totalBytesWritten %ld.totalBytesExpectedToWrite %ld",(long)bytesWritten,(long)totalBytesWritten,(long)totalBytesExpectedToWrite];
        NSLog(@"进度展示：bytesWritten %ld.totalBytesWritten %ld.totalBytesExpectedToWrite %ld",(long)bytesWritten,(long)totalBytesWritten,(long)totalBytesExpectedToWrite);
    };
    self.uploadFilePath = path;
    [myClient putObject:task];
}
- (NSString*) tempFileWithSize:(int64_t)size
{
    NSString* file4MBPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:file4MBPath]) {
        [[NSFileManager defaultManager] createFileAtPath:file4MBPath contents:[NSData data] attributes:nil];
    }
    NSFileHandle* handler = [NSFileHandle fileHandleForWritingAtPath:file4MBPath];
    int64_t aimMem = size;
    for (int64_t writedMem = 0; writedMem <= aimMem; ) {
        int64_t aimSlice = 512;
        aimSlice = MIN(aimSlice, aimMem - writedMem);
        if (aimSlice == 0) {
            break;
        }
        char* mem = malloc(sizeof(char)*aimSlice);
        NSData* data = [NSData dataWithBytes:mem length:aimSlice];
        [handler writeData:data];
        free(mem);
        writedMem += aimSlice;
    }
    [handler closeFile];
    return file4MBPath;
}

-(void)tryResumeSend:(NSString *)path
{
//    if (currentTaskid == 0) {
//        imgUrl.text = @"没有在上传中任务";
//        return;
//    }

    COSObjectMultipartResumePutTask *task = [[COSObjectMultipartResumePutTask alloc] init];
    NSLog(@"-send---taskId---%lld",task.taskId);
    currentTaskid = task.taskId;
    
    task.filePath = path;
    task.fileName = fileName;
    task.bucket = bucket;
    task.attrs = @"customAttribute";;
    task.directory = dir;
    task.insertOnly = NO;
    task.sign = _sign;
    
    if (currentTaskid == 0) {
        imgUrl.text = @"没有在上传中任务";
        return;
    }

    //    COSObjectMultipartResumePutTask *task = [[COSObrusumejectMultipartResumePutTask alloc] init];
//    NSLog(@"-send---taskId---%lld",task.taskId);
//    currentTaskid = task.taskId;
//    
//    task.filePath = path;
//    task.fileName = fileName;
//    task.bucket = bucket;
//    task.attrs = @"customAttribute";
//    task.directory = dir;
//    task.insertOnly = YES;
//    task.sign = _sign;
//    
//    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
//    //call back
//    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
//        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
//        if (rsp.retCode == 0) {
//            imgUrl.text = rsp.sourceURL;
//            NSLog(@"context  = %@",context);
//        }else{
//             imgUrl.text = rsp.descMsg;
//        }
//    };
//    
//    myClient.progressHandler = ^(NSInteger bytesWritten,NSInteger totalBytesWritten,NSInteger totalBytesExpectedToWrite){
//        imgUrl.text = [NSString stringWithFormat:@"进度展示：bytesWritten %ld.totalBytesWritten %ld.totalBytesExpectedToWrite %ld",(long)bytesWritten,(long)totalBytesWritten,(long)totalBytesExpectedToWrite];
//    };
    
//    [myClient ObjectResumePutMultipart:task];
}

-(void)deleteObject
{
    if (dir.length==0 &&fileName.length == 0 ) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"erro" message:@"fileName / dir 错误" delegate:nil
                                          cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [a show];
        return ;
    }
    NSString *path = nil;
    
    if (dir && dir.length>0) {
        //删除需要向业务后台申请一次性签名
        path = [NSString stringWithFormat:@"/%@/%@",dir,fileName];
    }else{
        //删除需要向业务后台申请一次性签名
        path = [NSString stringWithFormat:@"/%@",fileName];
    }
    
    //删除需要向业务后台申请一次性签名
    self.oneSign = [self getOneTimeSignatureWithFileId:path];
    COSObjectDeleteCommand *cm = [[COSObjectDeleteCommand alloc] initWithFile:fileName
                                                                       bucket:bucket
                                                                    directory:dir
                                                                         sign:self.oneSign ];
    NSLog(@"---删除任务的-taskId---%lld",cm.taskId);

    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];;
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        
        COSTaskRsp *rsp = (COSTaskRsp *)resp;
        if (rsp.retCode == 0) {
            imgUrl.text = rsp.descMsg;
        }else
        {
            imgUrl.text = rsp.descMsg;
        }
    };
    [client deleteObject:cm];
}


- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    switch (textField.tag-1000) {
        case 0:
            NSLog(@"--文件属性--%@",textField.text);
            break;
        case 1:
            NSLog(@"--是否允许访问--%@",textField.text);
            break;
        case 2:
            NSLog(@"--文件权限类型--%@",textField.text);
            break;
        case 3:
            NSLog(@"----%@",textField.text);
            break;
            
        default:
            break;
    }
}

-(void)updateFileWithBtn
{
    NSString *title = NSLocalizedString(@"文件属性", nil);
    NSString *sureButtonTitle = NSLocalizedString(@"OK", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"cancel", nil);
    
    __block  UITextField *textFieldOne;
    __block  UITextField *textFieldTwo;
    __block UITextField *textFieldThree;
    
    __block  UITextField *cacheControl;
    __block  UITextField *contentType;
    __block UITextField *contentDisposition;
    __block UITextField *contentLanguage;
    __block UITextField *cosMeta;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        textField.tag = 1000;
        textField.placeholder = @"文件属性";
           NSLog(@"--------%@",textField.text);
        textFieldOne = textField;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        textField.tag = 1001;
        textField.keyboardType =UIKeyboardTypePhonePad;
        textField.placeholder = @"0:不限制1：禁读2：禁止写";
        textFieldTwo = textField;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 1002;
        textField.placeholder = @"0:不限制1:私有读写2：写公有写私有";
        textField.keyboardType =UIKeyboardTypePhonePad;
        textFieldThree = textField;
    }];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"文件的缓存机制";
        cacheControl = textField;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"文件的MIME信息";
        contentType = textField;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"MIME协议的扩展";
        contentDisposition = textField;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"文件的语言";
        contentLanguage = textField;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"自定义内容";
          cosMeta = textField;
    }];
    
    // Create the actions.
      UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
        NSMutableDictionary * dic = [NSMutableDictionary new];
        if (textFieldOne.text) {
            [dic setObject:textFieldOne.text forKey:@"att"];
        }
        if (textFieldTwo.text) {
            [dic setObject:textFieldTwo.text forKey:@"forbid"];
        }
        if (textFieldThree.text) {
            [dic setObject:textFieldThree.text forKey:@"authority"];
        }
          
          NSMutableDictionary *header = [NSMutableDictionary new];
          
          if (cacheControl.text.length>0) {
              [header setObject:cacheControl.text forKey:@"Cache-Control"];
          }
          if (contentType.text.length>0) {
              [header setObject:contentType.text forKey:@"Content-Type"];
          }
          if (contentDisposition.text.length>0) {
              [header setObject:contentDisposition.text forKey:@"Content-Disposition"];
          }
          if (contentLanguage.text.length>0) {
              [header setObject:contentLanguage.text forKey:@"Content-Language"];
          }
          if (cosMeta.text.length>0) {
              [header setObject:cosMeta.text forKey:@"x-cos-meta-x"];
          }
          
          if (header.allKeys.count>0) {
              [dic setObject:header forKey:@"header"];
          }
          
        [self updateFileWith:dic];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
    // Add the actions.
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)updateFileWith:(NSMutableDictionary *)info
{
    //删除需要向业务后台申请一次性签名
    NSString *path = [NSString stringWithFormat:@"/%@/%@",dir,fileName];
      self.oneSign = [self getOneTimeSignatureWithFileId:path];  //删除需要向业务后台申请一次性签名
    
    COSObjectUpdateCommand *cm = [[COSObjectUpdateCommand alloc] initWithFile:fileName
                                                                      bucket:bucket
                                                                  directory:dir
                                                                       sign:self.oneSign ];
    NSLog(@"--更新任务的--taskId---%lld",cm.taskId);
   
    if (info[@"att"]) {
         cm.attrs = info[@"att"];
    }
    
    NSLog(@"%d",[info[@"forbid"] intValue]);
    NSLog(@"%d",[info[@"authority"] intValue]);
    
    
    if (info[@"authority"]&& [info[@"authority"] length] >0) {
        
        switch ([info[@"authority"] intValue]) {
            case 0:
                cm.authorityType = eInvalidFileAuth;
                break;
            case 1:
                cm.authorityType = eWRPrivateFileAuth;
                break;
            case 2:
                cm.authorityType = eWPrivateRPublicFileAuth;
                break;
                
            default:
                break;
        }
    }
    
    if ([info objectForKey:@"header"]) {
        cm.customHeader = [info objectForKey:@"header"];
    }
    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSTaskRsp *rsp = (COSTaskRsp *)resp;
        if (rsp.retCode == 0) {
            imgUrl.text = [NSString stringWithFormat:@"文件相关属性更新成功，%@",rsp.descMsg];;
        }else{
            imgUrl.text = rsp.descMsg;
        }
    };
    
    [client updateObject:cm];
}

-(void)queryUploadedFile
{
    if (dir.length==0 &&fileName.length == 0 ) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"erro" message:@"fileName / dir 错误" delegate:nil
                                          cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [a show];
        return ;
    }
    //删除需要向业务后台申请一次性签名
    NSString *path = [NSString stringWithFormat:@"/%@/%@",dir,fileName];
    //删除需要向业务后台申请一次性签名
    self.oneSign = [self getOneTimeSignatureWithFileId:path];
    COSObjectMetaCommand *cm = [[COSObjectMetaCommand alloc] initWithFile:fileName
                                                                       bucket:bucket
                                                                    directory:dir
                                                                         sign:_sign ];
    NSLog(@"--文件查询任务的--taskId---%lld",cm.taskId);

    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        
        COSObjectMetaTaskRsp *rsp = (COSObjectMetaTaskRsp *)resp;
        if (rsp.retCode == 0) {
            NSLog(@"query sucess！=%@",rsp.data);
            NSString *jsonString = nil;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rsp.data
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (! jsonData) {
                imgUrl.text = rsp.descMsg;
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
             imgUrl.text = jsonString;
        }else{
            imgUrl.text = rsp.descMsg;

        }
    };
    [client getObjectMetaData:cm];
}


-(void)creatDir
{
    COSCreateDirCommand *cm = [[COSCreateDirCommand alloc] initWithDir:dir
                                                                bucket:bucket
                                                                  sign:_sign
                                                             attribute:@"attr" ];
    cm.directory = dir;
    cm.bucket = bucket;
    cm.sign = _sign;
    cm.attrs = @"dirTest";

    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        
        COSCreatDirTaskRsp *rsp = (COSCreatDirTaskRsp *)resp;
        if (rsp.retCode == 0) {
            imgUrl.text = [NSString stringWithFormat:@"创建目录%@ :%@",dir,rsp.descMsg];
        }else{
            imgUrl.text = [NSString stringWithFormat:@"创建目录%@ :%@",dir,rsp.descMsg];;
        }
    };
    [client createDir:cm];
}

-(void)getDirMetaData
{
    COSDirmMetaCommand *cm = [[COSDirmMetaCommand alloc] initWithDir:dir
                                                                bucket:bucket
                                                                  sign:_sign];
    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        
        COSDirMetaTaskRsp *rsp = (COSDirMetaTaskRsp *)resp;
        if (rsp.retCode == 0) {
            NSLog(@"query sucess！=%@",rsp.data);
            NSString *jsonString = nil;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rsp.data
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (! jsonData) {
                NSLog(@"Got an error: %@", error);
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            imgUrl.text = jsonString;
        }else{
             imgUrl.text = rsp.descMsg;
        }
    };
    [client getDirMetaData:cm];
}

-(void)updateDirBtn
{
    NSString *title = NSLocalizedString(@"更新目录属性", nil);
    NSString *message = NSLocalizedString(@"目录属性", nil);
    NSString *sureButtonTitle = NSLocalizedString(@"OK", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"cancel", nil);
    
    __block  UITextField *textFieldOne;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"attr";
        textFieldOne = textField;
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (textFieldOne.text.length>0) {
             [self updateDir:textFieldOne.text];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)updateDir:(NSString *)att
{
    //删除需要向业务后台申请一次性签名
    NSString *path = [NSString stringWithFormat:@"/%@/",dir];
    //删除需要向业务后台申请一次性签名
    self.oneSign = [self getOneTimeSignatureWithFileId:path];
    COSUpdateDirCommand *cm = [[COSUpdateDirCommand alloc] initWithDir:dir
                                                              bucket:bucket
                                                                sign:self.oneSign
                                                             attribute:att];
    //cm.attrs = @"dirTest";
    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){

        COSUpdateDirTaskRsp *rsp = (COSUpdateDirTaskRsp *)resp;
        if (rsp.retCode == 0) {
            imgUrl.text = rsp.descMsg;
        }else{
            imgUrl.text = rsp.descMsg;
        }
    };
    [client updateDir:cm];
}

-(void)deleteDir
{
    //删除需要向业务后台申请一次性签名
    NSString *path = [NSString stringWithFormat:@"/%@/",dir];
    NSLog(@"path == %@",path);
    //删除需要向业务后台申请一次性签名
    self.oneSign = [self getOneTimeSignatureWithFileId:path];
    COSDeleteDirCommand *cm = [[COSDeleteDirCommand alloc] initWithDir:dir
                                                              bucket:bucket
                                                                sign: self.oneSign];
    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        
        COSdeleteDirTaskRsp *rsp = (COSdeleteDirTaskRsp *)resp;
        if (rsp.retCode == 0) {
            imgUrl.text = rsp.descMsg;
        }else{
            imgUrl.text = rsp.descMsg;
        }
    };
    [client removeDir:cm];
}

- (void)getBucketBtn
{
    COSBucketMetaCommand *cm = [[COSBucketMetaCommand alloc] initWithBucket:bucket
                                                                  sign: self.sign];
    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSBucketMetaRsp *rsp = (COSBucketMetaRsp *)resp;
        if (rsp.retCode == 0) {
            NSString *jsonString = nil;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rsp.data
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (! jsonData) {
                imgUrl.text = rsp.descMsg;
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            imgUrl.text = jsonString;

        }else{
            imgUrl.text = rsp.descMsg;
        }
    };
    [client headBucket:cm];
}


- (void)getBucketAclBtn
{
    COSBucketAclCommand *cm = [[COSBucketAclCommand alloc] initWithBucket:bucket
                                                                       sign: self.sign];
    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSBucketAclRsp *rsp = (COSBucketAclRsp *)resp;
        if (rsp.retCode == 0) {
            imgUrl.text = rsp.authority;
            
        }else{
            imgUrl.text = rsp.descMsg;
        }
    };
    [client getBucketAcl:cm];
}

-(void)getDirList
{
    NSString *title = NSLocalizedString(@"目录列表", nil);
    NSString *message = NSLocalizedString(@"目录列表更改", nil);
    NSString *sureButtonTitle = NSLocalizedString(@"OK", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"cancel", nil);
    __block  UITextField *textFieldOne;
    __block  UITextField *textFieldTwo;
    __block  UITextField *textFieldThree;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"显示多少条";
        textFieldOne = textField;
        textFieldOne.text = @"1000";
        textField.keyboardType =UIKeyboardTypePhonePad;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"dir";
        textFieldTwo = textField;
        textFieldTwo.text = dir;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"prefix";
        textFieldThree = textField;
     
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSMutableDictionary * dic = [NSMutableDictionary new];
        if (textFieldOne.text) {
            [dic setObject:textFieldOne.text forKey:@"num"];
        }
        if (textFieldTwo.text) {
            [dic setObject:textFieldTwo.text forKey:@"dir"];
        }
        if (textFieldTwo.text) {
            [dic setObject:textFieldThree.text forKey:@"prefix"];
        }
        [self getDirListWith:dic];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
         }];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)getDirListWith:(NSMutableDictionary *)info
{
    COSListDirCommand *cm = [[COSListDirCommand alloc] initWithDir:info[@"dir"]
                                                                bucket:bucket
                                                                prefix:info[@"prefix"]
                                                                  sign:_sign
                                                            number:[info[@"num"] intValue]
                                                       pageContext:@""];
    
    
    cm.directory = dir;
    cm.bucket = bucket;
    cm.sign = _sign;
    cm.num = 100;
    cm.pageContext = @"";
    cm.prefix = @"xx";
    

    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
    
        COSDirListTaskRsp *rsp = (COSDirListTaskRsp *)resp;
        if (rsp.retCode == 0) {
            NSLog(@"query sucess！=%@",rsp.data);
            NSString *jsonString = nil;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rsp.infos
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (! jsonData) {
                NSLog(@"Got an error: %@", error);
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            imgUrl.text = jsonString;
        }else{
            imgUrl.text = rsp.descMsg;

        }
    };
    [client listDir:cm];
}

-(void)downloadFile
{
    if (imgUrl.text.length==0) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"错误" message:@"urlisnull" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [a show];
        return;
    }
    
//    COSObjectGetTask *cm = [[COSObjectGetTask alloc] initWithUrl:imgUrl.text];
    COSObjectGetTask *cm = [[COSObjectGetTask alloc] initWithUrl:@"http://guangzhou-1251668577.cosgz.myqcloud.com/dir2/admin1233211234567s"];

    cm.sign = @"lS/P14faZKdpbZViKL00RHZsaShhPTEyNTM2NTMzNjcmaz1BS0lEUGlxbVczcWNnWFZTS044am5nUHpSaHZ4ell5REw1cVAmZT0xNDk4MzY3Mzk5JnQ9MTQ5ODI4MDk5OSZyPTE2ODA3JmY9JmI9Z3Vhbmd6aG91";
    
    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    
    client.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSGetObjectTaskRsp *rsp = (COSGetObjectTaskRsp *)resp;
        imgUrl.text = [NSString stringWithFormat:@"下载retCode = %d retMsg= %@",rsp.retCode,rsp.descMsg];
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"文件大小" message:[NSString stringWithFormat:@"%lu B",(unsigned long)rsp.object.length] delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [a show];
        
    };
    client.downloadProgressHandler = ^(int64_t receiveLength,int64_t contentLength){
        imgUrl.text = [NSString stringWithFormat:@"receiveLength =%ld,contentLength%ld",(long)receiveLength,(long)contentLength];;
    };
    [client getObject:cm];
}
//分片上传取消
-(void)tryCancelSend
{
    if (currentTaskid == 0) {
        imgUrl.text = @"没有在上传中任务";
        return;
    }
    [myClient cancel:currentTaskid];
}



-(void)pauseBtn
{
    if (currentTaskid == 0) {
        imgUrl.text = @"没有在上传中任务";
        return;
    }
    [myClient pause:currentTaskid];
    
}

#pragma mark - download
- (void)drawBorderWithButton:(id)view {
    
    CALayer * downButtonLayer = [(UIView *)view layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setBorderWidth:1.0];
    [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
}


#pragma mark －network
-(void)getSignFinish:(NSString *)string
{
    if (string) {
        self.sign = string;
        NSLog(@"self.sign = %@",self.sign);
        imgUrl.text =self.sign;
    }else{
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"警告" message:@"签名为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
    }
}

-(void)getOneSignFinish:(NSString *)string
{
    self.oneSign = string;
}

-(void)getUploadImageSign
{
    NSString *url = [NSString stringWithFormat:@"http://203.195.194.28/cosv4/getsignv4.php?bucket=%@&service=video",[Congfig instance].bucket];
    [self.client getSignWithUrl:url callBack:@selector(getSignFinish:)];

     //[self.client getSignWithUrl:SIGN_URL callBack:@selector(getSignFinis:)];
}

- (NSString *)getOneTimeSignatureWithFileId:(NSString *)fileId
{
    NSString *pams = [NSString stringWithFormat:@"http://203.195.194.28/cosv4/getsignv4.php?bucket=%@&service=cos&expired=0&path=",[Congfig instance].bucket];
    NSString *tem = [NSString stringWithFormat:@"%@%@",pams,fileId];
    NSURL *url =  [NSURL URLWithString:[tem stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
  
   // NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ONE_SIGN_URL,fileId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *httpResponse = nil;
    NSError *connectionError = nil;
    NSData *signData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&connectionError];
    NSDictionary *responseDic = nil;
    if (signData) {
       responseDic = [NSJSONSerialization JSONObjectWithData:signData options:kNilOptions error:nil];
    }
    NSString *result = nil;
    if (responseDic) {
        result = [responseDic  objectForKey:@"sign"];
    }
   return result;
    // return [[responseDic objectForKey:@"data"] objectForKey:@"sign"];
}

#pragma mark - UI

#pragma mark -- select Photo

//    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    imagePickerController.delegate = self;
//    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];

- (void)gotoImagePickerController
{
//    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
//    //设置选取的照片是否可编辑
//    pickerController.allowsEditing = YES;
//    //设置相册呈现的样式
//    pickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;//图片分组列表样式
//    pickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*) kUTTypeMovie, (NSString*) kUTTypeVideo, nil];
//    //照片的选取样式还有以下两种
//    //,直接全部呈现系统相册
//    //UIImagePickerControllerSourceTypeCamera//调取摄像头
//    //选择完成图片或者点击取消按钮都是通过代理来操作我们所需要的逻辑过程
//    pickerController.delegate = self;
//    //使用模态呈现相册
//    [self.navigationController presentViewController:pickerController animated:YES completion:nil];

    
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
        [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        
//        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoUrl] ;
//        UIImage  *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
//        
//        imageV.image = thumbnail;
//        player = nil;
        
        NSString *videoCacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UploadPhoto/"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:videoCacheDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:videoCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        int value = arc4random();
        NSString *lastPathComponent = [NSString stringWithFormat:@"%d.mov", value];
        imgSavepath = [videoCacheDir stringByAppendingPathComponent:lastPathComponent];
        NSLog(@"videoPath = %@",imgSavepath);
        [[NSFileManager defaultManager] copyItemAtPath:moviePath toPath:imgSavepath error:nil];
        //[self uploadSelectedVideo:movieLocalPath];
    }else{
        
        NSURL *url  = [info objectForKey:UIImagePickerControllerReferenceURL];
        NSString *photoPath = [self photoSavePathForURL:url];
        imgSavepath = photoPath;
        
        UIImage *orginalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(orginalImage, 1.f);
        [imageData writeToFile:imgSavepath atomically:YES];
        
        imageV.image = orginalImage;
        imgUrl.text = [NSString stringWithFormat:@"图片选择成功地址：%@",imgSavepath];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];

    [self uploadFileMultipartWithPath:imgSavepath];
    
}

- (NSString *)photoSavePathForURL:(NSURL *)url
{
    NSString *photoSavePath = nil;
    NSString *urlString = [url absoluteString];
    NSString *uuid = nil;
    if (urlString) {
        uuid = [QCloudUtils findUUID:urlString];
    } else {
        uuid = [QCloudUtils uuid];
    }
    
    NSString *resourceCacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UploadPhoto/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:resourceCacheDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resourceCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    photoSavePath = [resourceCacheDir stringByAppendingPathComponent:uuid];
    
    return photoSavePath;
}
//批量测试使用
-(void)completeSelectFiles:(NSArray *)fileList uploadDir:(NSString *)dirPath
{
    if ([fileList count]<=0 || !dirPath) {
        return;
    }
    //one file upload
      [self uploadFileWithPath:fileList.firstObject];
    //more file upload
//    for (NSString *path in fileList) {
//         [self uploadFileWithPath:path];
//    }
}

-(void)resumeUploadMultipart
{
    [self tryResumeSend:self.uploadFilePath];
    //  [self btnTryAction:nil];
}

-(void)selectFile
{
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];//test/jpg/mp4/MOV

    [self uploadFileWithPath:videoPath];
    
//    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"bigceshi" ofType:@"mp4"];
//    [self uploadFileWithPath:videoPath];
//    [self uploadFileMultipartWithPath:videoPath];
//////////////////////////
//    FileBrowserController * fileBrowser = [[FileBrowserController alloc]init];
//    fileBrowser.delegate = self;
//    fileBrowser.uploadDirPath = @"/";
//    fileBrowser.supportMultifiles = NO;
//    [self.navigationController pushViewController:fileBrowser animated:YES];
}

-(void)btnAction:(UIButton *)btn
{
    switch (btn.tag) {
        case 0:
            [self selectFile];
            break;
        case 1:
            [self updateFileWithBtn];
            break;
        case 2:
            [self deleteObject];
            break;
        case 3:
            [self queryUploadedFile];
            break;
        case 4:
            [self creatDir];
            break;
        case 5:
            [self deleteDir];
            break;
        case 6:
            [self getDirMetaData];
            break;
        case 7:
            [self updateDirBtn];
            break;
        case 8:
            [self getDirList];
            break;
        case 9:
            [self downloadFile];
            break;
        case 10:
            [self gotoImagePickerController];
            break;
        case 11:
            [self tryCancelSend];
            break;
        case 12:
            [self resumeUploadMultipart];
            break;
        case 13:
            [self getBucketBtn];
            break;
        case 14:
            [self pauseBtn];
            break;
        case 15:
            [self getBucketAclBtn];
            break;
        case 16:
            [self gotoImagePickerController];
            break;
        default:
            break;
    }
}

-(void)registerBtn
{
    RegisterViewController *vc = [RegisterViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)updateSignM
{
    //向自己的业务服务器请求 上传所需要的签名
    [self getUploadImageSign];
}

-(void)clearBtn
{
    imgUrl.text = @"";
}


-(void)setUI
{
    currentTaskid = 0;
    int btnWidth = 100;
    int btnHeight = 100;
    int btnX = (kScreenWidth-btnWidth)/2;
    int btnY = 70;
    
    imageV = [[UIImageView alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
    [self.view addSubview:imageV];
    imageV.contentMode = UIViewContentModeScaleToFill;
    imageV.backgroundColor = [UIColor whiteColor];
//    [self drawBorderWithButton:imageV];
    
    [self saveImage:[UIImage imageNamed:@"try.jpg"] WithName:@"try.jpg"];
    
    UIButton *registerB  = [UIButton buttonWithType:UIButtonTypeCustom];
    registerB.frame = CGRectMake(10, btnY, 80, 30);
    [self.view addSubview:registerB];
    [registerB setBackgroundColor:UIColorFromRGB(0x1da5fe)];
    [registerB setTitle:@"注册" forState:UIControlStateNormal];
    [registerB addTarget:self action:@selector(registerBtn) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *clearB  = [UIButton buttonWithType:UIButtonTypeCustom];
    clearB.frame = CGRectMake(10, btnY+ 30+ 20, 80, 30);
    [self.view addSubview:clearB];
    [clearB setBackgroundColor:UIColorFromRGB(0x1da5fe)];
    [clearB setTitle:@"清理显示结果" forState:UIControlStateNormal];
    clearB.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
    [clearB addTarget:self action:@selector(clearBtn) forControlEvents:UIControlEventTouchUpInside];
    btnWidth = 85;

    
    UIButton *updateSign  = [UIButton buttonWithType:UIButtonTypeCustom];
    updateSign.frame = CGRectMake(kScreenWidth - btnWidth - 10, btnY, btnWidth, 30);
    [self.view addSubview:updateSign];
    [updateSign setBackgroundColor:UIColorFromRGB(0x1da5fe)];
    [updateSign setTitle:@"更新签名" forState:UIControlStateNormal];
    [updateSign addTarget:self action:@selector(updateSignM) forControlEvents:UIControlEventTouchUpInside];
    
    
    dele  = [UIButton buttonWithType:UIButtonTypeCustom];
    dele.frame = CGRectMake(kScreenWidth - btnWidth - 10, btnY+ 30+ 20, btnWidth, 30);
    [self.view addSubview:dele];
    [dele setBackgroundColor:UIColorFromRGB(0x1da5fe)];
    [dele setTitle:@"更新签名" forState:UIControlStateNormal];
    [dele addTarget:self action:@selector(updateSignM) forControlEvents:UIControlEventTouchUpInside];
    
    btnWidth = (kScreenWidth-30)/2;
    
    bucketLable = [[UILabel alloc] init];
    [self.view addSubview:bucketLable];
    bucketLable.text= @"/";
    bucketLable.contentMode = UIViewContentModeScaleToFill;
    bucketLable.backgroundColor = UIColorFromRGB(0x1da5fe);
    bucketLable.textColor = [UIColor whiteColor];
    bucketLable.alpha = 0.5;
    [self drawBorderWithButton:bucketLable];
    bucketLable.frame = CGRectMake(10, 180, btnWidth, 20);
    
    dirLable = [[UILabel alloc] init];
    [self.view addSubview:dirLable];
    dirLable.text= @"/";
    dirLable.contentMode = UIViewContentModeScaleToFill;
    dirLable.backgroundColor = UIColorFromRGB(0x1da5fe);
    dirLable.alpha = 0.5;
    [self drawBorderWithButton:dirLable];
    dirLable.frame = CGRectMake(btnWidth+20, 180, btnWidth, 20);
    regionLable = [[UILabel alloc] init];
    [self.view addSubview:regionLable];
    regionLable.text= @"/";
    regionLable.contentMode = UIViewContentModeScaleToFill;
    regionLable.backgroundColor =UIColorFromRGB(0x1da5fe);
    regionLable.alpha = 0.5;
    [self drawBorderWithButton:regionLable];
    
    regionLable.frame = CGRectMake(10, 210, btnWidth, 20);

    appidLable = [[UILabel alloc] init];
    [self.view addSubview:appidLable];
    appidLable.text= @"/";
    appidLable.contentMode = UIViewContentModeScaleToFill;
    appidLable.backgroundColor = UIColorFromRGB(0x1da5fe);
    appidLable.alpha = 0.5;
    [self drawBorderWithButton:appidLable];
    
    appidLable.frame = CGRectMake(btnWidth+20, 210, btnWidth, 20);
    
    NSArray *titles =  @[@"选择文件",@"文件更新",@"删除",@"查询",];
     btnY = 250;
     btnWidth = (kScreenWidth-((titles.count+1) * 10))/titles.count;
     btnHeight = 30;
    
    for (int tag = 0; tag<titles.count; tag++) {
        UIButton *upload = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        upload.frame = CGRectMake(10+(tag * btnWidth)+(10 * tag), btnY, btnWidth, btnHeight);
        [self.view addSubview:upload];
        upload.tag = tag;
        [upload addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [upload setTitle:titles[tag] forState:UIControlStateNormal];
        upload.backgroundColor = UIColorFromRGB(0x1da5fe);
        upload.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [upload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    NSArray *titlesS =  @[@"创建目录",@"删除目录",@"目录查询",@"更新目录",@"目录列表",@"下载文件"];
    
    btnWidth = (kScreenWidth-((titlesS.count+1) * 10))/titlesS.count;
    for (int tag = 0; tag<titlesS.count; tag++) {
        UIButton *upload = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        upload.frame = CGRectMake(10+(tag * btnWidth)+(10 * tag), btnY+btnHeight +10, btnWidth, btnHeight);
        [self.view addSubview:upload];
        upload.tag = tag + titles.count;
        [upload addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [upload setTitle:titlesS[tag] forState:UIControlStateNormal];
        upload.backgroundColor = UIColorFromRGB(0x1da5fe);
        upload.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [upload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    NSArray *titlesT =  @[@"分片上传",@"取消上传",@"继续分片上传",@"bucket查询",@"暂停",@"bucket权限",@"test"];

    btnWidth = (kScreenWidth-((titlesT.count+1) * 10))/titlesT.count;
    for (int tag = 0; tag<titlesT.count; tag++) {
        UIButton *upload = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        upload.frame = CGRectMake(10+(tag * btnWidth)+(10 * tag), btnY+btnHeight*2+20, btnWidth, btnHeight);
        [self.view addSubview:upload];
        upload.tag = tag + titles.count+titlesS.count;
        [upload addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [upload setTitle:titlesT[tag] forState:UIControlStateNormal];
        upload.backgroundColor = UIColorFromRGB(0x1da5fe);
        upload.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [upload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    //
    imgUrl = [[UITextView alloc]init];
    imgUrl.editable = NO;
    imgUrl.frame = CGRectMake(10, 380, self.view.bounds.size.width -20, 220);
    imgUrl.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:imgUrl];
}

-(void)uploadMultipart
{
    [self uploadFileMultipartWithPath:imgSavepath];
      //  [self btnTryAction:nil];
}

//-(void)resumeUploadMultipart
//{
//    [self tryResumeSend:imgSavepath];
//    //  [self btnTryAction:nil];
//}

- (int64_t)generateFileName
{
    return (int64_t)[[NSDate date] timeIntervalSince1970]*1000 + [self randomIn1000];
}

- (NSInteger)randomIn1000
{
    return arc4random() % 1000;
}

//保存图片
- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1re" ofType:@"jpg"];
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    imgSavepath = [documentPath stringByAppendingPathComponent:imageName];
    
    //图片数据保存到 document
    [imageData writeToFile:imgSavepath atomically:NO];
    imageData = [self loadFileData:0 Len:7441564];
    imageV.image = [UIImage imageWithData:imageData];
}
//static int64_t  slice = 1024 *1024;
//
//#pragma mark -- utility methods
- (NSData *)loadFileData:(unsigned long long )offset Len:(NSUInteger)length
{
    NSData *fileData = nil;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:imgSavepath];
    if (fileHandle !=  nil)
    {
        [fileHandle seekToFileOffset:offset];
        fileData = [fileHandle readDataOfLength:length];
        [fileHandle closeFile];
    }
    else
    {
//        TXYUploadLog_Info(@"open file error path:%@", self.filePath);
    }
    
    return fileData;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
