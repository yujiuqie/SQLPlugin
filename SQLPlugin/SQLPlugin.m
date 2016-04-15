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

#define SP_DEFAULT_SHORTCUT      @"$@V" // for key binding system
#define DEFAULTS_KEY_BINDING     @"SQLPluginKeyBinding"

#define SP_MENU_PARENT_TITLE     @"SQL"
#define SP_MENU_ITEM_TITLE       @"Run"
#define SP_MENU_ITEM_TITLE_GROUP @"TitleGroup"

static NSString * const IDEKeyBindingSetDidActivateNotification = @"IDEKeyBindingSetDidActivateNotification";

@interface SQLPlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) NSMenuItem *sqlPluginMenuItem;
@property (nonatomic, strong) SQLMainWindowController *sqlMainVC;

@end

@implementation SQLPlugin

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        
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
    
    [[SQLKeybindingManager sharedManager] setupKeyBinding:DEFAULTS_KEY_BINDING
                                               withShortcut:SP_DEFAULT_SHORTCUT];
    
    [[SQLKeybindingManager sharedManager] installStandardKeyBinding:DEFAULTS_KEY_BINDING
                                                          withTitle:SP_MENU_ITEM_TITLE
                                                             parent:SP_MENU_PARENT_TITLE
                                                              group:SP_MENU_ITEM_TITLE_GROUP];
    [self addPluginMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBindingsHaveChanged:)
                                                 name:IDEKeyBindingSetDidActivateNotification
                                               object:nil];
    
    [[SQLSimulatorManager sharedManager] setupLocalDeviceInfosWithWorkspace:[self workspaceForKeyWindow]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ExecutionEnvironmentLastBuildCompletedNotification"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
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
    for (IDEWorkspaceWindowController *controller in workspaceWindowControllers) {
        if (controller.window.isKeyWindow) {
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
    
    self.sqlPluginMenuItem = [[NSMenuItem alloc] init];
    self.sqlPluginMenuItem.title = SP_MENU_ITEM_TITLE;
    self.sqlPluginMenuItem.target = self;
    self.sqlPluginMenuItem.action = @selector(openSqlPluginWindow);
    [pluginsMenuItem.submenu addItem:self.sqlPluginMenuItem];
    
    [[SQLKeybindingManager sharedManager] updateMenuItem:self.sqlPluginMenuItem
                                            withShortcut:[[SQLKeybindingManager sharedManager] keyboardShortcutFrom:DEFAULTS_KEY_BINDING]];
}

- (void)openAboutWindow
{
    NSString *msgText = [NSString stringWithFormat:@"SQL Plugin %@",[[[NSBundle bundleForClass:NSClassFromString(@"SQLPlugin")] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:msgText];
    
    NSString *infoText = @"Created by Alfred Jiang \
    \n  \
    \n2016-4-4  \
    \n \
    ";
    
    [alert setInformativeText:infoText];
    [alert runModal];
}

- (void)openSqlPluginWindow
{
    if (!_sqlMainVC) {
        _sqlMainVC = (SQLMainWindowController *)[[SQLWindowsManager sharedManager] windowWithType:SQLWindowType_SQL_Viewer];
    }
    
    [_sqlMainVC.window center];
    [_sqlMainVC.window makeKeyAndOrderFront:nil];
}

- (void)keyBindingsHaveChanged:(NSNotification *)notification
{
    [[SQLKeybindingManager sharedManager] updateKeyBinding:[[SQLKeybindingManager sharedManager] menuKeyBindingWithItemTitle:SP_MENU_ITEM_TITLE
                                                                                                             underMenuCalled:SP_MENU_ITEM_TITLE_GROUP]
                                               forMenuItem:self.sqlPluginMenuItem
                                               defaultsKey:DEFAULTS_KEY_BINDING];
}

@end
