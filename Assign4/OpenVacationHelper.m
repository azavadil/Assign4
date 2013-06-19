//
//  OpenVacationHelper.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "OpenVacationHelper.h"

@implementation OpenVacationHelper

+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]; 
    NSURL *appDirectoryURL = [url URLByAppendingPathComponent:@"VacationsDirectory"]; 
    
    
    // if the directory doesn't exist, create it /NSDocumentDirector/MyVacations
    if(![[NSFileManager defaultManager] fileExistsAtPath:[appDirectoryURL path]])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[appDirectoryURL path] withIntermediateDirectories:YES attributes:nil error:nil]; 
    }
    
    url = [appDirectoryURL URLByAppendingPathComponent:vacationName]; 
    
    UIManagedDocument *photoDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; 
    
    // if the file doesn't exist, create it
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        [photoDatabase saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){ completionBlock(photoDatabase);}]; 
    }
    else if(photoDatabase.documentState == UIDocumentStateClosed)
    {
        [photoDatabase openWithCompletionHandler:^(BOOL success){ completionBlock(photoDatabase); }]; 
    }
    
    
}



@end
