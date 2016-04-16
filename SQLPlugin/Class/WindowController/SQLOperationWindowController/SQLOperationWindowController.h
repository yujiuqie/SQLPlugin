//
//  SQLOperationWindowController.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/15.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SQLDatabaseDescription;

@interface SQLOperationWindowController : NSWindowController

@property (nonatomic, strong) SQLDatabaseDescription *currentDatabase;

@end
