//
//  DataToBeWrite.h
//  evaKool
//
//  Created by Sierra on 2019/7/24.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
@interface DataToBeWrite : NSObject
@property Byte start;   //0.通讯开始
@property Byte power;   //1.0x01:开机 0x00:关机  0x02获取冰箱状态
@property Byte temp1;   //2.0XEC:-20  0X0A:10 温度设定1
@property Byte temp2;   //3.0XEC:-20  0XFB:-5 温度设定2
@property Byte mode;    //4.0x00: ECO模式 0x01:Turbo模式
@property Byte protection;  //5.电池保护设定 0-L 1-M 2-H
@property Byte unit;     //6.华氏或摄氏显示 0：摄氏 1：华氏
@property Byte crcH;     //7.CRC校验高8位
@property Byte crcL;     //8.CRC校验低8位
@property Byte end;      //9.通讯结束

-(void)baseInit;
@end
*/

@interface DataToBeWrite : NSObject
@property Byte start;     //0.0xAA 通讯开始
@property Byte command;   //1.0x?? 8种指令a
@property Byte data;      //2.0x?? 数值b
@property Byte crcH;      //3.0x?? CRC校验高8位
@property Byte crcL;      //4.0x?? CRC校验低8位
@property Byte end;       //5.0x55 通讯结束
@end
