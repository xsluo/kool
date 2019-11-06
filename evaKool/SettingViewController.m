//
//  SettingViewController.m
//  Colku
//
//  Created by 罗 显松 on 2017/3/31.
//  Copyright © 2017年 neusoft. All rights reserved.
//

#import "SettingViewController.h"
#import "Socket.h"
#import "SVProgressHUD.h"

@interface SettingViewController () <SocketDelegate>
@property (strong, nonatomic)Socket *header;
@end

@implementation SettingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self OnDidReadData];
    // Do any additional setup after loading the view.
    
    self.header = [Socket sharedInstance];
    self.header.delegate = self;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 255/255.0, 255/255.0, 255/255.0, 1 });
    
    [_buttonMode.layer setMasksToBounds:YES];
    [_buttonMode.layer setCornerRadius:3.0]; //设置矩圆角半径
    [_buttonMode.layer setBorderWidth:1.0];   //边框宽度
    [_buttonMode.layer setBorderColor:colorref];//边框颜色
    
    [_buttonUnit.layer setMasksToBounds:YES];
    [_buttonUnit.layer setCornerRadius:3.0]; //设置矩圆角半径
    [_buttonUnit.layer setBorderWidth:1.0];   //边框宽度
    [_buttonUnit.layer setBorderColor:colorref];//边框颜色
    
    [_buttonON.layer setMasksToBounds:YES];
    [_buttonON.layer setCornerRadius:3.0]; //设置矩圆角半径
    [_buttonON.layer setBorderWidth:1.0];   //边框宽度
    [_buttonON.layer setBorderColor:colorref];//边框颜色
    
    [_buttonOff.layer setMasksToBounds:YES];
    [_buttonOff.layer setCornerRadius:3.0]; //设置矩圆角半径
    [_buttonOff.layer setBorderWidth:1.0];   //边框宽度
    [_buttonOff.layer setBorderColor:colorref];//边框颜色
    
    
    // Do any additional setup after loading the view.
    UIButton *button0 =(UIButton*) [self.view viewWithTag:100];
    [button0 setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    
    UILabel *label1 =(UILabel*) [self.view viewWithTag:101];
    [label1 setText:NSLocalizedString(@"DeviceSelect", nil)];
    
    UILabel *label2 =(UILabel*) [self.view viewWithTag:201];
    [label2 setText:NSLocalizedString(@"UnitSelect", nil)];
    
    UILabel *label3 =(UILabel*) [self.view viewWithTag:301];
    [label3 setText:NSLocalizedString(@"ModeSelect", nil)];
    
    UIButton *button4 =(UIButton*) [self.view viewWithTag:401];
    [button4 setTitle:NSLocalizedString(@"PowerON", nil) forState:UIControlStateNormal];

    UIButton *button5 =(UIButton*) [self.view viewWithTag:402];
    [button5 setTitle:NSLocalizedString(@"PowerOFF", nil) forState:UIControlStateNormal];
    
    UILabel *label5 =(UILabel*) [self.view viewWithTag:501];
    [label5 setText:NSLocalizedString(@"LabelSetting", nil)];

}

- (void)getStatus{
    //每秒写一次数据
    [_header initData];
    NSLog(@"每秒读一次数据");
}

-(void)OnDidReadData{
    [SVProgressHUD dismissWithDelay:3 completion:nil];
    
    if(!self.unit){
        [self.buttonUnit setTitle:@"°C" forState:UIControlStateNormal];
    }
    else{
        [self.buttonUnit setTitle:@"°F" forState:UIControlStateNormal];
    }
    
    //工作模式
    if(!self.mode){
        [self.buttonMode setTitle:NSLocalizedString(@"Eco",nil) forState:UIControlStateNormal];
    }
    else{
        [self.buttonMode setTitle:NSLocalizedString(@"Turbo",nil) forState:UIControlStateNormal];
    }
    
    //电源开关
    if(!self.power){
        [self.buttonOff setBackgroundColor:[UIColor grayColor]];
    }
    else{
        [self.buttonON setBackgroundColor:[UIColor grayColor]];
    }
}

-(void)onConnectBreak{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Connect",nil)];
    //[SVProgressHUD dismissWithDelay:3 completion:nil];
}

-(void)onConnected{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Successful",nil)];
    [SVProgressHUD dismissWithDelay:1];
    //[self.header initData];
}

-(void)OnDataError{
    //数据校验不通过
    [SVProgressHUD showWithStatus:@"Data Error"];
    [SVProgressHUD dismissWithDelay:3];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeRefra:(id)sender {
    //切换目标冰箱
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Caution", nil)  message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel",nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *changeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"change" ,nil)style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        [self.header cutOffSocket];
    }];
    
    UIAlertAction *disconnectAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"disconnect" ,nil)style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){

        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        [self.header cutOffSocket];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:changeAction];
    [alertController addAction:disconnectAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


//因为wifi原因连接不上
-(void)onConnectFailed{
    [self.header socketConnectHost];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Connect",nil)];
}

- (IBAction)changeUnit:(id)sender {
    self.unit = !self.unit;
    [self reFreshController];
   // [self OnDidReadData];
}

- (IBAction)changMode:(id)sender {
    self.mode = !self.mode;
    [self reFreshController];
   // [self OnDidReadData];
}

- (IBAction)powerON:(id)sender {
    if(!self.power){
        [self.buttonON setBackgroundColor:[UIColor grayColor]];
        [self.buttonOff setBackgroundColor:nil];
        self.power = !self.power;
    }
    [self reFreshController];
   // [self OnDidReadData];
}

- (IBAction)powerOFF:(id)sender {
    if(self.buttonOff.selected == NO){
        [self.buttonOff setBackgroundColor:[UIColor grayColor]];
        [self.buttonON setBackgroundColor:nil];
        self.power = !self.power;
    }
    [self reFreshController];
   // [self OnDidReadData];
}

-(void)reFreshController{
    _header.dataWrite.protection = _header.dataRead.protection;
    _header.dataWrite.unit = self.unit;
    _header.dataWrite.mode = self.mode;
    _header.dataWrite.power = self.power;
    
    self.header.dataWrite.temp1 = self.header.dataRead.temp1;
    //self.header.dataWrite.temp2 = 0xEC + 20 +(int)self.slider2.value;
    
    NSLog(@"write data................");
    [self.header writeBoard];
}

- (IBAction)backToBoard:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //[self initController];
}
@end
