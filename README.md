# Crop

Crop interface for UIImage on UIImageView on iOS

* ONLY autolayout.
* ONLY ARC.
* UIImageView must use AspectFit mode by now.

Download project & execute to see how it works. 

ViewController.m has the code you need to include, snippet here: 

```
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

