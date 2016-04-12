//
//  SQLDatabaseListDescription.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/5.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLDatabaseListDescription.h"

@implementation SQLDatabaseListDescription

-(NSInteger)outlineView:(nonnull NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    if(!item){
        return [self.databases count];
    }
    else{
        return [item outlineView:outlineView numberOfChildrenOfItem:item];
    }
}

-(BOOL)outlineView:(nonnull NSOutlineView *)outlineView isItemExpandable:(nonnull id)item
{
    return [self.databases count];
}

-(id)outlineView:(nonnull NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    if(!item){
        return [self.databases objectAtIndex:index];
    }
    else{
        return [item outlineView:outlineView child:index ofItem:item];
    }
}

- (NSView *)outlineView:(nonnull NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(nonnull id)item
{
    return [item outlineView:outlineView viewForTableColumn:tableColumn item:item];
}

@end
