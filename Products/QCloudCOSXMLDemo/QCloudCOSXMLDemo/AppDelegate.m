//
//  AppDelegate.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/2/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "AppDelegate.h"
#import "QCloudCore.h"
#import <QCloudCOSXML/QCloudCOSXML.h>
#import "QCloudCOSXMLVersion.h"
#import <COSXMLToolCommon/COSXMLToolCommon.h>
#import <QCloudCOSXML/QCloudCOSXMLService.h>
//#define  USE_TEMPERATE_SECRET
#if QCloudCOSXMLModuleVersionNumber > 500003

@interface AppDelegate () <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>
@property (nonatomic, strong) QCloudCredentailFenceQueue* credentialFenceQueue;
@end

#else
@interface AppDelegate () <QCloudSignatureProvider>

@end

#endif

@implementation AppDelegate
#if QCloudCOSXMLModuleVersionNumber > 500003

- (void) fenceQueue:(QCloudCredentailFenceQueue *)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{

}
#endif
- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
#ifdef USE_TEMPERATE_SECRET
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator, NSError *error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);    
        }
    }];
#else
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = [SecretStorage sharedInstance].secretID;
    credential.secretKey = [SecretStorage sharedInstance].secretKey;
#if QCloudCOSXMLModuleVersionNumber > 500003
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
#else
    //兼容Version没搞好的版本
    QCloudSignature* signature;
    Class authenticationClass = NSClassFromString(@"QCloudAuthentationV5Creator");
    if (authenticationClass) {
      __strong typeof(authenticationClass) creator = [[authenticationClass alloc] initWithCredential:credential];
        signature =  [creator performSelector:@selector(signatureForData:) withObject:urlRequst];
    } else {
        authenticationClass  = NSClassFromString(@"QCloudAuthentationCreator");
         __strong typeof(authenticationClass) creator = [[authenticationClass alloc] initWithCredential:credential];
        signature = [creator performSelector:@selector(signatureForCOSXMLRequest:) withObject:request];
    }
    
//    QCloudAuthentationCreator* creator = [[QCloudAuthentationCreator alloc] initWithCredential:credential];
//    QCloudSignature* signature = [creator signatureForCOSXMLRequest:request];
#endif
    continueBlock(signature, nil);
#endif
}

- (void) setupCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = [SecretStorage sharedInstance].appID;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
#ifdef CNNORTH_REGION
    endpoint.regionName = [SecretStorage sharedInstance].regionName;
#else
    endpoint.regionName = @"ap-guangzhou";
#endif
    configuration.endpoint = endpoint;

    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
#if QCloudCOSXMLModuleVersionNumber == 501000
    [QCloudCOSTransferMangerService registerdefaultCOSTransferManagerWithConfiguration:configuration];
#elif QCloudCOSXMLModuleVersionNumber <= 500003
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
#else
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupCOSXMLShareService];
#if QCloudCOSXMLModuleVersionNumber > 500003

    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
#endif
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
