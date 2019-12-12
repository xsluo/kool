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

//Byte unit;
//Byte mode;

@interface SettingViewController ()<SocketDelegate>
@property (strong,nonatomic) Socket *header;
@property  Byte unit;
//@property  Byte mode;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.header = [Socket sharedInstance];
    self.header.delegate = self;
   // [self.header initDevice];
    
    //unit = self.header.dataRead.unit;
    //mode = self.header.dataRead.mode;

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


-(void)OnDidReadData{
    //unit = self.header.dataRead.unit;
    //mode = self.header.dataRead.mode;
    //NSLog(@"unit is ---%i",unit);
    Byte onOff = self.header.dataRead.power;
    Byte unitNow = self.header.dataRead.unit;
    Byte modeNow = self.header.dataRead.mode;
    
    UIButton *btUnit = (UIButton *)[self.view viewWithTag:103];
    UIButton *btMode = (UIButton *)[self.view viewWithTag:104];
    
    if(onOff == 0x00){
        [btUnit setEnabled:NO];
        [btMode setEnabled:NO];
        if(unitNow == 0x00){
            [btUnit setImage:[UIImage imageNamed:@"celsiusOff.png"] forState:UIControlStateDisabled];
        }else{
            [btUnit setImage:[UIImage imageNamed:@"fahrenheitOff.png"] forState:UIControlStateDisabled];
        }
        if(modeNow == 0x00){
            [btMode setImage:[UIImage imageNamed:@"ecoOff.png"] forState:UIControlStateDisabled];
        }else{
            [btMode setImage:[UIImage imageNamed:@"turboOff.png"] forState:UIControlStateDisabled];
        }
    }else{
        [btUnit setEnabled:YES];
        [btMode setEnabled:YES];
        if(unitNow == 0x00){
            [btUnit setImage:[UIImage imageNamed:@"celsius.png" ] forState:UIControlStateNormal];
        }else{
            [btUnit setImage:[UIImage imageNamed:@"fahrenheit.png"] forState:UIControlStateNormal];
        }
        if(modeNow == 0x00){
            [btMode setImage:[UIImage imageNamed:@"eco.png"] forState:UIControlStateNormal];
        }else{
            [btMode setImage:[UIImage imageNamed:@"turbo.png"] forState:UIControlStateNormal];
        }
    }
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
    UIButton *btUnit = (UIButton *)[self.view viewWithTag:103];
    Byte unitNow = self.header.dataRead.unit;

    //此处似乎有逻辑错误
    if(unitNow == 0x01){
        unitNow = 0x01;
        //[btUnit setImage:[UIImage imageNamed:@"celsius.png"] forState:UIControlStateNormal];
    }else if(unitNow ==0x00){
        unitNow = 0x00;
        //[btUnit setImage:[UIImage imageNamed:@"fahrenheit.png"] forState:UIControlStateNormal];
    }
    self.header.dataWrite.data = unitNow;
    self.header.dataWrite.command = 0x07;
    [self.header writeBoard];
    
}

-(void)SetMode{
    UIButton *btMode = (UIButton *)[self.view viewWithTag:104];
    Byte modeNow = self.header.dataRead.mode;
    
    if(modeNow==0x01){
        modeNow = 0x00;
        [btMode setImage:[UIImage imageNamed:@"eco.png"] forState:UIControlStateNormal];
    }else if(modeNow == 0x00){
        modeNow = 0x01;
        [btMode setImage:[UIImage imageNamed:@"turbo.png"] forState:UIControlStateNormal];
    }
    self.header.dataWrite.data = modeNow;
    self.header.dataWrite.command = 0x08;
    [self.header writeBoard];
}

-(void) SetWifi{
    [SVProgressHUD dismiss];
    UIAlertController*alert = [UIAlertController
                               alertControllerWithTitle: NSLocalizedString(@"Alert", nil)
                               message: NSLocalizedString(@"Please connect WiFi in the settings", nil)
                               preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }
    }]];
    //弹出提示框
    [self presentViewController:alert animated:YES completion:nil];
}


@end
