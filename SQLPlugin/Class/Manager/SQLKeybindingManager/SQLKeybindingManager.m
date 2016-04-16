//
//  SQLKeybindingManager.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/15.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLKeybindingManager.h"

@implementation SQLKeybindingManager

static SQLKeybindingManager *_sharedManager = nil;

+ (instancetype)sharedManager
{
    if(!_sharedManager)
    {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            _sharedManager = [[SQLKeybindingManager alloc] init];
        });
    }
    
    return _sharedManager;
}

#pragma mark -

- (id<IDEKeyboardShortcut>)keyboardShortcutFrom:(NSString *)keybinding
{
    Class<IDEKeyboardShortcut> _IDEKeyboardShortcut = NSClassFromString(@"IDEKeyboardShortcut");
    return [_IDEKeyboardShortcut keyboardShortcutFromStringRepresentation:[[NSUserDefaults standardUserDefaults] valueForKey:keybinding]];
}

- (void)setupKeyBinding:(NSString *)keybinding withShortcut:(NSString *)shortcut
{
    if (IsEmpty([[NSUserDefaults standardUserDefaults] valueForKey:keybinding]))
    {
        [self saveKeyBindingToUserDefaults:shortcut forKey:keybinding];
    }
}

- (void)saveKeyBindingToUserDefaults:(NSString *)keyBinding forKey:(NSString *)defaultsKey
{
    [[NSUserDefaults standardUserDefaults] setObject:keyBinding forKey:defaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateKeyBinding:(id<IDEKeyBinding>)keyBinding forMenuItem:(NSMenuItem *)menuItem defaultsKey:(NSString *)defaultsKey
{
    if ([[keyBinding keyboardShortcuts] count] > 0)
    {
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

- (id<IDEMenuKeyBinding>)menuKeyBindingWithItemTitle:(NSString *)itemTitle underMenuCalled:(NSString *)menuName
{
    Class<IDEKeyBindingPreferenceSet> _IDEKeyBindingPreferenceSet = NSClassFromString(@"IDEKeyBindingPreferenceSet");
    
    id<IDEKeyBindingPreferenceSet> currentPreferenceSet = [[_IDEKeyBindingPreferenceSet preferenceSetsManager] currentPreferenceSet];
    
    id<IDEMenuKeyBindingSet> menuKeyBindingSet = [currentPreferenceSet menuKeyBindingSet] ;
    
    for (id<IDEMenuKeyBinding> keyBinding in [menuKeyBindingSet keyBindings])
    {
        if ([[keyBinding group] isEqualToString:menuName] && [[keyBinding title] isEqualToString:itemTitle])
        {
            return keyBinding;
        }
    }
    
    return nil;
}

- (void)installStandardKeyBinding:(NSString *)keybinding withTitle:(NSString *)kTitle parent:(NSString *)kParent group:(NSString *)kGroup
{
    Class<IDEKeyBindingPreferenceSet> _IDEKeyBindingPreferenceSet = NSClassFromString(@"IDEKeyBindingPreferenceSet");
    
    id<IDEKeyBindingPreferenceSet> currentPreferenceSet = [[_IDEKeyBindingPreferenceSet preferenceSetsManager] currentPreferenceSet];
    
    id<IDEMenuKeyBindingSet> menuKeyBindingSet = [currentPreferenceSet menuKeyBindingSet];
    
    Class<IDEKeyboardShortcut> _IDEKeyboardShortcut = NSClassFromString(@"IDEKeyboardShortcut");
    
    id<IDEKeyboardShortcut> defaultShortcut = [_IDEKeyboardShortcut keyboardShortcutFromStringRepresentation:[[NSUserDefaults standardUserDefaults] valueForKey:keybinding]];
    
    Class<IDEMenuKeyBinding> _IDEMenuKeyBinding = NSClassFromString(@"IDEMenuKeyBinding");
    
    id<IDEMenuKeyBinding> cpKeyBinding = [_IDEMenuKeyBinding keyBindingWithTitle:kTitle
                                                                     parentTitle:kParent
                                                                           group:kGroup
                                                                         actions:[NSArray arrayWithObject:@"whatever:"]
                                                               keyboardShortcuts:[NSArray arrayWithObject:defaultShortcut]];
    
    [cpKeyBinding setCommandIdentifier:kTitle];
    
    [menuKeyBindingSet insertObject:cpKeyBinding inKeyBindingsAtIndex:0];
    [menuKeyBindingSet updateDictionary];
}

#pragma mark -

static inline BOOL IsEmpty(id thing)
{
    return thing == nil
    || ([NSNull null]==thing)
    || ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0);
}


@end
