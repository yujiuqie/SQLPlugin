@protocol IDETextKeyBindingSet, IDEMenuKeyBindingSet;

@protocol IDEKeyBindingPreferenceSetManager

- (id)currentPreferenceSet;

@end

@protocol IDEKeyBindingPreferenceSet

+ (id)_logAspect;
+ (id)keyPathsForValuesAffectingConflictedKeyBindings;
+ (id)keyPathsForValuesAffectingAllKeyBindings;
+ (id)titleForManagePreferenceSets;
+ (id)titleForNewPreferenceSetFromTemplate;
+ (id)preferenceSetsListHeader;
+ (id)preferenceSetsFileExtension;
+ (id)defaultKeyForExcludedBuiltInPreferenceSets;
+ (id)defaultKeyForCurrentPreferenceSet;
+ (id)builtInPreferenceSetsDirectoryURL;
+ (id)systemPreferenceSet;
+ (id)preferenceSetGroupingName;
+ (id<IDEKeyBindingPreferenceSetManager>)preferenceSetsManager;
+ (id)_defaultKeyBindingsDictionary;
+ (void)initialize;
@property(readonly) NSURL *dataURL;
@property BOOL contentNeedsSaving;
@property(readonly, getter=isBuiltIn) BOOL builtIn;
@property(retain) NSImage *image;
@property(readonly) NSString *localizedName;
@property(readonly) NSString *name;

- (void)activate;
- (void)_resolveConflictWithMenuKeyBindingSet:(id)arg1 textKeyBindingSet:(id)arg2;
- (id)conflictedKeyBindingsWithKeyBinding:(id)arg1 keyboardShortcut:(id)arg2;
- (id)_conflictedKeyBindingsWithKeyBinding:(id)arg1 keyboardShortcut:(id)arg2 menuKeyBindingSet:(id)arg3 textKeyBindingSet:(id)arg4;
- (id)alternateKeyBindingsForKeyBinding:(id)arg1;
@property(retain) id<IDETextKeyBindingSet> textKeyBindingSet;
@property(retain) id<IDEMenuKeyBindingSet> menuKeyBindingSet;
- (void)_symbolicHotKeyDidChange;
- (unsigned long long)_numberOfConflictedHotKeyBindings;
- (unsigned long long)_numberOfConflictedKeyBindigns;
@property(readonly) NSArray *conflictedKeyBindings;
- (void)_updateConflictedKeyBindings;
- (id)_cachedHotKeyboardShortcuts;
@property(readonly) NSArray *modifiedKeyBindings;
@property(readonly) NSArray *allKeyBindings;
- (void)loadData;
- (long long)_disableActivateCount;
- (id)initWithCustomDataSpecifier:(id)arg1 basePreferenceSet:(id)arg2;
- (id)dataRepresentationWithError:(id *)arg1;
- (void)primitiveInvalidate;
- (id)initWithName:(id)arg1 dataURL:(id)arg2;

@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

@protocol IDEKeyBindingSet

- (id)valueForKey:(NSString *)key;

+ (id)defaultKeyBindingSet;
+ (void)initialize;
@property(retain, nonatomic) NSUndoManager *undoManager;
@property(copy, nonatomic) NSArray *keyBindings;
@property(retain) id <IDEKeyBindingPreferenceSet> keyBindingPreferenceSet;
@property(copy, nonatomic) NSDictionary *dictionary;
- (void)activate;
- (void)didActivate;
- (void)willActivate;
- (id)conflictedKeyBindingsWithKeyboardShortcut:(id)arg1;
- (id)prefixedKeyBindingsForKeyboardshortcut:(id)arg1;
- (BOOL)isPrefixedKeyboardShortcut:(id)arg1;
- (BOOL)_keyboardShortcuts:(id)arg1 containsPrefixKeyboardShortcut:(id)arg2;
@property(readonly) NSArray *prefixedKeyboardShortcuts;
- (id)keyBindingForCommandIdentifier:(id)arg1;
- (id)keyBindingsForKeyboardShortcut:(id)arg1;
- (id)alternateKeyBindingsForKeyBinding:(id)arg1;
- (id)baseKeyBindingForKeyBinding:(id)arg1;
- (void)removeObjectFromKeyBindingsAtIndex:(unsigned long long)arg1;
- (void)insertObject:(id)arg1 inKeyBindingsAtIndex:(unsigned long long)arg2;
@property(readonly) NSMutableArray *mutableKeyBindings;
- (void)_keyBindingSetWillRemoveKeyBinding:(id)arg1;
- (void)_keyBindingSetDidInsertKeyBinding:(id)arg1;
- (void)_keyBindingWillRemoveKeyboardShortcuts:(id)arg1;
- (void)_keyBindingDidInsertKeyboardShortcuts:(id)arg1;
- (void)_keyBinding:(id)arg1 willRemoveKeyboardShortcut:(id)arg2;
- (void)_keyBinding:(id)arg1 didInsertKeyboardShortcut:(id)arg2;
@property(readonly) NSDictionary *deltaDictionary;
@property BOOL needsUpdateDictionary;
- (void)updateDictionary;
- (void)primitiveInvalidate;
- (id)init;
- (id)initWithDictionary:(id)arg1;

