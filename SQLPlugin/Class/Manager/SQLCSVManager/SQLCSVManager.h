//
//  SQLCSVManager.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/15.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLTableDescription;

@interface SQLCSVManager : NSObject

+ (instancetype)sharedManager;

- (void)exportTo:(NSString *)filename withTable:(SQLTableDescription *)table;

@end
