//
//  AlmanacKit.h
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 2/26/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHAttributedLabel/OHAttributedLabel.h>

@class AlmanacEvent;
@class AlmanacSpecial;

@interface AlmanacKit : NSObject

+ (instancetype)sharedInstance;

- (void)setDate:(NSDate *)date;

- (void)loadJson:(NSString *)jsonString;

- (NSString *)getTodayString;
- (NSString *)getGoodString;
- (NSAttributedString *)getGoodAttributedString;
- (NSString *)getBadString;
- (NSAttributedString *)getBadAttributedString;
- (NSString *)getDirectionString;
- (NSString *)getDrinkString;
- (NSString *)getStarString;

@end


@interface AlmanacEvent : NSObject {
    
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *good;
@property (nonatomic, strong) NSString *bad;
@property (nonatomic, assign) BOOL weekend;

@end

@interface AlmanacSpecial : NSObject

@property (nonatomic, assign) NSInteger date;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *descriptionString;

@end