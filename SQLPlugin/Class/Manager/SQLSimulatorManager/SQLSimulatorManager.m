//
//  SQLSimulatorManager.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLSimulatorManager.h"

#import "IDEKit.h"
#import "SQLSimulatorModel.h"
#import "SQLDatabaseDescription.h"

@interface SQLSimulatorManager()

@property (nonatomic,strong,readwrite) NSMutableArray *allSimulators;
@property (nonatomic,strong) NSDictionary *deviceInfos;

@end

@implementation SQLSimulatorManager

static SQLSimulatorManager *_sharedManager = nil;

+ (instancetype)sharedManager
{
    if(!_sharedManager)
    {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            _sharedManager = [[SQLSimulatorManager alloc] init];
        });
    }
    
    return _sharedManager;
}

- (NSString*)simulatorIdentifierWithWorkspace:(IDEWorkspace *)workspace
{
    IDERunContextManager * runContextManager = [workspace valueForKey:@"runContextManager"];
    IDERunDestination * activeRunDestination = runContextManager.activeRunDestination;
    DVTDevice *targetDevice = activeRunDestination.targetDevice;
    
    NSString *identifier = nil;
    NSString *pathIdentifier = [[targetDevice.deviceLocation standardizedURL]relativeString];
    NSArray *listItems = [pathIdentifier componentsSeparatedByString:@":"];
    
    if(listItems.count == 2 && [targetDevice.deviceType.identifier caseInsensitiveCompare:@"Xcode.DeviceType.iPhoneSimulator"] == NSOrderedSame )
    {
        identifier = listItems[1];
    }
    
    return identifier;
}

- (void)setupLocalDeviceInfosWithWorkspace:(IDEWorkspace *)workspace
{
    NSString *simulatorId = [self simulatorIdentifierWithWorkspace:workspace];
    NSString *appDocDir = [NSHomeDirectory() stringByAppendingString:@"/Library/Developer/CoreSimulator/Devices"];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appDocDir error:NULL];
    
    for (NSString *aPath in contentOfFolder)
    {
        NSString * fullPath = [appDocDir stringByAppendingPathComponent:aPath];
        BOOL isDir;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir)
        {
            if ([[aPath pathExtension] isEqualToString:@"plist"])
            {
                self.deviceInfos = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:fullPath]];
            }
        }
    }
    
    NSDictionary *dicDefaultDevices = [self.deviceInfos objectForKey:@"DefaultDevices"];
    NSArray *allSystemkeys = [dicDefaultDevices allKeys];
    
    for (NSString *systemKey in allSystemkeys)
    {
        if ([systemKey isEqualToString:@"version"])
        {
            continue;
        }
        
        NSString *systemVersion = [[systemKey componentsSeparatedByString:@"."] lastObject];
        NSDictionary *dicDevices = [dicDefaultDevices objectForKey:systemKey];
        NSArray *allDeviceKeys = [dicDevices allKeys];
        
        for (NSString *deviceKey in allDeviceKeys)
        {
            NSString *deviceVersion = [[deviceKey componentsSeparatedByString:@"."] lastObject];
            NSString *deviceid = [dicDevices objectForKey:deviceKey];
            
            SQLSimulatorModel *model = [[SQLSimulatorModel alloc] init];
            model.systemVersion = systemVersion;
            model.deviceVersion = deviceVersion;
            model.simulatorId = deviceid;
            model.xcodeConfig = [deviceid isEqualToString:simulatorId];
            
            [self addSimulator:model];
        }
    }
}

- (void)addSimulator:(SQLSimulatorModel *)model
{
    if (!_allSimulators)
    {
        _allSimulators = [NSMutableArray array];
    }
    
    SQLSimulatorModel *obj = [self deviceInfoWithId:model.simulatorId];
    
    if (obj)
    {
        NSInteger index = [_allSimulators indexOfObject:obj];
        
        obj.systemVersion = model.systemVersion;
        obj.deviceVersion = model.deviceVersion;
        obj.simulatorId = model.simulatorId;
        obj.xcodeConfig = model.xcodeConfig;
        
        [_allSimulators replaceObjectAtIndex:index withObject:obj];
    }
    else
    {
        model.selected = YES;
        [_allSimulators addObject:model];
    }
}

