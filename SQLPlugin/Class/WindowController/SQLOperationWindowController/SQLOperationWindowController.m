//
//  SQLOperationWindowController.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/15.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLOperationWindowController.h"

#import "FMDB.h"
#import "SQLCommandManager.h"
#import "SQLCSVManager.h"
#import "SQLDatabaseListDescription.h"
#import "SQLDatabaseManager.h"
#import "SQLSimulatorManager.h"
#import "SQLSimulatorModel.h"
#import "SQLStoreSharedManager.h"
#import "SQLTableDetailView.h"
#import "SQLWindowsManager.h"

@interface SQLOperationWindowController ()
<
NSWindowDelegate,
NSTextFieldDelegate
>

@property (nonatomic, strong) NSMutableArray *databases;
@property (nonatomic, strong) NSMutableArray *tables;
@property (nonatomic, strong) SQLMainWindowController *sqlMainVC;
@property (nonatomic, weak) IBOutlet NSButton *clearButton;
@property (nonatomic, weak) IBOutlet NSButton *exportButton;
@property (nonatomic, weak) IBOutlet NSButton *historyCommandButton;
@property (nonatomic, weak) IBOutlet NSButton *runButton;
@property (nonatomic, weak) IBOutlet NSButton *showInFinderButton;
@property (nonatomic, weak) IBOutlet NSButton *tableButton;
@property (nonatomic, weak) IBOutlet NSTextField *textFieldErrorLog;
@property (nonatomic, weak) IBOutlet NSTextField *textFieldSQLCommand;
@property (nonatomic, weak) IBOutlet NSView *seperatorView;
@property (nonatomic, weak) IBOutlet NSView *seperatorViewBottom;
@property (nonatomic, weak) IBOutlet SQLTableDetailView *tableDetailView;

@end

@implementation SQLOperationWindowController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self refreshTextFieldErrorLog:@""];
    self.exportButton.enabled = NO;
    self.tableButton.enabled = NO;
    self.showInFinderButton.enabled = NO;
    [self refreshRunButton];
    [self refreshHistoryCommandButton];
    
    NSArray *databases = [[SQLDatabaseManager sharedManager] databaseDescriptions];
    
    if ([databases count] == 0)
    {
        [self refreshSimulator];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sqlOperationError:) name:FMDATABASEERRORNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiAddNewDatabasePath:) name:@"NOTI_ADD_NEW_DATABASE_PATH" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidChangeNotification object:self.textFieldSQLCommand];
    
    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

-(BOOL)windowShouldClose:(nonnull id)sender
{
    [[SQLStoreSharedManager sharedManager] close];
    [[SQLWindowsManager sharedManager] removeWindow:sender];
    return YES;
}

-(void)awakeFromNib
{
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:[NSColor grayColor].CGColor];
    [self.seperatorView setWantsLayer:YES];
    [self.seperatorView setLayer:viewLayer];
    
    CALayer *viewLayerBottom = [CALayer layer];
    [viewLayerBottom setBackgroundColor:[NSColor grayColor].CGColor];
    [self.seperatorViewBottom setWantsLayer:YES];
    [self.seperatorViewBottom setLayer:viewLayerBottom];
    
    self.window.title = @"SQL Query ( Choose A Database First )";
    self.window.delegate = self;
}

#pragma mark - Fetch Info

- (NSString *)pathInfoWith:(SQLDatabaseDescription *)database
{
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
    
    return [NSString stringWithFormat:@"%@ (%lu %@) (%@)",[database databaseName],(unsigned long)[database.tables count],[database.tables count] > 0 ? @"tables" : @"table",info];
}

-(void)fetchDatabaseInPath:(NSString*)path completion:(void (^)(SQLDatabaseDescription *))completion
{
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO];
    
    if(!fileExists)
    {
        //
    }
    else
    {
        BOOL isOpened = [[SQLStoreSharedManager sharedManager] openDatabaseAtPath:path];
        
        if(!isOpened)
        {
            //
        }
        else
        {
            [[SQLStoreSharedManager sharedManager] getAllTablesinPath:path
                                                           completion:^(NSArray *tables)
             {
                 SQLDatabaseDescription *database = [[SQLDatabaseDescription alloc] init];
                 database.name = path.lastPathComponent;
                 database.path = path;
                 database.tables = tables;
                 
                 completion(database);
             }];
        }
    }
}

