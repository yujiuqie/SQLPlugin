//
//  SQLTableDescription.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLTableDescription.h"

@implementation SQLTableDescription
- (NSInteger)outlineView:(nonnull NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    return 0;
}

- (id)outlineView:(nonnull NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    return nil;
}

- (BOOL)outlineView:(nonnull NSOutlineView *)outlineView isItemExpandable:(nonnull id)item
{
    return NO;
}

- (id)outlineView:(nonnull NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(nullable id)item
{
    return [NSString stringWithFormat:@"%@ (%@)",self.name, self.rows];
}

- (NSView *)outlineView:(nonnull NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(nonnull id)item
{
    NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"SQLTableNameView" owner:self];
    cell.textField.stringValue = [NSString stringWithFormat:@"%@ (%@ rows)",self.name,self.rows];
    return cell;
}

- (NSString *)databaseName
{
    return [_path lastPathComponent];
}

- (NSString *)selectedPropertName
{
    if (!_selectedPropertName || [_selectedPropertName length] == 0) {
        if (_properties && [_properties count] > 0) {
            SQLTableProperty *property = [_properties firstObject];
            return property.name;
        }
    }
    
    return _selectedPropertName;
}

@end
