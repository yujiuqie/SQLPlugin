//
//  SQLCommandManager.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/6.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLCommandManager : NSObject

+ (instancetype)sharedManager;

- (void)addCommandHistoryItem:(NSString *)info;
- (NSArray *)commandHistoryItems;
- (void)clearCommandHistoryItems;

@end
