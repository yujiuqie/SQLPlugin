//
//  SQLDatabaseManager.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/6.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SQLSimulatorModel.h"
#import "SQLDatabaseDescription.h"

@interface SQLDatabaseManager : NSObject

@property (nonatomic, strong, readonly) NSArray *databaseDescriptions;

+ (instancetype)sharedManager;

- (SQLDatabaseDescription *)databaseDescriptionInPath:(NSString *)path;
- (void)addDatabaseDescription:(SQLDatabaseDescription *)databaseDescription;
- (void)clearDatabaseDescriptions;
- (void)removeDatabaseDescription:(SQLDatabaseDescription *)databaseDescription;

@end
