//
//  TopPlacePhotoVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "TopPlacePhotoVC.h"
#import "FlickrFetcher.h" 

@interface TopPlacePhotoVC() <UIScrollViewDelegate>          //all methods in <UIScrollViewDelegate> are optional

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (UIImage *)fetchImageWithDictionary; 
- (NSURL*)makeCacheURL; 
- (UIImage *)fetchImageWithDatabase;


@end

@implementation TopPlacePhotoVC
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;


@synthesize  photoDictionary = _photoDictionary;
@synthesize photo = _photo; 
@synthesize fileManager = _fileManager; 
@synthesize vacationName = _vacationName; 

- (NSFileManager*)fileManager
{
    if (!_fileManager) _fileManager = [[NSFileManager alloc] init]; 
    return _fileManager; 
}



/* required if we want zooming to work 
 * all we have to do is return which subview we want to zoom
 * in this case (and most cases) you only have 1 subview so 
 * this is trivial
 */ 


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView   
{
    return self.imageView; 
}






-(unsigned long long)sizeOfCacheContainer
{
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *filePath = [[[self makeCacheURL]URLByAppendingPathComponent:@"photoCache"] path]; 
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:NULL]; 
	unsigned long long cacheSize = [fileAttributes fileSize]; 
    return cacheSize; 
}






- (int)getSizeOfCache
{
    NSURL *filePath = [[self makeCacheURL]URLByAppendingPathComponent:@"photoCache"];
    NSDictionary *cachedData = [[NSDictionary alloc] initWithContentsOfURL:filePath]; 
    
    int fileSize = 0; 
    
    for (id item in cachedData)
    {
        if([item isKindOfClass:[NSData class]])
        {
            fileSize += [item length];
        }
    }
    return fileSize; 
}





-(int)getSizeOfDictionary:(NSDictionary *)dictionaryOfImageData
{
    int totalSize = 0; 
    for(id item in dictionaryOfImageData)
    {
        NSData *imageValue = [dictionaryOfImageData valueForKey:item]; 
        totalSize += [imageValue length]; 
    }
    return totalSize; 
}





#define MAXIMUM_CACHE_SIZE 10485760

- (NSURL*)makeCacheURL
{
    NSArray *urlsArray = [self.fileManager URLsForDirectory:NSCachesDirectory 
                                                  inDomains:NSUserDomainMask];  
    
    return [urlsArray lastObject]; 
}






- (void)cachePhoto:(NSString *)uniqueID imageToCache:(UIImage *)image
{
    
    if(!image) return; 
    
    NSURL *filePath = [[self makeCacheURL]URLByAppendingPathComponent:@"photoCache"];
    
    
    // read the cache
    NSMutableDictionary *cachedImages = [[NSMutableDictionary alloc] initWithContentsOfURL:filePath]; 
    if(!cachedImages) cachedImages = [[NSMutableDictionary alloc] init]; 
    
    
    // extract the chronological order from the cache 
    NSMutableArray *chronology = [cachedImages objectForKey:@"chronology"];
    [cachedImages removeObjectForKey:@"chronology"];
    if(!chronology) chronology = [[NSMutableArray alloc] init]; 
    
    while( [self getSizeOfDictionary:cachedImages] > MAXIMUM_CACHE_SIZE )
    {
        
        if([chronology count] > 0)
        {
            NSString *currKey = [chronology objectAtIndex:0]; 
            [chronology removeObjectAtIndex:0];
            [cachedImages removeObjectForKey:currKey];
            
        }
    }
        
    // check that the image isn't already in the cache
    id obj = [cachedImages objectForKey:uniqueID]; 
    if(!obj)
    {
    
        [chronology addObject:uniqueID]; 
        [cachedImages setObject:chronology forKey:@"chronology"]; 
        NSData *pngImage = UIImagePNGRepresentation(image); 
        [cachedImages setObject:pngImage forKey:uniqueID];

        [cachedImages writeToURL:filePath atomically:YES]; 
    }
    //NSLog(@"cachePhoto = %d, %d", [cachedImages count], [self sizeOfCacheContainer]); 
    
}








