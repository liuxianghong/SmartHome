//
//  CRC8.m
//  SmartHome
//
//  Created by 刘向宏 on 16/2/1.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "CRC8.h"

short CRC_POLYNOM = 0x8c;

short CRC_INITIAL = 0x00;

@implementation CRC8
{
    short crcTable[256];
    short value;
}

-(id)init{
    self = [super init];
    
    for (int dividend = 0; dividend < 256; dividend++) {
        UInt16 remainder = dividend;// << 8;
        for (int bit = 0; bit < 8; ++bit)
            if ((remainder & 0x01) != 0)
                remainder = (remainder >> 1) ^ CRC_POLYNOM;
            else
                remainder >>= 1;
        crcTable[dividend] = (short) remainder;
    }
    
    value = CRC_INITIAL;
    
    return self;
}

-(void)update:(Byte *)buffer offset:(int)offset len:(int)len{
    for (int i = 0; i < len; i++) {
        UInt16 data = buffer[offset + i] ^ value;
        value = (UInt16) (crcTable[data & 0xff] ^ (value << 8));
    }
}

-(void)update:(NSData *)buffer{
    [self update:(Byte *)[buffer bytes]  offset:0 len:(int)[buffer length]];
}


-(void)updateB:(int)b{
    Byte bb[1] = {(Byte)b};
    [self update:bb offset:0 len:1];
}

-(long)getValue{
    return value & 0xff;
}

-(void)reset{
    value = CRC_INITIAL;
}


@end
