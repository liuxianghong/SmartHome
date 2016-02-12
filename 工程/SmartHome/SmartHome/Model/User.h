//
//  User.h
//  SmartHome
//
//  Created by 刘向宏 on 16/1/29.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SHDevice;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(User *)UserWithName:(NSString *)userName;
-(void)upDataWithArray:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"
