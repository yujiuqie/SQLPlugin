//
//  NSObject_Extension.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//


#import "NSObject_Extension.h"
#import "SQLPlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    
    if ([currentApplicationName isEqual:@"Xcode"])
    {
        dispatch_once(&onceToken, ^{
            
            sharedPlugin = [[SQLPlugin alloc] initWithBundle:plugin];
        });
    }
}

@end
