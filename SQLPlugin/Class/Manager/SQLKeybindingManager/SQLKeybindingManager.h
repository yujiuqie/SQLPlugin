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

- (id<IDEKeyboardShortcut>)keyboardShortcutFrom:(NSString *)keybinding;
- (id<IDEMenuKeyBinding>)menuKeyBindingWithItemTitle:(NSString *)itemTitle underMenuCalled:(NSString *)menuName;
- (void)installStandardKeyBinding:(NSString *)keybinding withTitle:(NSString *)kTitle parent:(NSString *)kParent group:(NSString *)kGroup;
- (void)setupKeyBinding:(NSString *)keybinding withShortcut:(NSString *)shortcut;
- (void)updateKeyBinding:(id<IDEKeyBinding>)keyBinding forMenuItem:(NSMenuItem *)menuItem defaultsKey:(NSString *)defaultsKey;
- (void)updateMenuItem:(NSMenuItem *)menuItem withShortcut:(id<IDEKeyboardShortcut>)keyboardShortcut;

@end
