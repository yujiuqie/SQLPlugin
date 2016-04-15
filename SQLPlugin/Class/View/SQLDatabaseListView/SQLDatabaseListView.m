//
//  SQLDatabaseListView.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/5.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLDatabaseListView.h"
#import "SQLDatabaseDescription.h"

@implementation SQLDatabaseListView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (NSMenu *)menuForEvent:(NSEvent *)event;
{
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:point];

    if (row == -1)
    {
        return nil;
    }
    
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    
    id cell = [self itemAtRow:self.selectedRow];
    NSMenuItem *item = [_databaseItemMenu itemWithTitle:@"Save to CSV"];
    
    if ([cell isKindOfClass:[SQLDatabaseDescription class]]) {
        [item setEnabled:NO];
    }
    else if([cell isKindOfClass:[SQLTableDescription class]]){
        [item setEnabled:YES];
    }
    
    return _databaseItemMenu;
}

@end
