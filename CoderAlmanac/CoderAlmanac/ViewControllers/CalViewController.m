//
//  CalViewController.m
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 2/23/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import "CalViewController.h"

@interface CalViewController () <TSQCalendarViewDelegate>

@property (nonatomic, strong) TSQCalendarView *calendarView;

@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, strong) NSDate *lastDate;

@end

@implementation CalViewController

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
    
    __weak __typeof(&*self) weakSelf = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"昨天"
                                                                                style:UIBarButtonItemStylePlain
                                                                              handler:^(id sender)
                                             {
                                                if ([weakSelf.delegate respondsToSelector:@selector(calDidSelectDate:)]) {
                                                    [weakSelf.delegate calDidSelectDate:[NSDate dateWithTimeIntervalSinceNow:-24 * 3600]];
                                                }
                                             }];
    
    self.title = @"您要看哪天";
    
    // 第一台计算机诞生于：19460214
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    self.firstDate = [dateFormatter dateFromString:@"19460214"];
    self.lastDate = [dateFormatter dateFromString:@"20200202"];
	
    TSQCalendarView *calendarView = [[TSQCalendarView alloc] initWithFrame:self.view.bounds];
    calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    calendarView.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    calendarView.rowCellClass = [TSQTACalendarRowCell class];
    calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    calendarView.pagingEnabled = NO;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    calendarView.firstDate = self.firstDate;
    calendarView.lastDate = self.lastDate;
    calendarView.selectedDate = [NSDate date];
    calendarView.delegate = self;
    self.calendarView = calendarView;
    
    [self.view addSubview:calendarView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.calendarView scrollToDate:[NSDate date] animated:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // [self.calendarView scrollToDate:[NSDate date] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TSQCalendarViewDelegate

- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldSelectDate:(NSDate *)date {
    if (([date timeIntervalSinceDate:self.firstDate] < 0) || ([date timeIntervalSinceDate:self.lastDate] > 0)) {
        return NO;
    }
    return YES;
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date {
    if ([self.delegate respondsToSelector:@selector(calDidSelectDate:)]) {
        [self.delegate calDidSelectDate:date];
    }
}

@end
