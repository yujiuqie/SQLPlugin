//
//  SQLSimulatorManager.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDEWorkspace;
@class SQLSimulatorModel;

@interface SQLSimulatorManager : NSObject

@property (nonatomic,strong,readonly) NSMutableArray *allSimulators;

+ (instancetype)sharedManager;

- (NSArray *)fetchAppsWithSelectedSimulators:(NSArray *)selectedList;
- (NSString *)deviceIdWithPath:(NSString *)path;
- (SQLSimulatorModel *)simulatorWithId:(NSString *)deviceId;
- (void)setupLocalDeviceInfosWithWorkspace:(IDEWorkspace *)workspace;

@end
