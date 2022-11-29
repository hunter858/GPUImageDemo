//
//  Demo6ViewController.m
//  GPUImageDemo
//
//  Created by pengchao on 2022/11/28.
//

#import "Demo6ViewController.h"
#import "commonHeader.h"
@interface Demo6ViewController ()
@property (nonatomic ,strong) UILabel  *mLabel;
@property (nonatomic ,strong) GPUImageMovie *movieFile;
@property (nonatomic ,strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic ,strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic ,strong) GPUImageVideoCamera *videoCamera;
@end

@implementation Demo6ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self setuFunc];
    [self.view bringSubviewToFront:self.mLabel];
}

- (void)setupUI {
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    [self.mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@140);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(100);
    }];
}

- (void)setuFunc {
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:filterView];
    
    self.filter = [[GPUImageDissolveBlendFilter alloc] init];
    [(GPUImageDissolveBlendFilter *)self.filter setMix:0.5];
    
    // 视频输入源
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    self.movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    self.movieFile.runBenchmark = YES;
    self.movieFile.playAtActualSpeed = YES;
    // 摄像头输入源
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    // mix输出
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    // 音频是否来在文件
    Boolean audioFromFile = YES;
    if (audioFromFile) {
        // 响应链
        [self.movieFile addTarget:self.filter];
        [self.videoCamera addTarget:self.filter];
        self.movieWriter.shouldPassthroughAudio = YES;
        //这里以capture auido 为音轨
        self.movieFile.audioEncodingTarget = self.movieWriter;
        [self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
        self.movieWriter.encodingLiveVideo = YES;
    } else {
        // 响应链
        [self.videoCamera addTarget:self.filter];
        [self.movieFile addTarget:self.filter];
        self.movieWriter.shouldPassthroughAudio = NO;
        self.videoCamera.audioEncodingTarget = self.movieWriter;
        self.movieWriter.encodingLiveVideo = NO;
    }
    // 显示到界面
    [self.filter addTarget:filterView];
    [self.filter addTarget:self.movieWriter];
    
    [self.videoCamera startCameraCapture];
    [self.movieWriter startRecording];
    [self.movieFile startProcessing];
    
    CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
    
    __weak typeof(self) weakSelf = self;
    [self.movieWriter setCompletionBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.filter removeTarget:strongSelf.movieWriter];
        [strongSelf.movieWriter finishRecording];
        
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
    }];
}

- (void)updateProgress
{
   self.mLabel.text = [NSString stringWithFormat:@"Progress:%d%%", (int)(self.movieFile.progress * 100)];
   [self.mLabel sizeToFit];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
