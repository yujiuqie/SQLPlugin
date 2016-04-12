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

-(NSInteger)outlineView:(nonnull NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    if(item == nil)
    {
        return 1;
    }
    return self.tables.count;
}

-(BOOL)outlineView:(nonnull NSOutlineView *)outlineView isItemExpandable:(nonnull id)item
{
    return YES;
}

-(id)outlineView:(nonnull NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    if(item == nil)
    {
        return self;
    }
    return self.tables[index];
}

- (NSView *)outlineView:(nonnull NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(nonnull id)item {
    
    NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"SQLDatabaseNameView" owner:self];
    
    SQLDatabaseDescription *database = (SQLDatabaseDescription *)item;
    
    SQLSimulatorModel *model = [[SQLSimulatorManager sharedManager] simulatorWithId:[[SQLSimulatorManager sharedManager] deviceIdWithPath:database.path]];
    
    NSString *info = @"";
    
    if (model.deviceVersion && model.systemVersion) {
        info = [NSString stringWithFormat:@"%@-%@",model.deviceVersion,model.systemVersion];
    }
    else{
        info = database.path;
    }
    
    cell.textField.stringValue = [NSString stringWithFormat:@"%@ (%lu tables) (%@)",self.name,(unsigned long)[self.tables count],info];
    
    return cell;
}

@end
