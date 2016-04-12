//
//  SQLDatabaseListView.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/5.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SQLDatabaseListView : NSOutlineView

@property (nonatomic, weak) IBOutlet NSMenu *databaseItemMenu;

@end
