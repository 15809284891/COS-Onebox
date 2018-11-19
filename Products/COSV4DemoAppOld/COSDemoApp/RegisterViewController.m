//
//  RegisterViewController.m
//  COSDemoApp
//
//  Created by 贾立飞 on 16/9/12.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "RegisterViewController.h"
#import "Congfig.h"


@interface RegisterViewController ()
{
    UITextField *bucketF;
    UITextField *dirF;
    UITextField *regionF;
    UITextField *fileNameF;

}
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    bucketF = [[UITextField alloc] init];
    bucketF.placeholder = @"bucket";
    bucketF.text =  [Congfig instance].bucket;
    [self.view addSubview:bucketF];
    bucketF.contentMode = UIViewContentModeScaleToFill;
    bucketF.backgroundColor = UIColorFromRGB(0x1da5fe);
    bucketF.alpha = 0.5;
    [bucketF setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(self.view, bucketF);
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[bucketF(>=100)]-10-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[bucketF(>=30)]" options:0 metrics:nil views:views]];
    
    dirF = [[UITextField alloc] init];
    dirF.placeholder = @"目录";
    dirF.text =  [Congfig instance].dir;

    [self.view addSubview:dirF];
    dirF.contentMode = UIViewContentModeScaleToFill;
    dirF.backgroundColor = UIColorFromRGB(0x1da5fe);
    dirF.alpha = 0.5;
    [dirF setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    views = NSDictionaryOfVariableBindings(self.view, dirF);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[dirF(>=100)]-10-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[dirF(>=30)]" options:0 metrics:nil views:views]];
    
    regionF = [[UITextField alloc] init];
    regionF.placeholder = @"地域";
    regionF.text =  [Congfig instance].region;

    [self.view addSubview:regionF];
    regionF.contentMode = UIViewContentModeScaleToFill;
    regionF.backgroundColor =UIColorFromRGB(0x1da5fe);
    regionF.alpha = 0.5;
    [regionF setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    views = NSDictionaryOfVariableBindings(self.view, regionF);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[regionF(>=100)]-10-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-160-[regionF(>=30)]" options:0 metrics:nil views:views]];
    
    
    fileNameF = [[UITextField alloc] init];
    fileNameF.placeholder = @"fileName";
    [self.view addSubview:fileNameF];
    fileNameF.text =  [Congfig instance].fileName;

    fileNameF.contentMode = UIViewContentModeScaleToFill;
    fileNameF.backgroundColor = UIColorFromRGB(0x1da5fe);
    fileNameF.alpha = 0.5;
    [fileNameF setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    views = NSDictionaryOfVariableBindings(self.view, fileNameF);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[fileNameF(>=100)]-10-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-210-[fileNameF(>=30)]" options:0 metrics:nil views:views]];
    
    int64_t btnW = (kScreenWidth-40)/2;
    UIButton *zhuce  = [UIButton buttonWithType:UIButtonTypeCustom];
    zhuce.frame = CGRectMake((kScreenWidth-btnW)/2, 300, btnW, 40);
    [self.view addSubview:zhuce];
    [zhuce setBackgroundColor:UIColorFromRGB(0x1da5fe)];
    [zhuce setTitle:@"确定" forState:UIControlStateNormal];
    [zhuce addTarget:self action:@selector(zhuce) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [bucketF resignFirstResponder];
    [dirF resignFirstResponder];
    [regionF resignFirstResponder];
    [fileNameF resignFirstResponder];
}

-(void)zhuce
{
    if (bucketF.text.length >0) {
        [Congfig instance].bucket  = bucketF.text;
    }
//    if (dirF.text.length >= 0) {
        [Congfig instance].dir  = dirF.text;
 //   }
    if (fileNameF.text.length >0) {
        [Congfig instance].fileName  = fileNameF.text;
    }
    if (regionF.text.length >0) {
        [Congfig instance].region = regionF.text;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
