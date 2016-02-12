//
//  DataCode.h
//  SmartHome
//
//  Created by 刘向宏 on 16/2/1.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRC8.h"

@interface DataCode : NSObject
-(id)initWithu8:(UInt16)u8 index:(int)index;
-(NSData *)getBytes;
@end
