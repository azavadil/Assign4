//
//  MapVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MapVC.h"
#import <MapKit/MapKit.h> 

@interface MapVC() <MKMapViewDelegate>   //EMD2 denote we implement protocol

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapVC
@synthesize mapView = _mapView;
@synthesize annotations = _annotations; 
@synthesize delegate = _delegate; 


/* setMapView, setAnnoations, updateMapView
 * keep the mapView and annotations in sync
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
