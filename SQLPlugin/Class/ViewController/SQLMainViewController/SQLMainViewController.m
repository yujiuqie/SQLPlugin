//
//  SQLMainViewController.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLMainViewController.h"
#import "SQLTableListView.h"
#import "SQLTableDetailView.h"
#import "SQLStoreSharedManager.h"
#import "SQLTableListProtocol.h"
#import "SQLDatabaseDescription.h"
#import "SQLWindowsManager.h"
#import "SQLDatabaseManager.h"
#import "SQLSimulatorManager.h"
#import "SQLDatabaseListView.h"
#import "SQLSimulatorModel.h"

@interface SQLMainViewController ()
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
@property (nonatomic, weak) IBOutlet NSView *seperatorView;

@property (nonatomic, strong) SQLDatabaseListDescription *sqliteList;

@end

@implementation SQLMainViewController

#pragma mark - NSViewController Lifecycle
- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setupDatabaseList];
    
    self.tableListView.delegate = self;
    self.tableDetailView.leftButton = self.leftButton;
    self.tableDetailView.rightButton = self.rightButton;
    
    self.rightButton.enabled = NO;
    self.leftButton.enabled = NO;
    
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
    
    self.window.title = @"SQL Plugin";
    self.window.delegate = self;
}

#pragma mark - NSWindowDelegate

-(BOOL)windowShouldClose:(nonnull id)sender
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

-(IBAction)didPressSimulatorButton:(NSButton *)sender
{
    self.tableDetailView.table = nil;
    self.tableListView.databases = nil;
    [self refreshSimulator];
}

-(IBAction)didPressOpenButton:(NSButton *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSOpenPanel* openFileControl = [NSOpenPanel openPanel];
        
        NSArray *fileTypes = @[@"sqlite", @"sql", @"db"];
        
        openFileControl.canChooseFiles = YES;
        openFileControl.allowedFileTypes = fileTypes;
        openFileControl.allowsMultipleSelection = NO;
        
        if ([openFileControl runModal] == NSModalResponseOK )
        {
            [self addFetchOperation:openFileControl.URLs.firstObject.path];
        }
    });
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
            [[SQLStoreSharedManager sharedManager] getAllTablesinPath:path completion:^(NSArray<SQLTableDescription *> *tables) {
                SQLDatabaseDescription *database = [[SQLDatabaseDescription alloc] init];
                database.name = path.lastPathComponent;
                database.path = path;
                database.tables = tables;
                
                if (!_sqliteList) {
                    _sqliteList = [[SQLDatabaseListDescription alloc] init];
                    _sqliteList.databases = [NSMutableArray array];
                }
                
                [_sqliteList.databases enumerateObjectsUsingBlock:^(SQLDatabaseDescription * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //
                    if ([obj.path isEqualToString:path]) {
                        [_sqliteList.databases removeObjectAtIndex:idx];
                        *stop = YES;
                    }
                }];
                
                [_sqliteList.databases insertObject:database atIndex:0];
                
                self.tableListView.databases = _sqliteList;
            }];
        }
    }
}

#pragma mark - SQLTableListDelegate

-(void)didSelectTable:(SQLTableDescription*)table
{
    self.tableDetailView.table = table;
}

-(void)didSelectDatabase:(SQLDatabaseDescription*)database
{
    self.tableDetailView.table = nil;
}

#pragma mark - Action

- (void)setupDatabaseList
{
    NSArray *databasesList = [[SQLDatabaseManager sharedManager] recordDatabaseItems];
    if (!databasesList || [databasesList count] == 0) {
        [self refreshSimulator];
    }
    else{
        [databasesList enumerateObjectsUsingBlock:^(SQLDatabaseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addFetchOperation:obj.path];
        }];
    }
}

- (void)refreshSimulator
{
    [self clearInfos];
    
    NSArray *apps = [[SQLSimulatorManager sharedManager] fetchAppsWithSelectedSimulators:[[SQLSimulatorManager sharedManager] allSimulators]];
    
    for (SQLApplicationModel *app in apps) {
        
        [[SQLDatabaseManager sharedManager] addDatabaseItems:app.databases];
        
        for (SQLDatabaseModel *dbModel in app.databases) {
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
    
    [[SQLDatabaseManager sharedManager] clearDatabaseItems];
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
    
    SQLDatabaseModel *database = [[SQLDatabaseManager sharedManager] databaseInPath:path];
    [[SQLDatabaseManager sharedManager] removeDatabaseItem:database];
    [self.tableListView removeSelectedItem];
    
    return path;
}

#pragma mark - Menu Operation

- (IBAction)add:(id)sender {
    [self didPressOpenButton:nil];
}

- (IBAction)refreshDatabase:(id)sender
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
    
    SQLDatabaseModel *database = [[SQLDatabaseManager sharedManager] databaseInPath:path];
    
    [self addFetchOperation:database.path];
}

- (IBAction)revealInFinder:(id)sender
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

- (IBAction)moveToTrash:(id)sender
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

- (IBAction)removeReference:(id)sender
{
    [self removeSelectedItemReference];
}

- (IBAction)export:(id)sender
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

@end
