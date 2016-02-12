//
//  TCPSocketManager.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/29.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "TCPSocketManager.h"
#import <GCDAsyncSocket.h>
#import "UserInfo.h"
#import "NSString+scisky.h"
#import "LoginRequest.h"

#define IMIP @"cloud.ai-thinker.com"
#define IMPORT 6009

@interface TCPSocketManager() <GCDAsyncSocketDelegate>
@end

@implementation TCPSocketManager
{
    GCDAsyncSocket *asyncSocket;
    NSTimer *countDownTimer;
    BOOL isLogin;
    NSData *uid;
    NSData *token;
    NSData *tcpTorken;
    NSMutableData *reciveData;
}

+ (TCPSocketManager *)sharedManager
{
    static TCPSocketManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[TCPSocketManager alloc] init];
    });
    return _sharedManager;
}

-(id)init{
    self = [super init];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    return self;
}

-(void)Login{
    isLogin = NO;
    NSString *tokenStr = [UserInfo currentUser].token;
    token = [tokenStr hexToData];
    NSString *userID = [UserInfo currentUser].getwayid;
    unsigned long uuid = strtoul([userID UTF8String],0,10);
    uid = [NSData dataWithBytes:&uuid length:sizeof(uuid)];
    [self setudpSocket];
    
    NSString *userPW = [UserInfo currentUser].getwaypwd;
    unsigned long pw = strtoul([userPW UTF8String],0,10);
    NSString *pww = [NSString stringWithFormat:@"%lx",pw];
    Msg *msg = [[Msg alloc] init];
    msg.cmdType = 0xA0;
    msg.cmd = 0x00;
    msg.devId = uid;
    msg.token = token;
    msg.data = [pww hexToData];
    [msg enCode];
    NSLog(@"%@",msg.sendData);
    [asyncSocket writeData:msg.sendData withTimeout:-1 tag:1];
}

-(void)countDown
{
    if(isLogin && asyncSocket.isConnected ){
        Msg *msg = [[Msg alloc] init];
        msg.cmdType = 0xA0;
        msg.cmd = 0x01;
        msg.devId = uid;
        msg.token = token;
        [msg enCode];
        NSLog(@"%@",msg.sendData);
        [asyncSocket writeData:msg.sendData withTimeout:-1 tag:1];
//        [LoginRequest HeartThrobWithUsername:[UserInfo currentUser].userName token:[UserInfo currentUser].token success:^(id responseObject) {
//            GDataXMLElement *root = responseObject;
//            NSLog(@"%@ , %@",root.name , root.stringValue);
//        } failure:^(NSError *error) {
//            NSLog(@"%@",error);
//        }];
    }
}

- (void)setudpSocket
{
    if (!asyncSocket) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    }
    else
    {
        //[asyncSocket disconnect];
    }
    
    if (![asyncSocket isConnected]) {
        NSString *host = IMIP;
        uint16_t port = IMPORT;
        NSError *error = nil;
        if (![asyncSocket connectToHost:host onPort:port error:&error])
        {
            NSLog(@"无法建立连接");
        }
    }
    
}

- (void)addDevice:(NSString *)deviceID password:(NSString *)pw{
    
    Byte data[16];
    int index = 0;
    UInt64 val = 0;
    
    // id 低位在前
    val = [deviceID longLongValue];
    for (int i = 0; i < 8; i++) {
        data[index++] = (Byte) (val % 256);
        val /= 256;
    }
    // pass 高位在前
    Byte b[8];
    val = [pw longLongValue];
    for (int i = 0; i < 8; i++) {
        b[i] = (Byte) (val % 256);
        val /= 256;
    }
    Byte buff[8];
    {
        int length = 8;
        for (int i = 0; i < length; i++) {
            buff[i] = b[length - 1 - i];
        }
    }
    for (int i = 0; i < 8; i++) {
        // if(buff[i] != 0){
        data[index++] = buff[i];
        // }
    }
    
    Msg *msg = [[Msg alloc] init];
    msg.cmdType = 0xEF;
    msg.cmd = 0x06;
    msg.devId = uid;
    msg.token = tcpTorken;
    msg.data = [NSData dataWithBytes:data length:16];
    [msg enCode];
    NSLog(@"%@",msg.sendData);
    [asyncSocket writeData:msg.sendData withTimeout:-1 tag:1];
    
}