- (NSArray *)fetchAppsWithSelectedSimulators:(NSArray *)selectedList
{
    NSMutableArray *list = [NSMutableArray array];
    NSString *appDocDir = [NSHomeDirectory() stringByAppendingString:@"/Library/Developer/CoreSimulator/Devices"];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appDocDir error:NULL];
    
    for (NSString *aPath in contentOfFolder)
    {
        NSString * fullPath = [appDocDir stringByAppendingPathComponent:aPath];
        BOOL isDir;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)
        {
            SQLSimulatorModel *model = [self deviceInfoWithId:aPath];
            
            if (model && model.selected)
            {
                [list addObjectsFromArray:[self applicationsforSimulator:aPath]];
            }
        }
        else if([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir)
        {
            if ([[aPath pathExtension] isEqualToString:@"plist"])
            {
                self.deviceInfos = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:fullPath]];
            }
        }
    }
    
    return list;
}

- (NSArray*)applicationsforSimulator:(NSString*)deviceIdentifier
{
    NSMutableArray *apps = [NSMutableArray array];
    
    if([[self class] ios7Vesion:deviceIdentifier])
    {
        NSString * path = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Developer/CoreSimulator/Devices/%@/data/Applications",deviceIdentifier];
        NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        
        for(NSString * uuid in array)
        {
            NSString *appPath = [path stringByAppendingFormat:@"/%@",uuid];
            SQLApplicationModel *app = [[SQLApplicationModel alloc] init];
            app.simulatorId = deviceIdentifier;
            app.appName = [self fetchAppNameWithDeviceId:deviceIdentifier andAppId:uuid];
            app.databases = [NSMutableArray arrayWithArray:[self fetchdatabaseInPath:appPath]];
            app.dirs = [NSMutableArray arrayWithArray:[self fetchAppDirsWithDeviceId:deviceIdentifier andAppId:uuid]];
            
            if(app)
            {
                [apps addObject:app];
            }
        }
    }
    else
    {
        NSString * path = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Developer/CoreSimulator/Devices/%@/data/Containers/Data/Application",deviceIdentifier];
        NSArray * applications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        
        for(NSString * applicationIdentifier in applications)
        {
            NSString *appPath = [path stringByAppendingFormat:@"/%@",applicationIdentifier];
            
            SQLApplicationModel *app = [[SQLApplicationModel alloc] init];
            app.simulatorId = deviceIdentifier;
            app.appName = [self fetchAppNameWithDeviceId:deviceIdentifier andAppId:applicationIdentifier];
            app.databases = [NSMutableArray arrayWithArray:[self fetchdatabaseInPath:appPath]];
            app.dirs = [NSMutableArray arrayWithArray:[self fetchAppDirsWithDeviceId:deviceIdentifier andAppId:applicationIdentifier]];
            
            if(app)
            {
                [apps addObject:app];
            }
        }
    }
    
    return apps;
}

- (NSArray *)fetchdatabaseInPath:(NSString *)aPath
{
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:aPath];
    NSMutableArray *files = [NSMutableArray array];
    NSString *fileName;
    
    while (fileName = [direnum nextObject])
    {
        if ([@[@"sqlite", @"sql", @"db"] containsObject:[fileName pathExtension]])
        {
            NSString *fullPath = [aPath stringByAppendingFormat:@"/%@",fileName];
            
            SQLDatabaseDescription *model = [[SQLDatabaseDescription alloc] init];
            model.appId = [self appIdWithPath:aPath];
            model.path = fullPath;
            
            [files addObject:model];
        }
    }
    
    return files;
}


