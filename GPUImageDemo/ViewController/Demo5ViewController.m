//
//  Demo5ViewController.m
//  GPUImageDemo
//
//  Created by pengchao on 2022/11/28.
//

#import "Demo5ViewController.h"
#import "commonHeader.h"
@interface Demo5ViewController ()
@property (nonatomic , strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic , strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic , strong) GPUImageView *GPUImageView;

@property (nonatomic , strong) UIButton *mButton;
@property (nonatomic , strong) UILabel  *mLabel;
@property (nonatomic , strong) UISlider  *slider;
@property (nonatomic , assign) long     mLabelTime;
@property (nonatomic , strong) NSTimer  *mTimer;

@property (nonatomic , strong) CADisplayLink *mDisplayLink;
@end

@implementation Demo5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self setupFunc];
    [self layoutUI];
}

- (void)setupUI {
    self.mButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.mButton setTitle:@"录制" forState:UIControlStateNormal];
    [self.mButton sizeToFit];
    [self.view addSubview:self.mButton];
    [self.mButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 100)];
    self.mLabel.hidden = YES;
    self.mLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.mLabel];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [self.slider addTarget:self action:@selector(changeSliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.slider];
    
}

- (void)layoutUI {
    
    [self.mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_centerY);
    }];
    [self.mButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.mLabel.mas_bottom);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@140);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.mButton.mas_bottom);
    }];
    [self.view sendSubviewToBack:self.GPUImageView];
}

- (void)setupFunc {
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    [self.videoCamera addAudioInputsAndOutputs];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    self.filter = [[GPUImageSepiaFilter alloc] init];
    self.GPUImageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.GPUImageView];
    
    [self.videoCamera addTarget:self.filter];
    [self.filter addTarget:self.GPUImageView];
    [self.videoCamera startCameraCapture];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }];
    
    self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displaylink:)];
    [self.mDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)displaylink:(CADisplayLink *)displaylink {
}



- (void)onTimer:(id)sender {
    _mLabel.text  = [NSString stringWithFormat:@"录制时间:%lds", _mLabelTime++];
    [_mLabel sizeToFit];
}

- (void)onClick:(UIButton *)sender {
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie4.m4v"];
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    if([sender.currentTitle isEqualToString:@"录制"]) {
        [sender setTitle:@"结束" forState:UIControlStateNormal];
        NSLog(@"Start recording");
        unlink([pathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
        _movieWriter.encodingLiveVideo = YES;
        [_filter addTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = _movieWriter;
        [_movieWriter startRecording];
        
        _mLabelTime = 0;
        _mLabel.hidden = NO;
        [self onTimer:nil];
        _mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    }
    else {
        [sender setTitle:@"录制" forState:UIControlStateNormal];
        NSLog(@"End recording");
        _mLabel.hidden = YES;
        if (_mTimer) {
            [_mTimer invalidate];
        }
        [_filter removeTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = nil;
        [_movieWriter finishRecording];
        
        ///保存视频到相册
        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [photoLibrary performChanges:^{
          PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieURL];
          request.creationDate = [NSDate date];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
          if (success) {
              NSError *fileError;
              [[NSFileManager defaultManager] removeItemAtPath:movieURL.filePathURL.absoluteURL error:&fileError];
              if (fileError) {
                  NSLog(@"remove cache video error :%@",fileError);
              }
            NSLog(@"已将视频保存至相册");
          } else {
            NSLog(@"未能保存视频到相册");
          }
        }];
        
    }
}

- (void)updateSliderValue:(id)sender
{
    [(GPUImageSepiaFilter *)_filter setIntensity:[(UISlider *)sender value]];
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
