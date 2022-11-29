//
//  Demo7ViewController.m
//  GPUImageDemo
//
//  Created by pengchao on 2022/11/28.
//

#import "Demo7ViewController.h"

@interface Demo7ViewController ()
@property (nonatomic , strong) UILabel  *mLabel;
@property (nonatomic , strong) GPUImageMovie *movieFile;
@property (nonatomic , strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;
@end

@implementation Demo7ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self setupFunc];
    [self layoutUI];
}

- (void)setupUI {
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
}

- (void)setupFunc {
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:filterView];
    
    // 滤镜
    self.filter = [[GPUImageDissolveBlendFilter alloc] init];
    [(GPUImageDissolveBlendFilter *)self.filter setMix:0.5];
    
    // 播放
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:sampleURL];
    CGSize size = self.view.bounds.size;
    self.movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
    self.movieFile.runBenchmark = YES;
    self.movieFile.playAtActualSpeed = YES;
    
    // 水印
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    label.text = @"我是水印";
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor redColor];
    [label sizeToFit];
    UIImage *image = [UIImage imageNamed:@"image2.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    subView.backgroundColor = [UIColor clearColor];
    imageView.center = CGPointMake(subView.bounds.size.width / 2, subView.bounds.size.height / 2);
    [subView addSubview:imageView];
    [subView addSubview:label];
    
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
    
    // GPUImageTransformFilter 动画的filter
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [self.movieFile addTarget:progressFilter];
    [progressFilter addTarget:self.filter];
    [uielement addTarget:self.filter];
    self.movieWriter.shouldPassthroughAudio = YES;
    self.movieFile.audioEncodingTarget = self.movieWriter;
    [self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    // 显示到界面
    [self.filter addTarget:filterView];
    [self.filter addTarget:self.movieWriter];

    
    [self.movieWriter startRecording];
    [self.movieFile startProcessing];
    
    
    CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
    
    __weak typeof(self) weakSelf = self;
    
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        CGRect frame = imageView.frame;
        frame.origin.x += 1;
        frame.origin.y += 1;
        imageView.frame = frame;
        [uielement updateWithTimestamp:time];
    }];
    
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

- (void)layoutUI {
    [self.mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@140);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_right).offset(10);
        make.top.equalTo(self.view.mas_centerY);
    }];
    [self.view bringSubviewToFront:self.mLabel];
}

- (void)updateProgress
{
    self.mLabel.text = [NSString stringWithFormat:@"Progress:%d%%", (int)(self.movieFile.progress * 100)];
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
