//
//  ViewController.h
//  OCVR
//
//  Created by Mario Aleo on 05/11/15.
//  Copyright (c) 2015 Mario Aleo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/opencv.hpp>
#import <TesseractOCR/TesseractOCR.h>

#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController <G8TesseractDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, retain) UIImage *imgTaken;
@property (strong, retain) IBOutlet UIImageView *imgPreview;

- (IBAction)openCamera:(id)sender;
- (IBAction)ocrThis:(id)sender;
- (IBAction)renderThis:(id)sender;

@end

