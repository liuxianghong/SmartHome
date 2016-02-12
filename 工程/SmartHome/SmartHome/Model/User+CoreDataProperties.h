//
//  User+CoreDataProperties.h
//  SmartHome
//
//  Created by 刘向宏 on 16/1/29.
//  Copyright © 2016年 刘向宏. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSString *getwayid;
@property (nullable, nonatomic, retain) NSString *getwaypwd;
@property (nullable, nonatomic, retain) NSSet<SHDevice *> *devices;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addDevicesObject:(SHDevice *)value;
- (void)removeDevicesObject:(SHDevice *)value;
- (void)addDevices:(NSSet<SHDevice *> *)values;
- (void)removeDevices:(NSSet<SHDevice *> *)values;

@end

NS_ASSUME_NONNULL_END
