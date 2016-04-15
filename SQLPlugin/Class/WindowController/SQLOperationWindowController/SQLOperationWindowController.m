//
//  SQLOperationWindowController.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/15.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLOperationWindowController.h"
#import "SQLTableDetailView.h"
#import "SQLSimulatorModel.h"
#import "SQLCommandManager.h"
#import "SQLStoreSharedManager.h"
#import "SQLWindowsManager.h"
#import "FMDatabase.h"
#import "SQLCSVManager.h"
#import "SQLDatabaseManager.h"
#import "SQLSimulatorManager.h"

@interface SQLOperationWindowController ()
<
NSWindowDelegate,
NSTextFieldDelegate
>

@property (nonatomic, weak) IBOutlet NSButton *databaseButton;
@property (nonatomic, weak) IBOutlet NSButton *clearButton;
@property (nonatomic, weak) IBOutlet NSButton *historyCommandButton;
@property (nonatomic, weak) IBOutlet NSTextField *textFieldSQLCommand;
@property (nonatomic, weak) IBOutlet NSTextField *textFieldErrorLog;
@property (nonatomic, weak) IBOutlet SQLTableDetailView *tableDetailView;
@property (nonatomic, weak) IBOutlet NSView *seperatorView;
@property (nonatomic, weak) IBOutlet NSView *seperatorViewBottom;
@property (nonatomic, strong) SQLMainWindowController *sqlMainVC;
@property (nonatomic, weak) IBOutlet NSTextField *pathLabel;
@property (nonatomic,weak) IBOutlet NSButton *showInFinderButton;

@end

@implementation SQLOperationWindowController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self refreshPathLabel:@""];
    [self refreshTextFieldErrorLog:@""];
    [self refreshHistoryCommandButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sqlOperationError:) name:FMDATABASEERRORNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiAddNewDatabasePath:) name:@"NOTI_ADD_NEW_DATABASE_PATH" object:nil];

    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

#pragma mark - Path

- (void)refreshPathLabel:(NSString *)path
{
    self.pathLabel.stringValue = path;
    self.showInFinderButton.hidden = ([path length] == 0);
}

#pragma mark - Error

- (void)sqlOperationError:(NSNotification *)noti
{
    [self refreshTextFieldErrorLog:noti.object];
}

- (void)refreshTextFieldErrorLog:(NSString *)errString
{
    self.textFieldErrorLog.stringValue = errString;
    self.clearButton.enabled = ([errString length] != 0);
}

#pragma mark - NSWindowDelegate

-(BOOL)windowShouldClose:(nonnull id)sender
{
    [[SQLStoreSharedManager sharedManager] close];
    [[SQLWindowsManager sharedManager] removeWindow:sender];
    return YES;
}

- (void)notiAddNewDatabasePath:(NSNotification *)noti
{
    for (NSString *path in noti.object) {
        SQLDatabaseModel *model = [[SQLDatabaseModel alloc] initWithAppId:@"" path:path];
        [[SQLDatabaseManager sharedManager] addDatabaseItem:model];
        [self setCurrentDatabase:model];
    }
}

-(void)awakeFromNib
{
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:[NSColor lightGrayColor].CGColor];
    [self.seperatorView setWantsLayer:YES];
    [self.seperatorView setLayer:viewLayer];
    self.seperatorView.layer.backgroundColor = [NSColor grayColor].CGColor;
    
    CALayer *viewLayerBottom = [CALayer layer];
    [viewLayerBottom setBackgroundColor:[NSColor lightGrayColor].CGColor];
    [self.seperatorViewBottom setWantsLayer:YES]; 
    [self.seperatorViewBottom setLayer:viewLayerBottom];
    self.seperatorViewBottom.layer.backgroundColor = [NSColor grayColor].CGColor;
    
    self.window.title = @"SQL Query";
    self.window.delegate = self;
}

#pragma mark - Operation

- (void)selectedDatabaseItem:(NSMenuItem *)item
{
    NSArray *databases = [[SQLDatabaseManager sharedManager] recordDatabaseItems];
    SQLDatabaseModel *obj = [databases objectAtIndex:item.tag];
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
        if ([openFileControl.URLs count] > 0) {
            NSString *path = (NSString *)[(NSURL *)[openFileControl.URLs firstObject] path];
            
            if (![@[@"sqlite", @"sql", @"db"] containsObject:[path pathExtension]]) {
                return;
            }
            
            SQLDatabaseModel *model = [[SQLDatabaseModel alloc] initWithAppId:@"" path:path];
            [[SQLDatabaseManager sharedManager] addDatabaseItem:model];
            [self setCurrentDatabase:model];
        }
    }
}

