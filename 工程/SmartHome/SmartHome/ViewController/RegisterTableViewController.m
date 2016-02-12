//
//  RegisterTableViewController.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/31.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "RegisterTableViewController.h"
#import "UDPSocketManager.h"
#import <MBProgressHUD.h>
#import "LoginRequest.h"

@interface RegisterTableViewController () <UDPSocketScanfDelegate>
@property (nonatomic,weak) IBOutlet UITextField *userNameField;
@property (nonatomic,weak) IBOutlet UITextField *userPWField;
@property (nonatomic,weak) IBOutlet UITextField *userPhoneField;
@property (nonatomic,weak) IBOutlet UITextField *userEmailField;
@property (nonatomic,weak) IBOutlet UITextField *userDeviceIDField;
@property (nonatomic,weak) IBOutlet UITextField *userDevicePWField;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activity;
@end

@implementation RegisterTableViewController
{
    NSTimer *timer;
    NSInteger countTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [UDPSocketManager sharedManager].ScanfDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

-(IBAction)registClick:(id)sender{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.userNameField.text.length < 1) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"please enter user name";
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    if (self.userPWField.text.length < 1) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"please enter password";
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    if (self.userPhoneField.text.length < 1) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"please enter phone number";
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    if (self.userEmailField.text.length < 1) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"please enter email";
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    if (self.userDeviceIDField.text.length < 1) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"please enter device ID";
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    if (self.userDevicePWField.text.length < 1) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"please enter device password";
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    
    NSDictionary *dic = @{@"userName" : self.userNameField.text,
                          @"passWord" : self.userPWField.text,
                          @"mobile" : self.userPhoneField.text,
                          @"email" : self.userEmailField.text,
                          @"deviceID" : @([self.userDeviceIDField.text longLongValue]),
                          @"devicePWD" : @([self.userDevicePWField.text longLongValue])
                          };
    [LoginRequest RegisterWithParameters:dic success:^(id responseObject) {
        GDataXMLElement *root = responseObject;
        if ([root.name isEqualToString:@"string"]) {
            NSString *str = root.stringValue;
            if ([str rangeOfString:@"FAIL:"].location == 0) {
                hud.mode = MBProgressHUDModeText;
                hud.detailsLabelText = str;
                [hud hide:YES afterDelay:1.0f];
                return ;
            }
            else if ([str rangeOfString:@"OK:"].location == 0){
                [hud hide:YES];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            
        }
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"Register Failure";
        [hud hide:YES afterDelay:1.0f];
    } failure:^(NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = error.domain;
        [hud hide:YES afterDelay:1.0f];
    }];
}

-(IBAction)scanfClick:(id)sender{
    [self.activity startAnimating];
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cutdown) userInfo:nil repeats:YES];
    countTime = 0;
    [self cutdown];
}


-(void)cutdown{
    countTime ++;
    if (countTime > 3) {
        [self finish:YES];
        return;
    }
    [[UDPSocketManager sharedManager] doScanDevice];
}

-(void)finish:(BOOL)faile{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [self.activity stopAnimating];
}

-(void)didScanf:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@"PRL:" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *array = [str componentsSeparatedByString:@","];
    [self finish:NO];
    
    self.userDeviceIDField.text = [NSString stringWithFormat:@"%ld",strtoul([array[0] UTF8String],0,16)];
    
//    unsigned long pw = strtoul([array[1] UTF8String],0,16);
//    Byte *value = &pw;
//    value[3] = (pw & 0xff);
//    value[2] = ((pw >> 8) & 0xff);
//    value[1] = ((pw >> 16) & 0xff);
//    value[0] = ((pw >> 24) & 0xff);
//    self.userDevicePWField.text = [NSString stringWithFormat:@"%ld",pw];
    self.userDevicePWField.text = [NSString stringWithFormat:@"%lld",[self dd:array[1]]];
    //self.typeLabel.text = array[4];
    //[self.scanButton setTitle:@"Add" forState:UIControlStateNormal];
}


-(UInt64)dd:(NSString *)strVal
{
    long val = 0;
    NSUInteger len;
    NSString *tmp;
    NSString *str = [[strVal stringByReplacingOccurrencesOfString:@"0x" withString:@""] uppercaseString];
    //strVal.replace("0x", " ").trim().toUpperCase();
    //		while (true) {
    //			if (str.charAt(0) == '0') {
    //				str = str.substring(1);
    //			} else {
    //				break;
    //			}
    //		}
    if(str.length == 0){
        return 0;
    }
    len = str.length;
    if (len % 2 == 1) {
        if(len ==1){
            str =  [NSString stringWithFormat:@"0%@",str];//"0"+str;
        }else{
            tmp = [str substringWithRange:NSMakeRange(len-1, 1)];//str.substring(len-1,len);
            str = [str substringWithRange:NSMakeRange(0, len-1)];//str.substring(0,len-1);
            str = [NSString stringWithFormat:@"%@0%@",str,tmp];// str+"0"+tmp;
        }
    }
    len = str.length/2;// (str.length() / 2);
    Byte result[1024];
    //byte[] result = new byte[len];
    char *achar = [str UTF8String];
    for (int i = 0; i < len; i++) {
        int pos = i * 2;
        result[i] = (Byte) ([self toByte:achar[pos]]) << 4 | ([self toByte:achar[pos + 1]]);
    }
    for (int i = len - 1; i >= 0; i--) {
        val *= 256;
        val += result[i] & 0xFF;
    }
    return val;
}

-(Byte)toByte:(char)c{
    if (c>='0' && c<='9') {
        return c - '0';
    }
    else if (c>='A' && c <= 'F'){
        return c - 'A' + 10;
    }
    return 0;
}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
