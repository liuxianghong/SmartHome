//
//  UserInfo.h
//  WisdomParking
//
//  Created by 刘向宏 on 16/1/17.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserInfo : NSObject
+ (UserInfo *)sharedManager;
+ (User *)currentUser;
@end
