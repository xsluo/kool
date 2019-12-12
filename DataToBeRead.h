//
//  DataToBeRead.h
//  evaKool
//
//  Created by Sierra on 2019/7/24.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataToBeRead : NSObject
@property Byte start;  //0.0x55 通讯开始
@property Byte power; //1.0x01:开机 0x00:关机
@property Byte tempLeftReal; //2.0x00-0xff 左箱实时温度
@property Byte tempRightReal; //3.0x00-0xff 右箱实时温度
@property Byte tempLeftSetting; //4.0x00-0xff 左箱制冷设定温度
@property Byte tempRightSetting; //5.0x00-0xff 右箱制冷设定温度
@property Byte tempLeftHeating;  //6.0x00-0xff 左箱加热设定（冷热型号）
@property Byte err;  //7.0x00-0xff 故障代码（备用）
@property Byte type;   //8.0x00:单冷冰箱 0x01:冷热冰箱，0x02双冷冰箱
@property Byte pattern; //9.0X00:制冷模式 0X01加热模式
@property Byte unit;    //10.0x00-摄氏度  0x01-华氏度
@property Byte mode;   //11.0x00-eco  0x01-turbo
@property Byte crcH;    //12.0x00-0xff CRC校验高8位
@property Byte crcL;    //13.0x00-0xff CRC校验低8位
@property Byte end;     //14.0xaa 通讯结束
@end

/*
 单冷型号可以忽略数位：3，5，6，9。
 冷热型号可以忽略数位：3，5。//没有冷热型号,数位备用
 双冷型号可以忽略数位：6，9。
*/
