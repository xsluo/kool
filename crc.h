//
//  crc.h
//  evaKool
//
//  Created by Sierra on 2019/7/24.
//  Copyright © 2019年 baidu. All rights reserved.
//

#ifndef crc_h
#define crc_h

#include <stdio.h>

#define CRC_INIT  0xffff
#define M16    0xA001
unsigned int CalcCRC(unsigned char *pBuf, unsigned char ucLen);

#endif /* crc_h */
