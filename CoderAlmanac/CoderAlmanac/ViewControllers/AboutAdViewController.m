//
//  AboutAdViewController.m
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 2/22/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import "AboutAdViewController.h"

#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>

#import "Constants.h"
#import "IAdManager.h"

@interface AboutAdViewController () <UIWebViewDelegate, IADContainer>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *adSwitchView;
@property (nonatomic, strong) UISwitch *adSwitch;
@property (nonatomic, strong) UILabel *adStateLabel;
@property (nonatomic, strong) ADBannerView *adBannerView;

- (void)switchAd:(BOOL)showingAd;

@end

@implementation AboutAdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"关于广告";
    
    __weak __typeof(&*self) weakSelf = self;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.webView];
    
    BOOL showingAd = [IAdManager showingAd];
    
    self.adSwitchView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 120, CGRectGetWidth(self.view.bounds), 120)];
    self.adSwitchView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.adSwitchView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    [self.view addSubview:self.adSwitchView];
    
    self.adSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    self.adSwitch.center = CGPointMake(CGRectGetMidX(self.adSwitchView.bounds) - 50, 25);
    self.adSwitch.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.adSwitch.tintColor = [UIColor redColor];
    [self.adSwitch bk_addEventHandler:^(id sender) {
        UISwitch *adSwitch = (UISwitch *)sender;
        [weakSelf switchAd:adSwitch.isOn];
    }
                     forControlEvents:UIControlEventValueChanged];
    self.adSwitch.on = showingAd;
    [self.adSwitchView addSubview:self.adSwitch];
    
    self.adStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 100, 40)];
    self.adStateLabel.center = CGPointMake(CGRectGetMaxX(self.adSwitch.frame) + CGRectGetMidX(self.adStateLabel.bounds) + 20, CGRectGetMidY(self.adSwitch.frame));
    self.adStateLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.adStateLabel.text = [NSString stringWithFormat:@"广告已%@", (showingAd ? @"开启" : @"关闭")];
    self.adStateLabel.textColor = (showingAd ? [UIColor greenColor] : [UIColor redColor]);
    [self.adSwitchView addSubview:self.adStateLabel];
    
    self.adBannerView = [IAdManager sharedInstance].adBannerView;
    self.adBannerView.center = CGPointMake(CGRectGetMidX(self.adSwitchView.bounds), CGRectGetHeight(self.adSwitchView.bounds) + 66.0f / 2);
    [self.adSwitchView addSubview:self.adBannerView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about_ad" ofType:@"html"]]]];
    
    [[IAdManager sharedInstance] registerAdContainer:self];
}

- (void)switchAd:(BOOL)showingAd {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.adSwitchView.backgroundColor = [UIColor colorWithWhite:(showingAd ? 0.95f : 0.90f) alpha:1.0f];
                         
                         self.adStateLabel.text = [NSString stringWithFormat:@"广告已%@", (showingAd ? @"开启" : @"关闭")];
                         self.adStateLabel.textColor = (showingAd ? [UIColor greenColor] : [UIColor redColor]);
                     }
                     completion:^(BOOL finished) {

                     }];
    
    [IAdManager setShowingAd:showingAd];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:NSStringFromClass([self class])];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[IAdManager sharedInstance] unregisterAdContainer:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.adStateLabel.center = CGPointMake(CGRectGetMaxX(self.adSwitch.frame) + CGRectGetMidX(self.adStateLabel.bounds) + 20, CGRectGetMidY(self.adSwitch.frame));
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

#pragma mark - IADContainer

- (void)showAdBanner {
//    self.adBannerView.center = CGPointMake(CGRectGetMidX(self.adSwitchView.bounds),
//                                           CGRectGetHeight(self.adSwitchView.bounds) - 66.0f / 2);
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.adBannerView.center = CGPointMake(CGRectGetMidX(self.adSwitchView.bounds),
                                                                CGRectGetHeight(self.adSwitchView.bounds) - 66.0f / 2);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)hideAdBanner {
//    self.adBannerView.center = CGPointMake(CGRectGetMidX(self.adSwitchView.bounds),
//                                           CGRectGetHeight(self.adSwitchView.bounds) + 66.0f / 2);
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.adBannerView.center = CGPointMake(CGRectGetMidX(self.adSwitchView.bounds),
                                                                CGRectGetHeight(self.adSwitchView.bounds) + 66.0f / 2);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

@end
