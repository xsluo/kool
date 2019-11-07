//
//  SingleViewController.m
//  evaKool
//
//  Created by Sierra on 2019/8/7.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import "SingleViewController.h"
#import "Socket.h"
#import "SVProgressHUD.h"

@interface SingleViewController ()<SocketDelegate>
@property (strong,nonatomic) Socket *header;
@property int settingLeft,settingRight;
@end

@implementation SingleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.header = [Socket sharedInstance];
    self.header.delegate = self;
    [self.header initDevice];
    
    self.settingLeft = 0;
    
    [self.header socketConnectHost];
    
    [self.header initData];
    
    //[SVProgressHUD showWithStatus:NSLocalizedString(@"Connect",nil)];
   
    //获取ssid
    UILabel *lbSSID = (UILabel *)[self.view viewWithTag:101];
    NSString *wifiSSID = [self currentWifiSSID];
    lbSSID.text = wifiSSID;
    
    // Do any additional setup after loading the view.
    UIButton *btAdd = (UIButton *)[self.view viewWithTag:108];
    UIButton *btDec = (UIButton *)[self.view viewWithTag:109];
    UIButton *btOn = (UIButton *)[self.view viewWithTag:104];
    UIButton *btOff = (UIButton *)[self.view viewWithTag:105];
    
    
    [btAdd addTarget:self action:@selector(AddTemp) forControlEvents:UIControlEventTouchUpInside];
    [btDec addTarget:self action:@selector(DecTemp) forControlEvents:UIControlEventTouchUpInside];
    
    [btOn addTarget:self action:@selector(SetOn) forControlEvents:UIControlEventTouchUpInside];
    [btOff addTarget:self action:@selector(SetOff) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    self.header.delegate = self;
}


-(NSString *)currentWifiSSID{
    NSDictionary *info = nil;
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();

    for (NSString *ifname in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        //NSLog(@"%@ => %@",ifname,info);
    }
    if(info[@"SSID"]){
        ssid = info[@"SSID"];
        }
    return ssid;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)onConnected{
    [SVProgressHUD dismiss];
    NSLog(@"socket连接成功--single");

    //初始化app数据
    [SVProgressHUD showWithStatus:NSLocalizedString(@"read Data..",nil)];
    [self.header initData];
}

-(void)OnDidReadData{
    [SVProgressHUD dismiss];
    NSLog(@"read successful!---single");
    //UILabel *lbTempSetting = (UILabel *)[self.view viewWithTag:102];
    //lbTempSetting.text = [NSString stringWithFormat:@"%hhu℃",self.header.dataRead.tempLeftSetting];
    
    UILabel *lbTempReal = (UILabel *)[self.view viewWithTag:103];
    int16_t temp = self.header.dataRead.tempLeftReal;
    if(temp>100){
        temp -=256;
    }
    lbTempReal.text = [NSString stringWithFormat:@"%hi℃",temp];
}

-(void)onConnectBreak{
    NSLog(@"connect break!");
}

-(void)onConnectFailed{
    self.header.socket.userData = [NSNumber numberWithInt:SocketOfflineByServer];
    [self.header socketConnectHost];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Connect",nil)];
}

-(void) AddTemp{
    UILabel *lbTempSetting = (UILabel *)[self.view viewWithTag:102];
    //int value = (int)lbTempSetting.text;
    //int value = self.header.dataRead.tempLeftSetting;
    int value = self.settingLeft;
    if(value<10){
        self.settingLeft++;
        value++;
        lbTempSetting.text = [NSString stringWithFormat:@"%i℃",value];
        self.header.dataWrite.data = value;
        self.header.dataWrite.command = 0x03;
        [self.header writeBoard];
    }
}

-(void) DecTemp{
    UILabel *lbTempSetting = (UILabel *)[self.view viewWithTag:102];
    int value = self.settingLeft;
    if(value>-20){
        self.settingLeft--;
        value--;
        lbTempSetting.text = [NSString stringWithFormat:@"%i℃",value];
        self.header.dataWrite.data = value;
        self.header.dataWrite.command = 0x03;
        [self.header writeBoard];
    }
}

-(void) SetOn{
    self.header.dataWrite.data = 0x01;
    self.header.dataWrite.command = 0x02;
    [self.header writeBoard];
}

-(void)SetOff{
    self.header.dataWrite.data = 0x00;
    self.header.dataWrite.command = 0x02;
    [self.header writeBoard];
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
