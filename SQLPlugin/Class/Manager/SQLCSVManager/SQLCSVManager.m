//
//  SQLCSVManager.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/15.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLCSVManager.h"
#import "SQLTableDescription.h"

@implementation SQLCSVManager

static SQLCSVManager *_sharedManager = nil;

+ (instancetype)sharedManager
{
    if(!_sharedManager)
    {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            _sharedManager = [[SQLCSVManager alloc] init];
        });
    }
    
    return _sharedManager;
}

- (void)exportTo:(NSString *)filename withTable:(SQLTableDescription *)table
{
    @autoreleasepool
    {
        NSOutputStream* output = [[NSOutputStream alloc] initToFileAtPath:filename append:NO];
        
        [output open];
        
        if (![output hasSpaceAvailable])
        {
            NSLog(@"No space available in %@", filename);
        }
        else
        {
            NSMutableArray *titles = [NSMutableArray arrayWithCapacity:[table.properties count]];
            
            [table.properties enumerateObjectsUsingBlock:^(SQLTableProperty *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [titles addObject:[NSString stringWithFormat:@"'%@'",obj.name]];//TODO:: if property name equal to ID , csv can not open. Need add ''.
            }];
            
            NSString* header = [[titles componentsJoinedByString:@";"]  stringByAppendingString:@"\n"];
            NSInteger result = [output write:(uint8_t *)[header UTF8String] maxLength:[header length]];
            
            if (result <= 0)
            {
                NSLog(@"exportCsv encountered error=%ld from header write", (long)result);
            }
            
            [table.rows enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString* line = [[obj componentsJoinedByString:@";"] stringByAppendingString:@"\n"];
                NSInteger result = [output write:(uint8_t *)[line UTF8String] maxLength:[line length]];
                
                if (result <= 0)
                {
                    NSLog(@"exportCsv encountered error=%ld from row write", (long)result);
                }
            }];
        }
        
        [output close];
    }
}

@end
