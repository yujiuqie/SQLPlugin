//
//  SQLSimulatorModel.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/5.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLDirectoryModel : NSObject

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *dirName;

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@interface SQLApplicationModel : NSObject

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *simulatorId;
@property (nonatomic, strong) NSMutableArray *dirs;
@property (nonatomic, strong) NSMutableArray *databases;

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@interface SQLSimulatorModel : NSObject

@property (nonatomic, strong) NSString *simulatorId;
@property (nonatomic, strong) NSString *systemVersion;
@property (nonatomic, strong) NSString *deviceVersion;
@property (nonatomic, strong) NSMutableArray *applications;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL xcodeConfig;

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
