//
//  SQLDatabaseDescription.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SQLTableDescription.h"

@interface SQLDatabaseDescription : NSObject
<
NSOutlineViewDataSource
>

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *tables;

- (NSString *)databaseName;

@end
