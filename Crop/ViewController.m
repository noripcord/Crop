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


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // make crop button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Crop" style:UIBarButtonItemStylePlain target:self action:@selector(cropit:)];
    
    [self.view setBackgroundColor:[UIColor redColor]];
    
}

- (UIBarButtonItem*)cropButton
{
    return self.navigationItem.rightBarButtonItem;
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
        [_self.cropButton setEnabled:YES];
    };
    [self.cropButton setEnabled:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