/* fetchImage just calls its helper methods*/ 
 
- (UIImage *)fetchImage
{
    UIImage *image = nil;
    
    if(self.photoDictionary)
    {
        image = [self fetchImageWithDictionary]; 
    }
    else if(self.photo)
    {
        image = [self fetchImageWithDatabase]; 
    }
    return image; 
}








/* Fetch image:
 * cache data structure
 * dictionary of photo ID/images pairs 
 * and a single NSArray chronology
 */ 


- (UIImage *)fetchImageWithDictionary
{
    
    UIImage *image = nil; 
    
    NSURL *url = [self makeCacheURL]; 
    NSURL *filePath = [url URLByAppendingPathComponent:@"photoCache"]; 
    NSDictionary *cachedImages = [[NSDictionary alloc] initWithContentsOfURL:filePath]; 
    UIImage *cachedPhotoImage = [UIImage imageWithData:[cachedImages valueForKey:[self.photoDictionary valueForKey:FLICKR_PHOTO_ID]]]; 
    
        
    if(cachedPhotoImage)
    {
        image = cachedPhotoImage; 
    }
    else
    {
        image = [UIImage imageWithData:
                           [NSData dataWithContentsOfURL:
                            [FlickrFetcher urlForPhoto:self.photoDictionary format:FlickrPhotoFormatLarge]]];
    }
    return image; 
}



- (UIImage *)fetchImageWithDatabase
{
    UIImage *image = nil; 
    
    NSURL *url = [self makeCacheURL]; 
    
    NSURL *filePath = [url URLByAppendingPathComponent:@"photoCache"]; 
    NSDictionary *cachedImages = [[NSDictionary alloc] initWithContentsOfURL:filePath]; 
    UIImage *cachedPhotoImage = [UIImage imageWithData:[cachedImages valueForKey:self.photo.unique]];  
    
    if(cachedPhotoImage)
    {
        image = cachedPhotoImage; 
    }
    else
    {
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.photo.imageURL]]];
    }
    return image; 
}





// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/* viewDidLoad is the first place we want to think about putting things
 * all we need to do is set my scrollViews' contentSize to be the size of the image
 */ 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"TopPlacePhotoVC - viewDidLoad"); 

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; 
    [spinner startAnimating]; 
    
    
    spinner.center = self.view.center;  
    [self.view addSubview:spinner]; 
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("topPlaceImage downloader", NULL); 
    dispatch_async(downloadQueue, ^{ 
    
        UIImage *currImage = [self fetchImage]; 
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [spinner removeFromSuperview]; 
            self.imageView.image = currImage; 
            self.scrollView.delegate = self; 
            self.scrollView.contentSize = self.imageView.image.size; 
            self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
            
            
            //set the zoomRatio
            
            float imageWidth = self.imageView.image.size.width; 
            float imageHeight = self.imageView.image.size.height; 
            float viewWidth = self.view.bounds.size.width; 
            float viewHeight = self.view.bounds.size.height;
            
            float widthRatio = viewWidth / imageWidth; 
            float heightRatio = viewHeight / imageHeight; 
            
            self.scrollView.zoomScale = MAX(widthRatio, heightRatio); 
            
            
            self.title = [self.photoDictionary objectForKey:FLICKR_PHOTO_TITLE];
        }); 
        if(self.photoDictionary)
        {
            [self cachePhoto:[self.photoDictionary objectForKey:FLICKR_PHOTO_ID] imageToCache:currImage];
        }
        else if(self.photo)
        {
            [self cachePhoto:self.photo.unique imageToCache:currImage];
        }
        
    }); 
    
    dispatch_release(downloadQueue); 
    
}








- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}








- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}








- (void)debugLogging
{
    // implement
}

@end
