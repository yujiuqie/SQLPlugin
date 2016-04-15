//
//  SQLKeybindingManager.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/15.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "IDEKeyBindingPreferenceSet.h"

#define SP_DEFAULT_SHORTCUT      @"$@V" // for key binding system
#define DEFAULTS_KEY_BINDING     @"SQLPluginKeyBinding"

#define SP_MENU_PARENT_TITLE     @"SQL"
#define SP_MENU_ITEM_TITLE       @"Run"
#define SP_MENU_ITEM_TITLE_GROUP @"TitleGroup"

@interface SQLKeybindingManager : NSObject

+ (instancetype)sharedManager;

- (void)setupKeyBindingsIfNeeded;
- (void)installStandardKeyBinding;

- (id<IDEKeyboardShortcut>)keyboardShortcutFromUserDefaults;
- (NSString *)keyBindingFromUserDefaults;
- (id<IDEKeyBinding>)currentUserCPKeyBinding;

- (void)updateMenuItem:(NSMenuItem *)menuItem withShortcut:(id<IDEKeyboardShortcut>)keyboardShortcut;
- (id<IDEMenuKeyBinding>)menuKeyBindingWithItemTitle:(NSString *)itemTitle underMenuCalled:(NSString *)menuName;
- (void)updateKeyBinding:(id<IDEKeyBinding>)keyBinding forMenuItem:(NSMenuItem *)menuItem defaultsKey:(NSString *)defaultsKey;

@end
