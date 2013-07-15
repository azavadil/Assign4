//
//  MapVC.h
//  Assign4
//
//  Created by Anthony Zavadil on 6/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapVC; 

// we're going to ask this delegate anytime we need an image for the annotation

@protocol MapVCImageSource <NSObject>
-(UIImage *)provideImageToMapVC:(MapVC *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
@end

@interface MapVC : UIViewController


/**
 * Implementation notes
 * --------------------
 * convention is to always set the model for a controller. In this case the 
 * model for the controller is the annonations. 
 *
 * The controller will just pass the annotations on to the mapView. 
 * However, since the mapView will not be public, there needs to be 
 * to a public API in the controller so the annotations can be set.
 */ 

@property (nonatomic, strong) NSArray *annotations; 

@property (nonatomic, weak) id<MapVCImageSource> delegate; 

@end
