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

@interface SQLKeybindingManager : NSObject

+ (instancetype)sharedManager;

- (void)setupKeyBinding:(NSString *)keybinding withShortcut:(NSString *)shortcut;
- (void)installStandardKeyBinding:(NSString *)keybinding withTitle:(NSString *)kTitle parent:(NSString *)kParent group:(NSString *)kGroup;

- (id<IDEKeyboardShortcut>)keyboardShortcutFrom:(NSString *)keybinding;

- (void)updateMenuItem:(NSMenuItem *)menuItem withShortcut:(id<IDEKeyboardShortcut>)keyboardShortcut;
- (id<IDEMenuKeyBinding>)menuKeyBindingWithItemTitle:(NSString *)itemTitle underMenuCalled:(NSString *)menuName;
- (void)updateKeyBinding:(id<IDEKeyBinding>)keyBinding forMenuItem:(NSMenuItem *)menuItem defaultsKey:(NSString *)defaultsKey;

@end
