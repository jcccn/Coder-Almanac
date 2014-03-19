//
//  AlmanacViewController.m
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 2/24/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import "AlmanacViewController.h"

#import <BlocksKit/BlocksKit+UIKit.h>
#import <ShareSDK/ShareSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "MobClick.h"

#import "AlmanacKit.h"
#import "AlmanacHolder.h"
#import "Constants.h"
#import "OptionsViewController.h"
#import "CalViewController.h"

@interface AlmanacViewController () <CalViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIView *goodView;
@property (nonatomic, weak) IBOutlet UILabel *goodTitleLabel;
@property (nonatomic, weak) IBOutlet OHAttributedLabel *goodContentLabel;
@property (nonatomic, weak) IBOutlet UIView *badView;
@property (nonatomic, weak) IBOutlet UILabel *badTitleLabel;
@property (nonatomic, weak) IBOutlet OHAttributedLabel *badContentLabel;
@property (nonatomic, weak) IBOutlet UILabel *otherInfoLabel;

- (void)reloadAlmanac;
- (void)reloadAlmanacOnDate:(NSDate *)date;
- (IBAction)showMoreOptions:(id)sender;
- (void)showDailyCalPicker;
- (void)shareAlmanac;
- (UIImage *)screenshot;
- (NSString *)screenshotAndSave;

@end

@implementation AlmanacViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent =NO;
	
    self.title = @"程序员老黄历";
    
    __weak __typeof(&*self) weakSelf = self;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [leftButton addTarget:self action:@selector(showMoreOptions:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                   handler:^(id sender) {
                                                                                       [weakSelf shareAlmanac];
                                                                                   }];
    UIBarButtonItem *calButton = [[UIBarButtonItem alloc] bk_initWithTitle:@" 📅 "
                                                                     style:UIBarButtonItemStylePlain
                                                                   handler:^(id sender) {
                                                                       [weakSelf showDailyCalPicker];
                                                                   }];
    self.navigationItem.rightBarButtonItems = @[shareButton, calButton];
    
    self.goodContentLabel.centerVertically = YES;
    self.badContentLabel.centerVertically = YES;
    self.dateLabel.text = nil;
    self.goodContentLabel.text = nil;
    self.badContentLabel.text = nil;
    self.otherInfoLabel.text = nil;
    
    [self reloadAlmanac];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAlmanac:) name:kNotificationShouldReloadAlmanac object:nil];
}

- (void)reloadAlmanac:(NSNotification *)notification {
    [self reloadAlmanac];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:NSStringFromClass([self class])];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadAlmanac {
    [self reloadAlmanacOnDate:[NSDate date]];
}

- (void)reloadAlmanacOnDate:(NSDate *)date {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (! hud) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabelText = @"正在占卜测算";
    
    __weak __typeof(&*self) weakSelf = self;
    [hud showAnimated:YES
  whileExecutingBlock:^{
      [[AlmanacKit sharedInstance] setDate:date];
      [[AlmanacKit sharedInstance] loadJson:[[AlmanacHolder sharedInstance] currentJobJson]];
  }
      completionBlock:^{
          weakSelf.dateLabel.text = [[AlmanacKit sharedInstance] getTodayString];
          weakSelf.goodContentLabel.attributedText = [[AlmanacKit sharedInstance] getGoodAttributedString];
          weakSelf.badContentLabel.attributedText = [[AlmanacKit sharedInstance] getBadAttributedString];
          weakSelf.otherInfoLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@",
                                          [[AlmanacKit sharedInstance] getDirectionString],
                                          [[AlmanacKit sharedInstance] getDrinkString],
                                          [[AlmanacKit sharedInstance] getStarString]];
      }];
}

- (IBAction)showMoreOptions:(id)sender {
    OptionsViewController *optionsViewController = [[OptionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *optionsNavigationController = [[UINavigationController alloc] initWithRootViewController:optionsViewController];
    optionsNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:optionsNavigationController
                       animated:YES
                     completion:^{
                         
                     }];
    
}

- (void)showDailyCalPicker {
    CalViewController *calViewController = [[CalViewController alloc] init];
    calViewController.delegate = self;
    UINavigationController *calNavigationController = [[UINavigationController alloc] initWithRootViewController:calViewController];
    calNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    __weak UINavigationController *weakNavigationController = calNavigationController;
    calViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                           bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                           handler:^(id sender) {
                                                               [weakNavigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                                                                   
                                                               }];
                                                           }];
    [self presentViewController:calNavigationController
                       animated:YES
                     completion:NULL];
}

- (void)shareAlmanac {
    NSString *content = [NSString stringWithFormat:@"今日%@ (来自【程序员老黄历】%@ ) ", [[AlmanacKit sharedInstance] getStarString], AppStoreShortUrl];
    
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:[@"程序员老黄历 " stringByAppendingFormat:@"%@", AppStoreShortUrl]
                                                image:[ShareSDK imageWithPath:[self screenshotAndSave]]
                                                title:@"程序员老黄历今日宜忌"
                                                  url:AppStoreShortUrl
                                          description:content
                                            mediaType:SSPublishContentMediaTypeImage];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStylePopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    [authOptions setPowerByHidden:YES];
    
    NSArray *shareList = [ShareSDK getShareListWithType:
                          ShareTypeSinaWeibo,
                          ShareTypeTencentWeibo,
                          ShareTypeWeixiTimeline,
                          ShareTypeWeixiSession,
                          ShareTypeQQSpace,
                          ShareTypeQQ,
                          ShareTypeMail,
                          ShareTypeCopy,
                          ShareTypeAirPrint,
                          nil];
    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"程序员老黄历"
                                                              oneKeyShareList:shareList
                                                               qqButtonHidden:NO
                                                        wxSessionButtonHidden:NO
                                                       wxTimelineButtonHidden:NO
                                                         showKeyboardOnAppear:NO
                                                            shareViewDelegate:nil
                                                          friendsViewDelegate:nil
                                                        picViewerViewDelegate:nil];
    
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithBarButtonItem:[self.navigationItem.rightBarButtonItems lastObject]
                                     arrowDirect:UIPopoverArrowDirectionUp];
    [container setIPhoneContainerWithViewController:self];
    
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:shareOptions
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess) {
                                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                    hud.removeFromSuperViewOnHide = YES;
                                    hud.mode = MBProgressHUDModeText;
                                    hud.labelText = @"分享成功";
                                    [hud hide:YES afterDelay:1.0f];
                                }
                            }];
}

- (UIImage *)screenshot {
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    __autoreleasing UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}

- (NSString *)screenshotAndSave {
    UIImage *screenshot = [self screenshot];
    if ( ! screenshot) {
        return nil;
    }
    NSString *directoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"screenshot/"];
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    NSString *filename = [NSString stringWithFormat:@"%.0f.jpg", [[NSDate date] timeIntervalSince1970] * 1000];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:filename];
    if ([UIImageJPEGRepresentation(screenshot, 0.8f) writeToFile:filePath atomically:YES]) {
        return filePath;
    }
    else {
        return nil;
    }
}


#pragma mark - CalViewControllerDelegate

- (void)calDidSelectDate:(NSDate *)date {
    [self dismissViewControllerAnimated:YES completion:^{
        [self reloadAlmanacOnDate:date];
    }];
}


@end
