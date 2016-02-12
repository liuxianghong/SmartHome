//
//  DatumCode.m
//  SmartHome
//
//  Created by 刘向宏 on 16/2/1.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "DatumCode.h"

int EXTRA_LEN = 40;
int EXTRA_HEAD_LEN = 5;

@implementation DatumCode
{
    NSMutableArray *mDataCodes;
}


-(instancetype)init:(NSString *)ssid bssid:(NSString *)bssid password:(NSString *)pw IPAddress:(NSString *)PAddress ssidHiden:(BOOL)isSsidHiden{
    self = [super init];
    
    NSData *pwData = [pw dataUsingEncoding:NSUTF8StringEncoding];
    UInt16 apPwdLen = [pwData length];
    
    
    NSData *ssidData = [ssid dataUsingEncoding:NSUTF8StringEncoding];
    CRC8 *cr8 = [[CRC8 alloc] init];
    [cr8 update:ssidData];
    UInt16 apSsidCrc = [cr8 getValue];
    
    NSArray *bssidSplits = [bssid componentsSeparatedByString:@":"];
    Byte *result = malloc(bssidSplits.count);
    for(int i = 0;i < bssidSplits.count; i++) {
        result[i] = strtoul([bssidSplits[i] UTF8String],0,16);
    }
    NSData *bssidData = [NSData dataWithBytesNoCopy:result length:bssidSplits.count];
    [cr8 reset];
    [cr8 update:bssidData];
    UInt16 apBssidCrc = [cr8 getValue];
    
    UInt16 apSsidLen = [ssidData length];
    
    
    NSArray *ipAddrStrs = [PAddress componentsSeparatedByString:@"."];
    UInt16 ipLen = ipAddrStrs.count;
    
    UInt16 ipAddrChar[10];
    for (int i = 0; i < ipLen; ++i) {
        ipAddrChar[i] = [ipAddrStrs[i] integerValue];
    }
    
    UInt16 _totalLen = (char) (EXTRA_HEAD_LEN + ipLen + apPwdLen + apSsidLen);
    UInt16 totalLen = isSsidHiden ? (UInt16) (EXTRA_HEAD_LEN + ipLen + apPwdLen + apSsidLen)
				: (UInt16) (EXTRA_HEAD_LEN + ipLen + apPwdLen);
    
    UInt16 totalXor = 0;
    
    mDataCodes = [[NSMutableArray alloc]init];
    [mDataCodes addObject:[[DataCode alloc] initWithu8:_totalLen index:0]];
    totalXor ^= _totalLen;
    [mDataCodes addObject:[[DataCode alloc] initWithu8:apPwdLen index:1]];
    totalXor ^= apPwdLen;
    [mDataCodes addObject:[[DataCode alloc] initWithu8:apSsidCrc index:2]];
    totalXor ^= apSsidCrc;
    [mDataCodes addObject:[[DataCode alloc] initWithu8:apBssidCrc index:3]];
    totalXor ^= apBssidCrc;
    [mDataCodes addObject:[[DataCode alloc] initWithu8:apBssidCrc index:4]];
    for (int i = 0; i < ipLen; ++i) {
        [mDataCodes addObject:[[DataCode alloc] initWithu8:ipAddrChar[i] index:(i + EXTRA_HEAD_LEN)]];
        totalXor ^= (UInt16)ipAddrChar[i];
    }
    
    Byte *apPwdBytes = (Byte *)[pwData bytes];
    for (int i = 0; i < apPwdLen; i++) {
        [mDataCodes addObject:[[DataCode alloc] initWithu8:(UInt16)apPwdBytes[i] index:(UInt16)(i + EXTRA_HEAD_LEN + ipLen)]];
        totalXor ^= (UInt16)apPwdBytes[i];
    }
    
    Byte *apSsidBytes = (Byte *)[ssidData bytes];
    for (int i = 0; i < ssidData.length; i++) {
        totalXor ^= (UInt16)apSsidBytes[i];
    }
    
    if (isSsidHiden) {
        for (int i = 0; i < apSsidLen; i++) {
            [mDataCodes addObject:[[DataCode alloc] initWithu8:(UInt16)apSsidBytes[i] index:(UInt16)(i + EXTRA_HEAD_LEN + ipLen + apPwdLen)]];
        }
    }
    
    // set total xor last
    [mDataCodes replaceObjectAtIndex:4 withObject:[[DataCode alloc] initWithu8:totalXor index:4]];
    return self;
}

-(NSData *)getBytes{
    int DATA_CODE_LEN = 6;
    Byte *byte = malloc(mDataCodes.count * DATA_CODE_LEN);
    for (int i = 0; i < mDataCodes.count; i++) {
        NSData *ddd = [mDataCodes[i] getBytes];
        memcpy(byte + i*DATA_CODE_LEN, [ddd bytes], DATA_CODE_LEN);
    }
    NSData *dara2 = [NSData dataWithBytes:byte length:(mDataCodes.count * DATA_CODE_LEN)];
    free(byte);
    return dara2;
}

-(NSData *)getU8s{
    NSData *data = [self getBytes];
    Byte *dataBytes = (Byte *)[data bytes];
    NSUInteger len = data.length / 2;
    UInt16 *dataU8s = malloc(len * sizeof(UInt16));
    Byte high, low;
    for (int i = 0; i < len; i++) {
        high = dataBytes[i * 2];
        low = dataBytes[i * 2 + 1];
        UInt16 ddd = (UInt16) ([self combine2bytesToU16:high low:low] + EXTRA_LEN);
        dataU8s[i] = ddd;
    }
    NSData *dara2 = [NSData dataWithBytes:dataU8s length:len * sizeof(UInt16)];
    free(dataU8s);
    return dara2;
}

-(UInt16)combine2bytesToU16:(Byte)high low:(Byte)low {
    UInt16 highU8 = (UInt16)(high & 0xff);
    UInt16 lowU8 = (UInt16)(low & 0xff);
    UInt16 h = highU8 << 8;
    return (UInt16) (h | lowU8);
}
@end
