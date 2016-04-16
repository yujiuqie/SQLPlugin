//
//  SQLMainWindowController.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLMainWindowController.h"
#import "SQLTableListView.h"
#import "SQLTableDetailView.h"
#import "SQLStoreSharedManager.h"
#import "SQLTableListProtocol.h"
#import "SQLDatabaseDescription.h"
#import "SQLWindowsManager.h"
#import "SQLDatabaseManager.h"
#import "SQLSimulatorManager.h"
#import "SQLCSVManager.h"
#import "SQLDatabaseListView.h"
#import "SQLSimulatorModel.h"

@interface SQLMainWindowController ()
<
SQLTableListDelegate,
NSWindowDelegate,
NSTextFieldDelegate
>
{
    NSOperationQueue *queue;
}

@property (nonatomic, weak) IBOutlet SQLTableListView *tableListView;
@property (nonatomic, weak) IBOutlet SQLTableDetailView *tableDetailView;
@property (nonatomic, weak) IBOutlet SQLDatabaseListView *databaseList;
@property (nonatomic, weak) IBOutlet NSButton *simulatorButton;
@property (nonatomic, weak) IBOutlet NSButton *leftButton;
@property (nonatomic, weak) IBOutlet NSButton *rightButton;
@property (nonatomic, weak) IBOutlet NSButton *csvButton;
@property (nonatomic, weak) IBOutlet NSView *seperatorView;
@property (nonatomic, strong) SQLDatabaseListDescription *sqliteList;
@property (nonatomic, strong) SQLOperationWindowController *operationVC;

@end

@implementation SQLMainWindowController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSViewController Lifecycle

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setupDatabaseList];
    
    self.tableListView.delegate = self;
    self.tableDetailView.leftButton = self.leftButton;
    self.tableDetailView.rightButton = self.rightButton;
    
    self.rightButton.enabled = NO;
    self.leftButton.enabled = NO;
    self.csvButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiAddNewDatabasePath:) name:@"NOTI_ADD_NEW_DATABASE_PATH" object:nil];
    
    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

-(void)awakeFromNib
{
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:[NSColor lightGrayColor].CGColor]; //RGB plus Alpha Channel
    [self.seperatorView setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
    [self.seperatorView setLayer:viewLayer];
    self.seperatorView.layer.backgroundColor = [NSColor grayColor].CGColor;
    
    self.window.title = @"SQL Viewer";
    self.window.delegate = self;
}

#pragma mark - NSWindowDelegate

-(BOOL)windowShouldClose:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearInfos];
    [[SQLWindowsManager sharedManager] removeWindow:sender];
    return YES;
}

#pragma mark - Actions

- (void)notiAddNewDatabasePath:(NSNotification *)noti
{
    for (NSString *path in noti.object) {
        [self addFetchOperation:path];
    }
}

#pragma mark - Did Press Button

-(IBAction)didPressSQLButton:(NSButton *)sender
{
    if (!_operationVC) {
        _operationVC = (SQLOperationWindowController *)[[SQLWindowsManager sharedManager] windowWithType:SQLWindowType_SQL_Operation];
    }
    
    id cell = [_databaseList itemAtRow:_databaseList.selectedRow];
    
    NSString *path = @"";
    
    if ([cell isKindOfClass:[SQLDatabaseDescription class]]) {
        path = ((SQLDatabaseDescription *)cell).path;
    }
    else if([cell isKindOfClass:[SQLTableDescription class]]){
        path = ((SQLTableDescription *)cell).path;
    }
    
    [_operationVC.window center];
    [_operationVC.window makeKeyAndOrderFront:nil];
    _operationVC.currentDatabase = [[SQLDatabaseManager sharedManager] databaseDescriptionInPath:path];
}

-(IBAction)didPressCSVButton:(NSButton *)sender
{
    [self exportTable:nil];
}

-(IBAction)didPressSimulatorButton:(NSButton *)sender
{
    self.csvButton.enabled = NO;
    self.tableDetailView.table = nil;
    self.tableListView.databases = nil;
    [self refreshSimulator];
}

