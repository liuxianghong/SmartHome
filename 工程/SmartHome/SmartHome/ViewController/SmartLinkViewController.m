//
//  SmartLinkViewController.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/15.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "SmartLinkViewController.h"
#import "WIFIUtil.h"
#import "UDPSocketManager.h"
#import <MBProgressHUD.h>

@interface SmartLinkViewController ()<UDPSocketSmartLinkDelegate ,UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UILabel *label;
@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet UISwitch *showSSIDSwitch;
@property (nonatomic,weak) IBOutlet UIButton *confirmButton;
@end

@implementation SmartLinkViewController
{
    NSTimer *timer;
    MBProgressHUD *hud;
    NSInteger countTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.label.text = [WIFIUtil SSIDString];
    
    [UDPSocketManager sharedManager].SmartLinkDelegate = self;
    self.showSSIDSwitch.on = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [[UDPSocketManager sharedManager] finishSmartLink];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)switchClick:(id)sender{
    //self.label.hidden = !self.showSSIDSwitch.on;
}

-(IBAction)confirmClick:(id)sender{
    [self.textField resignFirstResponder];
    NSString *ssid = [WIFIUtil SSIDString];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([ssid length]<1) {
        hud.detailsLabelText = LocalizedStringTr(@"NO SSID");
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2.0];
        return;
    }
    [UDPSocketManager sharedManager].SmartLinkDelegate = self;
    [[UDPSocketManager sharedManager] doSartLink:[WIFIUtil SSIDString] bssid:[WIFIUtil BSSIDString] password:self.textField.text ssidHiden:self.showSSIDSwitch.on];
    
    hud.dimBackground = YES;
    hud.detailsLabelText = LocalizedStringTr(@"SmartLink touch is configuring,\nplease wait for a moment…");
    timer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(cutdown) userInfo:nil repeats:YES];
//    [self cutdown];
}

-(void)cutdown{
    [UDPSocketManager sharedManager].SmartLinkDelegate = nil;
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    hud.detailsLabelText = LocalizedStringTr(@"SmarrLink touch is failure");
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:2.0];
}

-(void)didSmartLink:(NSString *)ipAdress bssid:(NSString *)bssid{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    hud.detailsLabelText = [NSString stringWithFormat:LocalizedStringTr(@"SmarrLink touch is success,bssid = %@,InetAddress = %@"),bssid,ipAdress];
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:3.0];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
