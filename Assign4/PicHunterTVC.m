//
//  PicHunterTVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/7/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PicHunterTVC.h"
#import "FlickrFetcher.h"
#import "PlacePhotosTVC.h" 
#import "MapVC.h"
#import "PlaceAnnotation.h"

@interface PicHunterTVC()
- (NSArray *)mapAnnotations; 
@end


@implementation PicHunterTVC


@synthesize topPlaces = _topPlaces; 



- (IBAction)refresh:(id)sender {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; 
    [spinner startAnimating]; 
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner]; 

    
    dispatch_queue_t download_queue = dispatch_queue_create("topPlaces downloader", NULL); 
    dispatch_async(download_queue, ^{
        NSArray *topPlaces = [FlickrFetcher topPlaces]; 
        dispatch_async(dispatch_get_main_queue(), ^{   
            self.topPlaces = topPlaces;
            self.navigationItem.leftBarButtonItem = sender; 
        });
    }); 
    
    dispatch_release(download_queue);
}
- (IBAction)showMap:(id)sender {
    
    [self performSegueWithIdentifier:@"Show topPlaces Map" sender:self]; 
}

- (void) setTopPlaces:(NSArray *)topPlaces
{
    if (topPlaces != _topPlaces) 
    {
        _topPlaces = topPlaces; 
        if (self.tableView.window) [self.tableView reloadData]; 
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show List of Photos"])
        
    {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; 
        [spinner startAnimating]; 
        
        UIViewController *destinationVC = (UIViewController *)segue.destinationViewController; 
        destinationVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner]; 
        
        
        NSDictionary *placeDict = [self.topPlaces objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        dispatch_queue_t download_queue = dispatch_queue_create("topPlacePhotos downloader", NULL); 
        dispatch_async(download_queue, ^{
            NSArray *photoDictionaries = [FlickrFetcher photosInPlace:placeDict maxResults:50];
            dispatch_async(dispatch_get_main_queue(), ^{ 
                UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:destinationVC action:@selector(showMap:)];
                destinationVC.navigationItem.rightBarButtonItem = rightBarButtonItem; 
                [segue.destinationViewController setListOfPhotos:photoDictionaries];
            }); 
        }); 
        dispatch_release(download_queue); 
        
    }
    
    if([segue.identifier isEqualToString:@"Show topPlaces Map"])
    {
        [segue.destinationViewController setAnnotations:[self mapAnnotations]]; 
    }
}

- (NSArray *)mapAnnotations
{
    
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.topPlaces count]]; 
    for (NSDictionary *topPlace in self.topPlaces)
    {
        [annotations addObject:[PlaceAnnotation annotationForPlace:topPlace]]; 
    }
    return annotations; 
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.topPlaces count]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top Place Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *topPlacesEntry = [self.topPlaces objectAtIndex:indexPath.row]; 
    NSString *placeName = [topPlacesEntry objectForKey:FLICKR_PLACE_NAME]; 
        
    NSMutableArray *tokens = [[placeName componentsSeparatedByString:@","] mutableCopy]; 
    cell.textLabel.text = [tokens objectAtIndex:0];
    NSRange range = NSMakeRange(1, [tokens count] -1 );
    
    //strip off leading whitespace
    [tokens replaceObjectAtIndex:1 withObject:[[tokens objectAtIndex:1] substringFromIndex:1]]; 
 
    cell.detailTextLabel.text = [[tokens objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]] componentsJoinedByString:@", "]; 

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
