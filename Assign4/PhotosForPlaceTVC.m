//
//  PhotosForPlaceTVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PhotosForPlaceTVC.h"
#import "OpenVacationHelper.h"
#import "Photo.h"

@interface PhotosForPlaceTVC()

- (void) setupFetchedResultsController:(UIManagedDocument *)vacation; 
- (void) openDatabase; 

@end




@implementation PhotosForPlaceTVC

@synthesize place = _place; 
@synthesize vacationName = _vacationName; 







- (void)viewDidLoad
{
    [super viewDidLoad]; 
    [self openDatabase]; 
}







- (void) setupFetchedResultsController:(UIManagedDocument *)vacation
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"]; 
    request.predicate = [NSPredicate predicateWithFormat:@"fromPlace.placeName = %@", self.place.placeName]; 
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"fromPlace.firstVisited" ascending:YES]]; 
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





- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoForPlace Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath]; 
    cell.textLabel.text = photo.title; 
    cell.detailTextLabel.text = photo.subtitle; 
    
    return cell;
}







/* generic version of prepareForSegue
 * prepareForSegue will set the @property photo on the topPlacePhotoVC
 * 
*/ 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender]; 
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath]; 
    
    
    if([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]){
        [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photo]; 
    }
}


@end
