//
//  Demo4ViewController.m
//  GPUImageDemo
//
//  Created by pengchao on 2022/11/28.
//

#import "Demo4ViewController.h"
#import "commonHeader.h"
@interface Demo4ViewController ()
@property (nonatomic, strong) UISlider *slider1;
@property (nonatomic, strong) UISlider *slider2;
@property (nonatomic, strong) UISlider *slider3;
@property (nonatomic, strong) UISlider *slider4;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;
@property (nonatomic, strong) GPUImageTiltShiftFilter *sepiaFilter;
@end

@implementation Demo4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self setupFunc];
    [self layoutUI];
}

- (void)setupUI {
    CGRect sliderFrame = CGRectMake(0, 0, 140, 40);
    self.slider1 = [[UISlider alloc]initWithFrame:sliderFrame];
    self.slider2 = [[UISlider alloc]initWithFrame:sliderFrame];
    self.slider3 = [[UISlider alloc]initWithFrame:sliderFrame];
    self.slider4 = [[UISlider alloc]initWithFrame:sliderFrame];
    [self.view addSubview:self.slider1];
    [self.view addSubview:self.slider2];
    [self.view addSubview:self.slider3];
    [self.view addSubview:self.slider4];
    [self.slider1 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider2 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider3 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider4 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)layoutUI {
    
    [self.slider1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@140);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).offset(100);
    }];
    [self.slider2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@140);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.slider1.mas_bottom).offset(10);
    }];
    [self.slider3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@140);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.slider2.mas_bottom).offset(10);
    }];
    
    [self.slider4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@140);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.slider3.mas_bottom).offset(10);
    }];
    
    [self.view bringSubviewToFront:self.slider1];
    [self.view bringSubviewToFront:self.slider2];
    [self.view bringSubviewToFront:self.slider3];
    [self.view bringSubviewToFront:self.slider4];
    [self.view layoutIfNeeded];
}

- (void)sliderChange:(UISlider *)slider {
    if (slider == self.slider1) {
        _sepiaFilter.blurRadiusInPixels = slider.value;
    }
//    else if (slider == self.slider2){
//        _sepiaFilter.topFocusLevel = slider.value;
//    }
//    else if (slider == self.slider3){
//        _sepiaFilter.bottomFocusLevel = slider.value;
//    }
//    else if (slider == self.slider4){
//        _sepiaFilter.focusFallOffRate = slider.value;
//    }
    
}

- (void)setupFunc {
    GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:primaryView];
    UIImage *inputImage = [UIImage imageNamed:@"image1"];
    _sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage];
    _sepiaFilter = [[GPUImageTiltShiftFilter alloc] init];
    _sepiaFilter.blurRadiusInPixels = 40.0;
    [_sepiaFilter forceProcessingAtSize:primaryView.sizeInPixels];
    [_sourcePicture addTarget:_sepiaFilter];
    [_sepiaFilter addTarget:primaryView];
    [_sourcePicture processImage];
    
    
    // GPUImageContext相关的数据显示
    GLint size = [GPUImageContext maximumTextureSizeForThisDevice];
    GLint unit = [GPUImageContext maximumTextureUnitsForThisDevice];
    GLint vector = [GPUImageContext maximumVaryingVectorsForThisDevice];
    NSLog(@"%d %d %d", size, unit, vector);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    float rate = point.y / self.view.frame.size.height;
    NSLog(@"Processing");
    [_sepiaFilter setTopFocusLevel:rate - 0.1];
    [_sepiaFilter setBottomFocusLevel:rate + 0.1];
    [_sourcePicture processImage];
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
