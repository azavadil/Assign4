//
//  PlaceItineraryTVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PlaceItineraryTVC.h"
#import "OpenVacationHelper.h" 
#import "Place.h"


@implementation PlaceItineraryTVC


@synthesize vacationName = _vacationName; 


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}








- (void) setupFetchedResultsController:(UIManagedDocument *)vacation
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"]; 
    /* returning all places because we only have 1 vacation. if we had multiple 
     * vacations we would need the predicate
     */ 
    //request.predicate = [NSPredicate predicateWithFormat:@"name = %@", self.vacationName]; 
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:vacation.managedObjectContext
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil]; 
}




/* openDatabase works with setupFetchedResultsController
 * to connect the TVC to a shared managedDocument
 */ 



- (void) openDatabase 
{
    [OpenVacationHelper openVacation:self.vacationName usingBlock:^(UIManagedDocument *vacation){
        [self setupFetchedResultsController:vacation];}];
}









- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Itinerary Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath]; 
    cell.textLabel.text = place.placeName; 
    
    return cell;
}




/* generic version of prepareForSegue. 
 * we check that the destinationViewController responds to 
 * setPlace and setVacationName
*/ 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender]; 
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath]; 
    
    
    if([segue.destinationViewController respondsToSelector:@selector(setPlace:)] && 
       [segue.destinationViewController respondsToSelector:@selector(setVacationName:)])
    {
        [segue.destinationViewController performSelector:@selector(setPlace:) withObject:place]; 
        [segue.destinationViewController performSelector:@selector(setVacationName:) withObject:self.vacationName];
    }
}


@end
