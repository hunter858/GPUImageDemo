//
//  Demo2ViewController.m
//  GPUImageDemo
//
//  Created by pengchao on 2022/11/28.
//

#import "Demo2ViewController.h"
#import "commonHeader.h"
@interface Demo2ViewController ()
@property (nonatomic, strong) GPUImageView *GPUImageView;
@property (nonatomic, strong) GPUImageVideoCamera *GPUVideoCamera;
@end

@implementation Demo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupFunc];
}


- (void)setupFunc {
    self.GPUImageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    self.GPUImageView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self.view addSubview:self.GPUImageView];
    
    self.GPUVideoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.GPUVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
   
    GPUImageSepiaFilter* filter = [[GPUImageSepiaFilter alloc] init];
    [self.GPUVideoCamera addTarget:filter];
    [filter addTarget:self.GPUImageView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.GPUVideoCamera startCameraCapture];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
