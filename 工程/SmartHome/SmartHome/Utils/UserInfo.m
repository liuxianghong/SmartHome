//
//  UserInfo.m
//  WisdomParking
//
//  Created by 刘向宏 on 16/1/17.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+ (UserInfo *)sharedManager
{
    static UserInfo *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[UserInfo alloc] init];
    });
    return _sharedManager;
}

+ (User *)currentUser{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]) {
        return [User UserWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
    }
    return nil;
}

@end
