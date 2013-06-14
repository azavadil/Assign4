//
//  PlaceAnnotation.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation PlaceAnnotation

@synthesize place = _place; 
@synthesize placeTitle = _placeTitle; 
@synthesize placeSubtitle  = _placeSubtitle; 

+ (PlaceAnnotation *)annotationForPlace:(NSDictionary *)place
{
    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init]; 
    annotation.place = place; 
    
    NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME]; 
    NSMutableArray *tokens = [[placeName componentsSeparatedByString:@","] mutableCopy]; 
    annotation.placeTitle = [tokens objectAtIndex:0];
    NSRange range = NSMakeRange(1, [tokens count] -1 );
    
    //strip off leading whitespace
    [tokens replaceObjectAtIndex:1 withObject:[[tokens objectAtIndex:1] substringFromIndex:1]]; 
    
    annotation.placeSubtitle = [[tokens objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]] componentsJoinedByString:@", "]; 

    return annotation; 
}

- (NSString *)title
{
    return self.placeTitle; 
}

- (NSString *)subtitle
{
    return self.placeSubtitle; 
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate; 
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue]; 
    return coordinate; 
                           
}

@end
