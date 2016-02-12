//
//  CRC16.h
//  SmartHome
//
//  Created by 刘向宏 on 16/2/5.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRC16 : NSObject
-(void)reset;
-(long)getValue;
-(void)update:(Byte *)b off:(int)off len:(int)len;
@end
