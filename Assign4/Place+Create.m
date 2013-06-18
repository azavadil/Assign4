//
//  Place+Create.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Place+Create.h"

@implementation Place (Create)

+ (Place *)placeWithName:(NSString *)name inManagedObjectContect:(NSManagedObjectContext *)context; 
{
    Place *place = nil; 
    
    
    /* note that we only want to store unique places
     * therefore we query the database to see if the photo exists
     */ 
    
    // note that @Place matches the Place entity we created 
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"]; 
    
    
    /* this code builds the query/request
     * Note there's no predicate because we want all places
     * ugly code. we're relying on the fact that there's only on vacation 
     */ 
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstVisited" ascending:YES]; 
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor]; 
    
    
    // this code executes the query/request
    NSError *error = nil;
    NSArray *places = [context executeFetchRequest:request error:&error]; 
    
    if(!places || [places count] > 1) 
    {
        // handle error
    }
    else if([places count] == 0)
    {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context]; 
        place.placeName  = name; 
        place.firstVisited = [NSDate date]; 
    }
    else if([places count] == 1)
    {
        place = [places lastObject]; 
    }
    return place; 

}

@end
