//
//  ViewController.m
//  GPUImageDemo
//
//  Created by pengchao on 2022/11/28.
//

#import "ViewController.h"
#import "commonHeader.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    self.title = @"GUPImage Demo";
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = YES;

        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell description]];
    }
    return _tableView;
}


static inline NSArray *TitleDataSource (void) {
    return @[@"GPUBaseFilter",
             @"GPUImageVideoCamera",
             @"GPUImageMovieWriter",
             @"GPUImageFilterGroup",
             @"VideoCamera + MovieWriter ",
             @"Mix CameraSource & VideoSource",
             @"GPUImageUIElement 水印",
             @"demo8",
             @"demo9",
             @"demo10",
             @"demo11",];
}


static inline  NSArray *ControllerDataSource (void) {
    return @[[Demo1ViewController description],
             [Demo2ViewController description],
             [Demo3ViewController description],
             [Demo4ViewController description],
             [Demo5ViewController description],
             [Demo6ViewController description],
             [Demo7ViewController description],
             [Demo8ViewController description],
             [Demo9ViewController description],
             [Demo10ViewController description],
             [Demo11ViewController description],];
}


#pragma mark - UItableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class mapClass = NSClassFromString(ControllerDataSource()[indexPath.row]);
    UIViewController *mapVC = [[mapClass alloc] init];
//    mapVC.modalPresentationStyle = UIModalPresentationFullScreen;
    if (mapVC) {
        [self.navigationController pushViewController:mapVC animated:YES];
    }
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TitleDataSource().count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell description] forIndexPath:indexPath];
    cell.textLabel.text = TitleDataSource()[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    return cell;
}


@end
