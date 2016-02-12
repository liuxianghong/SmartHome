//
//  SHDevice.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/28.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "SHDevice.h"

@implementation SHDevice

// Insert code here to add functionality to your managed object subclass
+(SHDevice *)DeviceWithDid:(NSString *)did{
    SHDevice *device = [SHDevice MR_findFirstByAttribute:@"did" withValue:did];
    if (!device) {
        device = [SHDevice MR_createEntity];
        device.did = did;
    }
    return device;
}

-(void)upDataWithArray:(NSArray *)array{
    if (array.count < 6) {
        return;
    }
    self.did = array[0];
    self.name = array[1];
    self.time = array[2];
    self.tcp = array[3];
    
    if ([array[4] length] >0) {
        NSArray *arrayIP = [array[4] componentsSeparatedByString:@":"];
        if (arrayIP.count == 2) {
            self.ip = arrayIP[0];
            self.port = arrayIP[1];
        }
    }
    self.state = array[5];
}

@end
