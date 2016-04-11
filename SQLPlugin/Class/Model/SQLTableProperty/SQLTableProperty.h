//
//  SQLTableProperty.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SQLTablePropertyIntegerType,
    SQLTablePropertyBlobType,
    SQLTablePropertyVarcharType
} SQLTablePropertyType;

@interface SQLTableProperty : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) SQLTablePropertyType type;

@end
