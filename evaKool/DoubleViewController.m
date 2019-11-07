//
//  DoubleViewController.m
//  evaKool
//
//  Created by Sierra on 2019/8/7.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import "DoubleViewController.h"
#import "Socket.h"
#import "SVProgressHUD.h"


@interface DoubleViewController () <SocketDelegate>
@property (strong,nonatomic) Socket *header;
@property int settingLeft,settingRight;
@end

@implementation DoubleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.header = [Socket sharedInstance];
    self.header.delegate = self;
    [self.header initDevice];
    
    self.settingLeft = 0;
    self.settingRight = 0;
    
    [self.header socketConnectHost];
    [self.header initData];

    //获取ssid
    UILabel *lbSSID = (UILabel *)[self.view viewWithTag:101];
    NSString *wifiSSID = [self currentWifiSSID];
    lbSSID.text = wifiSSID;
    
    // Do any additional setup after loading the view.
    UIButton *btAddLeft = (UIButton *)[self.view viewWithTag:106];
    UIButton *btDecLeft = (UIButton *)[self.view viewWithTag:107];
    UIButton *btAddRight = (UIButton *)[self.view viewWithTag:108];
    UIButton *btDecRight = (UIButton *)[self.view viewWithTag:109];
    
    UIButton *btOn = (UIButton *)[self.view viewWithTag:110];
    UIButton *btOff = (UIButton *)[self.view viewWithTag:111];
    
    [btAddLeft addTarget:self action:@selector(AddTempLeft) forControlEvents:UIControlEventTouchUpInside];
    [btDecLeft addTarget:self action:@selector(DecTempLeft) forControlEvents:UIControlEventTouchUpInside];
    [btAddRight addTarget:self action:@selector(AddTempRight) forControlEvents:UIControlEventTouchUpInside];
    [btDecRight addTarget:self action:@selector(DecTempRight) forControlEvents:UIControlEventTouchUpInside];
    
    
    [btOn addTarget:self action:@selector(SetOn) forControlEvents:UIControlEventTouchUpInside];
    [btOff addTarget:self action:@selector(SetOff) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)viewWillAppear:(BOOL)animated{
      self.header.delegate = self;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void) onConnected{
    NSLog(@"socket连接成功!-Double");
    //初始化app数据
    [SVProgressHUD dismiss];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"read Data..",nil)];
    [self.header initData];
}

-(void)OnDidReadData{
    [SVProgressHUD dismiss];
    NSLog(@"read successful!---double");
    
    UILabel *lbTempRealLeft = (UILabel *)[self.view viewWithTag:104];
    int16_t tempL = self.header.dataRead.tempLeftReal;
    if(tempL>100){
        tempL -=256;
    }
    lbTempRealLeft.text = [NSString stringWithFormat:@"%hi℃",tempL];
    
    UILabel *lbTempRealRight = (UILabel *)[self.view viewWithTag:105];
    int16_t tempR = self.header.dataRead.tempRightReal;
    if(tempR>100){
        tempR -=256;
    }
    lbTempRealRight.text = [NSString stringWithFormat:@"%hi℃",tempR];
}

-(void)onConnectBreak{
      NSLog(@"connect break!");
}



-(void)onConnectFailed{
    self.header.socket.userData = [NSNumber numberWithInt:SocketOfflineByServer];
    [self.header socketConnectHost];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Connect",nil)];
}

-(void) AddTempLeft{
    UILabel *lbTempSetting = (UILabel *)[self.view viewWithTag:102];
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

-(void) DecTempLeft{
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

-(void) AddTempRight{
    UILabel *lbTempSetting = (UILabel *)[self.view viewWithTag:103];
    int value = self.settingRight;
    if(value<10){
        self.settingRight++;
        value++;
        lbTempSetting.text = [NSString stringWithFormat:@"%i℃",value];
        self.header.dataWrite.data = value;
        self.header.dataWrite.command = 0x04;
        [self.header writeBoard];
    }
}

-(void) DecTempRight{
    UILabel *lbTempSetting = (UILabel *)[self.view viewWithTag:103];
    int value = self.settingRight;
    if(value>-20){
        self.settingRight--;
        value--;
        lbTempSetting.text = [NSString stringWithFormat:@"%i℃",value];
        self.header.dataWrite.data = value;
        self.header.dataWrite.command = 0x04;
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