-(IBAction)didPressOpenButton:(NSButton *)sender
{
    self.csvButton.enabled = NO;
    
    NSOpenPanel* openFileControl = [NSOpenPanel openPanel];
    
    NSArray *fileTypes = @[@"sqlite", @"sql", @"db"];
    
    openFileControl.canChooseFiles = YES;
    openFileControl.allowedFileTypes = fileTypes;
    openFileControl.allowsMultipleSelection = NO;
    
    if ([openFileControl runModal] == NSModalResponseOK )
    {
        if ([openFileControl.URLs count] > 0) {
            NSString *path = (NSString *)[(NSURL *)[openFileControl.URLs firstObject] path];
            
            [self addFetchOperation:path];
        }
    }
}

-(void)fetchDatabaseInPath:(NSString*)path
{
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO];
    if(!fileExists)
    {
        //        [self showAlert:[NSString stringWithFormat:@"%@ Doesn't Exist",path]];
    }
    else
    {
        BOOL isOpened = [[SQLStoreSharedManager sharedManager] openDatabaseAtPath:path];
        if(!isOpened)
        {
            //            [self showAlert:[NSString stringWithFormat:@"%@ Couldn't Be Opened",path]];
        }
        else{
            [[SQLStoreSharedManager sharedManager] getAllTablesinPath:path completion:^(NSArray *tables) {
                SQLDatabaseDescription *database = [[SQLDatabaseDescription alloc] init];
                database.name = path.lastPathComponent;
                database.path = path;
                database.tables = tables;
                
                if (!_sqliteList) {
                    _sqliteList = [[SQLDatabaseListDescription alloc] init];
                }
                
                [_sqliteList addDatabase:database];
                
                self.tableListView.databases = _sqliteList;
            }];
        }
    }
}

#pragma mark - SQLTableListDelegate

-(void)didSelectTable:(SQLTableDescription *)table
{
    self.tableDetailView.table = table;
    self.csvButton.enabled = ([table.rowCount integerValue] > 0);
}

-(void)didSelectDatabase:(SQLDatabaseDescription *)database
{
    self.tableDetailView.table = nil;
    self.csvButton.enabled = NO;
}

#pragma mark - Action

- (void)setupDatabaseList
{
    NSArray *databasesList = [[SQLDatabaseManager sharedManager] databaseDescriptions];
    if (!databasesList || [databasesList count] == 0) {
        [self refreshSimulator];
    }
    else{
        [databasesList enumerateObjectsUsingBlock:^(SQLDatabaseDescription * obj, NSUInteger idx, BOOL * stop) {
            [self addFetchOperation:obj.path];
        }];
    }
}

- (void)refreshSimulator
{
    [self clearInfos];
    
    NSArray *apps = [[SQLSimulatorManager sharedManager] fetchAppsWithSelectedSimulators:[[SQLSimulatorManager sharedManager] allSimulators]];
    
    for (SQLApplicationModel *app in apps) {
        
        for (SQLDatabaseDescription *dbModel in app.databases) {
            [self addFetchOperation:dbModel.path];
        }
    }
}

- (void)addFetchOperation:(NSString *)aPath
{
    if (![@[@"sqlite", @"sql", @"db"] containsObject:[aPath pathExtension]]) {
        return;
    }
    
    if(queue == nil){
        queue = [[NSOperationQueue  alloc]init];
        queue.maxConcurrentOperationCount = 1;
    }
    
    [queue addOperationWithBlock:^{
        __weak typeof(self)weakSelf = self;
        [weakSelf fetchDatabaseInPath:aPath];
    }];
}

- (void)clearInfos
{
    if (_sqliteList) {
        _sqliteList = nil;
        [[SQLStoreSharedManager sharedManager] close];
    }
    
    [[SQLDatabaseManager sharedManager] clearDatabaseDescriptions];
}

- (NSString *)removeSelectedItemReference
{
    id cell = [_databaseList itemAtRow:_databaseList.selectedRow];
    
    NSString *path = @"";
    
    if ([cell isKindOfClass:[SQLDatabaseDescription class]]) {
        path = ((SQLDatabaseDescription *)cell).path;
    }
    else if([cell isKindOfClass:[SQLTableDescription class]]){
        path = ((SQLTableDescription *)cell).path;
    }
    
    if ([path length] == 0) {
        return path;
    }
    
    SQLDatabaseDescription *database = [[SQLDatabaseManager sharedManager] databaseDescriptionInPath:path];
    [[SQLDatabaseManager sharedManager] removeDatabaseDescription:database];
    [self.tableListView removeSelectedItem];
    
    return path;
}

