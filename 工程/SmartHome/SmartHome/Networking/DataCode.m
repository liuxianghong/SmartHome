//
//  DataCode.m
//  SmartHome
//
//  Created by 刘向宏 on 16/2/1.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "DataCode.h"

#define DATA_CODE_LEN  6

#define INDEX_MAX  127



@implementation DataCode
{
    Byte mSeqHeader;
    Byte mDataHigh;
    Byte mDataLow;
    Byte mCrcHigh;
    Byte mCrcLow;
}

-(id)initWithu8:(UInt16)u8 index:(int)index{
    self = [super init];
    mDataHigh = u8 / 0x10;
    mDataLow = u8 % 0x10;
    CRC8 *cr8 = [[CRC8 alloc] init];
    [cr8 updateB:(Byte)u8];
    [cr8 updateB:index];
    short value = [cr8 getValue];
    mCrcHigh = value / 0x10;
    mCrcLow = value % 0x10;
    mSeqHeader = (Byte) index;
    return self;
}

-(NSData *)getBytes{
    Byte dataBytes[DATA_CODE_LEN];
    dataBytes[0] = 0x00;
    dataBytes[1] = [self combine2bytesToOne:mCrcHigh low:mDataHigh];
    dataBytes[2] = 0x01;
    dataBytes[3] = mSeqHeader;
    dataBytes[4] = 0x00;
    dataBytes[5] = [self combine2bytesToOne:mCrcLow low:mDataLow];
    return [NSData dataWithBytes:dataBytes length:DATA_CODE_LEN];
}

-(Byte)combine2bytesToOne:(Byte)high low:(Byte)low {
    return (Byte) (high << 4 | low);
}


@end
