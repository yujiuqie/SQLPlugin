//
//  SQLDatabaseDescription.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLDatabaseDescription.h"

#import "SQLSimulatorManager.h"
#import "SQLSimulatorModel.h"

@implementation SQLDatabaseDescription

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(item == nil)
    {
        return 1;
    }
    
    return self.tables.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return YES;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(item == nil)
    {
        return self;
    }
    
    return self.tables[index];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    
    NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"SQLDatabaseNameView" owner:self];
    
    SQLDatabaseDescription *database = (SQLDatabaseDescription *)item;
    
    SQLSimulatorModel *model = [[SQLSimulatorManager sharedManager] simulatorWithId:[[SQLSimulatorManager sharedManager]
                                                                                     deviceIdWithPath:database.path]];
    
    NSString *info = @"";
    
    if (model.deviceVersion && model.systemVersion)
    {
        info = [NSString stringWithFormat:@"%@-%@",model.deviceVersion,model.systemVersion];
    }
    else
    {
        info = database.path;
    }
    
    cell.textField.stringValue = [NSString stringWithFormat:@"%@ (%lu %@) (%@)",self.name,(unsigned long)[self.tables count],[self.tables count] > 1 ? @"tables" : @"table",info];
    
    return cell;
}

- (NSString *)databaseName
{
    return [_path lastPathComponent];
}

@end
