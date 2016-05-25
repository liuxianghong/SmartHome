//
//  LocalizedString.m
//  Howare
//
//  Created by 刘向宏 on 16/3/30.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "LocalizedString.h"

NSString *LocalizedStringTr(NSString *str){
    return [LocalizedString Tr:str];
}

@implementation LocalizedString
+(NSString *)Tr:(NSString *)tr{
    return NSLocalizedString(tr, nil);
}
@end
