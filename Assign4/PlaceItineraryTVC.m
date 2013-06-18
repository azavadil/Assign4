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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}








- (void) setupFetchedResultsController:(UIManagedDocument *)vacation
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Vacation"]; 
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", self.vacationName]; 
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:vacation.managedObjectContext
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil]; 
}


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


@end
