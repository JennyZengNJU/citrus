//
//  RoomBookViewController.m
//  EWS
//
//  Created by Tianhui  on 6/22/16.
//  Copyright © 2016 Tianhui . All rights reserved.
//

#import "RoomBookViewController.h"
#import "ASIHTTPRequest.h"

@interface RoomBookViewController ()



@end


@implementation RoomBookViewController

EventManager *eventManager4RoomBook;


- (void)viewDidLoad {
    [super viewDidLoad];
    eventManager4RoomBook = [[EventManager alloc]init];
    
    //[self RoomBookRequest];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)book{
    
    NSLog(@"this method was for book room");
//    NSLog(self.roomName.text);
//    NSLog(@"tianhui is good");
//    NSDate *start = [self.startTime date];//获取选取时间
//    NSString *date = [[NSString alloc] initWithFormat:@"你选择了：%@",start];
//    
//    NSDate *end = [self.endTime date];
//    NSString *datend = [[NSString alloc] initWithFormat:@"choose:%@",end];
//    NSLog(@"start date is %@,end date is %@",date,datend);
//    
//    NSLog(@"attends are %@",self.attends.text);
//    NSLog(@"reminder for the meeting %@",self.reminder.text);
    [eventManager4RoomBook RoomBookRequest:self.roomName startTime:self.startTime endTime:self.endTime attends:self.attends reminder:self.reminder];
    
}

//- (IBAction)roomBook:(UIButton *)sender {
//    NSLog(@"bad girl");
//    NSLog(self.roomName.text);
//    NSLog(@"tianhui is good");
//    NSDate * selected = [self.startTime date];//获取选取时间
//    
//    NSLog(@"date is %@",date);
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
