//
//  SettingViewController.h
//  Colku
//
//  Created by 罗 显松 on 2017/3/31.
//  Copyright © 2017年 neusoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController

/*
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentprotection;

@property (weak, nonatomic) IBOutlet UISwitch *switchUnint;
@property (weak, nonatomic) IBOutlet UISwitch *switchmode;
@property (weak, nonatomic) IBOutlet UISwitch *switchPower;
*/

@property (weak, nonatomic) IBOutlet UIButton *buttonUnit;
@property (weak, nonatomic) IBOutlet UIButton *buttonMode;
@property (weak, nonatomic) IBOutlet UIButton *buttonON;
@property (weak, nonatomic) IBOutlet UIButton *buttonOff;

@property Boolean unit;
@property Boolean mode;
@property Boolean power;

@end
