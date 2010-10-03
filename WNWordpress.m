//
//  WNWordpress.m
//  Wordpress Command Line
//
//  Created by Paul William on 9/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WNWordpress.h"

@implementation WNWordpress

@synthesize url;
@synthesize username;
@synthesize password;

- (id)initWithURL:(NSURL *)_url username:(NSString *)_username  password:(NSString *)_password
{
  [super self];
  self.url = _url;
  self.username = _username;
  self.password = _password;
  return self;
}

- (void)checkComments
{
  XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost: self.url];

  [request setMethod: @"wp.getComments" withParameters: [NSDictionary dictionaryWithObjectsAndKeys: @"held", @"status", self.username, @"username", self.password, @"password", nil]];
  [request setUserAgent: @"Wordpress Notifier"];
	
  XMLRPCConnection *connection = [[XMLRPCConnection alloc] initWithXMLRPCRequest: request delegate: self];
  
  if (connection == nil) {
    NSLog(@"Connection failed.");
  }
  
  [connection retain];
}

- (void)connection: (XMLRPCConnection *)connection didReceiveResponse:(XMLRPCResponse *)response forMethod: (NSString *)method {
  NSLog(@"Response Method: %@", method);
  if (response != nil) {
    if ([response isFault]) {
      //NSLog(@"Fault code: %@", [response faultCode]);
    } else {
      //NSLog(@"Response object: %@", [response responseObject]);
    }
    
    //NSLog(@"Response source: %@", [response responseSourceXML]);
  } else {
    //NSLog(@"Unable to parse response.");
  }
  
  //NSLog(@"Class: %@", [[response responseObject] class]);
  
  for(NSDictionary *comment in [response responseObject]){
    NSLog(@"%@", [comment objectForKey:@"link"]); 
  }
  
  [response release];
  [connection release];
}

- (void)connection: (XMLRPCConnection *)connection didFailWithError: (NSError *)error forMethod: (NSString *)method{
  NSLog(@"Error: %@", [error localizedDescription]);
   
}


@end
