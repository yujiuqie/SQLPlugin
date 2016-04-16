//
//  SQLWindowsManager.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLWindowsManager.h"

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

- (NSWindowController *)windowWithType:(SQLWindowType)windowType
{
    Class targetWindowVCClass = nil;
    
    switch (windowType)
    {
        case SQLWindowType_SQL_Viewer:
        {
            targetWindowVCClass = [SQLMainWindowController class];
        }
            break;
            
        case SQLWindowType_SQL_Operation:
        {
            targetWindowVCClass = [SQLOperationWindowController class];
        }
            break;
    }
    
    if (targetWindowVCClass)
    {
        __block NSWindowController *targetVC = nil;
        
        [windows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:targetWindowVCClass]) {
                targetVC = obj;
                *stop = YES;
            }
        }];
        
        if (!targetVC)
        {
            targetVC = [[targetWindowVCClass alloc] initWithWindowNibName:NSStringFromClass(targetWindowVCClass)];
            [self addWindowController:targetVC];
        }
        
        return targetVC;
    }
    
    return nil;
}

- (void)addWindowController:(NSWindowController *)aWindowVC
{
    if (!windows)
    {
        windows = [NSMutableArray array];
    }
    
    [windows addObject:aWindowVC];
}

- (void)removeWindow:(NSWindow *)aWindow
{
    if (!windows || [windows count] == 0)
    {
        return;
    }
    
    [windows enumerateObjectsUsingBlock:^(NSWindowController *obj, NSUInteger idx, BOOL * stop) {
        
        if ([obj.window isEqualTo:aWindow])
        {
            [obj close];
            [windows removeObject:obj];
            *stop = YES;
        }
    }];
}

@end
