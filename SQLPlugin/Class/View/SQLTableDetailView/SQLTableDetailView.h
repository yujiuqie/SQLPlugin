//
//  SQLTableDetailViewController.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SQLTableDescription.h"

@interface SQLTableDetailView : NSView

@property (nonatomic, strong) SQLTableDescription *table;
@property (nonatomic, weak) NSButton *leftButton;
@property (nonatomic, weak) NSButton *rightButton;

- (void)refreshTable:(SQLTableDescription *)table;

@end