+ (BOOL)ios7Vesion:(NSString*)simulatorIdentifier
{
    NSString * path = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Developer/CoreSimulator/Devices/%@/device.plist",simulatorIdentifier];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString * runtime = [dictionary objectForKey:@"runtime"];
    NSString *ext = runtime.pathExtension;
    
    NSComparisonResult result = [@"iOS-8-0" caseInsensitiveCompare:ext];
    
    if(result  ==  NSOrderedDescending)
    {
        return YES;
    }
    
    if(result  ==  NSOrderedSame || result ==  NSOrderedAscending)
    {
        return NO ;
    }
    
    return NO;
}


- (SQLSimulatorModel *)deviceInfoWithId:(NSString *)deviceId
{
    __block SQLSimulatorModel *model = nil;
    
    [_allSimulators enumerateObjectsUsingBlock:^(SQLSimulatorModel * obj, NSUInteger idx, BOOL * stop) {
        
        if ([obj.simulatorId isEqualToString:deviceId])
        {
            model = obj;
            *stop = YES;
        }
    }];
    
    return model;
}

- (NSString *)fetchAppNameWithDeviceId:(NSString *)deviceId andAppId:(NSString *)appId
{
    NSString *path = @"";
    
    if([[self class] ios7Vesion:deviceId])   //TODO::
    {
        path = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Developer/CoreSimulator/Devices/%@/data/Applications/%@",deviceId,appId];
    }
    else
    {
        path = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Developer/CoreSimulator/Devices/%@/data/Containers/Bundle/Application/%@",deviceId,appId];
    }
    
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    
    for (NSString *aPath in contentOfFolder)
    {
        NSString * fullPath = [path stringByAppendingPathComponent:aPath];
        BOOL isDir;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)
        {
            return aPath;
        }
    }
    
    return nil;
}

- (NSArray *)fetchAppDirsWithDeviceId:(NSString *)deviceId andAppId:(NSString *)appId
{
    NSMutableArray *list = [NSMutableArray array];
    NSString *path = @"";
    
    if([[self class] ios7Vesion:deviceId])   //TODO::
    {
        path = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Developer/CoreSimulator/Devices/%@/data/Applications/%@",deviceId,appId];
    }
    else
    {
        path = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Developer/CoreSimulator/Devices/%@/data/Containers/Data/Application/%@",deviceId,appId];
    }
    
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    
    for (NSString *aPath in contentOfFolder)
    {
        NSString * fullPath = [path stringByAppendingPathComponent:aPath];
        BOOL isDir;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)
        {
            SQLDirectoryModel *model = [[SQLDirectoryModel alloc] init];
            model.dirName = [self fetchAppNameWithDeviceId:deviceId andAppId:appId];
            model.appId = appId;
            
            [list addObject:model];
        }
    }
    
    return list;
}

- (NSString *)deviceIdWithPath:(NSString *)path
{
    NSArray *items = [path componentsSeparatedByString:@"/"];
    
    if ([items count] > 7)
    {
        return [items objectAtIndex:7];
    }
    
    return nil;
}

- (NSString *)appIdWithPath:(NSString *)path
{
    NSArray *items = [path componentsSeparatedByString:@"/"];
    NSString *deviceIdentifier = [self deviceIdWithPath:path];
    
    NSInteger index = [[self class] ios7Vesion:deviceIdentifier] ? 10 : 12;
    
    if ([items count] > index)
    {
        return [items objectAtIndex:index];
    }
    
    return nil;
}

- (SQLSimulatorModel *)simulatorWithId:(NSString *)deviceId
{
    __block SQLSimulatorModel * existSimulator = nil;
    
    [_allSimulators enumerateObjectsUsingBlock:^(SQLSimulatorModel * simulator, NSUInteger idx, BOOL * stop) {
        
        if ([simulator.simulatorId isEqualToString:deviceId])
        {
            existSimulator = simulator;
            *stop = YES;
        }
    }];
    
    return existSimulator;
}

@end
