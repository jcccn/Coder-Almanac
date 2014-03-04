//
//  AlmanacHolder.m
//  CoderAlmanac
//
//  Created by Jiang Chuncheng on 3/4/14.
//  Copyright (c) 2014 SenseForce. All rights reserved.
//

#import "AlmanacHolder.h"

#define kCurrentJobTitle    @"currentJobTitle"

@interface AlmanacHolder ()

@property (nonatomic, strong) NSDictionary *jobs;

@end


@implementation AlmanacHolder

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
        NSArray *jobsArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"jobs_info" ofType:@"plist"]];
        NSMutableDictionary *jobsDict = [NSMutableDictionary dictionaryWithCapacity:[jobsArray count]];
        NSMutableArray *jobTitles = [NSMutableArray arrayWithCapacity:[jobsArray count]];
        
        for (NSDictionary *jobInfo in jobsArray) {
            NSString *jobName = jobInfo[@"name"];
            NSString *fileName = jobInfo[@"path"];
            if (jobName && fileName) {
                [jobTitles addObject:jobName];
                jobsDict[jobName] = fileName;
            }
        }
        
        _jobTitles = jobTitles;
        self.jobs = jobsDict;
        
        if ( ! [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentJobTitle]) {
            self.currentJobTitle = [self.jobTitles firstObject];
            [[NSUserDefaults standardUserDefaults] setObject:self.currentJobTitle
                                                      forKey:kCurrentJobTitle];
        }
        else {
            self.currentJobTitle = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentJobTitle];
        }
    }
    return self;
}

- (void)setCurrentJobTitle:(NSString *)currentJobTitle {
    _currentJobTitle = [currentJobTitle copy];
    [[NSUserDefaults standardUserDefaults] setObject:currentJobTitle forKey:kCurrentJobTitle];
}

- (NSString *)currentJobJson {
    NSString *jobTitle = self.currentJobTitle;
    if ( ! jobTitle) {
        return @"";
    }
    NSString *fileName = self.jobs[jobTitle];
    fileName = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    return [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];
}

@end
