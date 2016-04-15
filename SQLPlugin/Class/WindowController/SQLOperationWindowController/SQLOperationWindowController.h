//
//  SQLOperationWindowController.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/15.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SQLDatabaseModel;

@interface SQLOperationWindowController : NSWindowController

@property (nonatomic, strong) SQLDatabaseModel *currentDatabase;

@end
