//
//  Photo+CreatePhotoWithFlickrData.h
//  Assign4
//
//  Created by Anthony Zavadil on 6/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@interface Photo (CreatePhotoWithFlickrData)

/* note that we need to pass the MOC
 */ 

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo inManagedObjectContext:(NSManagedObjectContext *)context; 

@end
