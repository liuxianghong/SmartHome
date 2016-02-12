//
//  DatumCode.h
//  SmartHome
//
//  Created by 刘向宏 on 16/2/1.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataCode.h"

@interface DatumCode : NSObject
-(instancetype)init:(NSString *)ssid bssid:(NSString *)bssid password:(NSString *)pw IPAddress:(NSString *)PAddress ssidHiden:(BOOL)isSsidHiden;
-(NSData *)getU8s;
@end