- (void)deleteDevice:(NSString *)deviceID{
    Byte data[8];
    int index = 0;
    UInt64 val = 0;
    
    // id 低位在前
    val = [deviceID longLongValue];
    for (int i = 0; i < 8; i++) {
        data[index++] = (Byte) (val % 256);
        val /= 256;
    }
    Msg *msg = [[Msg alloc] init];
    msg.cmdType = 0xEF;
    msg.cmd = 0x07;
    msg.devId = uid;
    msg.token = tcpTorken;
    msg.data = [NSData dataWithBytes:data length:8];
    [msg enCode];
    NSLog(@"%@",msg.sendData);
    [asyncSocket writeData:msg.sendData withTimeout:-1 tag:1];
}

- (void)commandDevice:(SHDevice *)device command:(NSString *)cmd{
    NSString *deid = [NSString stringWithFormat:@"%llx",[device.did longLongValue]];
    Msg *msg = [[Msg alloc] init];
    msg.cmdType = 0xAA;
    msg.cmd = 0xFF;
    msg.token = [device.tcp hexToData];
    msg.devId = [deid hexToDataSwap];
    msg.data = [cmd dataUsingEncoding:NSUTF8StringEncoding];
    [msg enCode];
    [asyncSocket writeData:msg.sendData withTimeout:-1 tag:1];
}

-(void)listenData{
    [asyncSocket readDataToData:[NSData dataWithBytes:"\x55" length:1] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
 
    //[self countDown];
    NSLog(@"GCDAsyncSocket didConnectToHost: %@:%d",host,port);
    [self listenData];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    NSLog(@"GCDAsyncSocket socketDidSecure");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"GCDAsyncSocket didWriteDataWithTag:%ld", tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"GCDAsyncSocket didReadData: %@",data);
    if (!reciveData) {
        reciveData = [[NSMutableData alloc] init];
    }
    [reciveData appendData:data];
    if ([reciveData length] > 21) {
        Msg *msg = [Msg MsgWithData:reciveData];
        reciveData = nil;
        NSString *str = [[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding];
        NSLog(@"%d %@ %@ %@ %@",msg.state,msg.devId,msg.token,str,msg.data);
        if (msg.cmd == 0x00 && msg.cmdType == 0xA0) {
            isLogin = YES;
            tcpTorken = token;//msg.data;
            [self countDown];
        }
        else if (msg.cmd == 0x06 && msg.cmdType == 0xEF){
            if (self.addDeviceDelegate && [self.addDeviceDelegate respondsToSelector:@selector(didAddDevice:state:)]) {
                [self.addDeviceDelegate didAddDevice:msg.devId state:msg.state];
            }
        }
        else if (msg.cmd == 0x07 && msg.cmdType == 0xEF){
            if (self.deleteDeviceDelegate && [self.deleteDeviceDelegate respondsToSelector:@selector(didDeleteDevice:state:)]) {
                [self.deleteDeviceDelegate didDeleteDevice:msg.devId state:msg.state];
            }
        }
        else if (msg.cmd == 0xee && msg.cmdType == 0xAA){
            if (self.commandDeviceDelegate && [self.commandDeviceDelegate respondsToSelector:@selector(didCommandDevice:state:str:)]) {
                [self.commandDeviceDelegate didCommandDevice:msg.devId state:msg.state str:str];
            }
        }
    }
    [self listenData];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    if (isLogin) {
        [self Login];
    }
    NSLog(@"GCDAsyncSocket socketDidDisconnect :%@",error);
}
@end
