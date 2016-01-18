//
//  ScanViewController.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/18.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "ScanViewController.h"

@interface ScanViewController ()
@property (nonatomic,weak) IBOutlet UIButton *scanButton;
@property (nonatomic,weak) IBOutlet UILabel *idLabel;
@property (nonatomic,weak) IBOutlet UILabel *passwordLabel;
@property (nonatomic,weak) IBOutlet UILabel *typeLabel;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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
