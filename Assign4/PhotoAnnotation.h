//
//  PhotoAnnotation.h
//  Assign4
//
//  Created by Anthony Zavadil on 6/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h> 

/* This is part of the ViewController
 * bridge between model and mapView
 * Model = NSArray of annotations
 * View = mapView
 */ 

@interface PhotoAnnotation : NSObject <MKAnnotation> 

+ (PhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo; 

@property (nonatomic, strong) NSDictionary *photo; 

@end
