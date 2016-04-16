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

- (void)addDatabaseDescription:(SQLDatabaseDescription *)databaseDescription;

- (void)removeDatabaseDescription:(SQLDatabaseDescription *)databaseDescription;

- (SQLDatabaseDescription *)databaseDescriptionInPath:(NSString *)path;

- (void)clearDatabaseDescriptions;

@end