@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

@protocol IDETextKeyBindingSet <IDEKeyBindingSet>

+ (id)_rawDefaultSystemTextBindings;
+ (id)defaultKeyBindingSet;
+ (Class)_defaultTextKeyBindingSetClass;
+ (void)initialize;
- (void)activate;
- (id)deltaDictionary;
- (void)updateDictionary;
- (void)_appendDictionaryRepresentationOfTextKeyBinding:(id)arg1 appendsEmptyKeyboardShortcuts:(BOOL)arg2 toDictionary:(id)arg3;
- (id)initWithDictionary:(id)arg1;

@end

@protocol IDEMenuKeyBindingSet <IDEKeyBindingSet>

+ (id)defaultKeyBindingSet;
+ (Class)_defaultMenuKeyBindingSetClass;
+ (void)initialize;
- (void)activate;
- (id)prefixedKeyboardShortcuts;
- (void)_keyBindingSetWillRemoveKeyBinding:(id)arg1;
- (void)_keyBindingSetDidInsertKeyBinding:(id)arg1;
- (id)menuKeyBindingsForCommandGroupIdentifier:(id)arg1;
- (id)menuItemForCombinedIdentifier:(id)arg1;
- (id)menuKeyBindingForCombinedIdentifier:(id)arg1;
- (id)menuItemForCommandIdentifier:(id)arg1;
- (id)menuKeyBindingForCommandIdentifier:(id)arg1;
- (id)deltaDictionary;
- (void)updateDictionary;
- (void)primitiveInvalidate;
- (id)initWithDictionary:(id)arg1;
- (void)_appendMenuKeyBindingsDictionary:(id)arg1;
- (void)_appendDebuggingAdditionUIKeyBindingsToMenuKeyBindingSet:(id)arg1;
- (void)_appendKeyBindingsToMenuKeyBindingSet:(id)arg1 menuDefinitionExtensionAttribute:(id)arg2 allowedEditorDocumentIdentifiers:(id)arg3;
- (void)_appendKeyBindingsToMenuKeyBindingSet:(id)arg1 menuDefinitionExtension:(id)arg2 group:(id)arg3 groupIdentifier:(id)arg4 parentTitle:(id)arg5;
- (BOOL)getLockedModifierMask:(unsigned long long *)arg1 unlockedModifierMask:(unsigned long long *)arg2 forKeyBinding:(id)arg3;

@end

@protocol IDEKeyBinding

+ (id)keyPathsForValuesAffectingIsModified;
+ (id)keyBindingWithTitle:(id)arg1 parentTitle:(id)arg2 group:(id)arg3 actions:(id)arg4 keyboardShortcuts:(id)arg5;
+ (id)_stringFromModifierMask:(unsigned long long)arg1;
+ (unsigned long long)_defaultMaxNumberOfShortcuts;
@property unsigned long long maxNumberOfShortcuts;
@property(copy, nonatomic) NSArray *keyboardShortcuts;
@property(readonly) NSArray *actions;
@property(readonly) NSString *group;
@property(readonly) NSString *parentTitle;
@property(readonly) NSString *title;
@property(retain) id<IDEKeyBindingSet> keyBindingSet;
- (long long)tag;
- (SEL)action;
@property(setter=setControlModifierMaskLocked:) BOOL isControlModifierMaskLocked;
@property(setter=setCommandModifierMaskLocked:) BOOL isCommandModifierMaskLocked;
@property(setter=setAlternateModifierMaskLocked:) BOOL isAlternateModifierMaskLocked;
@property(setter=setShiftModifierMaskLocked:) BOOL isShiftModifierMaskLocked;
@property(setter=setConflictedWithHotKey:) BOOL isConflictedWithHotKey;
@property(setter=setConflicted:) BOOL isConflicted;
@property(readonly) BOOL isModified;
@property(setter=setNavigation:) BOOL isNavigation;
@property(setter=setGroupedAlternate:) BOOL isGroupedAlternate;
@property(setter=setAlternate:) BOOL isAlternate;
@property(readonly) NSString *commandIdentifier;
- (void)removePrefixFromKeyboardShortcut:(id)arg1;
- (id)addPrefixKeyboardShortcut:(id)arg1 toKeyboardShortcut:(id)arg2;
- (void)removeObjectFromKeyboardShortcutsAtIndex:(unsigned long long)arg1;
- (void)insertObject:(id)arg1 inKeyboardShortcutsAtIndex:(unsigned long long)arg2;
@property(readonly) NSMutableArray *mutableKeyboardShortcuts;
- (void)_disablePostingKeyboardShortcutsDidChangeNotification;
- (void)_reenablePostingKeyboardShortcutsDidChangeNotification;
- (id)description;
- (long long)compare:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (BOOL)isEqual:(id)arg1;
- (BOOL)isEqualToKeyBinding:(id)arg1;
- (id)initWithTitle:(id)arg1 parentTitle:(id)arg2 group:(id)arg3 actions:(id)arg4 keyboardShortcuts:(id)arg5;
- (id)displayTitle;

