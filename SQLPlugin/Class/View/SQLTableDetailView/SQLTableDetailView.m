//
//  SQLTableDetailViewController.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLTableDetailView.h"
#import "SQLTableProperty.h"
#import "SQLStoreSharedManager.h"

@interface SQLTableDetailView ()
<
NSTableViewDataSource,
NSTableViewDelegate
>

@property (nonatomic, weak) IBOutlet NSTableView *detailView;
@property (nonatomic, strong) NSNumber *offset;

@end

@implementation SQLTableDetailView

-(void)clearColumns
{
    // Remove All Columns
    for(NSTableColumn *column in self.detailView.tableColumns.copy)
    {
        [self.detailView removeTableColumn:column];
    }
}

-(void)awakeFromNib
{
    self.table.rows = [[NSMutableArray alloc] init];
    [self clearColumns];
    self.leftButton.target = self;
    self.leftButton.action = NSSelectorFromString(@"didPressLeftButton:");
    self.rightButton.target = self;
    self.rightButton.action = NSSelectorFromString(@"didPressRightButton:");
}

-(IBAction)didPressLeftButton:(NSBundle *)sender
{
    self.offset = @(self.offset.intValue - 50);
    [self fetchRowForOffset];
}

-(IBAction)didPressRightButton:(NSBundle *)sender
{
    self.offset = @(self.offset.intValue + 50);
    [self fetchRowForOffset];
}

-(void)setTable:(SQLTableDescription *)table
{
    _table = table;
    _table.rows = @[];
    [self reloadUI];
    [self fetchRowForOffset];
}

- (void)refreshTable:(SQLTableDescription *)table
{
    _table = table;
    [self reloadUI];
}

-(void)reloadUI
{
    self.offset = @(0);
    self.leftButton.enabled = NO;
    self.rightButton.enabled = NO;
    
    [self clearColumns];
    
    for (SQLTableProperty *property in self.table.properties)
    {
        NSTableColumn* column = [[NSTableColumn alloc] init];
        
        NSString *identifier = @([self.table.properties indexOfObject:property]).stringValue; // Make a distinct one for each column
        NSString *header = property.name; // Or whatever you want to show the user
        
        [column.headerCell setStringValue:header];
        column.identifier = identifier;
        [self.detailView addTableColumn:column];
    }
    
    [self.detailView reloadData];
}

-(void)fetchRowForOffset
{
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.table.path isDirectory:NO];
    
    if(!fileExists)
    {
        //        [self showAlert:[NSString stringWithFormat:@"%@ Doesn't Exist",path]];
    }
    else
    {
        BOOL isOpened = [[SQLStoreSharedManager sharedManager] openDatabaseAtPath:self.table.path];
        
        if(!isOpened)
        {
            //            [self showAlert:[NSString stringWithFormat:@"%@ Couldn't Be Opened",path]];
        }
        else
        {
            [[SQLStoreSharedManager sharedManager] getRowsWithOffset:self.offset
                                                withTableDescription:self.table
                                                          completion:^(NSArray *rows) {
                                                              
                                                              self.table.rows = rows;
                                                              
                                                              if(self.table.rows.count + self.offset.intValue != [self.table.rowCount integerValue])
                                                              {
                                                                  self.rightButton.enabled = YES;
                                                              }
                                                              else
                                                              {
                                                                  self.rightButton.enabled = NO;
                                                              }
                                                              
                                                              if(self.offset.intValue == 0)
                                                              {
                                                                  self.leftButton.enabled = NO;
                                                              }
                                                              else
                                                              {
                                                                  self.leftButton.enabled = YES;
                                                              }
                                                              
                                                              [self.detailView reloadData];
                                                          }];
        }
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.table.rows count];
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20.0f;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSUInteger columnIndex = [tableColumn.identifier integerValue];
    NSUInteger rowIndex = row;
    
    NSArray *rowValues = self.table.rows[rowIndex];
    
    return [NSString stringWithFormat:@"%@",rowValues[columnIndex]];
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    if (!_table.name)
    {
        return;
    }
    
    NSUInteger columnIndex = [tableColumn.identifier integerValue];
    SQLTableProperty *property = [self.table.properties objectAtIndex:columnIndex];
    
    if ([self.table.selectedPropertName isEqualToString:property.name])
    {
        self.table.desc = !self.table.desc;
    }
    else
    {
        self.table.selectedPropertName = property.name;
    }
    
    [self fetchRowForOffset];
}

@end
