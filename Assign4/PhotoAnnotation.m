//
//  PhotoAnnotation.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PhotoAnnotation.h"
#import "FlickrFetcher.h"

@implementation PhotoAnnotation

@synthesize photo = _photo; 

+ (PhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo
{
    PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init]; 
    annotation.photo = photo; 
    return annotation; 
}


/* MKAnnotation methods
 * title
 * subtitle
 * coordinate
 */ 

- (NSString *)title
{
    return [self.photo objectForKey:FLICKR_PHOTO_TITLE]; 
}
 
- (NSString *)subtitle
{
    return [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION]; 
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate; 
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue]; 
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue]; 
    return coordinate; 
}

@end