#pragma mark - Menu Operation

- (IBAction)executeSQL:(NSMenuItem *)sender {
    [self didPressSQLButton:nil];
}

- (IBAction)refreshDatabase:(NSMenuItem *)sender
{
    id cell = [_databaseList itemAtRow:_databaseList.selectedRow];
    
    NSString *path = @"";
    
    if ([cell isKindOfClass:[SQLDatabaseDescription class]]) {
        path = ((SQLDatabaseDescription *)cell).path;
    }
    else if([cell isKindOfClass:[SQLTableDescription class]]){
        path = ((SQLTableDescription *)cell).path;
    }
    
    if ([path length] == 0) {
        return;
    }
    
    SQLDatabaseDescription *database = [[SQLDatabaseManager sharedManager] databaseDescriptionInPath:path];
    
    [self addFetchOperation:database.path];
}

- (IBAction)revealInFinder:(NSMenuItem *)sender
{
    id cell = [_databaseList itemAtRow:_databaseList.selectedRow];
    
    NSString *path = @"";
    
    if ([cell isKindOfClass:[SQLDatabaseDescription class]]) {
        path = ((SQLDatabaseDescription *)cell).path;
    }
    else if([cell isKindOfClass:[SQLTableDescription class]]){
        path = ((SQLTableDescription *)cell).path;
    }
    
    if ([path length] == 0) {
        return;
    }
    
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:@""];
}

- (IBAction)exportDatabase:(NSMenuItem *)sender
{
    id cell = [_databaseList itemAtRow:_databaseList.selectedRow];
    
    NSString *path = @"";
    
    if ([cell isKindOfClass:[SQLDatabaseDescription class]]) {
        path = ((SQLDatabaseDescription *)cell).path;
    }
    else if([cell isKindOfClass:[SQLTableDescription class]]){
        path = ((SQLTableDescription *)cell).path;
    }
    
    if ([path length] == 0) {
        return;
    }
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    [panel setAllowsOtherFileTypes:NO];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel setNameFieldStringValue:[path lastPathComponent]];
    [panel setTitle:[NSString stringWithFormat:@"Saving %@",[path lastPathComponent]]]; // Window title
    
    NSInteger result = [panel runModal];
    NSError *error = nil;
    
    if (result == NSModalResponseOK) {
        NSString *path0 = [[panel URL] path];
        
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:path0 error:&error];
        
        if (error) {
            [NSApp presentError:error];
        }
    }
}

- (IBAction)exportTable:(NSMenuItem *)sender {
    
    id cell = [_databaseList itemAtRow:_databaseList.selectedRow];
    
    NSString *path = @"";
    
    if([cell isKindOfClass:[SQLTableDescription class]]){
        path = ((SQLTableDescription *)cell).path;
    }
    
    if ([path length] == 0) {
        return;
    }
    
    NSString *name = [self.tableDetailView.table.name stringByAppendingPathExtension:@"csv"];
    
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
        
        __weak SQLMainWindowController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong SQLMainWindowController *strongSelf = weakSelf;
            
            [[SQLStoreSharedManager sharedManager] getTableRowsWithCommand:[NSString stringWithFormat:@"select * from %@",strongSelf.tableDetailView.table.name] inDBPath:path completion:^(SQLTableDescription *table) {
                [[SQLCSVManager sharedManager] exportTo:path0 withTable:table];
            }];
        });
        
        if (error) {
            [NSApp presentError:error];
        }
    }
}

- (IBAction)removeReference:(NSMenuItem *)sender
{
    [self removeSelectedItemReference];
}


- (IBAction)moveToTrash:(NSMenuItem *)sender
{
    NSString *path = [self removeSelectedItemReference];
    
    if ([path length] == 0) {
        return;
    }
    
    NSError *error = nil;
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error) {
        [NSApp presentError:error];
    }
}

@end
