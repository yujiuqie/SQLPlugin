//
//  SQLTableListProtocol.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#ifndef SQLTableListProtocol_h
#define SQLTableListProtocol_h

@protocol SQLTableListDelegate <NSObject>

@required

-(void)didSelectTable:(SQLTableDescription*)table;
-(void)didSelectDatabase:(SQLDatabaseDescription*)database;

@end

#endif /* SQLTableListProtocol_h */
