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



#define MAXIMUM_CACHE_SIZE 10485760


- (void)cachePhoto:(NSDictionary *)photoData imageToCache:(UIImage *)image
{
    NSArray *urlsArray = [self.fileManager URLsForDirectory:NSCachesDirectory 
                                                      inDomains:NSUserDomainMask];  
    
    NSURL *cacheURL = [urlsArray lastObject]; 
    
    NSMutableDictionary *currImages = [[NSMutableDictionary alloc] initWithContentsOfURL:cacheURL]; 
    NSMutableArray *chronology;
    
    while([currImages fileSize] > MAXIMUM_CACHE_SIZE)
    {
        // store an array that keeps the order items are entered into the dictionary 
        
        chronology = [currImages objectForKey:@"chronology"]; 
        NSString *currKey = [chronology objectAtIndex:0]; 
        [chronology removeObjectAtIndex:0];
        [currImages removeObjectForKey:currKey]; 
    }
    
    [chronology addObject:[photoData valueForKey:FLICKR_PHOTO_ID]]; 
    [currImages setObject:image forKey:[photoData valueForKey:FLICKR_PHOTO_ID]]; 
    [currImages setObject:chronology forKey:@"chronology"]; 
    
    [currImages writeToURL:cacheURL atomically:YES]; 
    
}




- (UIImage *)fetchImage:(NSDictionary *)photoData
{
    return nil; 
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
    
        UIImage *currImage = [UIImage imageWithData:
                               [NSData dataWithContentsOfURL:
                                [FlickrFetcher urlForPhoto:self.photoDictionary format:FlickrPhotoFormatOriginal]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [spinner removeFromSuperview]; 
            self.imageView.image = currImage; 
            self.scrollView.delegate = self; 
            self.scrollView.contentSize = self.imageView.image.size; 
            self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height); 
            self.title = [self.photoDictionary objectForKey:FLICKR_PHOTO_TITLE];
        }); 
        
    }); 
    
    dispatch_release(downloadQueue); 
    
}

- (IBAction)zoomAndRefresh:(id)sender {
    
    CGRect visibleRect = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height); 
    
    [self.scrollView zoomToRect:visibleRect animated:YES]; 
    
    

}

- (IBAction)zoom1:(id)sender {
      
    float imageWidth = self.imageView.image.size.width; 
    float imageHeight = self.imageView.image.size.height; 
    float viewWidth = self.view.bounds.size.width; 
    float viewHeight = self.view.bounds.size.height;
    
    float widthRatio = viewWidth / imageWidth; 
    float heightRatio = viewHeight / imageHeight; 
    
       
    self.scrollView.zoomScale = MAX(widthRatio, heightRatio); 

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
