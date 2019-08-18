//
//  Socket.m
//  evaKool
//
//  Created by Sierra on 2019/7/24.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import "Socket.h"
#import "crc.h"

@implementation Socket


- (void)initDevice{
    self.dataRead = [DataToBeRead alloc];
    self.dataWrite = [DataToBeWrite alloc];
}

+ (Socket *) sharedInstance
{
    static Socket *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[self alloc] init];
    });
    return sharedInstace;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}


// socket连接
-(void)socketConnectHost{
    self.socketHost = @"192.168.4.1";
    self.socketPort = 5000;
  
    //必须确认在断开连接的情况下，进行连接
    if (self.socket.isDisconnected) {
        //[self.socket connectToHost:self.socketHost onPort:self.socketPort error:nil];
        [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:nil];
    }else{
        [self.socket disconnect];
        [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:nil];
    }
}

#pragma mark  - 连接成功回调
-(void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"socket连接成功");
    [self.delegate onConnected];
    
    if(![self.connectTimer isValid]){
        self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(initData)  userInfo:nil repeats:YES];
        [self.connectTimer fire];
    }
}

/*
-(void) longConnectToSocket{
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    NSString *longConnect = @"longConnect";
    NSData   *dataStream  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:dataStream withTimeout:1 tag:1];
}
*/

//断开连接
- (void)disConnected{
    [self.socket disconnect];
}

//断开之后重新连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"sorry the connect is failure %@",sock.userData);
    //这里可以列举枚举值
    //因用户自动断开 不自动连接
    if (sock.userData == [NSNumber numberWithInt:SocketOfflineByUser])  {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
        //[self.socket setDelegate:nil];
        [self.socket disconnect];
        [self.delegate onConnectFailed];
    }
    //因服务器原因断开 自动连接
    else if (sock.userData == [NSNumber numberWithInt:SocketOfflineByServer]) {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
       // [self.socket setDelegate:nil];
        [self.socket disconnect];
       // [self.socket setDelegate:self];
        [self.socket connectToHost:self.socketHost onPort:self.socketPort error:nil];
    //因Wifi原因断开 不自动连接
    }else{
        [self.connectTimer invalidate];
        self.connectTimer = nil;
        //[self.socket setDelegate:nil];
        [self.socket disconnect];
        [self.delegate onConnectFailed];
    }
}

// 切断socket
-(void)cutOffSocket{
    self.socket.userData = [NSNumber numberWithInt:SocketOfflineByUser];
    [self.connectTimer invalidate];
    [self.socket disconnect];
}

#pragma mark - 写数据

-(void)initData{
    //获取冰箱状态
    Byte value[6] ={0};
    value[0] = 0xAA;
    value[1] = 0x01;  //获取数据指令
    value[2] = 0x00;  //固定值0x00
    int crc = CalcCRC(&value[1],3);
    value[4] = crc & 0xff;
    value[3] = (crc>>8)& 0xff;
    value[5] = 0x55;
    
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    [self.socket writeData:data withTimeout:3 tag:3];
}

-(void) writeBoard{
    //写数据
    Byte value[6] ={0};
    value[0] = 0xAA;
    value[1] = self.dataWrite.command;
    value[2] = self.dataWrite.data;
    int crc = CalcCRC(&value[1],3);
    value[4] = crc & 0xff;
    value[3] = (crc>>8)& 0xff;
    value[5] = 0x55;
    
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    [self.socket writeData:data withTimeout:3 tag:3];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //写数据成功，开始读
    if(tag==0 || tag==3){
        [self.socket readDataWithTimeout:1 tag:1];
    }
}

-(void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //读数据
    if(tag==1){
        Byte value[15] = {0};
        NSUInteger len = [data length];
        if(len>=15){
            memcpy(value, [data bytes], len);
        }
        int crc = CalcCRC(&value[1],11);
        Byte crcL8= crc & 0xff;
        Byte crcH8= (crc>>8)& 0xff;
        if(value[13]==crcL8 && value[12]==crcH8 && value[0]==0x55 && value[14]==0xAA){
            NSLog(@"read successful!");
            
            self.dataRead.power = value[1];
            self.dataRead.tempLeftReal = value[2];
            self.dataRead.tempRightReal = value[3];
            self.dataRead.tempLeftHeating = value[4];
            self.dataRead.tempRightSetting = value[5];
            self.dataRead.tempLeftHeating = value[6];
            self.dataRead.err = value[7];
            self.dataRead.type = value[8];
            self.dataRead.mode = value[9];
            self.dataRead.unit = value[10];
            self.dataRead.pattern= value[11];
            self.dataRead.crcH = value[12];
            self.dataRead.crcL = value[13];
            self.dataRead.type = value[14];
            
            [self.delegate OnDidReadData];
        }
        else{
            [self.delegate OnDataError];
        }
    }
}

/*
 @interface DataToBeRead : NSObject
 @property Byte power; //1.0x01:开机 0x00:关机
 @property Byte tempLeftReal; //2.0x00-0xff 左箱实时温度
 @property Byte tempRightReal; //3.0x00-0xff 右箱实时温度
 @property Byte tempLeftSetting; //4.0x00-0xff 左箱制冷设定温度
 @property Byte tempRightSetting; //5.0x00-0xff 右箱制冷设定温度
 @property Byte tempLeftHeating;  //6.0x00-0xff 左箱加热设定（冷热型号）
 @property Byte err;  //7.0x00-0xff 故障代码（备用）
 @property Byte type;   //8.0x00:单冷冰箱 0x01:冷热冰箱，0x02双冷冰箱
 @property Byte mode; //9.0X00:制冷模式 0X01加热模式
 @property Byte unit;    //10.0x00-摄氏度  0x01-华氏度
 @property Byte pattern;   //11.0x00-eco  0x01-turbo
 @property Byte crcH;    //12.0x00-0xff CRC校验高8位
 @property Byte crcL;    //13.0x00-0xff CRC校验低8位
 @end
*/



@end
