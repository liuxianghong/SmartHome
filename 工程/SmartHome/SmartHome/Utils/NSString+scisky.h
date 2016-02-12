//
//  NSString+scisky.h
//  scisky
//
//  Created by 刘向宏 on 15/6/18.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (scisky)
-(NSString *)AESEncrypt;
- (NSString *)MD5String;
- (BOOL)checkTel;
+ (BOOL)validateIDCardNumber:(NSString *)value;
- (BOOL)isValidateEmail;
-(BOOL)isValidatePW;
-(BOOL)isValidateCarNo;
- (NSString *)formatData;
-(NSData *)hexToData;
-(NSData *)hexToDataSwap;
@end

@interface UIFont (wb)
+(UIFont *)appFontOfSize:(CGFloat)size;
@end