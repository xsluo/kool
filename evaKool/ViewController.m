//
//  ViewController.m
//  demoSocket
//
//  Created by 罗 显松 on 2017/6/24.
//  Copyright © 2017年 neusoft. All rights reserved.
//

#import "ViewController.h"
#import "Socket.h"
#import "SVProgressHUD.h"

@interface ViewController ()
@property (strong, nonatomic)Socket *header;
- (IBAction)Connectwifi:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button0 =(UIButton*) [self.view viewWithTag:101];
    [button0 setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
    
    self.header = [Socket sharedInstance];
    self.header.delegate = self;
    [self.header initDevice];
    //初始化读写缓冲
    //[self.header initBuff];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Connectwifi:(id)sender {
    [self.header socketConnectHost];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Connect",nil)];
}

-(void)onConnected{
    [SVProgressHUD dismiss];
    //初始化数据
    [self.header initData];
}

-(void)onConnectFailed{
    [SVProgressHUD dismiss];
    UIAlertController*alert = [UIAlertController
                               alertControllerWithTitle: NSLocalizedString(@"Alert", nil)
                               message: NSLocalizedString(@"请选择wifi", nil)
                               preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }
    }]];
    //弹出提示框
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)OnDidReadData{
    NSLog(@"read data successful!----entrance");
    if(self.header.dataRead.type == 0x00){
         [self performSegueWithIdentifier:@"showSingle" sender:self]; //单冷冰箱
    }else if(self.header.dataRead.type == 0x01){
         [self performSegueWithIdentifier:@"showDouble" sender:self]; //冷热冰箱
    }else{
         [self performSegueWithIdentifier:@"showDouble" sender:self]; //双冷冰箱？
    }
}

@end
