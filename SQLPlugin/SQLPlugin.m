//
//  SQLPlugin.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLPlugin.h"

#import "IDEKit.h"
#import "SQLWindowsManager.h"
#import "SQLSimulatorManager.h"
#import "SQLKeybindingManager.h"

#define SP_MENU_PARENT_TITLE            @"SQL"
#define SP_MENU_ITEM_GROUP_TITLE        @"TitleGroup"

#define SP_SHORTCUT_V                   @"$@V" // for key binding system
#define KEY_BINDING_V                   @"SQLPluginKeyBindingV"
#define SP_MENU_ITEM_VIEWER_TITLE       @"SQL Viewer"

#define SP_SHORTCUT_D                   @"$@D" // for key binding system
#define KEY_BINDING_D                   @"SQLPluginKeyBindingD"
#define SP_MENU_ITEM_QUERY_TITLE        @"SQL Query"

static NSString * const IDEKeyBindingSetDidActivateNotification = @"IDEKeyBindingSetDidActivateNotification";

@interface SQLPlugin()

@property (nonatomic, strong) NSMenuItem *sqlQueryMenuItem;
@property (nonatomic, strong) NSMenuItem *sqlViewerMenuItem;
@property (nonatomic, strong) SQLMainWindowController *sqlMainVC;
@property (nonatomic, strong) SQLOperationWindowController *sqlQueryVC;
@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation SQLPlugin

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init])
    {
        self.bundle = plugin;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    [[SQLKeybindingManager sharedManager] setupKeyBinding:KEY_BINDING_V
                                             withShortcut:SP_SHORTCUT_V];
    
    [[SQLKeybindingManager sharedManager] installStandardKeyBinding:KEY_BINDING_V
                                                          withTitle:SP_MENU_ITEM_VIEWER_TITLE
                                                             parent:SP_MENU_PARENT_TITLE
                                                              group:SP_MENU_ITEM_GROUP_TITLE];
    
    [[SQLKeybindingManager sharedManager] setupKeyBinding:KEY_BINDING_D
                                             withShortcut:SP_SHORTCUT_D];
    
    [[SQLKeybindingManager sharedManager] installStandardKeyBinding:KEY_BINDING_D
                                                          withTitle:SP_MENU_ITEM_QUERY_TITLE
                                                             parent:SP_MENU_PARENT_TITLE
                                                              group:SP_MENU_ITEM_GROUP_TITLE];
    
    [self addPluginMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBindingsHaveChanged:)
                                                 name:IDEKeyBindingSetDidActivateNotification
                                               object:nil];
    
    [[SQLSimulatorManager sharedManager] setupLocalDeviceInfosWithWorkspace:[self workspaceForKeyWindow]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ExecutionEnvironmentLastBuildCompletedNotification"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note)
     {
         [[SQLSimulatorManager sharedManager] setupLocalDeviceInfosWithWorkspace:[self workspaceForKeyWindow]];
     }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (IDEWorkspaceWindowController *)keyWindowController
{
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
    
    for (IDEWorkspaceWindowController *controller in workspaceWindowControllers)
    {
        if (controller.window.isKeyWindow)
        {
            return controller;
        }
    }
    return nil;
}

- (id)workspaceForKeyWindow
{
    return [[self keyWindowController] valueForKey:@"_workspace"];
}

#pragma mark -

- (void)addPluginMenu
{
    NSMenu *mainMenu = [NSApp mainMenu];
    
    if (!mainMenu)
    {
        return;
    }
    
    NSMenuItem *pluginsMenuItem = [mainMenu itemWithTitle:SP_MENU_PARENT_TITLE];
    
    if (!pluginsMenuItem)
    {
        pluginsMenuItem = [[NSMenuItem alloc] init];
        pluginsMenuItem.title = SP_MENU_PARENT_TITLE;
        pluginsMenuItem.submenu = [[NSMenu alloc] initWithTitle:pluginsMenuItem.title];
        NSInteger windowIndex = [mainMenu indexOfItemWithTitle:@"Window"];
        [mainMenu insertItem:pluginsMenuItem atIndex:windowIndex];
    }
    
    NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] init];
    aboutMenuItem.title = @"About";
    aboutMenuItem.target = self;
    aboutMenuItem.action = @selector(openAboutWindow);
    [pluginsMenuItem.submenu addItem:aboutMenuItem];
    
    [pluginsMenuItem.submenu addItem:[NSMenuItem separatorItem]];
    
    self.sqlViewerMenuItem = [[NSMenuItem alloc] init];
    self.sqlViewerMenuItem.title = SP_MENU_ITEM_VIEWER_TITLE;
    self.sqlViewerMenuItem.target = self;
    self.sqlViewerMenuItem.action = @selector(openSqlViewerWindow);
    [pluginsMenuItem.submenu addItem:self.sqlViewerMenuItem];
    
    [[SQLKeybindingManager sharedManager] updateMenuItem:self.sqlViewerMenuItem
                                            withShortcut:[[SQLKeybindingManager sharedManager] keyboardShortcutFrom:KEY_BINDING_V]];
    
    
    self.sqlQueryMenuItem = [[NSMenuItem alloc] init];
    self.sqlQueryMenuItem.title = SP_MENU_ITEM_QUERY_TITLE;
    self.sqlQueryMenuItem.target = self;
    self.sqlQueryMenuItem.action = @selector(openSqlQueryWindow);
    [pluginsMenuItem.submenu addItem:self.sqlQueryMenuItem];
    
    [[SQLKeybindingManager sharedManager] updateMenuItem:self.sqlQueryMenuItem
                                            withShortcut:[[SQLKeybindingManager sharedManager] keyboardShortcutFrom:KEY_BINDING_D]];
}

