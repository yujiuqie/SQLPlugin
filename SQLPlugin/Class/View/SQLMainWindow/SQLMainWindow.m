//
//  SQLMainWindow.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/11.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLMainWindow.h"

@implementation SQLMainWindow

- (void)awakeFromNib {
    [super awakeFromNib];
    printf("Awake\n");
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    printf("Enter\n");
    return NSDragOperationEvery;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    printf("Exit\n");
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    printf("Prepare\n");
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    printf("Perform\n");
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        unsigned long numberOfFiles = [files count];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_ADD_NEW_DATABASE_PATH" object:files];
        
        printf("%lu\n", numberOfFiles);
    }
    
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    printf("Conclude\n");
}

@end
