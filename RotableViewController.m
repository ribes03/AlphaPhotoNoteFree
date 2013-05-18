//
//  RotableViewController.m
//  Psychologist
//
//  Created by Juan Ribes on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RotableViewController.h"
#import "SplitViewBarButtonItemPresenter.h" //Now we can declare a splitButtonBarButtonItem from my detailVC

@implementation RotableViewController

- (void) awakeFromNib //to come up our StoryBoard for Dr Pill?
{
    [super awakeFromNib];
    self.splitViewController.delegate = self; //I'm the delegate
}

-(id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter //A way to communicate wiht our detail View (HVC in this case) in order to save our buttons)
{
    id detailVC = [self.splitViewController.viewControllers lastObject];//returns my detail view
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]){
        detailVC = nil;
    }
    return detailVC;
}

-(BOOL) splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
  //  [self splitViewBarButtonItemPresenter] ?  : NO
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void) splitViewController:(UISplitViewController *)svc 
      willHideViewController:(UIViewController *)aViewController 
           withBarButtonItem:(UIBarButtonItem *)barButtonItem 
        forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.title;
    //NSLog(@"digit pressed = %@", self.title);
    //tell the detail view to put this button up
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}


-(void) splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //tell the detail view to take the button away
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;

}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)shouldAutorotate
{
    return YES;
}


@end
