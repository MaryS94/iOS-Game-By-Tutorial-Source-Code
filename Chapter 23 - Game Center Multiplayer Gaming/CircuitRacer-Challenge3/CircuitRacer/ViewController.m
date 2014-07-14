//
//  ViewController.m
//  CircuitRacer
//
//  Created by Main Account on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "AnalogControl.h"
#import "MultiplayerNetworking.h"

@import CoreMotion;

@interface ViewController()
@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@end

@implementation ViewController {
  SKView *_skView;
  AnalogControl *_analogControl;
  MyScene *_scene;
  CMMotionManager *_motionManager;
  
  MultiplayerNetworking *_networkEngine;
  UITapGestureRecognizer *_tapRecognizer; /*Multiplayer challenge 2*/
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  if (!_skView) {
    _skView =
     [[SKView alloc] initWithFrame:self.view.bounds];
    
    MyScene *scene;
    if (_noOfCars) {
      scene = [[MyScene alloc] initWithSize:_skView.bounds.size
                               numberOfCars:_noOfCars
                                      level:CRLevelEasy];
    } else {
      scene = [[MyScene alloc] initWithSize:_skView.bounds.size
                                    carType:self.carType
                                      level:self.levelType];
    }
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [_skView presentScene:scene];
    [self.view addSubview:_skView];
    [self.view sendSubviewToBack:_skView];
      
    _scene = scene;
    
    __weak ViewController *weakSelf = self;
    _scene.gameOverBlock = ^(BOOL didWin){
      [weakSelf gameOverWithWin:didWin];
    };
    
    _scene.gameEndedBlock = ^(){
      [weakSelf goBack:nil];
    };
      
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.05;
    [_motionManager startAccelerometerUpdates];
    _scene.motionManager = _motionManager;
      
    if (_noOfCars > 1) {
        
      /*Multiplayer challenge 2*/
      _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)]; /*Multiplayer challenge 2*/
      [self.view addGestureRecognizer:_tapRecognizer];
      /*Multiplayer challenge 2*/
        
      _pauseButton.hidden = YES;
      _networkEngine = [[MultiplayerNetworking alloc] init];
      _networkEngine.delegate = _scene;
      _scene.networkingEngine = _networkEngine;
      [[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:(int)_noOfCars
                                                        maxPlayers:(int)_noOfCars
                                          presentingViewController:self
                                                          delegate:_networkEngine];
    }
  }
}
 
- (void)dealloc {
  [_analogControl removeObserver:_scene 
                      forKeyPath:@"relativePosition"];
  [_motionManager stopAccelerometerUpdates];
  _motionManager = nil;
}

/*Multiplayer challenge 2*/
- (void)tapDetected
{
  [_scene tap];
}
/*Multiplayer challenge 2*/

- (void)gameOverWithWin:(BOOL)didWin
{
  UIAlertView *alert = 
    [[UIAlertView alloc] 
      initWithTitle:didWin ? @"You won!" : @"You lost"
      message:@"Game Over"
      delegate:nil
      cancelButtonTitle:nil
      otherButtonTitles:nil];
  [alert show];
  
  [self performSelector:@selector(goBack:) withObject:alert 
    afterDelay:3.0];
}

- (void)goBack:(UIAlertView*)alert
{
 [alert dismissWithClickedButtonIndex:0 animated:YES];
 [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)showInGameMenu:(id)sender
{
  UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Game Menu" message:@"What would you like to do?" delegate:self cancelButtonTitle:@"Resume level" otherButtonTitles:@"Go to menu", nil];
  [alertView show];
  _scene.paused = YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  _scene.paused = NO;
  if (buttonIndex == alertView.firstOtherButtonIndex) {
    [self gameOverWithWin:NO];
  }
}

@end