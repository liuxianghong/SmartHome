//
//  User.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/29.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "User.h"
#import "SHDevice.h"

@implementation User

// Insert code here to add functionality to your managed object subclass
+(User *)UserWithName:(NSString *)userName{
    User *user = [User MR_findFirstByAttribute:@"userName" withValue:userName];
    if (!user) {
        user = [User MR_createEntity];
        user.userName = userName;
    }
    return user;
}

-(void)upDataWithArray:(NSArray *)array{
    if (array.count < 4) {
        return;
    }
    self.token = array[1];
    self.getwayid = array[2];
    self.getwaypwd = array[3];
}

@end
