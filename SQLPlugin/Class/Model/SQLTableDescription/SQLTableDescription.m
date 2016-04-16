//
//  SQLTableDescription.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLTableDescription.h"

@implementation SQLTableDescription

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return [NSString stringWithFormat:@"%@ (%@)",self.name, self.rowCount];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"SQLTableNameView" owner:self];
    cell.textField.stringValue = [NSString stringWithFormat:@"%@ (%@ %@)",self.name,self.rowCount,([self.rowCount integerValue] > 1) ? @"rows" : @"row"];
    return cell;
}

- (NSString *)databaseName
{
    return [_path lastPathComponent];
}

- (NSString *)selectedPropertName
{
    if (!_selectedPropertName || [_selectedPropertName length] == 0)
    {
        if (_properties && [_properties count] > 0)
        {
            SQLTableProperty *property = [_properties firstObject];
            return property.name;
        }
    }
    
    return _selectedPropertName;
}

@end
