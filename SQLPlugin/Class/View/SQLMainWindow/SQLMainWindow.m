//
//  SQLMainWindow.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/11.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLMainWindow.h"

@implementation SQLMainWindow

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationEvery;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    //
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_ADD_NEW_DATABASE_PATH" object:files];
    }
    
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    //
}

@end
