//
//  IAdManager.h
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 2/23/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

#define kShowingAd              @"showingAd"

@protocol IADContainer <NSObject>

- (void)showAdBanner;
- (void)hideAdBanner;

@end

@interface IAdManager : NSObject {
    
}

@property (nonatomic, strong) ADBannerView *adBannerView;

+ (instancetype)sharedInstance;

+ (BOOL)showingAd;
+ (void)setShowingAd:(BOOL)showingAd;

- (void)registerAdContainer:(id<IADContainer>)container;
- (void)unregisterAdContainer:(id<IADContainer>)container;

@end
