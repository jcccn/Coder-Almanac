//
//  AlmanacHolder.h
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 3/4/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlmanacHolder : NSObject {
    
}

@property (nonatomic, copy) NSString *currentJobTitle;
@property (nonatomic, strong, readonly) NSArray *jobTitles;

+ (instancetype)sharedInstance;

- (NSString *)currentJobJson;

@end
