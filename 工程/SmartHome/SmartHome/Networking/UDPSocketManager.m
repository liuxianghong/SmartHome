//
//  UDPSocketManager.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/29.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "UDPSocketManager.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <GCDAsyncUdpSocket.h>
#import "DatumCode.h"
#import "NSString+scisky.h"

#define DEV_UDP_SEND_PORT 2468

uint64_t reversebytes_uint64t(uint64_t value){
    Byte* ptr = (Byte*)(&value);
    Byte base[8];
    base[0] = 1;
    for(int i = 0; i < 8; ++i){
        base[i] = ptr[7-i];
    }
    uint64_t res = 0;
    memcpy(&res, base, 8);
    return res;
}

@interface UDPSocketManager() <GCDAsyncUdpSocketDelegate>
@end

@implementation UDPSocketManager
{
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncUdpSocket *smartUdpSocket;
    BOOL mIsInterrupt;
    
    NSInteger smartssidApwlength;
}

+ (UDPSocketManager *)sharedManager
{
    static UDPSocketManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[UDPSocketManager alloc] init];
    });
    [_sharedManager resetSocket];
    return _sharedManager;
}

-(id)init{
    self = [super init];
    udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self setudpSocket];
    return self;
}

-(void)resetSocket
{
    if(udpSocket.isClosed)
    {
        NSLog(@"resetSocket %d %d",udpSocket.isClosed,udpSocket.isConnected);
        [self setudpSocket];
    }
}

- (void)setudpSocket
{
    NSLog(@"setudpSocket");
    NSError *error = nil;
    if (![udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    NSLog(@"%@",@"UDP Ready");
}


- (void)doScanDevice{
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:[udpSocket localAddress]];
    //host = @"192.168.1.116";
    NSString *msg = [NSString stringWithFormat:@"PRL:\"%@\",\"%d\"",[self getIPAddress],udpSocket.localPort];
    NSLog(@"%@",msg);
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket enableBroadcast:TRUE error:nil];
    [udpSocket sendData:data toHost:@"255.255.255.255" port:DEV_UDP_SEND_PORT withTimeout:-1 tag:0];
}

-(void)doSetup:(NSString *)ip port:(UInt32)port message:(NSString *)msg{
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:ip port:port withTimeout:-1 tag:0];
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

/*
mIntervalGuideCodeMillisecond = 10;
mIntervalDataCodeMillisecond = 10;
mTimeoutGuideCodeMillisecond = 2000;
mTimeoutDataCodeMillisecond = 4000;
mTotalRepeatTime = 1;
mEsptouchResultOneLen = 1;
mEsptouchResultMacLen = 6;
mEsptouchResultIpLen = 4;
mEsptouchResultTotalLen = 1 + 6 + 4;
mPortListening = 18266;
mTargetHostname = "255.255.255.255";
mTargetPort = 7001;
mWaitUdpReceivingMilliseond = 10000;
mWaitUdpSendingMillisecond = 48000;
mThresholdSucBroadcastCount = 1;
*/

#define GUIDE_CODE_LEN 4
#define ONE_DATA_LEN 3
#define CRC_INITIAL 0x00
-(void)doSartLink:(NSString *)ssid bssid:(NSString *)bssid password:(NSString *)pw ssidHiden:(BOOL)hiden{
    mIsInterrupt = false;
    
    NSError *error = nil;
    if (!smartUdpSocket) {
        smartUdpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [smartUdpSocket enableBroadcast:TRUE error:nil];
    }
    if (![smartUdpSocket bindToPort:18266 error:&error])
    {
        NSLog(@"smartUdpSocket Error binding: %@", error);
    }
    if (![smartUdpSocket beginReceiving:&error])
    {
        NSLog(@"smartUdpSocket Error receiving: %@", error);
    }
    
    NSArray *dcArray = [self getDCArray:ssid bssid:bssid password:pw ssidHiden:hiden];
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(smartLink:) object:dcArray];
    [thread start];
    
    
}


