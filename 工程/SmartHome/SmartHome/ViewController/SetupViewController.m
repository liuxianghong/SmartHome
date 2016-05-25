//
//  SetupViewController.m
//  SmartHome
//
//  Created by 刘向宏 on 16/2/7.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "SetupViewController.h"
#import "TCPSocketManager.h"

@interface SetupViewController () <TCPSocketCommandDeviceDelegate>
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UIButton *lock1Button;
@property (nonatomic,weak) IBOutlet UIButton *lock2Button;
@property (nonatomic,weak) IBOutlet UIImageView *lock1ImageView;
@property (nonatomic,weak) IBOutlet UIImageView *lock2ImageView;
@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.device.name;
    [TCPSocketManager sharedManager].commandDeviceDelegate = self;
    [[TCPSocketManager sharedManager] commandDevice:self.device command:@"LIGHT:?"];
    [[TCPSocketManager sharedManager] commandDevice:self.device command:@"LIGHT1:?"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)lock1click:(UIButton *)sender{
    NSString *msg = @"LIGHT1:0";
    [self performSelector:@selector(doMSG:) withObject:@"LIGHT1:1" afterDelay:0.8];
    [[TCPSocketManager sharedManager] commandDevice:self.device command:msg];
    sender.backgroundColor = [UIColor colorWithRed:63/255.0 green:122/255.0 blue:22/255.0 alpha:0.8];
}

-(IBAction)lock2click:(UIButton *)sender{
    NSString *msg = @"LIGHT:0";
    [self performSelector:@selector(doMSG:) withObject:@"LIGHT:1" afterDelay:0.8];
    [[TCPSocketManager sharedManager] commandDevice:self.device command:msg];
    sender.backgroundColor = [UIColor colorWithRed:63/255.0 green:122/255.0 blue:22/255.0 alpha:0.8];
}

-(void)doMSG:(NSString *)msg{
    [[TCPSocketManager sharedManager] commandDevice:self.device command:msg];
    self.lock1Button.backgroundColor = [UIColor whiteColor];
    self.lock2Button.backgroundColor = [UIColor whiteColor];
}

-(void)didCommandDevice:(NSData *)deviceID state:(NSInteger)state str:(NSString *)str
{
    NSLog(@"%@ %ld %@",deviceID,state,str);
    if ([str hasPrefix:@"LIGHT1:"]) {
        str = [str stringByReplacingOccurrencesOfString:@"LIGHT1:" withString:@""];
        BOOL bo = [str intValue];
        //self.lock1Button.selected = !bo;
        self.lock1ImageView.highlighted = !bo;
    }
    if ([str hasPrefix:@"LIGHT:"]) {
        str = [str stringByReplacingOccurrencesOfString:@"LIGHT:" withString:@""];
        BOOL bo = [str intValue];
        //self.lock2Button.selected = !bo;
        self.lock2ImageView.highlighted = !bo;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
