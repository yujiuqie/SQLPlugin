//
//  SQLTableDescription.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLTableDescription.h"

@implementation SQLTableDescription
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return NO;
}

- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item
{
    return [NSString stringWithFormat:@"%@ (%@)",self.name, self.rows];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    
    NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"SQLTableNameView" owner:self];
    cell.textField.stringValue = [NSString stringWithFormat:@"%@ (%@ rows)",self.name,self.rows];
    return cell;
}

- (NSString *)databaseName
{
    return [_path lastPathComponent];
}

@end
