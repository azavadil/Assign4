//
//  OpenVacationHelper.h
//  Assign4
//
//  Created by Anthony Zavadil on 6/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h> 

@interface OpenVacationHelper : NSObject

typedef void(^completion_block_t)(UIManagedDocument *vacation); 

+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock; 

@end
