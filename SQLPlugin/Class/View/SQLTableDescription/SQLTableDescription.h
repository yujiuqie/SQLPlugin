//
//  SQLTableDescription.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import "SQLTableProperty.h"

@interface SQLTableDescription : NSObject <NSOutlineViewDataSource>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *rows;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSArray<SQLTableProperty *> *properties;
@property (nonatomic, strong) NSArray<SQLTableDescription*> *childern;

- (NSString *)databaseName;

@end
