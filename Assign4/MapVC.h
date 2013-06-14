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


/* annonation will just be passed right on to mapView
 * since I don't make the mapView public
 * I need to have public API so the annotations can 
 * be set
 */ 

/* when do the annotations need to be updated? 
 * when we hit refresh
 */ 

@property (nonatomic, strong) NSArray *annotations; 

@property (nonatomic, weak) id<MapVCImageSource> delegate; 

@end
