//
//  MapVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MapVC.h"
#import <MapKit/MapKit.h> 
#import "PlaceAnnotation.h"
#import "PhotoAnnotation.h"
#import "FlickrFetcher.h" 
#import "PlacePhotosTVC.h" 
#import "TopPlacePhotoVC.h"

@interface MapVC() <MKMapViewDelegate>   //EMD2 denote we implement protocol
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapVC
@synthesize mapView = _mapView;
@synthesize annotations = _annotations; 
@synthesize delegate = _delegate; 


/**
 * Instance method: sychronizeMapView
 * ----------------------------------
 * setMapView, setAnnoations, updateMapView
 * sychronizeMapView is a convience method so to help keep our view and out model 
 * in sync. Whenever our view and our model are setable, we want to make sure that
 * they are always in synch. We implement that in the setters of both the view and the 
 * model.
 * 
 * This way it doens't matter which order the outlets and the model gets set. 
 *
 * see implementation notes. 
 */ 

-(void)sychronizeMapView
{
    if(self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations]; 
    if(self.annotations) [self.mapView addAnnotations:self.annotations]; 
}

-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView; 
    [self sychronizeMapView]; 
}

-(void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations; 
    [self sychronizeMapView]; 
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

#pragma mark - View lifecycle

/* establish mapView delegate EMD1
 * EMD1
 */

-(void)viewDidLoad
{
    [super viewDidLoad]; 
    
    // mapVC gets involved as mapView delegate
    self.mapView.delegate = self;
    [self sychronizeMapView]; 
}

/* EMD3. most important method
 * like cellForRowAtIndexPath
 * MKMapView has a built-in delegate method MKMapViewDelegate
 * We're going to establish the MapVC as the delegate for the mapView
 * mapView's main delegate method to get us a view for a selected annotation
 * similar to the button dance
 * note that we don't download the image in this method 
 * this method is only for creating the generic pin. we don't download the image
 * until the pin is actually selected 
 */ 

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapPin"]; 
    if(!aView)
    {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapPin"]; 
        aView.canShowCallout = YES; 
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
    }
    // set @property annotation for the case were we deque 
    // (i.e. if we deque if{} block doesn't execute and annotation hasn't be set)
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil]; 
    return aView; 
                                          
}


/* EMD4. set the image if a pin is selected
 */ 

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)selectedPin
{
    UIImage *image = [self.delegate provideImageToMapVC:self imageForAnnotation:selectedPin.annotation]; 
    [(UIImageView *)selectedPin.leftCalloutAccessoryView setImage:image];
}

- (void)mapView:(MKMapView *)mapView 
 annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([(UIButton*)control buttonType] == UIButtonTypeDetailDisclosure){
        // Do your thing when the detailDisclosureButton is touched
        if([[self.annotations objectAtIndex:0] isKindOfClass:[PlaceAnnotation class]])
        {
            [self performSegueWithIdentifier:@"Show topPlace Photos From Annotation" sender:self]; 
        }
        else if([[self.annotations objectAtIndex:0] isKindOfClass:[PhotoAnnotation class]])
        {
            [self performSegueWithIdentifier:@"Show Photo From Annotation Origin" sender:self]; 
        }
                
    } 
}

- (void)setRightBarButtonItemInVCToSpinner:(UIViewController *)aViewController
{
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; 
    [spinner startAnimating]; 
    
    aViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner]; 
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 'From Annotation' is a reminder that the origin of this action was an annotation
    if([segue.identifier isEqualToString:@"Show topPlace Photos From Annotation"])
        
    {
     
        UIViewController *destinationVC = (UIViewController *)segue.destinationViewController; 
        [self setRightBarButtonItemInVCToSpinner:destinationVC];         
        
        /* there should always be only one annotation selected at a time 
         * to be defensive we pull out the first annotation
         */
        PlaceAnnotation *annotation = [[self.mapView selectedAnnotations] objectAtIndex:0];
        
        /* FlickrFetcher needs a dictionary for a topPlace 
         * For convience we store the dictionary that represents the place with the annotation
         * therefore it's simple to get the dictionary that represents the place 
         */ 
        
        NSDictionary *placeDict = annotation.place;
        
        dispatch_queue_t download_queue = dispatch_queue_create("topPlacePhotos downloader annotation", NULL); 
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
    if([segue.identifier isEqualToString:@"Show Photo From Annotation Origin"])
    {
        /* the imageViewVC takes care of downloading the photo
         * all we need to do here is set the photoDictionary @property in the destinationVC
         */ 
        PhotoAnnotation *annotation = [[self.mapView selectedAnnotations] objectAtIndex:0];
        [segue.destinationViewController setPhotoDictionary:annotation.photo];
    }
    
}



- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
