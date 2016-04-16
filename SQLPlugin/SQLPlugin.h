//
//  SQLPlugin.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <AppKit/AppKit.h>

@class SQLPlugin;

static SQLPlugin *sharedPlugin;

@interface SQLPlugin : NSObject

+ (instancetype)sharedPlugin;

- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;

@end