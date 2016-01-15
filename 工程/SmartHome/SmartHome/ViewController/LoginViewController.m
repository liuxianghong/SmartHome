//
//  LoginViewController.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/15.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (nonatomic,weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic,weak) IBOutlet UITextField *passwordTextField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)loginClick:(id)sender{
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
