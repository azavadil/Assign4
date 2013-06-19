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




/* helper method to generate the NSDocumentsDirectory URL
 * path is /NSDocumentDirectory/ListOfVacations
 */ 

- (NSURL *)makeVacationsArrayURL
{
    
    // NSDocumentDirectory/savedVacations   
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]; 
    url = [url URLByAppendingPathComponent:@"ListOfVacations"]; 
    return url; 
}








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












/* if we get to viewDidLoad and the self.vacations
 * hasn't been set up, then we need to setup
 * self.vacations 
 */ 



-(void)viewDidLoad
{
    [super viewDidLoad]; 
    
    if(!self.vacations)
    {
        self.vacations = [[NSArray alloc] initWithContentsOfURL:[self makeVacationsArrayURL]];  
    }
}














- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.vacations count]; 
}







-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    if([segue.destinationViewController respondsToSelector:@selector(setVacationName:)])
    {
        NSLog(@"cell title = %@", [[sender textLabel] text]); 
        [segue.destinationViewController performSelector:@selector(setVacationName:) withObject:[[sender textLabel] text]]; 
    }
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
