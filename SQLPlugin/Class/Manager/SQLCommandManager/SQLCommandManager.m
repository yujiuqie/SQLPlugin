//
//  SQLCommandManager.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/6.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLCommandManager.h"

#define MAX_COUNT 20
#define SQLCommandManagercommandHistoryList @"SQLCommandManagercommandHistoryList"

@interface SQLCommandManager()

@property (nonatomic,strong,readwrite) NSMutableArray *commandHistoryList;

@end

@implementation SQLCommandManager

static SQLCommandManager *_sharedManager = nil;

+ (instancetype)sharedManager
{
    if(!_sharedManager)
    {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            _sharedManager = [[SQLCommandManager alloc] init];
        });
    }
    
    return _sharedManager;
}

- (void)addCommandHistoryItem:(NSString *)info
{
    if (!info || [info length] == 0)
    {
        return;
    }
    
    self.commandHistoryList = [NSMutableArray arrayWithArray:[self commandHistoryList]];
    
    if ([self.commandHistoryList containsObject:info])
    {
        [self.commandHistoryList removeObject:info];
    }
    
    if ([self.commandHistoryList count] >= MAX_COUNT)
    {
        [self.commandHistoryList removeLastObject];
    }
    
    [self.commandHistoryList insertObject:info atIndex:0];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.commandHistoryList forKey:SQLCommandManagercommandHistoryList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)commandHistoryItems
{
    self.commandHistoryList = [[NSUserDefaults standardUserDefaults] objectForKey:SQLCommandManagercommandHistoryList];
    
    if ([self.commandHistoryList count] == 0)
    {
        return @[];
    }
    
    return self.commandHistoryList;
}

- (void)clearCommandHistoryItems
{
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:SQLCommandManagercommandHistoryList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
