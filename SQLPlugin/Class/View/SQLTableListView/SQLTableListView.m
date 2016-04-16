//
//  SQLTableListViewController.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLTableListView.h"

#import "SQLDatabaseManager.h"

@interface SQLTableListView ()
<
NSOutlineViewDataSource,
NSOutlineViewDelegate
>

@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;
@end

@implementation SQLTableListView

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(!item)
    {
        return [self.databases outlineView:outlineView numberOfChildrenOfItem:item];
    }
    else
    {
        return [item outlineView:outlineView numberOfChildrenOfItem:item];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return [item outlineView:outlineView isItemExpandable:item];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(!item)
    {
        return [self.databases outlineView:outlineView child:index ofItem:item];
    }
    else
    {
        return [item outlineView:outlineView child:index ofItem:item];
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if(!item)
    {
        return [self.databases outlineView:outlineView viewForTableColumn:tableColumn item:item];
    }
    else
    {
        return [item outlineView:outlineView viewForTableColumn:tableColumn item:item];
    }
}

-(void)awakeFromNib
{
    self.outlineView.delegate = self;
    self.outlineView.dataSource = self;
}

-(void)setDatabases:(SQLDatabaseListDescription *)database
{
    _databases = database;
    [self.outlineView reloadData];
}

-(void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSOutlineView *outlineView = notification.object;
    id selectedItem = [outlineView itemAtRow:outlineView.selectedRow];
    
    if([selectedItem isKindOfClass:[SQLTableDescription class]])
    {
        SQLTableDescription *table = selectedItem;
        [self.delegate didSelectTable:table];
        self.window.title = [NSString stringWithFormat:@"%@ > %@",[table databaseName],[table name]];
    }
    else if([selectedItem isKindOfClass:[SQLDatabaseDescription class]])
    {
        SQLDatabaseDescription *database = selectedItem;
        [self.delegate didSelectDatabase:selectedItem];
        self.window.title = database.name;
        
        [self.outlineView expandItem:selectedItem];
    }
}

#pragma mark -

- (void)removeSelectedItem
{
    id selectedItem = [self.outlineView itemAtRow:self.outlineView.selectedRow];
    
    id itemParent = nil;
    
    if ([selectedItem isKindOfClass:[SQLDatabaseDescription class]])
    {
        itemParent = selectedItem;
    }
    else if([selectedItem isKindOfClass:[SQLTableDescription class]])
    {
        itemParent = [self.outlineView parentForItem:selectedItem];
    }
    
    NSInteger index = [_databases.databases indexOfObject:itemParent];
    [[SQLDatabaseManager sharedManager] removeDatabaseDescription:itemParent];
    
    [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:nil withAnimation:NSTableViewAnimationSlideLeft];
}

@end