#pragma mark - Refresh Action

- (void)refreshHistoryCommandButton
{
    NSArray *list = [[SQLCommandManager sharedManager] commandHistoryItems];
    [self.historyCommandButton setEnabled:((list && [list count] > 0) && self.currentDatabase)];
}

- (void)refreshPathLabel:(SQLDatabaseDescription *)database
{
    self.window.title = [self pathInfoWith:database];
    self.showInFinderButton.enabled = ([database.path length] != 0);
}

- (void)refreshRunButton
{
    [self.runButton setEnabled:(([self.textFieldSQLCommand.stringValue length] > 0) && self.currentDatabase)];
}

- (void)refreshTextFieldSQLCommand:(NSString *)command
{
    self.textFieldSQLCommand.stringValue = command;
    [self refreshRunButton];
    [self.textFieldSQLCommand becomeFirstResponder];
}

- (void)refreshSimulator
{
    [[SQLDatabaseManager sharedManager] clearDatabaseDescriptions];
    
    NSArray *apps = [[SQLSimulatorManager sharedManager] fetchAppsWithSelectedSimulators:[[SQLSimulatorManager sharedManager] allSimulators]];
    
    [apps enumerateObjectsUsingBlock:^(SQLApplicationModel *app, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [app.databases enumerateObjectsUsingBlock:^(SQLDatabaseDescription *dbModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [self fetchDatabaseInPath:dbModel.path
                           completion:^(SQLDatabaseDescription *database)
             {
                 [[SQLDatabaseManager sharedManager] addDatabaseDescription:database];
                 [self setCurrentDatabase:database];
             }];
        }];
    }];
}

- (void)refreshTextFieldErrorLog:(NSString *)errString
{
    self.textFieldErrorLog.stringValue = errString;
    self.textFieldErrorLog.textColor = [NSColor redColor];
    self.clearButton.enabled = ([errString length] != 0);
}

- (void)refreshTextFieldInfo:(NSString *)resultString
{
    self.textFieldErrorLog.stringValue = resultString;
    self.textFieldErrorLog.textColor = [NSColor grayColor];
    self.clearButton.enabled = ([resultString length] != 0);
}

- (void)refreshTableWithCommand:(NSString *)command
{
    [self refreshTextFieldErrorLog:@""];
    
    [[SQLCommandManager sharedManager] addCommandHistoryItem:command];
    
    [self refreshHistoryCommandButton];
    
    [[SQLStoreSharedManager sharedManager] executeSQLCommand:command
                                                    inDBPath:self.currentDatabase.path
                                                  completion:^(SQLTableDescription *table, NSError *error)
     {
         [self.tableDetailView refreshTable:table];
         
         self.exportButton.enabled = ([table.rowCount integerValue] > 0);
         
         if([self.textFieldErrorLog.stringValue length] == 0)
         {
             [self setCurrentDatabase:self.currentDatabase];
         }
         
         if (error.code == 0) {
             if ([self.textFieldSQLCommand.stringValue hasPrefix:@"select"])
             {
                 [self refreshTextFieldInfo:[NSString stringWithFormat:@"Result Items : %@",table.rowCount]];
             }
             else
             {
                 [self refreshTextFieldInfo:@"Execute Finished"];
             }
         }
         else
         {
             [self refreshTextFieldErrorLog:error.userInfo[NSLocalizedDescriptionKey]];
         }
     }];
}

#pragma mark - Operation

