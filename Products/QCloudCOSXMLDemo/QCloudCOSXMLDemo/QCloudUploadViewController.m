//
//  QCloudUploadViewController.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/6/11.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef BUILD_FOR_TEST

#import "QCloudUploadViewController.h"
#import <QCloudCore/QCloudCore.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import "QCloudCOSXMLContants.h"
@interface QCloudUploadViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSString* uploadTempFilePath;
@property (nonatomic, strong) QCloudCOSXMLUploadObjectRequest* uploadRequest;
@property (nonatomic, strong) NSData* uploadResumeData;
@end

@implementation QCloudUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationItem setTitle:@"上传"];
    [self.progressView setProgress:0.0f animated:NO];
}


- (IBAction)  selectImage{
    UIImagePickerController* picker = [UIImagePickerController new];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString* tempPath = QCloudTempFilePathWithExtension(@"png");
    [UIImagePNGRepresentation(image) writeToFile:tempPath atomically:YES];
    self.uploadTempFilePath = tempPath;
    self.imagePreviewView.image = image;
    [picker dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void) showErrorMessage:(NSString*)message
{
    self.resultTextView.text = message;
}

- (IBAction) beginUpload:(id)sender
{
    if (!self.uploadTempFilePath) {
        [self showErrorMessage:@"没有选择文件！！！"];
        return;
    }
    if (self.uploadRequest) {
        [self showErrorMessage:@"在上传中，请稍后重试"];
        return;
    }
    QCloudCOSXMLUploadObjectRequest* upload = [QCloudCOSXMLUploadObjectRequest new];
    upload.body = [NSURL fileURLWithPath:self.uploadTempFilePath];
    upload.bucket = QCloudUploadBukcet;
    upload.object = [NSUUID UUID].UUIDString;
    [self uploadFileByRequest:upload];
}

- (IBAction) abortUpload:(id)sender
{
    if (!self.uploadRequest) {
        [self showErrorMessage:@"不存在上传请求，无法完全中断上传"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.uploadRequest abort:^(id outputObject, NSError *error) {
        weakSelf.uploadRequest = nil;
    }];
}

- (IBAction) pasueUpload:(id)sender {
    QCloudLogDebug(@"点击了暂停按钮");
    if (!self.uploadRequest) {
        [self showErrorMessage:@"不存在上传请求，无法暂停上传"];
        return;
    }
    NSError* error;
    self.uploadResumeData = [self.uploadRequest cancelByProductingResumeData:&error];
    if (error) {
        [self showErrorMessage:error.localizedDescription];
    } else {
        [self showErrorMessage:@"暂停成功"];
    }
}

- (IBAction)resumeUpload:(id)sender {
    if (!self.uploadResumeData) {
        [self showErrorMessage:@"不再在恢复上传数据，无法继续上传"];
        return;
    }
    QCloudCOSXMLUploadObjectRequest* upload = [QCloudCOSXMLUploadObjectRequest requestWithRequestData:self.uploadResumeData];
    [self uploadFileByRequest:upload];
}


- (void) uploadFileByRequest:(QCloudCOSXMLUploadObjectRequest*)upload
{

    
    [self showErrorMessage:@"开始上传"];
    _uploadRequest = upload;
    __weak typeof(self) weakSelf = self;
    [upload setFinishBlock:^(QCloudUploadObjectResult *result, NSError * error) {
        weakSelf.uploadRequest = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [weakSelf showErrorMessage:error.localizedDescription];
            } else {
                [weakSelf showErrorMessage:[result qcloud_modelToJSONString]];
            }
        });
    }];
    
    [upload setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressView setProgress:(1.0f*totalBytesSent)/totalBytesExpectedToSend animated:YES];
            QCloudLogDebug(@"bytesSent: %i, totoalBytesSent %i ,totalBytesExpectedToSend: %i ",bytesSent,totalBytesSent,totalBytesExpectedToSend);
        });
    }];
    
    NSString* selectorName = @"defaultCOSTransferManager";
    NSString* targetName = [NSBundle mainBundle].infoDictionary[@"TargetName"];
    if (nil == targetName) {
        return ;
    }
    if (![targetName isEqualToString:@"QCloudCOSXMLDemo"]) {
        
    } else {
#if (QCloudCOSXMLModuleVersionNumber < 500004)
        selectorName = @"defaultCOSTRANSFERMANGER";
//    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:upload];
#else
//    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:upload];
        selectorName  = @"defaultCOSTRANSFERMANGER";
#endif
        [[QCloudCOSTransferMangerService performSelector:NSSelectorFromString(selectorName)] UploadObject:upload];
}

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
#endif
