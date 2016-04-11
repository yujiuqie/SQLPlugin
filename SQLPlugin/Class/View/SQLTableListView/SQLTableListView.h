//
//  SQLTableListViewController.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SQLDatabaseListDescription.h"
#import "SQLTableListProtocol.h"

@interface SQLTableListView : NSView

@property (nonatomic, weak) id<SQLTableListDelegate> delegate;
@property (nonatomic, strong) SQLDatabaseListDescription *databases;

- (void)removeSelectedItem;

@end
