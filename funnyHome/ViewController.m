//
//  ViewController.m
//  funnyHome
//
//  Created by Yuki.F on 2014/03/24.
//  Copyright (c) 2014年 Yuki Futagami. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>//haikeiをバラバラにするやつ

@interface ViewController ()

- (CGFloat)lowpassFilter:(CGFloat)accel before:(CGFloat)before;
- (CGFloat)highpassFilter:(CGFloat)accel before:(CGFloat)before;
@property (nonatomic, strong) NSMutableArray *views;//haikeiをバラバラに

@end

@implementation ViewController
@synthesize views;//haikeiをバラバラに

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //アプリの状態保存
    //http://ninjinkun.hatenablog.com/entry/2012/10/20/122257
   
//    //FIXME: サイズ、アイコンなど
//    UIImage *camera = [UIImage imageNamed:@"camera.png"];
//    UIImageView *cameraIcon = [[UIImageView alloc]initWithImage:camera];
//    cameraIcon.frame = CGRectMake(15,15,106,106);
////    cameraIcon.center = CGPointMake(100, 450);
//    [self.view addSubview:cameraIcon];
//    
//    //ドラッグジェスチャーをcameraIcon登録する
//    UIPanGestureRecognizer *pan =
//    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
//    [cameraIcon addGestureRecognizer:pan];
    
//http://lepetit-prince.net/ios/?p=677
//    views = [[NSMutableArray alloc] init];
//    
//    // サンプル画像を読み込む
//    UIImage *image = [UIImage imageNamed:@"funnyHomeUI.png"];
//    
//    NSArray *imageViews = [self divideImage:image];
//    
//    for (UIImageView *iv in imageViews) {
//        [self.view addSubview:iv];
//        [views addObject:iv];
//    }
    
}

-(NSArray *)divideImage:(UIImage *)image
{
    // イメージをバラバラに分割する
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int size = 20;
    
    // 10x10 point で切り取る
    for (int y=0; y<480; y+=size) {
        for (int x=0; x<320; x+=size) {
            CGRect rect = CGRectMake(x, y, size, size);
            UIImage *croppedImage = [self imageByCropping:image toRect:rect];
            UIImageView *v = [[UIImageView alloc] initWithFrame:rect];
            v.image = croppedImage;
            v.layer.cornerRadius = 2.0;
            v.layer.borderWidth = 1.0;
            v.layer.borderColor = [UIColor whiteColor].CGColor;
            v.layer.zPosition = - (y * 100 + x); // 重なったとき上に来るように
            [result addObject:v];
        }
    }
    return result;
}


