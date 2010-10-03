//
//  WNWordpress.h
//  Wordpress Command Line
//
//  Created by Paul William on 9/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XMLRPC/XMLRPC.h>

@interface WNWordpress : NSObject{
  @private NSURL *url;
  @private NSString *username;
  @private NSString *password;
}
@property(retain) NSURL *url;
@property(retain) NSString *username;
@property(retain) NSString *password;

- (id)initWithURL:(NSURL *)url username:(NSString *)username  password:(NSString *)password;
- (void)checkComments;

- (void)connection: (XMLRPCConnection *)connection didReceiveResponse:(XMLRPCResponse *)response forMethod: (NSString *)method;

@end
