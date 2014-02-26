//
//  AlmanacKit.m
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 2/26/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import "AlmanacKit.h"

#import <JSONKit/JSONKit.h>

@interface AlmanacKit ()

@property (nonatomic, strong) NSDate *today;
@property (nonatomic, assign) NSInteger iday;
@property (nonatomic, assign) NSArray *weeks;
@property (nonatomic, assign) NSArray *directions;
@property (nonatomic, assign) NSArray *activities;
@property (nonatomic, assign) NSArray *specials;
@property (nonatomic, assign) NSArray *tools;
@property (nonatomic, assign) NSArray *varNames;
@property (nonatomic, assign) NSArray *drinks;

@property (nonatomic, strong) NSMutableString *goodResult;
@property (nonatomic, strong) NSMutableString *badResult;
@property (nonatomic, strong) NSString *directionResult;
@property (nonatomic, strong) NSString *drinkResult;
@property (nonatomic, assign) NSInteger starResult;

- (NSInteger)randomWithDay:(NSInteger)dayseed index:(NSInteger)indexseed;
- (NSString *)star:(NSInteger)num;
- (void)pickTodaysLuck;
- (NSArray *)filter:(NSArray *)activities;
- (BOOL)isWeekend;
- (NSArray *)pickSpecials;
- (NSArray *)pickRandomActivity:(NSArray *)activities size:(NSInteger)size;
- (AlmanacEvent *)parse:(AlmanacEvent *)event;
- (void)addToGood:(AlmanacEvent *)event;
- (void)addToBad:(AlmanacEvent *)event;

@end


@implementation AlmanacKit

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.goodResult = [NSMutableString string];
        self.badResult = [NSMutableString string];
    }
    return self;
}

- (void)loadJson:(NSString *)jsonString {
    NSDictionary *data = [jsonString objectFromJSONString];
    if ( ! [data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    self.today = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSInteger year = [[dateFormatter stringFromDate:self.today] integerValue];
    [dateFormatter setDateFormat:@"MM"];
    NSInteger month = [[dateFormatter stringFromDate:self.today] integerValue];
    [dateFormatter setDateFormat:@"dd"];
    NSInteger date = [[dateFormatter stringFromDate:self.today] integerValue];
    self.iday = year * 10000 + (month) * 100 + date;
    
    self.weeks = data[@"weeks"];
    
    self.directions = data[@"directions"];
    
    NSMutableArray *activities = [NSMutableArray arrayWithCapacity:[data[@"activities"] count]];
    for (NSDictionary *activity in data[@"activities"]) {
        if ([activity isKindOfClass:[NSDictionary class]]) {
            AlmanacEvent *event = [[AlmanacEvent alloc] init];
            event.name = [activity[@"name"] copy];
            event.good = [activity[@"good"] copy];
            event.bad = [activity[@"bad"] copy];
            event.weekend = [activity[@"weekend"] boolValue];
            
            [activities addObject:event];
        }
    }
    self.activities = activities;
    
    NSMutableArray *specials = [NSMutableArray arrayWithCapacity:[data[@"specials"] count]];
    for (NSDictionary *special in data[@"specials"]) {
        if ([specials isKindOfClass:[NSDictionary class]]) {
            AlmanacSpecial *event = [[AlmanacSpecial alloc] init];
            event.date = [special[@"date"] integerValue];
            event.type = [special[@"type"] copy];
            event.name = [special[@"name"] copy];
            event.description = [special[@"description"] copy];
            [specials addObject:event];
        }
    }
    self.specials = specials;
    
    self.tools = data[@"tools"];
    
    self.varNames = data[@"varNames"];
    
    self.drinks = data[@"drinks"];
    
    
    /**********  开始解析  *********/
    [self pickTodaysLuck];
    
    if ([self.directions count]) {
        self.directionResult = self.directions[[self randomWithDay:self.iday index:2] % [self.directions count]];
    }
    self.directionResult = [NSString stringWithFormat:@"座位朝向：面向%@写程序，BUG 最少。", (self.directionResult ? self.directionResult : @"地板")];
    
    NSArray *drinks = [self pickRandom:self.drinks size:2];
    self.drinkResult = [NSString stringWithFormat:@"今日宜饮：%@，%@", [drinks firstObject], [drinks lastObject]];
    
    self.starResult = [self randomWithDay:self.iday index:6] % 5 + 1;
    
}

- (NSString *)getGoodString {
    return [self.goodResult copy];
}

- (NSString *)getBadString {
    return [self.badResult copy];
}

- (NSString *)getDirectionString {
    return [self.directionResult copy];
}

- (NSString *)getDrinkString {
    return [self.drinkResult copy];
}

- (NSString *)getStarString {
    return [NSString stringWithFormat:@"女神亲近指数：%@", [self star:self.starResult]];
}

/*
 * 注意：本程序中的“随机”都是伪随机概念，以当前的天为种子。
 */
- (NSInteger)randomWithDay:(NSInteger)dayseed index:(NSInteger)indexseed {
    NSInteger n = dayseed % 11117;
	for (NSInteger i = 0; i < 100 + indexseed; i++) {
		n = n * n;
		n = n % 11117;   // 11117 是个质数
	}
	return n;
}

- (NSString *)getTodayString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"今天是yyyy年MM月dd日 EEEE"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    return [dateFormatter stringFromDate:self.today];
}

- (NSString *)star:(NSInteger)num {
    NSMutableString *result = [NSMutableString string];
    NSInteger i = 0;
	while (i < num) {
		[result appendString:@"★"];
		i++;
	}
	while(i < 5) {
		[result appendString:@"☆"];
		i++;
	}
	return result;
}

// 生成今日运势
- (void)pickTodaysLuck {
    NSArray *activities = [self filter:self.activities];
    
	NSInteger numGood = [self randomWithDay:self.iday index:98] % 3 + 2;
	NSInteger numBad = [self randomWithDay:self.iday index:87] % 3 + 2;
	NSArray *eventArr = [self pickRandomActivity:activities size:numGood + numBad];
	
	NSArray *specialSize = [self pickSpecials];
	
	for (NSInteger i = 0, count = [eventArr count]; i < numGood && i < count; i++) {
		[self addToGood:eventArr[i]];
	}
	
	for (NSInteger i = 0, count = [eventArr count]; i < numBad && (numGood + i < count); i++) {
		[self addToBad:eventArr[numGood + i]];
	}
}

// 去掉一些不合今日的事件
- (NSArray *)filter:(NSArray *)activities {
    NSMutableArray *result = [NSMutableArray array];
    
    // 周末的话，只留下 weekend = true 的事件
    if ([self isWeekend]) {
        
        for (NSInteger i = 0; i < [activities count]; i++) {
            if (((AlmanacEvent *)activities[i]).weekend) {
                [result addObject:activities[i]];
            }
        }
        
        return result;
    }
    
    return activities;
}

- (BOOL)isWeekend {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"e"];
    NSInteger day = [[dateFormatter stringFromDate:self.today] integerValue];
    return day == 0 || day == 6;
}