- (void)setCurrentDatabase:(SQLDatabaseDescription *)currentDatabase
{
    _currentDatabase = currentDatabase;
    
    if (![currentDatabase databaseName] || [[currentDatabase databaseName] length] == 0)
    {
        return;
    }
    
    if (![@[@"sqlite", @"sql", @"db"] containsObject:[currentDatabase.path pathExtension]])
    {
        return;
    }
    
    [[SQLStoreSharedManager sharedManager] openDatabaseAtPath:currentDatabase.path];
    
    [self refreshPathLabel:currentDatabase];
    [self refreshHistoryCommandButton];
    [self refreshRunButton];
    
    [[SQLStoreSharedManager sharedManager] getAllTablesinPath:currentDatabase.path
                                                   completion:^(NSArray * tables)
     {
         _tables = [NSMutableArray arrayWithArray:tables];
         
         NSInteger count = [_tables count];
         
         _tableButton.enabled = count > 0;
         
         if (count == 0)
         {
             return ;
         }
         
         _tableButton.title = [NSString stringWithFormat:@"%@ ( %ld )",[tables count] > 1 ? @"Tables" : @"Table",count];
     }];
}

- (void)sqlOperationError:(NSNotification *)noti
{
    [self refreshTextFieldErrorLog:noti.object];
}

#pragma mark - Notification Action

- (void)notiAddNewDatabasePath:(NSNotification *)noti
{
    NSArray *paths = noti.object;
    
    [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self fetchDatabaseInPath:path
                       completion:^(SQLDatabaseDescription *database)
         {
             [[SQLDatabaseManager sharedManager] addDatabaseDescription:database];
             [self setCurrentDatabase:database];
         }];
    }];
}

#pragma mark - MenuItem Operation

- (void)selectTableItem:(NSMenuItem *)item
{
    SQLTableDescription *table = [_tables objectAtIndex:item.tag];
    [self refreshTextFieldSQLCommand:[NSString stringWithFormat:@"PRAGMA table_info(%@);",table.name]];
}

- (void)selectRefreshDatabaseItem:(NSMenuItem *)item
{
    [self refreshSimulator];
}

- (void)selectedDatabaseItem:(NSMenuItem *)item
{
    NSArray *databases = [[SQLDatabaseManager sharedManager] databaseDescriptions];
    SQLDatabaseDescription *obj = [databases objectAtIndex:item.tag];
    [self setCurrentDatabase:obj];
}

- (void)addDatabaseItem:(NSMenuItem *)item
{
    NSOpenPanel* openFileControl = [NSOpenPanel openPanel];
    
    NSArray *fileTypes = @[@"sqlite", @"sql", @"db"];
    
    openFileControl.canChooseFiles = YES;
    openFileControl.allowedFileTypes = fileTypes;
    openFileControl.allowsMultipleSelection = NO;
    
    if ([openFileControl runModal] == NSModalResponseOK )
    {
        if ([openFileControl.URLs count] > 0)
        {
            NSString *path = (NSString *)[(NSURL *)[openFileControl.URLs firstObject] path];
            
            if (![@[@"sqlite", @"sql", @"db"] containsObject:[path pathExtension]])
            {
                return;
            }
            
            [self fetchDatabaseInPath:path
                           completion:^(SQLDatabaseDescription *database)
             {
                 [[SQLDatabaseManager sharedManager] addDatabaseDescription:database];
                 [self setCurrentDatabase:database];
             }];
        }
    }
}

#pragma mark - Command Operation

- (void)selectedCommandHistoryItem:(NSMenuItem *)item
{
    [self refreshTextFieldSQLCommand:item.title];
}

- (void)clearCommandHistoryItems:(NSMenuItem *)item
{
    [[SQLCommandManager sharedManager] clearCommandHistoryItems];
    [self refreshHistoryCommandButton];
}

#pragma mark - Did Press Button

-(IBAction)didPressDatabaseButton:(NSButton *)sender
{
    NSArray *databases = [[SQLDatabaseManager sharedManager] databaseDescriptions];
    
    if ([databases count] == 0)
    {
        [self refreshSimulator];
        databases = [[SQLDatabaseManager sharedManager] databaseDescriptions];
    }
    
    NSMenu *menu = [[NSMenu alloc] init];
    [databases enumerateObjectsUsingBlock:^(SQLDatabaseDescription *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[self pathInfoWith:obj] action:@selector(selectedDatabaseItem:) keyEquivalent:@""];
        item.tag = idx;
        [menu insertItem:item atIndex:idx];
    }];
    
    [menu insertItem:[NSMenuItem separatorItem] atIndex:[[menu itemArray] count]];
    [menu insertItemWithTitle:@"Refresh Database" action:@selector(selectRefreshDatabaseItem:) keyEquivalent:@"" atIndex:[[menu itemArray] count]];
    
    [menu insertItem:[NSMenuItem separatorItem] atIndex:[[menu itemArray] count]];
    [menu insertItemWithTitle:@"Add New Database" action:@selector(addDatabaseItem:) keyEquivalent:@"" atIndex:[[menu itemArray] count]];
    
    [menu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

-(IBAction)didPressShowInFinderButton:(NSButton *)sender
{
    NSString *path = self.currentDatabase.path;
    
    if ([path length] == 0)
    {
        return;
    }
    
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:@""];
}

