//
//  ItineraryTVC.m
//  Assign4
//
//  Created by Anthony Zavadil on 6/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ItineraryTVC.h"


@implementation ItineraryTVC

@synthesize itineraryOptions = _itineraryOptions; 
@synthesize vacationName = _vacationName; 


/* setupItineraryOptionsArray is called if we reach 
 * viewDidLoad and self.itineraryOptions hasn't been 
 * setup. 
 */ 

- (void)setupItineraryOptionsArray
{
    self.itineraryOptions = [[NSArray alloc] initWithObjects:@"Itinerary", @"Tags", nil]; 
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad/vacationName = %@", self.vacationName); 

    if(!self.itineraryOptions)
    {
        [self setupItineraryOptionsArray]; 
    }

}









-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Itinerary Option"])
    {
        NSLog(@"Prepare for Itinerary Option"); 
        if([segue.destinationViewController respondsToSelector:@selector(setVacationName:)])
        {
            [segue.destinationViewController setVacationName:[[sender textLabel] text]]; 
        }
    }
    else if ( [segue.identifier isEqualToString:@"Show Tag Option"])
    {
        NSLog(@"Prepare for Tag Option"); 
        if([segue.destinationViewController respondsToSelector:@selector(setVacationName:)])
        {
            [segue.destinationViewController setVacationName:[[sender textLabel] text]]; 
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) 
    {
        NSLog(@"Show Itinerary Option"); 
        [self performSegueWithIdentifier:@"Show Itinerary Option" sender:self]; 
    }
    else if(indexPath.row == 1)
    {
        NSLog(@"Show Tag Options"); 
        [self performSegueWithIdentifier:@"Show Tag Option" sender:self];
    }


}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}






- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itineraryOptions count];
}







- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Itinerary Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    
    cell.textLabel.text = [self.itineraryOptions objectAtIndex:indexPath.row]; 
    return cell;
}



@end