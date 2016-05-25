//
//  ChangePWViewController.m
//  SmartHome
//
//  Created by 刘向宏 on 16/5/11.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "ChangePWViewController.h"
#import <MBProgressHUD.h>
#import "LocalizedString.h"
#import "LoginRequest.h"
#import "UserInfo.h"
#import "NSString+scisky.h"

@interface ChangePWViewController ()
@property (nonatomic,weak) IBOutlet UITextField *userPWField;
@property (nonatomic,weak) IBOutlet UITextField *usernewPWField;
@property (nonatomic,weak) IBOutlet UITextField *userrePWField;
@end

@implementation ChangePWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction)backClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)okClick:(id)sender{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.userPWField.text.length < 1 || self.usernewPWField.text.length < 1 || self.userrePWField.text.length < 1) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = LocalizedStringTr(@"please enter password");
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    if (![self.usernewPWField.text isEqualToString:self.userrePWField.text]) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = LocalizedStringTr(@"Incorrect password");
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    [LoginRequest ChangePasswordWithUsername:[UserInfo currentUser].userName token:[UserInfo currentUser].token password:[self.userPWField.text MD5String] newpassword:[self.usernewPWField.text MD5String] success:^(id responseObject) {
        GDataXMLElement *root = responseObject;
        NSString *str = root.stringValue;
        NSLog(@"%@",str);
        NSString *mesge = @"";
        if ([str containsString:@"OK"]) {
            mesge = LocalizedStringTr(@"修改成功");
            [self.navigationController popViewControllerAnimated:true];
        }
        else{
            mesge = LocalizedStringTr(@"修改失败");
        }
        hud.detailsLabelText = mesge;
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES];
    } failure:^(NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = error.domain;
        [hud hide:YES afterDelay:1.0f];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
