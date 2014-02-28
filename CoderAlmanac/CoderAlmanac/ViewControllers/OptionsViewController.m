//
//  OptionsViewController.m
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 8/20/13.
//  Copyright (c) 2013 SenseForce. All rights reserved.
//

#import "OptionsViewController.h"
#import "MobClick.h"
#import "UMFeedback.h"
#import <Appirater/Appirater.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <RETableViewManager/RETableViewManager.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "FaqViewController.h"
#import "AboutViewController.h"
#import "AboutAdViewController.h"
#import "Constants.h"
#import "IAdManager.h"

@interface OptionsViewController ()

@property (nonatomic, strong) NSArray *optionTitles;

@property (nonatomic, strong) RETableViewManager *tableViewManager;

@property (nonatomic, weak) RETableViewItem *adSwitchItem;

- (void)refreshAdSwitchState;

@end

@implementation OptionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"设置";
    
    __weak __typeof(&*self) weakSelf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              bk_initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                              handler:^(id sender) {
                                                  [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:^{
                                                      
                                                  }];
                                              }];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    RETableViewSection *section = [RETableViewSection section];
    [section addItem:[RETableViewItem itemWithTitle:@"☂ 说问题，提建议"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item) {
                                       [item deselectRowAnimated:YES];
                                       [UMFeedback showFeedback:self withAppkey:UmengAppKey];
                                   }]];
    [section addItem:[RETableViewItem itemWithTitle:@"🛀 帮我清理一把"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item) {
                                       [item deselectRowAnimated:YES];
                                       MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                       hud.labelText = @"正在清理";
                                       [hud showAnimated:YES
                                     whileExecutingBlock:^{
                                         [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"screenshot"]
                                                                                    error:NULL];
                                     }
                                         completionBlock:^{
                                             hud.removeFromSuperViewOnHide = YES;
                                             hud.mode = MBProgressHUDModeText;
                                             hud.labelText = @"清理干净了";
                                             [hud show:NO];
                                             [hud hide:YES afterDelay:1.0f];
                                         }];
                                       
                                   }]];
    [section addItem:[RETableViewItem itemWithTitle:@"★ 打个分支持一下"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item) {
                                       [item deselectRowAnimated:YES];
                                       [Appirater rateApp];
                                   }]];
    [section addItem:[RETableViewItem itemWithTitle:@"🌀 这玩意儿怎么用"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item) {
                                       [item deselectRowAnimated:YES];
                                       FaqViewController *faqViewController = [[FaqViewController alloc] init];
                                       [weakSelf.navigationController pushViewController:faqViewController animated:YES];
                                   }]];
    [section addItem:[RETableViewItem itemWithTitle:@"☃ 关于程序员老黄历"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item) {
                                       [item deselectRowAnimated:YES];
                                       AboutViewController *aboutViewController = [[AboutViewController alloc] init];
                                       [weakSelf.navigationController pushViewController:aboutViewController animated:YES];
                                   }]];
    [self.tableViewManager addSection:section];
    
    RETableViewItem *adSwitchItem = [RETableViewItem itemWithTitle:@"🐎 关于万恶的广告"
                                                     accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                                  selectionHandler:^(RETableViewItem *item) {
                                                      [item deselectRowAnimated:YES];
                                                      AboutAdViewController *aboutAdViewController = [[AboutAdViewController alloc] init];
                                                      [weakSelf.navigationController pushViewController:aboutAdViewController animated:YES];
                                                  }];
    adSwitchItem.style = UITableViewCellStyleValue1;
    self.adSwitchItem = adSwitchItem;
    
    section = [RETableViewSection section];
    [section addItem:adSwitchItem];
    [self.tableViewManager addSection:section];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self refreshAdSwitchState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:NSStringFromClass([self class])];
    [super viewWillDisappear:animated];
}

- (void)refreshAdSwitchState {
    self.adSwitchItem.detailLabelText = ([IAdManager showingAd] ? @"谢谢支持" : @"已关闭广告");
    [self.adSwitchItem reloadRowWithAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
