//
//  TCPSocketManager.h
//  SmartHome
//
//  Created by 刘向宏 on 16/1/29.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Msg.h"
#import "SHDevice.h"

@protocol TCPSocketDeleteDeviceDelegate <NSObject>
-(void)didDeleteDevice:(NSData *)deviceID state:(NSInteger)state;
@end

@protocol TCPSocketAddDeviceDelegate <NSObject>
-(void)didAddDevice:(NSData *)deviceID state:(NSInteger)state;
@end

@protocol TCPSocketCommandDeviceDelegate <NSObject>
-(void)didCommandDevice:(NSData *)deviceID state:(NSInteger)state str:(NSString *)str;
@end

@interface TCPSocketManager : NSObject
+ (TCPSocketManager *)sharedManager;
@property (nonatomic,weak) id<TCPSocketDeleteDeviceDelegate> deleteDeviceDelegate;
@property (nonatomic,weak) id<TCPSocketAddDeviceDelegate> addDeviceDelegate;
@property (nonatomic,weak) id<TCPSocketCommandDeviceDelegate> commandDeviceDelegate;
- (void)addDevice:(NSString *)deviceID password:(NSString *)pw;
- (void)deleteDevice:(NSString *)deviceID;
- (void)commandDevice:(SHDevice *)device command:(NSString *)cmd;
- (void)Login;
@end
