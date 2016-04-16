//
//  SQLSimulatorModel.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/5.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLSimulatorModel.h"

@implementation SQLDirectoryModel

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_appId forKey:@"appId"];
    [aCoder encodeObject:_dirName forKey:@"dirName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _appId = [aDecoder decodeObjectForKey:@"appId"];
        _dirName = [aDecoder decodeObjectForKey:@"dirName"];
    }
    
    return self;
}

#pragma mark - NSCoping

- (id)copyWithZone:(NSZone *)zone
{
    SQLDirectoryModel *copy = [[[self class] allocWithZone:zone] init];
    copy.appId = [self.appId copyWithZone:zone];
    copy.dirName = [self.dirName copyWithZone:zone];
    
    return copy;
}

#pragma mark - Equal

- (BOOL)isEqual:(SQLDirectoryModel *)object
{
    if ([_appId isEqual:object.appId] && [_dirName isEqual:object.dirName])
    {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return [self.appId hash] ^ [self.dirName hash];
}

@end

@implementation SQLApplicationModel

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_appId forKey:@"appId"];
    [aCoder encodeObject:_appName forKey:@"appName"];
    [aCoder encodeObject:_simulatorId forKey:@"simulatorId"];
    [aCoder encodeObject:_dirs forKey:@"dirs"];
    [aCoder encodeObject:_databases forKey:@"databases"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _appId = [aDecoder decodeObjectForKey:@"appId"];
        _appName = [aDecoder decodeObjectForKey:@"appName"];
        _simulatorId = [aDecoder decodeObjectForKey:@"simulatorId"];
        _dirs = [aDecoder decodeObjectForKey:@"dirs"];
        _databases = [aDecoder decodeObjectForKey:@"databases"];
    }
    
    return self;
}

#pragma mark - NSCoping

- (id)copyWithZone:(NSZone *)zone
{
    SQLApplicationModel *copy = [[[self class] allocWithZone:zone] init];
    copy.appId = [self.appId copyWithZone:zone];
    copy.appName = [self.appName copyWithZone:zone];
    copy.simulatorId = [self.simulatorId copyWithZone:zone];
    copy.dirs = [self.dirs copyWithZone:zone];
    copy.databases = [self.databases copyWithZone:zone];
    
    return copy;
}

@end

@implementation SQLSimulatorModel

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_simulatorId forKey:@"simulatorId"];
    [aCoder encodeObject:_systemVersion forKey:@"systemVersion"];
    [aCoder encodeObject:_deviceVersion forKey:@"deviceVersion"];
    [aCoder encodeObject:_applications forKey:@"applications"];
    [aCoder encodeObject:[NSNumber numberWithBool:_selected] forKey:@"selected"];
    [aCoder encodeObject:[NSNumber numberWithBool:_xcodeConfig] forKey:@"xcodeConfig"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _simulatorId = [aDecoder decodeObjectForKey:@"simulatorId"];
        _systemVersion = [aDecoder decodeObjectForKey:@"systemVersion"];
        _deviceVersion = [aDecoder decodeObjectForKey:@"deviceVersion"];
        _applications = [aDecoder decodeObjectForKey:@"applications"];
        _selected = [[aDecoder decodeObjectForKey:@"selected"] boolValue];
        _xcodeConfig = [[aDecoder decodeObjectForKey:@"xcodeConfig"] boolValue];
    }
    
    return self;
}

#pragma mark - NSCoping

- (id)copyWithZone:(NSZone *)zone
{
    SQLSimulatorModel *copy = [[[self class] allocWithZone:zone] init];
    copy.simulatorId = [self.simulatorId copyWithZone:zone];
    copy.systemVersion = [self.systemVersion copyWithZone:zone];
    copy.deviceVersion = [self.deviceVersion copyWithZone:zone];
    copy.applications = [self.applications copyWithZone:zone];
    copy.selected = self.selected;
    copy.xcodeConfig = self.xcodeConfig;
    
    return copy;
}

@end
