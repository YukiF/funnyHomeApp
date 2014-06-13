//
//  ViewController.h
//  funnyHome
//
//  Created by Yuki.F on 2014/03/24.
//  Copyright (c) 2014年 Yuki Futagami. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController :  UIViewController<UIGestureRecognizerDelegate>{
                                         //上　ジェスチャー認識のデリゲート宣言
    //カメラロールからの写真
    IBOutlet UIImageView *haikei;
    
    IBOutlet UIImageView *cameraIcon;
    IBOutlet UIImageView *messeIcon;
    IBOutlet UIImageView *photoIcon;
    IBOutlet UIImageView *tenkiIcon;
    IBOutlet UIImageView *gameIcon;
    IBOutlet UIImageView *contactsIcon;
    IBOutlet UIImageView *faceTimeIcon;
    IBOutlet UIImageView *calendarIcon;
    IBOutlet UIImageView *mapsIcon;
    IBOutlet UIImageView *newsIcon;
    IBOutlet UIImageView *compassIcon;
    IBOutlet UIImageView *calculatorIcon;
    IBOutlet UIImageView *passbookIcon;
    IBOutlet UIImageView *safariIcon;
    IBOutlet UIImageView *musicIcon;
    IBOutlet UIImageView *phoneIcon;
    IBOutlet UIImageView *notesIcon;
    
    float count; //アニメーションの判定
    NSTimer *timer;
    
    /* -- 加速度センサー --*/
    UIAccelerationValue speedX_;
    UIAccelerationValue speedY_;

}

-(IBAction)settei;
//-(void)panAction:(UIPanGestureRecognizer *)sender;  //ジェスチャーに必要なやつ
-(void)up;

@end
