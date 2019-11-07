//
//  SettingViewController.m
//  evaKool
//
//  Created by user on 2019/11/6.
//  Copyright © 2019 baidu. All rights reserved.
//

#import "Socket.h"
#import "SVProgressHUD.h"
#import "SettingViewController.h"

@interface SettingViewController ()<SocketDelegate>
@property (strong,nonatomic) Socket *header;
@property Byte unit;
@property Byte mode;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.header = [Socket sharedInstance];
    self.header.delegate = self;
    [self.header initDevice];
    
    [self.header socketConnectHost];
    [self.header initData];
    
    // Do any additional setup after loading the view.
    UIButton *btBack = (UIButton *)[self.view viewWithTag:101];
    [btBack addTarget:self action:@selector(SetBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btWifi = (UIButton *)[self.view viewWithTag:102];
    [btWifi addTarget:self action:@selector(SetWifi) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btUnit = (UIButton *)[self.view viewWithTag:103];
    [btUnit addTarget:self action:@selector(SetUnit) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btMode = (UIButton *)[self.view viewWithTag:104];
    [btMode addTarget:self action:@selector(SetMode) forControlEvents:UIControlEventTouchUpInside];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)OnDidReadData{
    self.unit = self.header.dataRead.unit;
    self.mode = self.header.dataRead.mode;
    NSLog(@"unit is ---%i",self.unit);
}

-(void)onConnectFailed{
    [self.header socketConnectHost];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Connect",nil)];
}

-(void)onConnected{
    NSLog(@"connect setting successful!");
    [SVProgressHUD dismiss];
}

-(void) SetBack{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) SetUnit{
    if(self.unit==0x01){
        self.unit = 0x00;
    }else if(self.unit == 0x00){
        self.unit = 0x01;
    }
    self.header.dataWrite.data = self.unit;
    self.header.dataWrite.command = 0x07;
    [self.header writeBoard];
}

-(void) SetWifi{
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


-(void)SetMode{
    if(self.mode==0x01){
        self.mode = 0x00;
    }else if(self.mode == 0x00){
        self.mode = 0x01;
    }
    self.header.dataWrite.data = self.mode;

    self.header.dataWrite.command = 0x08;
    [self.header writeBoard];
}

@end
