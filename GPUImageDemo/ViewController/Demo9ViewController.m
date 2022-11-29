//
//  Demo9ViewController.m
//  GPUImageDemo
//
//  Created by pengchao on 2022/11/28.
//

#import "Demo9ViewController.h"

@interface Demo9ViewController ()
@property (nonatomic, strong) UILabel  *mLabel;
@property (nonatomic, strong) UIImageView *mImageView;
@property (nonatomic, strong) GPUImageRawDataOutput *mOutput;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@end

@implementation Demo9ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self setupFunc];
    [self layoutUI];
}

- (void)setupUI {
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    self.mImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mImageView];
}

- (void)layoutUI {
    [self.mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@240);
        make.height.equalTo(@40);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.top.equalTo(self.view.mas_centerY);
    }];
    
    [self.mImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width).multipliedBy(0.5);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.5);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
    }];
    
    [self.view bringSubviewToFront:self.mLabel];
    [self.view bringSubviewToFront:self.mImageView];
}

- (void)setupFunc {
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    filterView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self.view addSubview:filterView];
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
   
    self.mOutput = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(640, 480) resultsInBGRAFormat:YES];
    [self.videoCamera addTarget:self.mOutput];
    [self.videoCamera addTarget:filterView];
    
    
    __weak typeof(self) wself = self;
    __weak typeof(self.mOutput) weakOutput = self.mOutput;
    [self.mOutput setNewFrameAvailableBlock:^{

        __strong GPUImageRawDataOutput *strongOutput = weakOutput;
        __strong typeof(wself) strongSelf = wself;
        [strongOutput lockFramebufferForReading];
        GLubyte *outputBytes = [strongOutput rawBytesForImage];
        NSInteger bytesPerRow = [strongOutput bytesPerRowInOutput];
        CVPixelBufferRef pixelBuffer = NULL;
        CVReturn ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, 640, 480, kCVPixelFormatType_32BGRA, outputBytes, bytesPerRow, nil, nil, nil, &pixelBuffer);
        if (ret != kCVReturnSuccess) {
            NSLog(@"status %d", ret);
        }

        [strongOutput unlockFramebufferAfterReading];
        if(pixelBuffer == NULL) {
            return ;
        }
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, strongOutput.rawBytesForImage, bytesPerRow * 480, NULL);

        CGImageRef cgImage = CGImageCreate(640, 480, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        [strongSelf updateWithImage:image];
        CGImageRelease(cgImage);
        CFRelease(pixelBuffer);

    }];

    [self.videoCamera startCameraCapture];
    CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
}

- (void)updateWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mImageView.image = image;
    });
}

- (void)updateProgress
{
    self.mLabel.text = [[NSDate dateWithTimeIntervalSinceNow:0] description];
    [self.mLabel sizeToFit];
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
