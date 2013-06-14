//
//  PlaceAnnotation.h
//  Assign4
//
//  Created by Anthony Zavadil on 6/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject <MKAnnotation> 

+ (PlaceAnnotation *)annotationForPlace:(NSDictionary *)place; 

@property (nonatomic, strong) NSDictionary *place; 
@property (nonatomic, strong) NSString *placeTitle; 
@property (nonatomic, strong) NSString *placeSubtitle; 

@end

