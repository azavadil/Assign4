//
//  PicHunterTop20TVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/7/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PicHunterTop20TVC.h"
#import "FlickrFetcher.h"
#import "MostRecentVC.h"
#import "PhotoAnnotation.h"
#import "MapVC.h"

@interface PicHunterTop20TVC() <MapVCImageSource> 
@end


@implementation PicHunterTop20TVC 

@synthesize photoDictionaries = _photoDictionaries; 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#define MOST_RECENT @"20_MostRecentPhotos"

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.photoDictionaries = [[NSUserDefaults standardUserDefaults] objectForKey:MOST_RECENT]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return [self.photoDictionaries count]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recently Viewed Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photoDict = [self.photoDictionaries objectAtIndex:indexPath.row]; 
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


/* CODE FOR SHOWING MAP */ 


- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photoDictionaries count]]; 
    for (NSDictionary *photo in self.photoDictionaries)
    {
        [annotations addObject:[PhotoAnnotation annotationForPhoto:photo]]; 
    }
    return annotations; 
}

-(UIImage *)provideImageToMapVC:(MapVC *)sender imageForAnnotation:(id<MKAnnotation>)annotation
{
    PhotoAnnotation *photoAnnotation = (PhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:photoAnnotation.photo format:FlickrPhotoFormatSquare]; 
    NSData *data = [NSData dataWithContentsOfURL:url]; 
    return data ? [UIImage imageWithData:data] : nil; 
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Recent Photo"])
    {
        
        NSDictionary *photoDict = [self.photoDictionaries objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        [segue.destinationViewController setRecentPhotoDictionary:photoDict];
    }
    if([segue.identifier isEqualToString:@"Show recentPhotos Map"])
    {
        MapVC *destinationMapVC = segue.destinationViewController; 
        destinationMapVC.delegate = self; 
        [segue.destinationViewController setAnnotations:[self mapAnnotations]]; 
    }
    
}



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
