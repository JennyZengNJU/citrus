//
//  EventManager.m
//  room
//
//  Created by lcm_ios on 16/6/24.
//  Copyright © 2016年 lcm_ios. All rights reserved.
//

#import "EventManager.h"
#import "ASIHTTPRequest.h"

@implementation EventManager


- (NSArray *)fetchEvents
{
    NSArray *resultEvents = nil;
    self.resultArray = [[NSMutableArray alloc]init];
    [self getFolder];

    return resultEvents;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"Finished : %@",[request responseString]);
    self.resultText = [request responseString];
    if ([self.resultText rangeOfString:@"m:GetFolderResponseMessage"].location != NSNotFound) {
        [self findItem];
    } else if ([self.resultText rangeOfString:@"m:FindItemResponseMessage"].location != NSNotFound) {
        [self parseCalendar];
        NSDictionary *userInfo = self.resultArray ? @{DataAvailableContext : self.resultArray} : nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:DataAvailableNotification
                                                            object:self userInfo:userInfo];
    }
}

- (void)parseCalendar {
    NSString *responseString = self.resultText;
     while ([responseString rangeOfString:@"<t:CalendarItem>"].location != NSNotFound)
    {
        NSRange rangeSubjectStart = [responseString rangeOfString:@"<t:Subject>"];
        NSRange rangeSubjectEnd = [responseString rangeOfString:@"</t:Subject>"];
        NSRange rangeStartStart = [responseString rangeOfString:@"<t:Start>"];
        NSRange rangeStartEnd = [responseString rangeOfString:@"</t:Start>"];
        NSRange rangeEndStart = [responseString rangeOfString:@"<t:End>"];
        NSRange rangeEndEnd = [responseString rangeOfString:@"</t:End>"];
        
        NSRange rangeSubject = NSMakeRange(rangeSubjectStart.location + rangeSubjectStart.length, rangeSubjectEnd.location  - rangeSubjectStart.location - rangeSubjectStart.length);
        NSString *subject = [responseString substringWithRange:rangeSubject];
        
        NSRange rangeStart = NSMakeRange(rangeStartStart.location + rangeStartStart.length, rangeStartEnd.location  - rangeStartStart.location - rangeStartStart.length);
        NSString *startTime = [responseString substringWithRange:rangeStart];
        
        NSRange rangeEnd = NSMakeRange(rangeEndStart.location + rangeEndStart.length, rangeEndEnd.location  - rangeEndStart.location - rangeEndStart.length);
        NSString *endTime = [responseString substringWithRange:rangeEnd];
        
        NSRange calendarItemEnd = [responseString rangeOfString:@"</t:CalendarItem>"];
        NSString *subString = [responseString substringFromIndex:(calendarItemEnd.length + calendarItemEnd.location)];
        responseString = subString;
        NSString *result = [[[[startTime stringByAppendingString:@"-"] stringByAppendingString:endTime] stringByAppendingString:@":"] stringByAppendingString:subject];
        NSLog(@"zzzz%@",result);
        [self.resultArray addObject:subject];
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Failed %@ with code %ld and with userInfo %@", [error domain], (long)[error code], [error userInfo]);
}

// build SOAP request and send asynchronous
- (void)doSOAPRequest: (NSString *)soapMessage {
    NSURL *url = [NSURL URLWithString: EWS_ADDRESS];
    ASIHTTPRequest *theRequest =  [ASIHTTPRequest requestWithURL:url];
    
    [theRequest addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addRequestHeader:@"Content-Length" value:msgLength];
    [theRequest setRequestMethod:@"POST"];
    [theRequest appendPostData: [soapMessage dataUsingEncoding: NSUTF8StringEncoding]];
    [theRequest setDefaultResponseEncoding: NSUTF8StringEncoding];
    
    [theRequest setAuthenticationScheme: (NSString *) kCFHTTPAuthenticationSchemeBasic];
    [theRequest setUsername: @"zhenz"];
    [theRequest setPassword: @"Citrix@123"];
    [theRequest setShouldPresentCredentialsBeforeChallenge: YES];

    
    [theRequest setDelegate: self];
    
    [theRequest startAsynchronous];
}


- (void)RoomBookRequest:(UITextField *)roomName
              startTime:(UIDatePicker *)startTime
                endTime:(UIDatePicker *)endTime
                attends:(UITextField *)attends
               reminder:(UITextField *)reminder {
    NSLog(@"okokok");
    NSString *part1 = [NSString stringWithFormat:
                       @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                       "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
                       "                     xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\n"
                       "                     xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\n"
                       "                    xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
                       "<soap:Body>\n"
                       "<CreateItem xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\n"
                       "                    xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\"\n"
                       "                    SendMeetingInvitations=\"SendToAllAndSaveCopy\" >\n"
                       "<SavedItemFolderId>\n"
                       "<t:DistinguishedFolderId Id=\"calendar\"/>\n"
                       "</SavedItemFolderId>\n"
                       "<Items>\n"
                       "<t:CalendarItem xmlns=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
                       
                       ];
    
    
    
    part1 = [part1 stringByAppendingString:@"<ReminderMinutesBeforeStart>"];
    
    part1 = [part1 stringByAppendingString:reminder.text];
    part1 = [part1 stringByAppendingString:@"</ReminderMinutesBeforeStart>\n"];
    part1 = [part1 stringByAppendingString:@"<Start>"];
    NSDate *start = [startTime date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *date = [dateFormatter stringFromDate:start];
    
    //NSString *date = [[NSString alloc] initWithFormat:@"%@",start];
    date = [date stringByReplacingOccurrencesOfString:@" "
                                           withString:@"T"];
    
    part1 = [part1 stringByAppendingString:date];
    part1 = [part1 stringByAppendingString:@"</Start>\n"];
    part1 = [part1 stringByAppendingString:@"<End>"];
    NSDate *end = [endTime date];
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *datend = [dateFormatter stringFromDate:end];
    datend = [datend stringByReplacingOccurrencesOfString:@" "
                                               withString:@"T"];
    
    NSLog(@"start time %@, end time %@",date, datend);
    //NSString *datend = [[NSString alloc] initWithFormat:@"%@",end];
    part1 = [part1 stringByAppendingString:datend];
    part1 = [part1 stringByAppendingString:@"</End>\n"];
    //
    part1 = [part1 stringByAppendingString:@"<Location>"];
    part1 = [part1 stringByAppendingString:roomName.text];
    
    
    part1 = [part1 stringByAppendingString:@"</Location>\n<RequiredAttendees>\n<Attendee>\n<Mailbox>\n<EmailAddress>"];
    part1 = [part1 stringByAppendingString:attends.text];
    part1 = [part1 stringByAppendingString:
             @"</EmailAddress>\n</Mailbox>\n</Attendee>\n</RequiredAttendees>\n</t:CalendarItem>\n</Items>\n</CreateItem>\n</soap:Body>\n</soap:Envelope>"
             ];
    
    
    NSLog(@"tianhui is a good girl");
    NSLog(@"part1 %@:",part1);
    //    NSString *bookroom = [NSString stringWithFormat:
    //                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    //                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
    //                          "                     xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\n"
    //                          "                     xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\n"
    //                          "                    xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
    //                          "<soap:Body>\n"
    //                          "<CreateItem xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\n"
    //                          "                    xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\"\n"
    //                          "                    SendMeetingInvitations=\"SendToAllAndSaveCopy\" >\n"
    //                          "<SavedItemFolderId>\n"
    //                          "<t:DistinguishedFolderId Id=\"calendar\"/>\n"
    //                          "</SavedItemFolderId>\n"
    //                          "<Items>\n"
    //                          "<t:CalendarItem xmlns=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
    //                          //"<Subject>Planning Meeting</Subject>\n"
    //                          //"<Body BodyType=\"Text\">this is send from meeting room app. haha</Body>\n"
    //                          //"<ReminderIsSet>true</ReminderIsSet>\n"
    //                          "<ReminderMinutesBeforeStart>60</ReminderMinutesBeforeStart>\n"
    //                          "<Start>2016-06-30T20:30:00</Start>\n"
    //                          "<End>2016-06-30T21:00:00</End>\n"
    //                          //"<IsAllDayEvent>false</IsAllDayEvent>\n"
    //                          //"<LegacyFreeBusyStatus>Busy</LegacyFreeBusyStatus>\n"
    //                          "<Location>_Nanjing_C3_4.123_Lake_Como@citrix.com</Location>\n"
    //                          "<RequiredAttendees>\n"
    //                          "<Attendee>\n"
    //                          "<Mailbox>\n"
    //                          "<EmailAddress>tianhui.ji@citrix.com</EmailAddress>\n"
    //                          "</Mailbox>\n"
    //                          "</Attendee>\n"
    //                          "</RequiredAttendees>\n"
    //                          "</t:CalendarItem>\n"
    //                          "</Items>\n"
    //                          "</CreateItem>\n"
    //                          "</soap:Body>\n"
    //                          "</soap:Envelope>"
    //                          ];
    //    
    [self doSOAPRequest:part1];
    //
}


- (void)getFolder {
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n"
                             "               xmlns:m=\"http://schemas.microsoft.com/exchange/services/2006/messages\" \n"
                             "               xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\" \n"
                             "               xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "  <soap:Header>\n"
                             "    <t:RequestServerVersion Version=\"Exchange2010\" />\n"
                             "  </soap:Header>\n"
                             "  <soap:Body>\n"
                             "    <m:GetFolder>\n"
                             "      <m:FolderShape>\n"
                             "        <t:BaseShape>IdOnly</t:BaseShape>\n"
                             "      </m:FolderShape>\n"
                             "      <m:FolderIds>\n"
                             "        <t:DistinguishedFolderId Id=\"calendar\">\n"
                             "          <t:Mailbox>\n"
                             "            <t:EmailAddress>_Nanjing_C3_1.007_Galaxy@citrix.com</t:EmailAddress>\n"
                             "          </t:Mailbox>\n"
                             "        </t:DistinguishedFolderId>\n"
                             "      </m:FolderIds>\n"
                             "    </m:GetFolder>\n"
                             "  </soap:Body>\n"
                             "</soap:Envelope>"
                             ];
    
    [self doSOAPRequest: soapMessage];
}

- (void)getFolderResponse {
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n"
                             "               xmlns:m=\"http://schemas.microsoft.com/exchange/services/2006/messages\" \n"
                             "               xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\" \n"
                             "               xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "  <soap:Header>\n"
                             "    <t:RequestServerVersion Version=\"Exchange2010\" />\n"
                             "  </soap:Header>\n"
                             "  <soap:Body>\n"
                             "    <m:GetFolderResponse xmlns:m=\"http://schemas.microsoft.com/exchange/services/2006/messages\"xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
                             "      <m:ResponseMessages>\n"
                             "        <m:GetFolderResponseMessage ResponseClass=\"Success\">\n"
                             "          <m:ResponseCode>NoError</m:ResponseCode>\n"
                             "          <m:Folders>\n"
                             "            <t:CalendarFolder>\n"
                             "              <t:FolderId Id=\"QMkAGVhMDk0ZTVmLTYyZjItNDA0Ny1hZjE2LWMzN2MxMzYxZTczMQAuAAADu4595GA3Rketc7D8wigZkAEAfw0eyqsYaUGyYLpjwRSmNwAAAb1HPQAAAA==\" ChangeKey=\"AgAAABYAAADY9YrqyjJtRLCXrlg2TfwJAAB3KU4F\" />\n"
                             "            </t:CalendarFolder>\n"
                             "          </m:Folders>\n"
                             "        </m:GetFolderResponseMessage>\n"
                             "      </m:ResponseMessages>\n"
                             "    </m:GetFolderResponse>\n"
                             "  </soap:Body>\n"
                             "</soap:Envelope>"
                             ];
    
    [self doSOAPRequest: soapMessage];
}


