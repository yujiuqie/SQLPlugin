//
//  SQLWindowsManager.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SQLMainViewController;

@interface SQLWindowsManager : NSObject

@property (nonatomic,strong,readonly) NSMutableArray *windows;

+(instancetype)sharedManager;

- (SQLMainViewController *)createWindowController;
- (void)removeWindow:(NSWindow *)aWindow;

@end
