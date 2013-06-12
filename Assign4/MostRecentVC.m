//
//  MostRecentVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MostRecentVC.h"
#import "FlickrFetcher.h"

@interface MostRecentVC() <UIScrollViewDelegate>

@property (nonatomic, strong) NSFileManager *fileManager; 
@end


@implementation MostRecentVC

@synthesize scrollView = _scrollView; 
@synthesize imageView = _imageView; 
@synthesize fileManager = _fileManager; 


@synthesize recentPhotoDictionary = _recentPhotoDictionary; 

-(NSFileManager *)fileManager
{
    if(!_fileManager) _fileManager = [[NSFileManager alloc] init]; 
    return _fileManager; 
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView   
{
    return self.imageView; 
}

- (UIImage *)fetchImage:(NSDictionary *)photoData
{
    
    NSArray *urlsArray = [self.fileManager URLsForDirectory:NSCachesDirectory 
                                                  inDomains:NSUserDomainMask];  
    
    NSURL *filePath = [[urlsArray lastObject] URLByAppendingPathComponent:@"photoCache"]; 
    NSDictionary *cachedImages = [[NSDictionary alloc] initWithContentsOfURL:filePath]; 
    UIImage *cachedPhotoImage = [UIImage imageWithData:[cachedImages valueForKey:[photoData valueForKey:FLICKR_PHOTO_ID]]]; 
    
    
    if(cachedPhotoImage)
    {
        NSLog(@"cachedPhoto %@", [photoData valueForKey:FLICKR_PHOTO_ID]); 
        return cachedPhotoImage; 
    }
    else
    {
        UIImage *result = [UIImage imageWithData:
                           [NSData dataWithContentsOfURL:
                            [FlickrFetcher urlForPhoto:self.recentPhotoDictionary format:FlickrPhotoFormatOriginal]]];
        
        return result; 
    }
    
    
}



#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; 
    [spinner startAnimating]; 
    
    
    spinner.center = self.view.center;  
    [self.view addSubview:spinner]; 
    
    
    dispatch_queue_t download_q = dispatch_queue_create("download recent photo", NULL); 
    dispatch_async(download_q, ^{ 
    
        self.imageView.image = [UIImage imageWithData:
                            [NSData dataWithContentsOfURL:
                             [FlickrFetcher urlForPhoto:self.recentPhotoDictionary format:FlickrPhotoFormatOriginal]]];
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [spinner removeFromSuperview]; 
            self.scrollView.delegate = self; 
            self.scrollView.contentSize = self.imageView.image.size; 
            self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height); 
            self.title = [self.recentPhotoDictionary objectForKey:FLICKR_PHOTO_TITLE];
            
            //set the zoomRatio
            
            float imageWidth = self.imageView.image.size.width; 
            float imageHeight = self.imageView.image.size.height; 
            float viewWidth = self.view.bounds.size.width; 
            float viewHeight = self.view.bounds.size.height;
            
            float widthRatio = viewWidth / imageWidth; 
            float heightRatio = viewHeight / imageHeight; 
            
            self.scrollView.zoomScale = MAX(widthRatio, heightRatio); 

            
        }); 
            
    }); 
    
}


- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
