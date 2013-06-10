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



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/* viewDidLoad is the first place we want to think about putting things
 * all we need to do is set my scrollViews' contentSize to be the size of the image
 */ 


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = [UIImage imageWithData:
                            [NSData dataWithContentsOfURL:
                             [FlickrFetcher urlForPhoto:self.photoDictionary format:FlickrPhotoFormatOriginal]]];
    
    
    self.scrollView.delegate = self; 
    self.scrollView.contentSize = self.imageView.image.size; 
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height); 
    self.title = [self.photoDictionary objectForKey:FLICKR_PHOTO_TITLE];
    
    
}

- (IBAction)zoomAndRefresh:(id)sender {
    
    CGRect visibleRect = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height); 
    
    [self.scrollView zoomToRect:visibleRect animated:YES]; 
    
    

}

- (IBAction)zoom1:(id)sender {
    
    CGFloat imageWidth = self.imageView.image.size.width; 
    CGFloat imageHeight = self.imageView.image.size.height; 
    CGFloat viewWidth = self.scrollView.bounds.size.width; 
    CGFloat viewHeight = self.scrollView.bounds.size.height;
    
    CGFloat zoomFactor = 0; 
    
    if(imageWidth/imageHeight == viewWidth/viewHeight)
    {
        zoomFactor = viewWidth / imageWidth; 
    } 
    else if(imageWidth/imageHeight > viewWidth/viewHeight)
    {
        zoomFactor = viewHeight / imageWidth; 
    } 
    else if(imageWidth/imageHeight < viewWidth/viewHeight) 
    {
        zoomFactor = viewWidth / imageWidth; 
    }
     
    CGPoint midPoint; 
    
    midPoint.x = self.scrollView.contentSize.width/2.; 
    midPoint.y = self.scrollView.contentSize.height/2.; 
     
    CGPoint visibleOrigin; 
    visibleOrigin.x = midPoint.x - self.scrollView.bounds.size.width/2.0; 
    visibleOrigin.y = midPoint.y - self.scrollView.bounds.size.height/2.0;
     
    
    CGRect visibleRect  = CGRectMake(visibleOrigin.x, visibleOrigin.y, 
                                      midPoint.x - self.imageView.image.size.width*zoomFactor, 
                                      midPoint.y - self.imageView.image.size.width*zoomFactor); 
    
    [self.scrollView zoomToRect:visibleRect animated:YES]; 

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
