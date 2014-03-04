//
//  IAdManager.m
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 2/23/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import "IAdManager.h"


@interface IAdManager () <ADBannerViewDelegate>

@property (nonatomic, strong) NSMutableArray *iAdContainers;

- (void)showAllAdBanners;
- (void)hideAllAdBanners;

@end


@implementation IAdManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
//        _sharedObject = [[self alloc] init];
        //FIXME:暂时屏幕广告管理器
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.iAdContainers = [NSMutableArray array];
        
        if ( ! [[NSUserDefaults standardUserDefaults] objectForKey:kShowingAd]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShowingAd];
        }
        
        self.adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        self.adBannerView.delegate = self;
        self.adBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

+ (BOOL)showingAd {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShowingAd];
}

+ (void)setShowingAd:(BOOL)showingAd {
    [[NSUserDefaults standardUserDefaults] setBool:showingAd forKey:kShowingAd];
    
    if (showingAd && [IAdManager sharedInstance].adBannerView.bannerLoaded) {
        [[IAdManager sharedInstance] showAllAdBanners];
    }
    else {
        [[IAdManager sharedInstance] hideAllAdBanners];
    }
    
}

- (void)registerAdContainer:(id<IADContainer>)container {
    if (container && ( ! [self.iAdContainers containsObject:container])) {
        [self.iAdContainers addObject:container];
        
        if (self.adBannerView.bannerLoaded && [IAdManager showingAd]) {
            if ([container respondsToSelector:@selector(showAdBanner)]) {
                [container showAdBanner];
            }
        }
        else {
            if ([container respondsToSelector:@selector(hideAdBanner)]) {
                [container hideAdBanner];
            }
        }
    }
}

- (void)unregisterAdContainer:(id<IADContainer>)container {
    if (container) {
        [self.iAdContainers removeObject:container];
    }
}

- (void)showAllAdBanners {
    for (id<IADContainer> container in self.iAdContainers) {
        if ([container respondsToSelector:@selector(showAdBanner)]) {
            [container showAdBanner];
        }
    }
}

- (void)hideAllAdBanners {
    for (id<IADContainer> container in self.iAdContainers) {
        if ([container respondsToSelector:@selector(hideAdBanner)]) {
            [container hideAdBanner];
        }
    }
}

#pragma mark - ADBanner Delegate

- (void)bannerViewWillLoadAd:(ADBannerView *)banner {
    
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (banner.bannerLoaded && [IAdManager showingAd]) {
        [self showAllAdBanners];
    }
    else {
        [self hideAllAdBanners];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self hideAllAdBanners];
    NSLog(@"ADBanner Loading Error:\n%@", error);
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    
}

@end
