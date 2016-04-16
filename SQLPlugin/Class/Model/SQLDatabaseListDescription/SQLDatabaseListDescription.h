//
//  SQLDatabaseListDescription.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/5.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SQLDatabaseDescription.h"

@interface SQLDatabaseListDescription : NSObject
<
NSOutlineViewDataSource,
NSOutlineViewDelegate
>

@property (nonatomic, strong, readonly) NSArray *databases;

@end
