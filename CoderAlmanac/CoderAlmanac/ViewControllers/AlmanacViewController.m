//
//  AlmanacViewController.m
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 2/24/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import "AlmanacViewController.h"

#import "AlmanacKit.h"

@interface AlmanacViewController ()

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIView *goodView;
@property (nonatomic, weak) IBOutlet UILabel *goodTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *goodContentLabel;
@property (nonatomic, weak) IBOutlet UIView *badView;
@property (nonatomic, weak) IBOutlet UILabel *badTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *badContentLabel;
@property (nonatomic, weak) IBOutlet UILabel *otherInfoLabel;


@end

@implementation AlmanacViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent =NO;
	
    self.title = @"程序员老黄历";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AlmanacKit sharedInstance] loadJson:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data_normal_coder" ofType:@"json"]
                                                                        encoding:NSUTF8StringEncoding
                                                                           error:NULL]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.dateLabel.text = [[AlmanacKit sharedInstance] getTodayString];
            self.goodContentLabel.text = [[AlmanacKit sharedInstance] getGoodString];
            self.badContentLabel.text = [[AlmanacKit sharedInstance] getBadString];
            self.otherInfoLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@",
                                        [[AlmanacKit sharedInstance] getDirectionString],
                                        [[AlmanacKit sharedInstance] getDrinkString],
                                        [[AlmanacKit sharedInstance] getStarString]];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