-(void)smartLink:(NSArray *)dcArray{
    
    dispatch_async(dispatch_queue_create("com.example.MyQueue", NULL), ^{
        // something
        NSArray *gcArray = [self getGCArray];
        
        NSTimeInterval startTime = [NSDate date].timeIntervalSince1970;
        NSTimeInterval currentTime = startTime;
        NSTimeInterval lastTime = currentTime - (2 + 4);
        
        int i = 0;
        int index = 0;
        while (!mIsInterrupt) {
            
            if (currentTime - lastTime >= (2 + 4)) {
                
                while (!mIsInterrupt && [NSDate date].timeIntervalSince1970 - currentTime < 2) {
                    [smartUdpSocket sendData:gcArray[i%4] toHost:@"255.255.255.255" port:7001 withTimeout:-1 tag:i];
                    usleep(10*1000);
                    i++;
                    if ([NSDate date].timeIntervalSince1970 - startTime > 48) {
                        break;
                    }
                }
                lastTime = currentTime;
            }
            else
            {
                for (int i=0; i< ONE_DATA_LEN; i++) {
                    if ([dcArray[index + i] length] == 0) {
                        continue;
                    }
                    [smartUdpSocket sendData:dcArray[index + i] toHost:@"255.255.255.255" port:7001 withTimeout:-1 tag:i];
                    usleep(10*1000);
                }
                index = (index + ONE_DATA_LEN) % dcArray.count;
                
            }
            currentTime = [NSDate date].timeIntervalSince1970;
            if (currentTime - startTime > 48) {
                break;
            }
        }
        [self finishSmartLink];
    });
}

-(NSArray *)getGCArray{
    short guidesU8s[GUIDE_CODE_LEN];
    guidesU8s[0] = 515;
    guidesU8s[1] = 514;
    guidesU8s[2] = 513;
    guidesU8s[3] = 512;
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:GUIDE_CODE_LEN];
    for (int i = 0; i < GUIDE_CODE_LEN; i++) {
        Byte *data = malloc(guidesU8s[i]);
        memset(data, '1', guidesU8s[i]);
        [array addObject:[NSData dataWithBytes:data length:guidesU8s[i]]];
        free(data);
    }
    return array;
}

-(NSArray *)getDCArray:(NSString *)ssid bssid:(NSString *)bssid password:(NSString *)pw ssidHiden:(BOOL)isSsidHiden{
    NSMutableArray *mDcBytes2 = [[NSMutableArray alloc] init];
    
    smartssidApwlength = [ssid dataUsingEncoding:NSUTF8StringEncoding].length + [pw dataUsingEncoding:NSUTF8StringEncoding].length + 9;
    DatumCode *dc = [[DatumCode alloc] init:ssid bssid:bssid password:pw IPAddress:[self getIPAddress] ssidHiden:isSsidHiden];
    NSData *dcU81 = [dc getU8s];
    short *dataShort = (short *)[dcU81 bytes];
    for (int i = 0; i < dcU81.length/2; i++) {
        Byte *data = malloc(dataShort[i]);
        memset(data, '1', dataShort[i]);
        NSLog(@"%d",dataShort[i]);
        [mDcBytes2 addObject:[NSData dataWithBytes:data length:dataShort[i]]];
        free(data);
    }
        
    return mDcBytes2;
}

-(void)finishSmartLink{
    mIsInterrupt = true;
    [smartUdpSocket close];
    smartUdpSocket = nil;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"%@",@"didNotSendDataWithTag");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    if ([sock isEqual:smartUdpSocket]){
        NSLog(@"smartUdpSocket %@:%d %@",host,port,data);
        if ([data length] >= 7) {
            Byte *byteData = [data bytes];
            if (smartssidApwlength == byteData[0]) {
                [data subdataWithRange:NSMakeRange(1,6)];
                if (self.SmartLinkDelegate && [self.SmartLinkDelegate respondsToSelector:@selector(didSmartLink:bssid:)]) {
                    [self.SmartLinkDelegate didSmartLink:host bssid:[[[data description] formatData] lowercaseString]];
                }
                [self finishSmartLink];
            }
        }
    }
    else
    {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@:%d %@",host,port,str);
        if ([str rangeOfString:@"PRL:"].location == 0) {
            if (self.ScanfDelegate && [self.ScanfDelegate respondsToSelector:@selector(didScanf:)]) {
                [self.ScanfDelegate didScanf:str];
            }
        }
    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
}
@end