// 添加预定义事件
- (NSArray *)pickSpecials {
    NSMutableArray *specialSize = [@[@(0), @(0)] mutableCopy];
	
	for (NSInteger i = 0; i < [self.specials count]; i++) {
		AlmanacSpecial *special = self.specials[i];
		
		if (self.iday == special.date) {
			if ([special.type isEqualToString:@"good"]) {
				specialSize[0] = @([specialSize[0] integerValue] + 1);
                AlmanacEvent *event = [[AlmanacEvent alloc] init];
                event.name = [special.name copy];
                event.good = [special.description copy];
                [self addToGood:event];
			}
            else {
                specialSize[1] = @([specialSize[1] integerValue] + 1);
                AlmanacEvent *event = [[AlmanacEvent alloc] init];
                event.name = [special.name copy];
                event.good = [special.description copy];
                [self addToBad:event];
			}
		}
	}
	
	return specialSize;
}

// 从 activities 中随机挑选 size 个
- (NSArray *)pickRandomActivity:(NSArray *)activities size:(NSInteger)size {
    NSMutableArray *picked_events = [NSMutableArray arrayWithArray:[self pickRandom:activities size:size]];
	
	for (NSInteger i = 0; i < [picked_events count]; i++) {
		picked_events[i] = [self parse:picked_events[i]];
	}
	
	return picked_events;
}

// 从数组中随机挑选 size 个
- (NSArray *)pickRandom:(NSArray *)array size:(NSInteger)size {
    NSMutableArray *result = [NSMutableArray array];
	
	for (NSInteger i = 0; i < [array count]; i++) {
        [result addObject:array[i]];
	}
	
	for (NSInteger j = 0; j < [array count] - size; j++) {
		NSInteger index = [self randomWithDay:self.iday index:j] % MAX([result count], 1);
		[result removeObjectAtIndex:index];
	}
	
	return result;
}

// 解析占位符并替换成随机内容
- (AlmanacEvent *)parse:(AlmanacEvent *)event {
    AlmanacEvent *result = [[AlmanacEvent alloc] init];
    result.name = event.name;
    result.good = event.good;
    result.bad = event.bad;
	
	if ([result.name rangeOfString:@"%v"].location != NSNotFound) {
		result.name = [result.name stringByReplacingOccurrencesOfString:@"%v" withString:self.varNames[[self randomWithDay:self.iday index:12] % MAX([self.varNames count], 1)]];
	}
	
	if ([result.name rangeOfString:@"%t"].location != NSNotFound) {
        result.name = [result.name stringByReplacingOccurrencesOfString:@"%t" withString:self.tools[[self randomWithDay:self.iday index:11] % MAX([self.tools count], 1)]];
	}
	
	if ([result.name rangeOfString:@"%l"].location != NSNotFound) {
        result.name = [result.name stringByReplacingOccurrencesOfString:@"%l" withString:[NSString stringWithFormat:@"%d", [self randomWithDay:self.iday index:12] % 247 + 30]];
	}
	
	return result;
}

// 添加到“宜”
- (void)addToGood:(AlmanacEvent *)event {
    [self.goodResult appendFormat:@"%@%@%@\n", event.name, ([event.good length] ? @"：": @""), event.good];
}

// 添加到“不宜”
- (void)addToBad:(AlmanacEvent *)event {
    [self.badResult appendFormat:@"%@%@%@\n", event.name, ([event.bad length] ? @"：": @""), event.bad];
}

@end


@implementation AlmanacEvent


@end


@implementation AlmanacSpecial


@end