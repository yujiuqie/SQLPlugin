//
//  SQLPlugin.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLPlugin.h"
#import "IDEKeyBindingPreferenceSet.h"
#import "SQLMainWindowController.h"
#import "SQLWindowsManager.h"
#import "SQLSimulatorManager.h"
#import "IDEKit.h"

#define SP_DEFAULT_SHORTCUT      @"$@V" // for key binding system
#define DEFAULTS_KEY_BINDING     @"SQLPluginKeyBinding"
#define SP_MENU_PARENT_TITLE     @"SQL"
#define SP_MENU_ITEM_TITLE       @"Run"

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
    
    [self setupKeyBindingsIfNeeded];
    [self installStandardKeyBinding];
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
    
    [self updateMenuItem:self.sqlPluginMenuItem withShortcut:[self keyboardShortcutFromUserDefaults]];
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

#pragma mark -

- (id<IDEKeyboardShortcut>)keyboardShortcutFromUserDefaults
{
    Class<IDEKeyboardShortcut> _IDEKeyboardShortcut = NSClassFromString(@"IDEKeyboardShortcut");
    return [_IDEKeyboardShortcut keyboardShortcutFromStringRepresentation:[self keyBindingFromUserDefaults]];
}

- (void)setupKeyBindingsIfNeeded
{
    if (IsEmpty([self keyBindingFromUserDefaults])) {
        [self saveKeyBindingToUserDefaults:SP_DEFAULT_SHORTCUT forKey:DEFAULTS_KEY_BINDING];
    }
}

- (NSString *)keyBindingFromUserDefaults
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_KEY_BINDING];
}

- (void)saveKeyBindingToUserDefaults:(NSString *)keyBinding forKey:(NSString *)defaultsKey
{
    [[NSUserDefaults standardUserDefaults] setObject:keyBinding forKey:defaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)keyBindingsHaveChanged:(NSNotification *)notification
{
    [self updateKeyBinding:[self currentUserCPKeyBinding] forMenuItem:self.sqlPluginMenuItem defaultsKey:DEFAULTS_KEY_BINDING];
}

- (void)updateKeyBinding:(id<IDEKeyBinding>)keyBinding forMenuItem:(NSMenuItem *)menuItem defaultsKey:(NSString *)defaultsKey
{
    if ([[keyBinding keyboardShortcuts] count] > 0) {
        id<IDEKeyboardShortcut> keyboardShortcut = [[keyBinding keyboardShortcuts] objectAtIndex:0];
        [self saveKeyBindingToUserDefaults:[keyboardShortcut stringRepresentation] forKey:defaultsKey];
        [self updateMenuItem:menuItem withShortcut:keyboardShortcut];
    }
}

- (void)updateMenuItem:(NSMenuItem *)menuItem withShortcut:(id<IDEKeyboardShortcut>)keyboardShortcut
{
    [menuItem setKeyEquivalent:[keyboardShortcut keyEquivalent]];
    [menuItem setKeyEquivalentModifierMask:[keyboardShortcut modifierMask]];
}

- (id<IDEKeyBinding>)currentUserCPKeyBinding
{
    return [self menuKeyBindingWithItemTitle:SP_MENU_ITEM_TITLE underMenuCalled:SP_MENU_ITEM_TITLE];
}

- (id<IDEMenuKeyBinding>)menuKeyBindingWithItemTitle:(NSString *)itemTitle underMenuCalled:(NSString *)menuName
{
    Class<IDEKeyBindingPreferenceSet> _IDEKeyBindingPreferenceSet = NSClassFromString(@"IDEKeyBindingPreferenceSet");
    
    id<IDEKeyBindingPreferenceSet> currentPreferenceSet = [[_IDEKeyBindingPreferenceSet preferenceSetsManager] currentPreferenceSet];
    
    id<IDEMenuKeyBindingSet> menuKeyBindingSet = [currentPreferenceSet menuKeyBindingSet] ;
    
    for (id<IDEMenuKeyBinding> keyBinding in [menuKeyBindingSet keyBindings]) {
        if ([[keyBinding group] isEqualToString:menuName] && [[keyBinding title] isEqualToString:itemTitle]) {
            return keyBinding;
        }
    }
    
    return nil;
}

- (void)installStandardKeyBinding
{
    Class<IDEKeyBindingPreferenceSet> _IDEKeyBindingPreferenceSet = NSClassFromString(@"IDEKeyBindingPreferenceSet");
    
    id<IDEKeyBindingPreferenceSet> currentPreferenceSet = [[_IDEKeyBindingPreferenceSet preferenceSetsManager] currentPreferenceSet];
    
    id<IDEMenuKeyBindingSet> menuKeyBindingSet = [currentPreferenceSet menuKeyBindingSet];
    
    Class<IDEKeyboardShortcut> _IDEKeyboardShortcut = NSClassFromString(@"IDEKeyboardShortcut");
    
    id<IDEKeyboardShortcut> defaultShortcut = [_IDEKeyboardShortcut keyboardShortcutFromStringRepresentation:[self keyBindingFromUserDefaults]];
    
    Class<IDEMenuKeyBinding> _IDEMenuKeyBinding = NSClassFromString(@"IDEMenuKeyBinding");
    
    id<IDEMenuKeyBinding> cpKeyBinding = [_IDEMenuKeyBinding keyBindingWithTitle:SP_MENU_ITEM_TITLE
                                                                     parentTitle:SP_MENU_PARENT_TITLE
                                                                           group:SP_MENU_ITEM_TITLE
                                                                         actions:[NSArray arrayWithObject:@"whatever:"]
                                                               keyboardShortcuts:[NSArray arrayWithObject:defaultShortcut]];
    
    [cpKeyBinding setCommandIdentifier:SP_MENU_ITEM_TITLE];
    
    [menuKeyBindingSet insertObject:cpKeyBinding inKeyBindingsAtIndex:0];
    [menuKeyBindingSet updateDictionary];
}

#pragma mark -

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([NSNull null]==thing)
    || ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0);
}


@end
