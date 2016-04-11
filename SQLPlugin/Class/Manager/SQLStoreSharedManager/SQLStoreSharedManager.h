//
//  SQLStoreSharedManager.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLTableDescription.h"

@interface SQLStoreSharedManager : NSObject

+(instancetype)sharedManager;

-(void)close;
-(BOOL)openDatabaseAtPath:(NSString*)path;

-(void)getAllTablesinPath:(NSString *)path completion:(void (^)(NSArray<SQLTableDescription *> *))completion;
-(void)getRowsWithOffset:(NSNumber*)offset withTableDescription:(SQLTableDescription*)table completion:(void(^)(NSArray*))completion;

@end
