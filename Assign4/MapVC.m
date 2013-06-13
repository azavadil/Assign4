//
//  MapVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MapVC.h"
#import <MapKit/MapKit.h> 

@interface MapVC()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapVC
@synthesize mapView = _mapView;
@synthesize annotations = _annotations; 


/* setMapView, setAnnoations, updateMapView
 * keep the mapView and annotations in sync
 */ 

-(void)updateMapView
{
    if(self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations]; 
    if(self.annotations) [self.mapView addAnnotations:self.annotations]; 
}

-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView; 
    [self updateMapView]; 
}

-(void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations; 
    [self updateMapView]; 
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
