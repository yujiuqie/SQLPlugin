//
//  SQLWindowsManager.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLWindowsManager.h"
#import "SQLMainViewController.h"

@interface SQLWindowsManager()

@property (nonatomic,strong,readwrite) NSMutableArray *windows;

@end

@implementation SQLWindowsManager
@synthesize windows;

static SQLWindowsManager *_sharedManager = nil;

+(instancetype)sharedManager
{
    if(!_sharedManager)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedManager = [[SQLWindowsManager alloc] init];
        });
    }
    return _sharedManager;
}

- (SQLMainViewController *)createWindowController
{
    SQLMainViewController *mainVC = [[SQLMainViewController alloc] initWithWindowNibName:@"SQLMainViewController"];
    [self addWindowController:mainVC];
    return mainVC;
}

- (void)addWindowController:(SQLMainViewController *)aWindow
{
    if (!windows) {
        windows = [NSMutableArray array];
    }
    
    [windows addObject:aWindow];
}

- (void)removeWindow:(NSWindow *)aWindow
{
    if (!windows || [windows count] == 0) {
        return;
    }
    
    [windows enumerateObjectsUsingBlock:^(SQLMainViewController *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.window isEqualTo:aWindow]) {
            [obj close];
            [windows removeObject:obj];
            *stop = YES;
        }
    }];
}

@end
