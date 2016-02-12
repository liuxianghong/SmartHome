//
//  SHDevice.h
//  SmartHome
//
//  Created by 刘向宏 on 16/1/28.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MagicalRecord/MagicalRecord.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHDevice : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(SHDevice *)DeviceWithDid:(NSString *)did;
-(void)upDataWithArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END

#import "SHDevice+CoreDataProperties.h"
