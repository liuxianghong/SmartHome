//
//  WIFIUtil.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/18.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <SystemConfiguration/CaptiveNetwork.h>
#import "WIFIUtil.h"

@implementation WIFIUtil
+(NSString *)SSIDString{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return [info objectForKey:@"SSID"];
}
@end