- (void)setCurrentDatabase:(SQLDatabaseModel *)currentDatabase
{
    _currentDatabase = currentDatabase;
    if (![currentDatabase databaseName] || [[currentDatabase databaseName] length] == 0) {
        return;
    }
    
    SQLSimulatorModel *model = [[SQLSimulatorManager sharedManager] simulatorWithId:[[SQLSimulatorManager sharedManager] deviceIdWithPath:currentDatabase.path]];
    
    NSString *info = @"";
    
    if (model.deviceVersion && model.systemVersion) {
        info = [NSString stringWithFormat:@"%@-%@",model.deviceVersion,model.systemVersion];
    }
    else{
        info = currentDatabase.path;
    }
    
    [self.databaseButton setTitle:[currentDatabase databaseName]];
    [self refreshPathLabel:info];
    self.window.title = [currentDatabase databaseName];
}

- (void)refreshTableWithCommand:(NSString *)command
{
    [self refreshTextFieldErrorLog:@""];
    
    [[SQLCommandManager sharedManager] addCommandHistoryItem:command];
    
    [self refreshHistoryCommandButton];
    
    [[SQLStoreSharedManager sharedManager] getTableRowsWithCommand:command
                                                          inDBPath:self.currentDatabase.path
                                                        completion:^(SQLTableDescription *table) {
        [self.tableDetailView refreshTable:table];
    }];
}

#pragma mark - Command Operation

- (void)selectedCommandHistoryItem:(NSMenuItem *)item
{
    self.textFieldSQLCommand.stringValue = item.title;
    [self.textFieldSQLCommand becomeFirstResponder];
}

- (void)clearCommandHistoryItems:(NSMenuItem *)item
{
    [[SQLCommandManager sharedManager] clearCommandHistoryItems];
    [self refreshHistoryCommandButton];
}

- (void)refreshHistoryCommandButton
{
    NSArray *list = [[SQLCommandManager sharedManager] commandHistoryItems];
    [self.historyCommandButton setEnabled:(list && [list count] > 0)];
}

#pragma mark - Did Press Button

-(IBAction)didPressDatabaseButton:(NSButton *)sender
{
    NSArray *databases = [[SQLDatabaseManager sharedManager] recordDatabaseItems];
    
    if ([databases count] == 0) {
        return;
    }
    
    NSMenu *menu = [[NSMenu alloc] init];
    [databases enumerateObjectsUsingBlock:^(SQLDatabaseModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SQLSimulatorModel *model = [[SQLSimulatorManager sharedManager] simulatorWithId:[[SQLSimulatorManager sharedManager] deviceIdWithPath:obj.path]];
        
        NSString *info = @"";
        
        if (model.deviceVersion && model.systemVersion) {
            info = [NSString stringWithFormat:@"%@-%@",model.deviceVersion,model.systemVersion];
        }
        else{
            info = obj.path;
        }
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%@)",[obj databaseName],info] action:@selector(selectedDatabaseItem:) keyEquivalent:@""];
        item.tag = idx;
        [menu insertItem:item atIndex:idx];
    }];
    
    [menu insertItem:[NSMenuItem separatorItem] atIndex:[databases count]];
    [menu insertItemWithTitle:@"Add New Database" action:@selector(addDatabaseItem:) keyEquivalent:@"" atIndex:([databases count] + 1)];
    
    [menu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

-(IBAction)didPressPathButton:(NSButton *)sender
{
    NSString *path = self.currentDatabase.path;
    
    if ([path length] == 0) {
        return;
    }
    
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:@""];
}

-(IBAction)didPressHelpButton:(NSButton *)sender
{
    //TODO::
}

-(IBAction)didPressCloseButton:(NSButton *)sender
{
    if (!_sqlMainVC) {
        _sqlMainVC = (SQLMainWindowController *)[[SQLWindowsManager sharedManager] windowWithType:SQLWindowType_SQL_Viewer];
    }
    
    [_sqlMainVC.window center];
    [_sqlMainVC.window makeKeyAndOrderFront:nil];
}

-(IBAction)didPressRunButton:(NSButton *)sender
{
    [self refreshTableWithCommand:self.textFieldSQLCommand.stringValue];
}

-(IBAction)didPressHistoryButton:(NSButton *)sender
{
    NSArray *commands = [[SQLCommandManager sharedManager] commandHistoryItems];
    
    if ([commands count] == 0) {
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
    
    if ([path length] == 0) {
        return;
    }
    
    NSString *name = [[self.currentDatabase databaseName] stringByAppendingPathExtension:@"csv"];
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    [panel setAllowsOtherFileTypes:NO];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel setNameFieldStringValue:name];
    [panel setTitle:[NSString stringWithFormat:@"Saving %@",name]]; // Window title
    
    NSInteger result = [panel runModal];
    NSError *error = nil;
    
    if (result == NSModalResponseOK) {
        NSString *path0 = [[panel URL] path];
        
        __weak SQLOperationWindowController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong SQLOperationWindowController *strongSelf = weakSelf;
            
            [[SQLCSVManager sharedManager] exportTo:path0 withTable:[[strongSelf tableDetailView] table]];
        });
        
        if (error) {
            [NSApp presentError:error];
        }
    }
}

#pragma Control Delegate

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    NSLog(@"Selector method is (%@)", NSStringFromSelector( commandSelector ) );
    if (commandSelector == @selector(insertNewline:)) {
        [self refreshTableWithCommand:fieldEditor.string];
        return YES;
    }
    return NO;
}

@end
