//
//  RoomBookViewController.h
//  EWS
//
//  Created by Tianhui  on 6/22/16.
//  Copyright © 2016 Tianhui . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventManager.h"

@interface RoomBookViewController : UIViewController

@property (weak,nonatomic) UITextView *resultText;
//@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UITextField *roomName;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTime;
@property (weak, nonatomic) IBOutlet UITextField *attends;
@property (weak, nonatomic) IBOutlet UITextField *reminder;

-(void)RoomBookRequest;

@end
