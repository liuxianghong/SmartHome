//
//  DeviceListTableViewController.m
//  SmartHome
//
//  Created by 刘向宏 on 16/1/16.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "DeviceListTableViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "LoginRequest.h"
#import "NSString+scisky.h"
#import "UserInfo.h"
#import "SHDevice.h"
#import "DeviceListTableViewCell.h"
#import "TCPSocketManager.h"
#import <MBProgressHUD.h>
#import "SetupViewController.h"

@interface DeviceListTableViewController ()<DZNEmptyDataSetDelegate,DZNEmptyDataSetSource,TCPSocketDeleteDeviceDelegate>

@end

@implementation DeviceListTableViewController
{
    NSInteger numberRow;
    
    NSMutableArray *tableViewArray;
    
    BOOL first;
    
    NSTimer *timer;
    MBProgressHUD *hud;
    
    NSIndexPath *path;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [UIView new];
    first = YES;
    tableViewArray = [[NSMutableArray alloc] init];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        numberRow = 10;
        [self loadDeviceList];
    }];
    
    [TCPSocketManager sharedManager].deleteDeviceDelegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (first) {
        first = NO;
        [self.tableView.mj_header beginRefreshing];
    }
}

-(void)loadDeviceList{
    NSDictionary *dic = @{
                          @"userName" : [UserInfo currentUser].userName,
                          @"torken" : [UserInfo currentUser].token
                          };
    [LoginRequest GetDeviceListWithParameters:dic success:^(id responseObject) {
        GDataXMLElement *root = responseObject;
        NSString *str = root.stringValue;
        NSLog(@"%@",str);
        if (str.length > 0) {
            [tableViewArray removeAllObjects];
            NSArray *arrayDevice = [str componentsSeparatedByString:@";"];
            for (NSString *deviceStr in arrayDevice) {
                NSArray *array = [deviceStr componentsSeparatedByString:@","];
                if (array.count > 0) {
                    SHDevice *device = [SHDevice DeviceWithDid:array[0]];
                    [device upDataWithArray:array];
                    [tableViewArray addObject:device];
                }
            }
            
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DZNEmptyDataSet
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    return [[NSAttributedString alloc] initWithString:@"暂无设备"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableViewArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"controlIdentifier" sender:tableViewArray[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceListIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    SHDevice *device = tableViewArray[indexPath.row];
    cell.deviceIDLabel.text = device.did;
    cell.deviceNameLabel.text = device.name;
    cell.deviceStatusLabel.text = [device.state integerValue] ? @"在线" : @"离线";
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Prompt" message:@"Sure you want to delete the device?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            path = indexPath;
            SHDevice *device = tableViewArray[indexPath.row];
            [[TCPSocketManager sharedManager] deleteDevice:device.did];
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(cutdownAdd) userInfo:nil repeats:YES];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [vc addAction:ok];
        [vc addAction:cancel];
        [self presentViewController:vc animated:YES completion:nil];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

-(void)cutdownAdd{
    [self finishAdd:YES];
}

-(void)finishAdd:(BOOL)faile{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    if (!faile) {
        [tableViewArray removeObjectAtIndex:path.row];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    }
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = faile ? @"Delete Failure" : @"Delete Success";
    [hud hide:YES afterDelay:1.0];
}

-(void)didDeleteDevice:(NSData *)deviceID state:(NSInteger)state
{
    [self finishAdd:(state!=0)];
}
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"scanVCIdentfier"] ) {
        first = YES;
    }
    else if ([segue.identifier isEqualToString:@"controlIdentifier"] ) {
        SetupViewController *vc = segue.destinationViewController;
        vc.device = sender;
    }
}

@end
