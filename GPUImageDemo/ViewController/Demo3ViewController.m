//
//  Demo3ViewController.m
//  GPUImageDemo
//
//  Created by pengchao on 2022/11/28.
//

#import "Demo3ViewController.h"
#import "GPUImageBeautifyFilter.h"
#import "commonHeader.h"

@interface Demo3ViewController ()
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageView *GPUImageView;
@end

@implementation Demo3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.GPUImageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.GPUImageView.center = self.view.center;
    [self.view addSubview:self.GPUImageView];
    
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0,640.0)];
    
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    self.movieWriter.encodingLiveVideo = YES;
    [self.videoCamera startCameraCapture];
    
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.GPUImageView];
    [beautifyFilter addTarget:self.movieWriter];
    [self.movieWriter startRecording];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [beautifyFilter removeTarget:self.movieWriter];
        [self.movieWriter finishRecording];
        
        NSError *error;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
             [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieURL];
            
            if (!error){
                NSLog(@"视频保存成功");
                [[NSFileManager defaultManager] removeItemAtURL:movieURL error:nil];
            } else {
                NSLog(@"视频保存失败");
            }
            
        } error:&error];
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
