//
//  CRC8.h
//  SmartHome
//
//  Created by 刘向宏 on 16/2/1.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRC8 : NSObject
-(void)update:(Byte *)buffer offset:(int)offset len:(int)len;
-(void)update:(NSData *)buffer;
-(void)updateB:(int)b;
-(long)getValue;
-(void)reset;
@end
