//
//  LoginRequest.m
//  Where'sBaby
//
//  Created by 刘向宏 on 15/9/14.
//  Copyright © 2015年 coolLH. All rights reserved.
//

#import "BaseHTTPRequestOperationManager.h"
#import "LoginRequest.h"


#define kMethodUserLogin @"userLogin"
#define kMethodVDeviceList @"getDeviceList"
#define kMethodChkUserName @"chkUserName"
#define kMethodregistUser @"registUser"
#define kMethodheartThrob @"heartThrob"

@implementation LoginRequest

+ (void)UserLoginWithUsername:(NSString *)user password:(NSString *)password success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *dic = @{
                          @"userName" : user,
                          @"passWord" : password
                          };
    [[BaseHTTPRequestOperationManager sharedManager] defaultHTTPWithMethod:kMethodUserLogin WithParameters:dic post:YES success:success failure:failure];
}

+ (void)GetDeviceListWithParameters: (id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    [[BaseHTTPRequestOperationManager sharedManager]defaultHTTPWithMethod:kMethodVDeviceList WithParameters:parameters post:YES success:success failure:failure];
}

+ (void)CheckUserNameWithUsername:(NSString *)user success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *dic = @{
                          @"userName" : user
                          };
    [[BaseHTTPRequestOperationManager sharedManager]defaultHTTPWithMethod:kMethodChkUserName WithParameters:dic post:YES success:success failure:failure];
}

+ (void)RegisterWithParameters: (id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    [[BaseHTTPRequestOperationManager sharedManager]defaultHTTPWithMethod:kMethodregistUser WithParameters:parameters post:YES success:success failure:failure];
}

+ (void)HeartThrobWithUsername:(NSString *)user token:(NSString *)token success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure{
    NSDictionary *dic = @{
                          @"userName" : user,
                          @"torken" : token
                          };
    [[BaseHTTPRequestOperationManager sharedManager]defaultHTTPWithMethod:kMethodheartThrob WithParameters:dic post:YES success:success failure:failure];
}


+ (void)ChangeDeviceNickNameWithUsername:(NSString *)user token:(NSString *)token deviceid:(NSString *)deviceid nickName:(NSString *)nickName success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure{
    NSDictionary *dic = @{
                          @"userName" : user,
                          @"torken" : token,
                          @"deviceid" : deviceid,
                          @"nickName" : nickName
                          };
    [[BaseHTTPRequestOperationManager sharedManager]defaultHTTPWithMethod:@"changeDeviceNickName" WithParameters:dic post:YES success:success failure:failure];
}

+ (void)ChangePasswordWithUsername:(NSString *)user token:(NSString *)token password:(NSString *)password newpassword:(NSString *)newpassword success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure{
    NSDictionary *dic = @{
                          @"userName" : user,
                          @"torken" : token,
                          @"passWord" : password,
                          @"newPassword" : newpassword
                          };
    [[BaseHTTPRequestOperationManager sharedManager]defaultHTTPWithMethod:@"changePassword" WithParameters:dic post:YES success:success failure:failure];
}
@end