- (void)openAboutWindow
{
    NSString *msgText = [NSString stringWithFormat:@"SQL Plugin %@",[[[NSBundle bundleForClass:NSClassFromString(@"SQLPlugin")] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:msgText];
    
    NSString *infoText = @"Created by Alfred Jiang (viktyz)  2016-4-4 \
    \n  \
    \nhttps://github.com/viktyz \
    \n  \
    \nThank You For Using ! \
    ";
    
    [alert setInformativeText:infoText];
    [alert runModal];
}

- (void)openSqlViewerWindow
{
    if (!_sqlMainVC)
    {
        _sqlMainVC = (SQLMainWindowController *)[[SQLWindowsManager sharedManager] windowWithType:SQLWindowType_SQL_Viewer];
    }
    
    [_sqlMainVC.window center];
    [_sqlMainVC.window makeKeyAndOrderFront:nil];
}

- (void)openSqlQueryWindow
{
    if (!_sqlQueryVC)
    {
        _sqlQueryVC = (SQLOperationWindowController *)[[SQLWindowsManager sharedManager] windowWithType:SQLWindowType_SQL_Operation];
    }
    
    [_sqlQueryVC.window center];
    [_sqlQueryVC.window makeKeyAndOrderFront:nil];
}


- (void)keyBindingsHaveChanged:(NSNotification *)notification
{
    [[SQLKeybindingManager sharedManager] updateKeyBinding:[[SQLKeybindingManager sharedManager] menuKeyBindingWithItemTitle:SP_MENU_ITEM_VIEWER_TITLE
                                                                                                             underMenuCalled:SP_MENU_ITEM_GROUP_TITLE]
                                               forMenuItem:self.sqlViewerMenuItem
                                               defaultsKey:KEY_BINDING_V];
    
    [[SQLKeybindingManager sharedManager] updateKeyBinding:[[SQLKeybindingManager sharedManager] menuKeyBindingWithItemTitle:SP_MENU_ITEM_QUERY_TITLE
                                                                                                             underMenuCalled:SP_MENU_ITEM_GROUP_TITLE]
                                               forMenuItem:self.sqlQueryMenuItem
                                               defaultsKey:KEY_BINDING_D];
}

@end
