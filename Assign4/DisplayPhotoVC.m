//
//  DisplayPhotoVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DisplayPhotoVC.h"
#import "FlickrFetcher.h"
#import "OpenVacationHelper.h"
#import "Photo+CreatePhotoWithFlickrData.h"

@interface DisplayPhotoVC()

- (void)setupVacationDocument:(UIManagedDocument *)vacation; 
- (void)openDatabase; 
- (void)setupRightBarButtonItem;

@end


@implementation DisplayPhotoVC

@synthesize vacationDocument = _vacationDocument; 




/*
- (void)testQuery
{
    
    NSString *uniqueID = self.photoDictionary ? [self.photoDictionary objectForKey:FLICKR_PHOTO_ID] : self.photo.unique; 
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"]; 
    
    
    // this code builds the query/request
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", uniqueID];  
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]; 
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor]; 
    
    
    // this code executes the query/request
    NSError *error = nil;
    NSArray *matches = [self.vacationDocument.managedObjectContext executeFetchRequest:request error:&error]; 
    NSLog(@"DisplayPhotoVC - testQuery matches count = %d", [matches count]); 
    NSLog(@"DisplayPhotoVC - testQuery - uniqueID = %@", uniqueID); 

}
*/


- (void)setVacationDocument:(UIManagedDocument *)vacationDocument
{
    if(_vacationDocument != vacationDocument)
    {
        _vacationDocument = vacationDocument;
    }
    [self setupRightBarButtonItem]; 
    [self.view setNeedsDisplay]; 
    //[self testQuery]; 
     
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self openDatabase]; 
    
}





- (void)openDatabase
{
    
    NSString *currVacation = nil;
    currVacation = self.vacationName; 
    if(!currVacation) 
    {
        
        /* currently we have only one vacation so this is a kludge
         * if self.vacationName hasn't been set then we read the file
         * at /NSDocumentsDirectory/ListOfVacations which keeps a list
         * of all the vacations
         * because we know there's only one vacation we can just take
         * the vacation at index 0
         */ 
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]; 
        url = [url URLByAppendingPathComponent:@"ListOfVacations"];
        NSArray *vacations = [NSArray arrayWithContentsOfURL:url]; 
        currVacation = [vacations objectAtIndex:0];
        //NSLog(@"openDatabase, ListOfVacations = %@", vacations); 
        //NSLog(@"openDatabase vacationName = %@", currVacation); 
    }
    
    [OpenVacationHelper openVacation:currVacation usingBlock:^(UIManagedDocument *vacationDoc)
     {   
         [self setupVacationDocument:vacationDoc];      }]; 
    
}









/*  setupVacationDocument works in conjunction with 
 *  openDatabase to access the sharedManagedDocument
 */ 

- (void)setupVacationDocument:(UIManagedDocument *)vacation
{
    //NSLog(@"DisplayPhotoVC - setupVacationDocument"); 
    self.vacationDocument = vacation;               
}








- (BOOL)photoExistsInDatabase:(NSString *)uniqueID 
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"]; 
    
    
    // this code builds the query/request
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", uniqueID];  
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]; 
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor]; 
    
    
    // this code executes the query/request
    NSError *error = nil;
    NSArray *matches = [self.vacationDocument.managedObjectContext executeFetchRequest:request error:&error]; 
    
    
    BOOL result; 
    
    if (!matches || [matches count] > 1) {  
        NSLog(@"ERROR: nil or non-unique photos in database");
        NSLog(@"ERROR: numMatches = %@", [matches count]); 
        // return YES, stop addToDatabase from attemping to add the photo
        result = YES; 
    }
    else if([matches count] == 0)
    {
        result = NO; 
    }
    else 
    {
        result = YES; 
    }
    return result; 
}







- (void)setupRightBarButtonItem
{
    NSString *uniqueID = self.photoDictionary ? [self.photoDictionary objectForKey:FLICKR_PHOTO_ID] : self.photo.unique; 
        
    UIBarButtonItem *rightBarButton = nil;  
    
    BOOL existsInDatabase = [self photoExistsInDatabase:uniqueID]; 
        
    if(!existsInDatabase) 
    {
        rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Visit" style:UIBarButtonItemStylePlain target:self action:@selector(addToVacation:)];
    }
    else     
    {
        rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Unvisit" style:UIBarButtonItemStylePlain target:self action:@selector(removeFromVacation:)];
    }
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

















/* It should be the case that this is only triggered
 * when we have self.photoDictionary
 */ 


- (void)addToVacation:(id)sender
{
    [Photo photoWithFlickrInfo:self.photoDictionary inManagedObjectContext:self.vacationDocument.managedObjectContext]; 
    [self.vacationDocument saveToURL:self.vacationDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){} ]; 
    [self setupRightBarButtonItem]; 
    [self.view setNeedsDisplay]; 
}




- (void)removeFromVacation:(id)sender
{
    [Photo deletePhotoWithFlickrInfo:self.photoDictionary inManagedObjectContext:self.vacationDocument.managedObjectContext]; 
    [self setupRightBarButtonItem]; 
    [self.view setNeedsDisplay]; 
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
