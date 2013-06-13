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
- (NSURL*)makeCacheURL; 


@end

@implementation TopPlacePhotoVC
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;


@synthesize  photoDictionary = _photoDictionary; 
@synthesize fileManager = _fileManager; 

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

/*
- (void)viewWillAppear:(BOOL)animated
{
    self.imageView.image = [UIImage imageWithData:
                            [NSData dataWithContentsOfURL:
                            [FlickrFetcher urlForPhoto:self.photoDictionary format:FlickrPhotoFormatLarge]]];
}
*/ 
 

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

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
    
    NSURL *cacheURL = [urlsArray lastObject]; 
    return cacheURL; 
}


- (void)cachePhoto:(NSDictionary *)photoData imageToCache:(UIImage *)image
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
    
    
    [chronology addObject:(NSString*)[photoData valueForKey:FLICKR_PHOTO_ID]]; 
    [cachedImages setObject:chronology forKey:@"chronology"]; 
    NSData *pngImage = UIImagePNGRepresentation(image); 
    [cachedImages setObject:pngImage forKey:(NSString*)[photoData valueForKey:FLICKR_PHOTO_ID]];

    [cachedImages writeToURL:filePath atomically:YES]; 
    
}


/* Fetch image:
 * cache data structure
 * dictionary of photo ID/images pairs 
 * and a single NSArray chronology
 */ 



- (UIImage *)fetchImage:(NSDictionary *)photoData
{
    
    NSArray *urlsArray = [self.fileManager URLsForDirectory:NSCachesDirectory 
                                                  inDomains:NSUserDomainMask];  
    
    NSURL *filePath = [[urlsArray lastObject] URLByAppendingPathComponent:@"photoCache"]; 
    NSDictionary *cachedImages = [[NSDictionary alloc] initWithContentsOfURL:filePath]; 
    UIImage *cachedPhotoImage = [UIImage imageWithData:[cachedImages valueForKey:[photoData valueForKey:FLICKR_PHOTO_ID]]]; 
    
        
    if(cachedPhotoImage)
    {
        return cachedPhotoImage; 
    }
    else
    {
        UIImage *result = [UIImage imageWithData:
                           [NSData dataWithContentsOfURL:
                            [FlickrFetcher urlForPhoto:self.photoDictionary format:FlickrPhotoFormatOriginal]]];
        
        return result; 
    }
    

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/* viewDidLoad is the first place we want to think about putting things
 * all we need to do is set my scrollViews' contentSize to be the size of the image
 */ 

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; 
    [spinner startAnimating]; 
    
    
    spinner.center = self.view.center;  
    [self.view addSubview:spinner]; 
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("topPlaceImage downloader", NULL); 
    dispatch_async(downloadQueue, ^{ 
    
        UIImage *currImage = [self fetchImage:self.photoDictionary]; 
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
        [self cachePhoto:self.photoDictionary imageToCache:currImage]; 
        
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

@end
