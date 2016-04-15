//
//  SQLWindowsManager.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SQLMainWindowController.h"
#import "SQLOperationWindowController.h"

typedef NS_ENUM(NSInteger, SQLWindowType) {
    SQLWindowType_SQL_Viewer = 0,
    SQLWindowType_SQL_Operation
};

@interface SQLWindowsManager : NSObject

@property (nonatomic,strong,readonly) NSMutableArray *windows;

+(instancetype)sharedManager;

- (NSWindowController *)windowWithType:(SQLWindowType)windowType;
- (void)addWindowController:(NSWindowController *)aWindowVC;
- (void)removeWindow:(NSWindow *)aWindow;

@end
