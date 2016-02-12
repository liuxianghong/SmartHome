//
//  Msg.h
//  SmartHome
//
//  Created by 刘向宏 on 16/2/5.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Msg : NSObject
@property (nonatomic,strong) NSData *devId;
@property (nonatomic,assign) Byte cmdType;
@property (nonatomic,assign) Byte cmd;
@property (nonatomic,assign) Byte state;
@property (nonatomic,strong) NSData *data;
@property (nonatomic,strong) NSData *sendData;
@property (nonatomic,strong) NSData *reciveData;
@property (nonatomic,strong) NSData *token;
-(BOOL)enCode;
+(Msg *)MsgWithData:(NSData *)data;
@end
