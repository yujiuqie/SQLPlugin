//
//  SQLDatabaseListDescription.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/5.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLDatabaseListDescription.h"

#import "SQLDatabaseManager.h"

@interface SQLDatabaseListDescription()

@end

@implementation SQLDatabaseListDescription

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(!item)
    {
        return [self.databases count];
    }
    else
    {
        return [item outlineView:outlineView numberOfChildrenOfItem:item];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return [self.databases count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(!item)
    {
        return [self.databases objectAtIndex:index];
    }
    else
    {
        return [item outlineView:outlineView child:index ofItem:item];
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return [item outlineView:outlineView viewForTableColumn:tableColumn item:item];
}

#pragma mark -

- (NSArray *)databases
{
    return [[SQLDatabaseManager sharedManager] databaseDescriptions];
}

@end
