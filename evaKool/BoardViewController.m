//
//  BoardViewController.m
//  Colku
//
//  Created by 罗 显松 on 2017/3/31.
//  Copyright © 2017年 neusoft. All rights reserved.
//
#import<SystemConfiguration/CaptiveNetwork.h>
#import<SystemConfiguration/SystemConfiguration.h>
#import<CoreFoundation/CoreFoundation.h>

#import "BoardViewController.h"
#import "Socket.h"
#import "SettingViewController.h"
#import "SVProgressHUD.h"


@interface BoardViewController ()<SocketDelegate>
@property (strong, nonatomic)Socket *header;
@property (weak, nonatomic) IBOutlet UILabel *upTemp;//上面冰箱温度
@property int upSliderValue;
@property (weak, nonatomic) IBOutlet UIImageView *imageRefra;
@property (nonatomic,strong) NSString *currentDeviceName;
@end

@implementation BoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentDeviceName = [[NSString alloc]init];
    
    self.header = [Socket sharedInstance];
    self.header.delegate = self;
    [self.header initData];
    
    //定时接收数据
    /*
    NSTimer *timer  =  [NSTimer  timerWithTimeInterval:1.0 target:self selector:@selector(getStatus) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
   */
    
    
    UIButton *rightButton = [self.view viewWithTag:202];
    [rightButton setTitle:NSLocalizedString(@"Setting", nil) forState:UIControlStateNormal];
    UILabel *labelBoard = [self.view viewWithTag:203];
    [labelBoard setText:NSLocalizedString(@"board", nil)];
    
    self.slider1.maximumValue = 10;
    int type = _header.dataRead.type;
    //对于单门冰箱
    if(type==0x00){
        self.slider1.minimumValue = -18;
        [self.imageRefra setImage:[UIImage imageNamed:@"cool.png"]];
    }
    else{
        self.slider1.minimumValue = -5;
        [self.imageRefra setImage:[UIImage imageNamed:@"cool3.png"]];
    }
    [self GetWifiName]; 
   // [self OnDidReadData];
}

- (void)getStatus{
    //每秒写一次数据
    [_header initData];
    NSLog(@"每秒读一次数据");
}

- (void)GetWifiName{
    //获取wifi节点名称
    NSString *wifiName = @"DEVICE";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict =CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
            if(![wifiName isEqualToString:self.currentDeviceName]){
                self.currentDeviceName = wifiName;
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"wifiConnected", nil)];
                [SVProgressHUD dismissWithDelay:1];
            }
        }
    }
    UILabel *deviceName = [self.view viewWithTag:201];
    [deviceName setText:wifiName];
}

-(void)onConnectFailed{
    self.header.socket.userData = [NSNumber numberWithInt:SocketOfflineByServer];
    [self.header socketConnectHost];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Connect",nil)];
}

-(void)OnDidReadData{
    //冰箱1温度实际值
    [SVProgressHUD dismissWithDelay:1];
    
    self.slider1.maximumValue = 10;
    int type = _header.dataRead.type;
    //对于单门冰箱
    if(type==0x00){
        self.slider1.minimumValue = -18;
        [self.imageRefra setImage:[UIImage imageNamed:@"cool.png"]];
    }
    else{
        self.slider1.minimumValue = -5;
        [self.imageRefra setImage:[UIImage imageNamed:@"cool3.png"]];
    }
    [self GetWifiName];

    
    int temperature1 = _header.dataRead.temp1H & 0xFF;
    temperature1 = temperature1<<8;
    temperature1 += _header.dataRead.temp1L;
    if(temperature1>100){
        temperature1 -= 256;  //处理负数
    }
    if(_header.dataRead.unit == 0){
        self.temp1.text = [NSString stringWithFormat:@"%d°C",temperature1];
    }
    else{
        temperature1 = (int)(temperature1 * 9.0/5 + 32 +0.5);
        self.temp1.text = [NSString stringWithFormat:@"%d°F",temperature1];
    }
    
    //冰箱1温度设定值
    int value1 = _header.dataRead.temp1;
    if(value1 >100)
        value1  -= 256;
    self.slider1.value = value1;
    if(_header.dataRead.unit == 0){
        _upTemp.text = [NSString stringWithFormat:@"%d°C",value1];
    }
    else{
        _upTemp.text = [NSString stringWithFormat:@"%d°F",(int)(value1*9.0/5 +32 +0.5)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)upItemChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    int value = (int)slider.value;
    if(abs(value - self.upSliderValue)>0.5){
        _header.dataWrite.temp1 = 0xEC + 20 + value;
        [self reFreshController];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    self.header.delegate = self;
    
    NSLog(@"调用viewWillAppear");
        // [self OnDidReadData];
    [self.header initData];
    
    
    //[self OnDidReadData];
}

-(void)reFreshController{
    _header.dataWrite.unit = _header.dataRead.unit;
    _header.dataWrite.mode = _header.dataRead.mode;
    _header.dataWrite.power = _header.dataRead.power;
    _header.dataWrite.protection = _header.dataRead.protection;
    self.header.dataWrite.temp1 = 0xEC + 20 +(int)self.slider1.value;
    
    NSLog(@"write data................");
    [self.header writeBoard];
    [self OnDidReadData];
}

#pragma 微调温度
- (IBAction)UpAdd:(id)sender {
    int value = (int) self.slider1.value;
    if(value < self.slider1.maximumValue){
        self.slider1.value++;
        [self reFreshController];
    }
}

- (IBAction)UpSub:(id)sender {
    int value = (int) self.slider1.value;
    if(value > self.slider1.minimumValue){
        self.slider1.value--;
        [self reFreshController];
    }
}

-(void) onConnectBreak{
     [SVProgressHUD showWithStatus:NSLocalizedString(@"Connect",nil)];
     [SVProgressHUD dismissWithDelay:3 completion:nil];
}

-(void)onConnected{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Successful",nil)];
    [SVProgressHUD dismissWithDelay:1];
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"readData",nil)];
 //   [self.header initData];
    
}

-(void)OnDataError{
    //数据校验不通过
    [SVProgressHUD showWithStatus:@"Data Error"];
    [SVProgressHUD dismissWithDelay:3];    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"setting"]){
        SettingViewController * destination = (SettingViewController *)[segue destinationViewController];
        
       // Byte protection = _header.dataRead.protection;
       // destination.protection = (int)(protection&0xFF);  //电池状态
        Byte unit = _header.dataRead.unit;
        destination.unit = (bool)(unit&0xFF);    //单位
        Byte mode = _header.dataRead.mode;
        destination.mode = (bool)(mode&0xFF);    //模式
        Byte power = _header.dataRead.power;
        destination.power = (bool)(power&0xFF);   //开机\关机
    }
}

@end
