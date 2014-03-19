//
//  CalViewController.h
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 2/23/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BlocksKit/BlocksKit+UIKit.h>
#import <TimesSquare/TSQCalendarView.h>
#import "TSQTACalendarRowCell.h"

@protocol CalViewControllerDelegate <NSObject>

- (void)calDidSelectDate:(NSDate *)date;

@end

@interface CalViewController : UIViewController {
    
}

@property (nonatomic, weak) id<CalViewControllerDelegate> delegate;

@end
