//
//  LocalizedString.h
//  Howare
//
//  Created by 刘向宏 on 16/3/30.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *LocalizedStringTr(NSString *str);

@interface LocalizedString : NSObject
+(NSString *)Tr:(NSString *)tr;
@end
