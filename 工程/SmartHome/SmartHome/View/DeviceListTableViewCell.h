//
//  DeviceListTableViewCell.h
//  SmartHome
//
//  Created by 刘向宏 on 16/1/16.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceListTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *deviceIDLabel;
@property (nonatomic,weak) IBOutlet UILabel *deviceNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *deviceStatusLabel;
@end
