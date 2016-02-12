//
//  ScanViewController.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/18.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "ScanViewController.h"
#import "WIFIUtil.h"
#import "UDPSocketManager.h"
#import <MBProgressHUD.h>
#import "TCPSocketManager.h"

@interface ScanViewController () <UDPSocketScanfDelegate,TCPSocketAddDeviceDelegate>
@property (nonatomic,weak) IBOutlet UIButton *scanButton;
@property (nonatomic,weak) IBOutlet UITextField *idLabel;
@property (nonatomic,weak) IBOutlet UITextField *passwordLabel;
@property (nonatomic,weak) IBOutlet UITextField *typeLabel;
@end

@implementation ScanViewController
{
    NSTimer *timer;
    MBProgressHUD *hud;
    NSInteger countTime;
    long long devicePW;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [UDPSocketManager sharedManager].ScanfDelegate = self;
    [TCPSocketManager sharedManager].addDeviceDelegate = self;
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

-(IBAction)backClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)scanClick:(id)sender{
    if (self.idLabel.text.length<1) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //hud.dimBackground = YES;
        timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cutdown) userInfo:nil repeats:YES];
        countTime = 0;
        [self cutdown];
    }
    else
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[TCPSocketManager sharedManager] addDevice:self.idLabel.text password:self.passwordLabel.text];
        timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(cutdownAdd) userInfo:nil repeats:YES];
        countTime = 0;
    }
}

-(void)cutdown{
    countTime ++;
    if (countTime > 3) {
        [self finish:YES];
        return;
    }
    [[UDPSocketManager sharedManager] doScanDevice];
}

-(void)cutdownAdd{
    [self finishAdd:YES];
}

-(void)finish:(BOOL)faile{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = faile ? @"Scan Failure" : @"Scan Success";
    [hud hide:YES afterDelay:1.0];
}

-(void)finishAdd:(BOOL)faile{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = faile ? @"Add Failure" : @"Add Success";
    [hud hide:YES afterDelay:1.0];
}

-(void)didScanf:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@"PRL:" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *array = [str componentsSeparatedByString:@","];
    [self finish:NO];
    
    self.idLabel.text = [NSString stringWithFormat:@"%lld",strtoull([array[0] UTF8String],0,16)];
    
//    char *CC = [array[1] UTF8String];
//    char ccc[100] = {'0','x',0};
//    int len = [array[1] length];
//    for (int i =2; i<len; i++) {
//        ccc[i] = CC[len - 1 - i+2];
//        if (ccc[i] == 0) {
//            break;
//        }
//    }
//    UInt64 pw = strtoull(ccc,0,16);
//    UInt64 ppw;
//    Byte *value1 = &pw;
//    Byte *value2 = &ppw;
//    for (int i = 0; i < 4; i++) {
//        // if(buff[i] != 0){
//        value2[i] = value1[3-i];
//        // }
//    }
//    devicePW = pw;
    self.passwordLabel.text = [NSString stringWithFormat:@"%lld",[self dd:array[1]]];
    self.typeLabel.text = array[4];
    [self.scanButton setTitle:@"Add" forState:UIControlStateNormal];
    //self.passwordLabel.text = @"2422106994";
}

-(void)didAddDevice:(NSData *)deviceID state:(NSInteger)state{
    [self finishAdd:(state!=0)];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
