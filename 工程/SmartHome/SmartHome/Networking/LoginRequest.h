//
//  LoginRequest.h
//  Where'sBaby
//
//  Created by 刘向宏 on 15/9/14.
//  Copyright © 2015年 coolLH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GDataXML-HTML/GDataXMLNode.h>

@interface LoginRequest : NSObject

+ (void)UserLoginWithUsername:(NSString *)user password:(NSString *)password success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

+ (void)GetDeviceListWithParameters: (id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

+ (void)RegisterWithParameters: (id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

+ (void)CheckUserNameWithUsername:(NSString *)user success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

+ (void)HeartThrobWithUsername:(NSString *)user token:(NSString *)token success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