- (void)findItem {
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n"
                             "               xmlns:m=\"http://schemas.microsoft.com/exchange/services/2006/messages\" \n"
                             "               xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\" \n"
                             "               xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "  <soap:Header>\n"
                             "    <t:RequestServerVersion Version=\"Exchange2010\" />\n"
                             "  </soap:Header>\n"
                             "  <soap:Body>\n"
                             "    <m:FindItem Traversal=\"Shallow\">\n"
                             "      <m:ItemShape>\n"
                             "        <t:BaseShape>IdOnly</t:BaseShape>\n"
                             "        <t:AdditionalProperties>\n"
                             "          <t:FieldURI FieldURI=\"item:Subject\" />\n"
                             "          <t:FieldURI FieldURI=\"calendar:Start\" />\n"
                             "          <t:FieldURI FieldURI=\"calendar:End\" />\n"
                             "        </t:AdditionalProperties>\n"
                             "      </m:ItemShape>\n"
                             "      <m:CalendarView MaxEntriesReturned=\"5\" StartDate=\"2016-06-21T17:30:24.127Z\" EndDate=\"2016-06-30T17:30:24.127Z\" />\n"
                             "      <m:ParentFolderIds>\n"
                             "        <t:FolderId Id=\"AQMkAGVhMDk0ZTVmLTYyZjItNDA0Ny1hZjE2LWMzN2MxMzYxZTczMQAuAAADu4595GA3Rketc7D8wigZkAEAfw0eyqsYaUGyYLpjwRSmNwAAAb1HPQAAAA==\" ChangeKey=\"AgAAABYAAADY9YrqyjJtRLCXrlg2TfwJAAB3KU4F\" />\n"
                             "      </m:ParentFolderIds>"
                             "    </m:FindItem>"
                             "  </soap:Body>\n"
                             "</soap:Envelope>"
                             ];
    
    
    [self doSOAPRequest: soapMessage];
}


@end
