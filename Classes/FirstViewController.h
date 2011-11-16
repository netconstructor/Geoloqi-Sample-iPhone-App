//
//  FirstViewController.h
//  BackgroundTest
//
//  Created by Aaron Parecki on 2011-11-16.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FirstViewController : UIViewController {

}

@property (nonatomic, retain) IBOutlet UIButton *reloadBtn;

- (IBAction)reloadBtnTapped:(id)sender;

@end
