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
    /*
    Byte value[10] = {0xaa,0x02,0x00,0x00,0x00,0x00,0x00,0xf9,0x01,0x55};
    //aa 02 00 00 00 00 00 f9 01 55
    NSData *dataStream = [NSData dataWithBytes:value length:10];
    [self.header.socket writeData:dataStream withTimeout:1 tag:0];
     */
}

-(void)onConnectFailed{
    [SVProgressHUD dismiss];
    UIAlertController*alert = [UIAlertController
                               alertControllerWithTitle: NSLocalizedString(@"Alert", nil)
                               message: NSLocalizedString(@"Alertmsg", nil)
                               preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }]];
    //弹出提示框
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)OnDidReadData{
    [self performSegueWithIdentifier:@"showtemp" sender:self];
}

@end
