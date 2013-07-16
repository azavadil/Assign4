//
//  PlacePhotosTVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/7/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PlacePhotosTVC.h"
#import "FlickrFetcher.h"
#import "TopPlacePhotoVC.h" 
#import "PhotoAnnotation.h" 
#import "MapVC.h"


@interface PlacePhotosTVC() <MapVCImageSource> 
@property (nonatomic, strong) NSArray *annotationsForDestinationVC;
- (void)updateAnnotationsForDestinationVC;
@end

@implementation PlacePhotosTVC

@synthesize listOfPhotos = _listOfPhotos; 
@synthesize annotationsForDestinationVC = _annotationsForDestinationVC; 

- (void) setListOfPhotos:(NSArray *)listOfPhotos
{
    if (listOfPhotos != _listOfPhotos) 
    {
        _listOfPhotos = listOfPhotos; 
        if (self.tableView.window) [self.tableView reloadData]; 
    }
}



/** 
 * Instance method: mapAnnotations
 * -------------------------------
 * mapAnnotations returns an NSArray of mapAnnotations. When we segue to a map displaying
 * all of the places, we set the annotations of the successor view controller to the
 * annotations returned by mapAnnotations. 
 */

- (NSArray *)mapAnnotations
{
    
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.listOfPhotos count]]; 
    for (NSDictionary *photo in self.listOfPhotos)
    {
        [annotations addObject:[PhotoAnnotation annotationForPhoto:photo]]; 
    }
    return annotations; 
}

- (void)updateAnnotationsForDestinationVC
{
    self.annotationsForDestinationVC = [self mapAnnotations]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


// Note: leaving the numberOfSections method in the file was stoping the table from rendering


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.listOfPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo taken at topPlace";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSDictionary *photoDict = [self.listOfPhotos objectAtIndex:indexPath.row]; 
    NSString *photoTitle = [photoDict objectForKey:FLICKR_PHOTO_TITLE];
    NSString *photoDescription = [photoDict objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    if(photoTitle && ![photoTitle isEqualToString:@""]) 
    {
        cell.textLabel.text = photoTitle;    
    } 
    else 
    {
        if(photoDescription && ![photoDescription isEqualToString:@""]) 
        {
            cell.textLabel.text = photoDescription;
        }
        else
        {
            cell.textLabel.text = @"Unknown"; 
        }
    }
    
    cell.detailTextLabel.text = photoDescription; 
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show topPlace Photo"])
    {
        
        NSDictionary *photoDict = [self.listOfPhotos objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        [segue.destinationViewController setPhotoDictionary:photoDict];
    }
    if([segue.identifier isEqualToString:@"Show topPlaces Map"])
    {
        MapVC *destinationMapVC = segue.destinationViewController; 
        destinationMapVC.delegate = self; 
        [segue.destinationViewController setAnnotations:self.annotationsForDestinationVC]; 
    }
}



/**
 * Instance method: provideImageToMapVC 
 * ------------------------------------
 * PlacePhotosTVC is the datasource for a mapView controller (i.e. PlacePhotosTVC gets images
 * from Flickr on the mapView controllers behalf). provideImageToMapVC gets an image on behalf
 * of the mapView (the mapView subsequently passes the image to an annotation
 */
 
-(UIImage *)provideImageToMapVC:(MapVC *)sender imageForAnnotation:(id<MKAnnotation>)annotation
{
    PhotoAnnotation *photoAnnotation = (PhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:photoAnnotation.photo format:FlickrPhotoFormatSquare]; 
    NSData *data = [NSData dataWithContentsOfURL:url]; 
    return data ? [UIImage imageWithData:data] : nil; ; 
    
}

- (IBAction)showMap:(id)sender
{
    [self updateAnnotationsForDestinationVC]; 
    [self performSegueWithIdentifier:@"Show topPlaces Map" sender:self]; 
}


#define MOST_RECENT @"20_MostRecentPhotos" 

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *photoDictionary = [self.listOfPhotos objectAtIndex:indexPath.row]; 
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
    NSMutableArray *mostRecent = [[defaults objectForKey:MOST_RECENT] mutableCopy]; 
    if(!mostRecent) mostRecent = [NSMutableArray array]; 
    [mostRecent addObject:photoDictionary]; 
    if([mostRecent count] > 20) [mostRecent removeObjectAtIndex:0]; 
    [defaults setObject:mostRecent forKey:MOST_RECENT];
    [defaults synchronize]; 
     
    
}

@end
