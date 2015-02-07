//
//  ViewController.m
//  Crop
//
//  Created by Franco Santa Cruz on 2/6/15.
//  Copyright (c) 2015 BirdMaker. All rights reserved.
//

#import "ViewController.h"
#import "Cropper.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) Cropper *cropper;
@property (weak, nonatomic) IBOutlet UIButton *cropButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    

    
    
    
}
- (IBAction)cropit:(id)sender {
    
    self.cropper = [[Cropper alloc] initWithImageView:self.imageView];
    __weak ViewController *_self = self;
    _cropper.cropAction = ^(CropperAction action, UIImage *image){
        //        [_self.cropper removeFromSuperview];
        if( action == CropperActionDidCrop )
        {
            _self.imageView.image = image;
        }
        [_self.cropButton setHidden:NO];
        
    };
    
    [self.cropButton setHidden:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
