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

@interface SQLTableDescription : NSObject
<
NSOutlineViewDataSource
>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSNumber *rowCount;
@property (nonatomic, strong) NSString *selectedPropertName;
@property (nonatomic, assign) BOOL desc;
@property (nonatomic, strong) NSArray *properties;
@property (nonatomic, strong) NSArray *rows;

- (NSString *)databaseName;
- (NSString *)selectedPropertName;

@end