-(IBAction)didPressHelpButton:(NSButton *)sender
{
    NSURL *url = [NSURL URLWithString:@"https://github.com/viktyz/SQLPlugin"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

-(IBAction)didPressViewerButton:(NSButton *)sender
{
    if (!_sqlMainVC)
    {
        _sqlMainVC = (SQLMainWindowController *)[[SQLWindowsManager sharedManager] windowWithType:SQLWindowType_SQL_Viewer];
    }
    
    [_sqlMainVC.window center];
    [_sqlMainVC.window makeKeyAndOrderFront:nil];
}

-(IBAction)didPressRunButton:(NSButton *)sender
{
    [self refreshTableWithCommand:self.textFieldSQLCommand.stringValue];
}

-(IBAction)didPressTableButton:(NSButton *)sender
{
    if ([_tables count] == 0)
    {
        return;
    }
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    [_tables enumerateObjectsUsingBlock:^(SQLTableDescription *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%@ %@)",obj.name,obj.rowCount,([obj.rowCount integerValue] > 1) ? @"rows" : @"row"] action:@selector(selectTableItem:) keyEquivalent:@""];
        item.tag = idx;
        [menu insertItem:item atIndex:idx];
    }];
    
    [menu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

-(IBAction)didPressHistoryButton:(NSButton *)sender
{
    NSArray *commands = [[SQLCommandManager sharedManager] commandHistoryItems];
    
    if ([commands count] == 0)
    {
        return;
    }
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    [commands enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:obj action:@selector(selectedCommandHistoryItem:) keyEquivalent:@""];
        [menu insertItem:item atIndex:idx];
    }];
    
    [menu insertItem:[NSMenuItem separatorItem] atIndex:[commands count]];
    [menu insertItemWithTitle:@"Clear All" action:@selector(clearCommandHistoryItems:) keyEquivalent:@"" atIndex:([commands count] + 1)];
    
    [menu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

-(IBAction)didPressClearButton:(NSButton *)sender
{
    [self refreshTextFieldErrorLog:@""];
}

-(IBAction)didPressExportButton:(NSButton *)sender
{
    NSString *path = [self.currentDatabase path];
    
    if ([path length] == 0)
    {
        return;
    }
    
    NSString *name = [[[self.currentDatabase databaseName] stringByDeletingPathExtension] stringByAppendingPathExtension:@"csv"];
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    [panel setAllowsOtherFileTypes:NO];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel setNameFieldStringValue:name];
    [panel setTitle:[NSString stringWithFormat:@"Saving %@",name]]; // Window title
    
    NSInteger result = [panel runModal];
    NSError *error = nil;
    
    if (result == NSModalResponseOK)
    {
        NSString *path0 = [[panel URL] path];
        
        __weak SQLOperationWindowController *weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            __strong SQLOperationWindowController *strongSelf = weakSelf;
            
            [[SQLCSVManager sharedManager] exportTo:path0
                                          withTable:[[strongSelf tableDetailView] table]];
        });
        
        if (error)
        {
            [NSApp presentError:error];
        }
    }
}

#pragma mark - Control

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    [self refreshRunButton];
    
    if (commandSelector == @selector(insertNewline:) && [fieldEditor.string hasSuffix:@";"] && self.currentDatabase)
    {
        [self refreshTableWithCommand:fieldEditor.string];
        return YES;
    }
    return NO;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    [self refreshRunButton];
}

@end
