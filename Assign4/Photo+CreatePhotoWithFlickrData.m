//
//  Photo+CreatePhotoWithFlickrData.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Photo+CreatePhotoWithFlickrData.h"
#import "FlickrFetcher.h"

@implementation Photo (CreatePhotoWithFlickrData)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil; 
    
    
    /* note that we only want to store unique photos
     * therefore we query the database to see if the photo exists
     *
     * note that @Photo matches the Photo entity we created
     */ 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"]; 
    
    
    // this code builds the query/request
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [flickrInfo objectForKey:FLICKR_PHOTO_ID]];  
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]; 
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor]; 
    
    
    // this code executes the query/request
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error]; 
    
    if(!matches || [matches count] > 1) 
    {
        // handle error
    }
    else if([matches count] == 0)
    {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context]; 
        photo.unique = [flickrInfo objectForKey:FLICKR_PHOTO_ID]; 
        photo.title = [flickrInfo objectForKey:FLICKR_PHOTO_TITLE]; 
        photo.subtitle = [flickrInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge] absoluteString]; 
        //photo.whichVacation = [Photographer photographerWithName:[flickrInfo objectForKey:FLICKR_PHOTO_OWNER] inManagedObjectContect:context];
    }
    else if([matches count] == 1)
    {
        photo = [matches lastObject]; 
    }
    return photo; 
    
}


@end
