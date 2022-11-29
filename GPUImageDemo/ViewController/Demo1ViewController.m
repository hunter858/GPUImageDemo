//
//  Demo1ViewController.m
//  GPUImageDemo
//
//  Created by pengchao on 2022/11/28.
//

#import "Demo1ViewController.h"
#import "commonHeader.h"

@interface Demo1ViewController ()
@property (nonatomic ,strong) UIImageView* mImageView;
@end

@implementation Demo1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    self.mImageView = imageView;
    [self setupFunc];
}

- (void)setupFunc {
    GPUImageFilter *filter = [[GPUImageSepiaFilter alloc] init];
    UIImage *image = [UIImage imageNamed:@"image1"];
    self.mImageView.image = [filter imageByFilteringImage:image];
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
