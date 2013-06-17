//
//  VacationSelectorTVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "VacationSelectorTVC.h"

@interface VacationSelectorTVC()

- (NSURL *)makeVacationsArrayURL; 

@end




@implementation VacationSelectorTVC



@synthesize vacations = _vacations; 

/* we write to the NSDocumentsDirectory in the setter
 * to keep the TVC and the document synchronized
 */ 


- (void)setVacations:(NSArray *)vacations
{
    if(_vacations != vacations)
    {
        _vacations = vacations; 
        [vacations writeToURL:[self makeVacationsArrayURL] atomically:YES]; 
    }
}







/* setupVacationsArray is called if we reach 
 * viewDidLoad and self.vacations hasn't been 
 * setup. 
 */ 

- (void)setupVacationsArray
{
    
    // NSDocumentDirectory/savedVacations
    NSURL *url = [self makeVacationsArrayURL]; 
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        NSArray *savedVacations = [[NSArray alloc] initWithObjects:@"myVacation", nil]; 
        [savedVacations writeToURL:url atomically:YES]; 
        self.vacations = savedVacations; 
        
        NSLog(@"didn't exist = %@", self.vacations);
    }
    else
    {
        self.vacations = [[NSArray alloc] initWithContentsOfURL:url]; 
        NSLog(@"did exist = %@", self.vacations);
    }
    
}





/* if we get to viewDidLoad and the self.vacations
 * hasn't been set up, then we need to setup
 * self.vacations 
 */ 



-(void)viewDidLoad
{
    [super viewDidLoad]; 
    
    if(!self.vacations)
    {
        [self setupVacationsArray]; 
    }
}









/* helper method to generate the NSDocumentsDirectory URL
 */ 


- (NSURL *)makeVacationsArrayURL
{
    
    // NSDocumentDirectory/savedVacations   
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]; 
    url = [url URLByAppendingPathComponent:@"savedVacations"]; 
    return url; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.vacations count]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Vacation Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    cell.textLabel.text = [self.vacations objectAtIndex:indexPath.row]; 
    
    return cell;
}


@end
