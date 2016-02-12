//
//  Msg.m
//  SmartHome
//
//  Created by 刘向宏 on 16/2/5.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "Msg.h"
#import "CRC16.h"

int packLeng = 21;

@implementation Msg

-(instancetype)init{
    self = [super init];
    self.state = 0x02;
    return self;
}

-(instancetype)initWithDevid:(NSData *)devId cmdType:(Byte)cmdType cmd:(Byte)cmd
{
    self = [super init];
    self.devId = devId;
    self.cmdType = cmdType;
    self.cmd = cmd;
    self.state = 0x02;
    return self;
}

-(BOOL)enCode{
    
    int len = (int)self.data.length;// + packLeng+msg.getTorken().length+1;
    len += packLeng + 1;
    if (self.token != nil) {
        len += self.token.length;
    }
    long val = 0;
    int index = 0;
    int i = 0;
    NSData *torken;
    int buffLength = 0;
    Byte *buff = malloc(len);
    int daLength = 0;
    Byte *da = malloc(len * 2);
    
    // buff[index++] = 0x55;
    // 长度
    buff[index++] = (Byte) (len % 256);
    buff[index++] = (Byte) (len / 256);
    // 命令类别
    buff[index++] = (Byte) (self.cmdType);
    // 命令字
    buff[index++] = (Byte) (self.cmd);
    // 扩展信息 包括序号，加密等其它扩展
    buff[index++] = 0;
    buff[index++] = 0;
    buff[index++] = 0;
    buff[index++] = 0;
    // 状态
    buff[index++] = (Byte) (self.state);
    
    // 设备ID
    torken = self.devId;
    val = torken.length;
    
    for (int j = 0; j < 8; j++) {
        if (j < val) {
            buff[index++] = ((Byte *)[torken bytes])[j];
        } else {
            buff[index++] = 0;
        }
    }
    
    // Torken 通信令牌，登录成功后才有此字段,第一字节表示长度
    torken = self.token;
    if (torken == nil) {
        val = 0;
    } else {
        val = torken.length;
    }
    
    buff[index++] = (Byte) (val % 256);
    for (int j = 0; j < val; j++) {
        buff[index++] = ((Byte *)[torken bytes])[j];
    }
    
    if (self.data.length > 0) {
        memcpy(buff+index, [self.data bytes], self.data.length);
        index += self.data.length;
    }
    
    buffLength = index;
    
    //
    Byte *b = malloc(index + 1);
    b[0] = 0x55;
    for (int m = 1; m <= index; m++) {
        b[m] = buff[m - 1];
    }
    // cs
    CRC16 *crc = [[CRC16 alloc] init];
    [crc reset];
    [crc update:b off:0 len:index+1];
    long cs = [crc getValue];
    
    daLength = 0;
    index = 0;
    da[index++] = 0x55;
    for (i = 0; i < buffLength; i++, index++)// 编码 55=> 54 01 54=> 54 02
    {
        da[index] = buff[i];
        if (buff[i] == 0x55) {
            da[index] = 0x54;
            index++;
            da[index] = 0x01;
        } else if (buff[i] == 0x54) {
            da[index] = 0x54;
            index++;
            da[index] = 0x02;
        }
        
    }
    daLength = index;
    
    Byte csVal = (Byte) (cs / 256);
    if (csVal == 0x54) {
        da[daLength++] = 0x54;
        da[daLength++] = 0x02;
    } else if (csVal == 0x55) {
        da[daLength++] = 0x54;
        da[daLength++] = 0x01;
    } else {
        da[daLength++] = csVal;
    }
    csVal = (Byte) (cs % 256);
    if (csVal == 0x54) {
        da[daLength++] = 0x54;
        da[daLength++] = 0x02;
    } else if (csVal == 0x55) {
        da[daLength++] = 0x54;
        da[daLength++] = 0x01;
    } else {
        da[daLength++] = csVal;
    }
    // 包尾
    da[daLength++] = 0x55;
    self.sendData = [NSData dataWithBytes:da length:daLength];
    free(b);
    free(buff);
    free(da);
    return YES;
}

+(Msg *)MsgWithData:(NSData *)data{
    //NSLog(@"%@",data);
    data = [Msg codeData:data];
    //NSLog(@"%@",data);
    int len = 0;
    int val = 0;
    if (nil == data) {
        return nil;
    }
    Msg *msg = [[Msg alloc] init];
    msg.reciveData = data;
    Byte da[1024];
    Byte *ddata = (Byte *)[data bytes];
    // 长度
    len = ddata[2];
    len *= 256;
    len += ddata[1];
    if (len != data.length) {
        return nil;
    }
    // 命令类别
    msg.cmdType = ddata[3];
    // 命令字
    msg.cmd = ddata[4];
    // 命令序号 data[5][6]
    // 扩展信息 data[7][8]
    // 状态
    msg.state = ddata[9];
    // 设备ID
    Byte b[8];
    b[0] = ddata[10];
    b[1] = ddata[11];
    b[2] = ddata[12];
    b[3] = ddata[13];
    b[4] = ddata[14];
    b[5] = ddata[15];
    b[6] = ddata[16];
    b[7] = ddata[17];
    msg.devId = [NSData dataWithBytes:b length:8];
    // Torken
    val = ddata[18];
    if (val > (len - packLeng)) {
        return nil;
    }
    msg.token = [NSData dataWithBytes:ddata+19 length:val];
    
    len -= packLeng + val + 1;
    if (len > 0) {
        memcpy(da, ddata + packLeng + val - 2, len);
        msg.data = [NSData dataWithBytes:da length:len];
    }
    
    return msg;
}

+(NSData *)codeData:(NSData *)dataB{
    if (dataB.length == 0) {
        return nil;
    }
    int len = (int)dataB.length;
    int i = 0;
    int buffLength = 0;
    Byte *data = (Byte *)[dataB bytes];
    Byte *buff = malloc(len * 2);
    // 把0x54 0x02还原成0x54 把0x54 0x01还原成0x55
    buff[buffLength++] = 0x55;
    for (i = 1; i < len - 1; i++) {
        buff[buffLength++] = data[i];
        if (data[i] == 0x54) {
            if (data[i + 1] == 0x01) {
                buff[buffLength - 1] = 0x55;
                i++;
                continue;
            }
            if (data[i + 1] == 0x02) {
                buff[buffLength - 1] = 0x54;
                i++;
                continue;
            }
            //buff[buffLength++] = data[i];
        }
    }
    buff[buffLength++] = data[i];
    if (buffLength < 9) {
        // ok = false;
        return nil;
    }
    NSData *rdata = [NSData dataWithBytes:buff length:buffLength];
    free(buff);
    return rdata;
}
@end
