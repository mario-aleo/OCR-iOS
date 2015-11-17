//
//  ViewController.m
//  OCVR
//
//  Created by Mario Aleo on 05/11/15.
//  Copyright (c) 2015 Mario Aleo. All rights reserved.
//

#import "ViewController.h"

#import <opencv2/opencv.hpp>
#import <TesseractOCR/TesseractOCR.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize imgTaken;
@synthesize imgPreview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openCamera:(id)sender
{
    /*UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imgPicker.allowsEditing = YES;
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }*/
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if (imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //Create camera overlay
        CGRect f = imagePickerController.view.bounds;
        f.size.height -= imagePickerController.navigationBar.bounds.size.height;
        CGFloat barHeight = (f.size.height - f.size.width) / 2;
        UIGraphicsBeginImageContext(f.size);
        [[UIColor colorWithWhite:0 alpha:.5] set];
        UIRectFillUsingBlendMode(CGRectMake(0, 0, f.size.width, barHeight), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, 370, f.size.width, barHeight), kCGBlendModeNormal);
        UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:f];
        overlayIV.image = overlayImage;
        [imagePickerController setCameraOverlayView:overlayIV];
    }
    
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imgTaken = [info objectForKey:UIImagePickerControllerEditedImage];
    self.imgPreview.image = [info objectForKey:UIImagePickerControllerEditedImage];
}

// Inicio Metodos Conversão iOS - OpenCV
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
// Fim Metodos Conversão iOS - OpenCV

- (IBAction)renderThis:(id)sender{
    /*cv::Mat image = [self cvMatFromUIImage: self.imgTaken];
    

    cv::Mat grey;
    cv::cvtColor(image, grey, cv::COLOR_BGR2GRAY);
    
    cv::Mat newMat;
    grey.convertTo(newMat, -1, 2, 100);
    
    cv::Mat thres;
    cv::threshold(newMat, thres, 0, 275, cv::THRESH_OTSU|cv::THRESH_BINARY);
    
    self.imgPreview.image = [self UIImageFromCVMat:(thres)];*/
    
    
    cv::Mat image = [self cvMatFromUIImage: self.imgTaken];
    
    cv::Mat grey;
    cv::cvtColor(image, grey, CV_BGR2GRAY);
    
    cv::Mat gaussMat;
    cv::GaussianBlur(grey, gaussMat, cvSize(3, 3), 0);
    
    cv::Mat cannyMat;
    cv::Canny(gaussMat, cannyMat, 50, 275);
    
    cv::Mat thres;
    cv::threshold(cannyMat, thres, 0, 255, cv::THRESH_OTSU|cv::THRESH_BINARY_INV);
    
    self.imgPreview.image = [self UIImageFromCVMat:(thres)];
    
    
    /*cv::Mat image = [self cvMatFromUIImage: self.imgTaken];
    
    cv::Mat grey;
    cv::cvtColor(image, grey, CV_BGR2GRAY);
    
    cv::Mat newMat;
    grey.convertTo(newMat, -1, 2, 100);
    
    cv::Mat cannyMat;
    cv::Canny(newMat, cannyMat, 50, 275);
    
    cv::Mat thres;
    cv::threshold(cannyMat, thres, 0, 255, cv::THRESH_OTSU|cv::THRESH_BINARY_INV);
    
    self.imgPreview.image = [self UIImageFromCVMat:(thres)];*/
}

- (IBAction)ocrThis:(id)sender{
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    
    tesseract.engineMode = G8OCREngineModeTesseractCubeCombined;
    
    tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    
    tesseract.delegate = self;
    
    tesseract.image = self.imgPreview.image;
    
    [tesseract recognize];
    
    UIImage *imageWithBlocks = [tesseract imageWithBlocks:tesseract.characterBoxes drawText:YES thresholded:NO];
    
    self.imgPreview.image = imageWithBlocks;
    
    NSLog(@"%@", [tesseract recognizedText]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OCR Result"
                                                    message:[tesseract recognizedText]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


@end
