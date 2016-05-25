//
//  LoginViewController.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/15.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginRequest.h"
#import "NSString+scisky.h"
#import "UserInfo.h"
#import <MBProgressHUD.h>
#import <MagicalRecord/MagicalRecord.h>
#import "TCPSocketManager.h"


@interface LoginViewController ()<UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic,weak) IBOutlet UITextField *passwordTextField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.usernameTextField.text = @"andyi";
    //self.passwordTextField.text = @"1234";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)configClick:(id)sender{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = LocalizedStringTr(@"暂时不支持此功能");
    [hud hide:YES afterDelay:1.0f];
}

-(IBAction)loginClick:(id)sender{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    if (self.usernameTextField.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = LocalizedStringTr(@"请输入用户名");
        [hud hide:YES afterDelay:1.0f];
        return;
    }
    if (self.passwordTextField.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = LocalizedStringTr(@"请输入密码");
        [hud hide:YES afterDelay:1.0f];
        return;
    }
    [LoginRequest UserLoginWithUsername:self.usernameTextField.text password:[self.passwordTextField.text MD5String] success:^(id responseObject) {
        GDataXMLElement *root = responseObject;
        if ([root.name isEqualToString:@"string"]) {
            NSString *str = root.stringValue;
            if(str.length >= 1){
                NSArray *array = [str componentsSeparatedByString:@":"];
                if ([array[0] isEqualToString:@"OK"]) {
                    [hud hide:YES];
                    [[NSUserDefaults standardUserDefaults] setObject:self.usernameTextField.text forKey:@"userName"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[UserInfo currentUser] upDataWithArray:array];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    [[TCPSocketManager sharedManager] Login];
                    [self performSegueWithIdentifier:@"deviceListIdentifier" sender:nil];
                    return;
                }
            }
            
        }
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = LocalizedStringTr(@"用户名或密码错误");
        [hud hide:YES afterDelay:1.0f];
    } failure:^(NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = error.domain;
        [hud hide:YES afterDelay:1.0f];
    }];
    //[self performSegueWithIdentifier:@"deviceListIdentifier" sender:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
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
