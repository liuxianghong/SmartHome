//
//  UDPSocketManager.h
//  SmartHome
//
//  Created by 刘向宏 on 16/1/29.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalizedString.h"

uint64_t reversebytes_uint64t(uint64_t value);

@protocol UDPSocketSmartLinkDelegate <NSObject>
-(void)didSmartLink:(NSString *)ipAdress bssid:(NSString *)bssid;
@end

@protocol UDPSocketScanfDelegate <NSObject>
-(void)didScanf:(NSString *)str;
@end

@interface UDPSocketManager : NSObject
+ (UDPSocketManager *)sharedManager;
- (void)doScanDevice;
-(void)doSartLink:(NSString *)ssid bssid:(NSString *)bssid password:(NSString *)pw ssidHiden:(BOOL)hiden;
-(void)doSetup:(NSString *)ip port:(UInt32)port message:(NSString *)msg;
-(void)finishSmartLink;
@property (nonatomic,weak) id<UDPSocketScanfDelegate> ScanfDelegate;
@property (nonatomic,weak) id<UDPSocketSmartLinkDelegate> SmartLinkDelegate;
@end
