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
@property (weak) IBOutlet NSView *seperatorView;
@property (weak) IBOutlet NSView *seperatorViewBottom;

@end

@implementation SQLOperationWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self refreshHistoryCommandButton];
}

-(void)awakeFromNib
{
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:[NSColor lightGrayColor].CGColor]; //RGB plus Alpha Channel
    [self.seperatorView setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
    [self.seperatorView setLayer:viewLayer];
    self.seperatorView.layer.backgroundColor = [NSColor grayColor].CGColor;
    
    CALayer *viewLayerBottom = [CALayer layer];
    [viewLayerBottom setBackgroundColor:[NSColor lightGrayColor].CGColor]; //RGB plus Alpha Channel
    [self.seperatorViewBottom setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
    [self.seperatorViewBottom setLayer:viewLayerBottom];
    self.seperatorViewBottom.layer.backgroundColor = [NSColor grayColor].CGColor;
    
    self.window.title = @"SQL Query";
    self.window.delegate = self;
}

#pragma mark - Operation

- (void)setCurrentDatabase:(SQLDatabaseModel *)currentDatabase
{
    self.window.title = [currentDatabase databaseName];
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
    
}

-(IBAction)didPressHelpButton:(NSButton *)sender
{
    
}

-(IBAction)didPressCloseButton:(NSButton *)sender
{
    [self close];
}

-(IBAction)didPressRunButton:(NSButton *)sender
{
    
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
    
}

-(IBAction)didPressExportButton:(NSButton *)sender
{
    
}

@end