@end

@protocol IDEMenuKeyBinding <IDEKeyBinding>

+ (id)keyPathsForValuesAffectingCombinedIdentifier;
+ (id)combinedIdentifierWithCommandIdentifier:(id)arg1 group:(id)arg2 groupIdentifier:(id)arg3;
+ (long long)_defaultMaxNumberOfShortcuts;
@property unsigned long long defaultRawModifierMask;
@property(copy) NSString *groupIdentifier;
@property(copy) NSString *commandGroupIdentifier;
@property(readonly) NSString *commandIdentifier;
@property(readonly) NSString *combinedIdentifier;
- (BOOL)isEqualToKeyBinding:(id)arg1;
- (void)setCommandIdentifier:(NSString *)commandIdentifier;
- (id)copyWithZone:(struct _NSZone *)arg1;

@end

@protocol IDETextKeyBinding <IDEKeyBinding>

+ (unsigned long long)_defaultMaxNumberOfShortcuts;
- (id)commandIdentifier;

@end

@protocol IDEKeyboardShortcut

+ (id)commandKeyHumanRedableName;
+ (id)shiftKeyHumanRedableName;
+ (id)alternateKeyHumanRedableName;
+ (id)controlKeyHumanRedableName;
+ (id)humanReadableNameForKeyEquivalentCharacter:(unsigned short)arg1;
+ (id)translateKeyEquivalent:(id)arg1 modifierMask:(unsigned long long)arg2;
+ (id)emptyKeyboardShortcut;
+ (id)keyboardShortcutFromStringRepresentation:(id)arg1;
+ (id)_keyboardShortcutWithRawKeyEquivalent:(id)arg1 rawModifierMask:(unsigned long long)arg2;
+ (id)keyboardShortcutWithKeyEquivalent:(id)arg1 modifierMask:(unsigned long long)arg2;

@property(copy) id <IDEKeyboardShortcut> nextKeyboardShortcut;
@property(readonly) NSString *stringRepresentation;
@property(readonly) NSString *humanRedableName;
@property(readonly) NSString *localizedDisplayName;
@property(readonly) NSString *displayName;
@property(readonly) NSString *localizedModifierMaskDisplayName;
@property(readonly) NSString *modifierMaskDisplayName;
@property(readonly) NSString *localizedKeyEquivalentDisplayName;
@property(readonly) NSString *keyEquivalentDisplayName;
@property(readonly, getter=isEmpty) BOOL empty;
@property(readonly) id <IDEKeyboardShortcut> rawKeyboardShortcut;
@property(readonly) unsigned long long rawModifierMask;
@property(readonly) unsigned long long modifierMask;
@property(readonly) NSString *rawKeyEquivalent;
@property(readonly) NSString *keyEquivalent;
- (long long)compare:(id)arg1;
- (id)description;
- (unsigned long long)hash;
- (BOOL)isEqual:(id)arg1;
- (BOOL)isEqualToKeyboardShortcut:(id)arg1;
- (id)_rawCopyWithZone:(struct _NSZone *)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)initWithKeyEquivalent:(id)arg1 modifierMask:(unsigned long long)arg2;
- (id)initWithRawKeyEquivalent:(id)arg1 rawModifierMask:(unsigned long long)arg2;
- (id)attributedStringValue;
- (double)alignmentOffset;
- (void)_computeMetaKeyGlyphWidths;
- (double)_widthOfKeyEquivalentCharacter:(unsigned short)arg1 usingAttributes:(id)arg2;

@end