- (UIImage *)imageByCropping:(UIImage *)crop toRect:(CGRect)rect
{
    // 指定した四角でイメージを切り抜き
    CGImageRef imageRef = CGImageCreateWithImageInRect([crop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.updateInterval = 1.0 / 60.0;
    accelerometer.delegate = self;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    speedX_ = speedY_ = 0.0;
    
   
    //加速度センサーからの値取得終了
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = nil;
   
}


//加速度センサーからの通知
- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
    speedX_ += acceleration.x;
    speedY_ += acceleration.y;
    CGFloat posX = cameraIcon.center.x + speedX_;
    CGFloat posY = cameraIcon.center.y - speedY_;
    
    //端にあたったら跳ね返る処理
    if (posX < 0.0) {
        posX = 0.0;
        
        //左の壁にあたったら0.6倍の力で跳ね返る
        speedX_ *= -0.6;
    } else if (posX > self.view.bounds.size.width) {
        posX = self.view.bounds.size.width;
        
        //右の壁にあたったら0.6倍の力で跳ね返る
        speedX_ *= -0.6;
    }
    if (posY < 0.0) {
        posY = 0.0;
        
        //上の壁にあたっても跳ね返らない
        speedY_ = 0.0;
    } else if (posY > self.view.bounds.size.height) {
        posY = self.view.bounds.size.height;
        
        //下の壁にあたったら0.6倍の力で跳ね返る
        speedY_ *= -0.6;
    }
    cameraIcon.center = CGPointMake(posX, posY);
}

//ローパスフィルタ
- (CGFloat)lowpassFilter:(CGFloat)accel before:(CGFloat)before
{
    static const CGFloat kFilteringFactor = 0.1;
    return (accel * kFilteringFactor) + (before * (1.0 - kFilteringFactor));
}

//ハイパスフィルタ
- (CGFloat)highpassFilter:(CGFloat)accel before:(CGFloat)before
{
    return (accel - [self lowpassFilter:accel before:before]);
}



#pragma mark - 背景画像
/* -- タッチスタンプの教科書 -- */
-(IBAction)settei{
    
    UIImagePickerController *jpc = [[UIImagePickerController alloc] init];
    [jpc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [jpc setDelegate:self];
    [jpc setAllowsEditing:YES];
    [self presentViewController:jpc animated:YES completion:nil];
    
}
-(void)imagePickerController:(UIImagePickerController *)picer
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //バラバラにするやつ
    views = [[NSMutableArray alloc] init];
    
    NSArray *imageViews = [self divideImage:image];
    
    [haikei setImage:image];
    
    for (UIImageView *iv in imageViews) {
        [self.view addSubview:iv];
        [iv addSubview:haikei];
        [views addObject:iv];
    }

    
//    [haikei setImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}



//#pragma mark - ドラッグ
///* -- dragの教科書 -- */
//-(void)panAction:(UIPanGestureRecognizer *)sender
//{
//    
//    //移動した距離の取得
//    CGPoint p = [sender translationInView:self.view];
//    //移動した距離のx座標、y座標をcameraIconの中心に設定
//    CGPoint movedPoint = CGPointMake(cameraIcon.center.x + p.x, cameraIcon.center.y + p.y);
//    cameraIcon.center = movedPoint;
//    
//    NSLog(@"★座標を%@移動中", NSStringFromCGPoint(movedPoint));
//    
//    //移動した距離の初期化をする。これをしないと値が続きからなる。
//    [sender setTranslation:CGPointZero inView:self.view];
//    
//    //ジェスチャー終了
//    if(sender.state == UIGestureRecognizerStateEnded)
//    {
//        
//        NSLog(@"移動終了");
//        
//    }
//    
//    
//}


#pragma mark - タッチ
/* -- goldfishサンプル -- */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(![timer isValid]){
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self
                                               selector:@selector(up)
                                               userInfo:nil
                                                repeats:YES];
        
    }
    
    //-- タッチした位置を調べる
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self.view];
    //-- touchesBeganで必要な処理
	[super touchesBegan:touches withEvent:event];
	
    /* -- 21UIView教科書 -- */
    //アニメーション設定
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.6];
    
    cameraIcon.center = CGPointMake(location.x - 20, location.y - 20);
    messeIcon.center = CGPointMake(location.x + 20, location.y + 20);
    tenkiIcon.center = CGPointMake(location.x - 10, location.y - 10);
    photoIcon.center = CGPointMake(location.x + 10, location.y + 10);
    gameIcon.center = CGPointMake(location.x + 10, location.y - 10);
    contactsIcon.center = CGPointMake(location.x - 10, location.y + 10);
    faceTimeIcon.center = CGPointMake(location.x + 20, location.y - 20);
    calendarIcon.center = CGPointMake(location.x - 20, location.y + 20);
    mapsIcon.center = CGPointMake(location.x - 15, location.y + 15);
    newsIcon.center = CGPointMake(location.x + 15, location.y - 15);
    compassIcon.center = CGPointMake(location.x - 15, location.y - 15);
    calculatorIcon.center = CGPointMake(location.x + 15, location.y + 15);
    safariIcon.center = CGPointMake(location.x - 15, location.y + 10);
    passbookIcon.center = CGPointMake(location.x + 10, location.y - 15);
    phoneIcon.center = CGPointMake(location.x - 20, location.y - 15);
    musicIcon.center = CGPointMake(location.x + 15, location.y + 20);
    notesIcon.center = CGPointMake(location.x + 10, location.y + 20);


    
    
    [UIView commitAnimations];
    
    // タッチしたら、画像をバラバラにくずす
    for (int i=0; i<[views count]; i++) {
        [UIView animateWithDuration:0.8 delay:i * 0.05 options:UIViewAnimationOptionCurveEaseIn animations:^{
            UIView *v = [views objectAtIndex:i];
            v.center = CGPointMake(v.center.x, 600);
        } completion:^(BOOL finished) {}];
    }
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (count >= 0.6) {
        
    //-- タッチした位置を調べる
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self.view];
    //-- touchesMoved処理で必要な処理
	[super touchesMoved:touches withEvent:event];
	
    //アニメーション設定
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:1];
    
    [UIView setAnimationDelay:1];
    
    cameraIcon.center = CGPointMake(location.x - 20, location.y - 20);
    messeIcon.center = CGPointMake(location.x + 20, location.y + 20);
    tenkiIcon.center = CGPointMake(location.x - 10, location.y - 10);
    photoIcon.center = CGPointMake(location.x + 10, location.y + 10);
    gameIcon.center = CGPointMake(location.x + 10, location.y - 10);
    contactsIcon.center = CGPointMake(location.x - 10, location.y + 10);
    faceTimeIcon.center = CGPointMake(location.x + 20, location.y - 20);
    calendarIcon.center = CGPointMake(location.x - 20, location.y + 20);
    mapsIcon.center = CGPointMake(location.x - 15, location.y + 15);
    newsIcon.center = CGPointMake(location.x + 15, location.y - 15);
    compassIcon.center = CGPointMake(location.x - 15, location.y - 15);
    calculatorIcon.center = CGPointMake(location.x + 15, location.y + 15);
    safariIcon.center = CGPointMake(location.x - 15, location.y + 10);
    passbookIcon.center = CGPointMake(location.x + 10, location.y - 15);
    phoneIcon.center = CGPointMake(location.x - 20, location.y - 15);
    musicIcon.center = CGPointMake(location.x + 15, location.y + 20);
    notesIcon.center = CGPointMake(location.x + 10, location.y + 20);

        
    [UIView commitAnimations];
        
    [timer invalidate];
        
    }

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //-- touchesEnded処理で必要な処理
	[super touchesEnded:touches withEvent:event];
	
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:1];
    
    cameraIcon.center = CGPointMake(198,61);
    messeIcon.center = CGPointMake(47,62);
    tenkiIcon.center = CGPointMake(122,149);
    photoIcon.center = CGPointMake(273,63);
    gameIcon.center = CGPointMake(48, 328);
    contactsIcon.center = CGPointMake(122, 63);
    faceTimeIcon.center = CGPointMake(274, 237);
    calendarIcon.center = CGPointMake(46, 150);
    mapsIcon.center = CGPointMake(199, 150);
    newsIcon.center = CGPointMake(121, 327);
    compassIcon.center = CGPointMake(45,239 );
    calculatorIcon.center = CGPointMake(123,239 );
    safariIcon.center = CGPointMake(122, 522);
    phoneIcon.center = CGPointMake(198, 523);
    musicIcon.center = CGPointMake(46,524 );
    passbookIcon.center = CGPointMake(198,238 );
    notesIcon.center = CGPointMake(273, 148);
    



    
    [UIView commitAnimations];
    
    count = 0.0;

}


-(void)up{
    
    count = count + 0.01;
    
}































@end
