// Wordpress Notifier for Mac (wpnotifier) - Mac OS X Status Bar notifications for Wordpress Blogs.
// Copyright (C) 2010 Paul William

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


#import "Wordpress.h"

@implementation Wordpress

static Wordpress *sharedWordpressManager = nil;

# pragma mark Singleton

+ (Wordpress*)sharedManager
{
  @synchronized(self) {
    if (sharedWordpressManager == nil) {
      [[self alloc] init]; // assignment not done here
    }
  }
  return sharedWordpressManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
  @synchronized(self) {
    if (sharedWordpressManager == nil) {
      sharedWordpressManager = [super allocWithZone:zone];
      return sharedWordpressManager;  // assignment and return on first allocation
    }
  }
  return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (id)retain
{
  return self;
}

- (unsigned)retainCount
{
  return UINT_MAX;  //denotes an object that cannot be released
} 

- (void)release
{
  //do nothing
}

- (id)autorelease
{
  return self;
}

#pragma mark -

- (id)init
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePreferences:) name:@"preferencesUpdated" object:nil];
  [self updatePreferences];
  return [super init];
}

#pragma mark Wordpress

- (void)updatePreferences
{
  username = [[NSUserDefaults standardUserDefaults] objectForKey:@"wordpressUsername"];
  NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"wordpressURL"];
  
  if(url){
    [url release];
    url = nil;
  }

  @try {
    url = [NSURL URLWithString:@"./xmlrpc.php" relativeToURL:[NSURL URLWithString:urlString]];
    [url retain];
  } @catch ( NSException *e ) {}
  
  if(url == nil){
    [self setErrorMessage:@"Invalid URL." withFaultCode:WP_ERROR_URL];
  }
  
  #ifdef RELEASE_MODE
    EMKeychainProxy *keychainProxy = [EMKeychainProxy sharedProxy];
    EMGenericKeychainItem *keychain = [keychainProxy genericKeychainItemForService:@"WordpressNotifier" withUsername:username];
    if(keychain){
      password = [keychain password];
    }
  #else
    #include "password"
  #endif

  ZLog(@"updated Wordpress object prefs");
  [[NSNotificationCenter defaultCenter] postNotificationName:@"wordpressFinishedUpdatingPreferences" object:self];
}

- (void)updatePreferences: (NSNotification *)notification
{
  [self updatePreferences];
}

- (NSString *)lastErrorMessage
{
  return lastErrorMessage;
}

- (NSInteger)faultCode
{
  return faultCode;
}

- (void)setErrorMessage:(NSString *)message
{
  lastErrorMessage = message;
  faultCode = WP_ERROR_UNKNOWN;
}

- (void)setErrorMessage:(NSString *)message withFaultCode:(NSInteger)code
{
  lastErrorMessage = message;
  faultCode = code;
}

- (void)notifyError
{
  NSLog(@"Wordpress Notifier Error: '%@' : %i", lastErrorMessage, faultCode);
  [[NSNotificationCenter defaultCenter] postNotificationName:@"wordpressError" object:self];
}

- (void)processReponse:(NSObject *)object
{
  BOOL isError = NO;
  
  if([[object className] isEqual:@"NSCFArray"] == YES){
    for (NSObject *comment in (NSArray *)object) {
      if([[comment className] isEqual:@"NSCFDictionary"] == NO){
        isError = YES; 
      }
    }
  }else{
    isError = YES;
  }
  
  if(isError == NO){
    [self setComments:(NSArray *)object];    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentsUpdated" object:self];
    if(previousComments){
      [self checkCommentsForNewComments];
    }
  }else{
    [self setErrorMessage:@"Unknown Schema Error"];
    [self setComments:nil];
    [self notifyError];
  }
  
}

- (void)setComments:(NSArray *)_comments
{
  [previousComments release];
  previousComments = comments;
  [_comments retain];
  comments = _comments;
}

- (void)checkCommentsForNewComments
{
  NSInteger newCommentsCount = 0;
  for (NSDictionary *comment in comments) {
    BOOL foundComment = NO;
    for (NSDictionary *previousComment in previousComments) {
      if([[previousComment objectForKey:@"content"] isEqual:[comment objectForKey:@"content"]]){
        foundComment = YES;
      }
    }    
    if(foundComment == NO){
      newCommentsCount++;
    }    
  }
  newComments = newCommentsCount;
  if(newCommentsCount > 0){
    // DEBUG
    ZLog(@"New comments: %i", newCommentsCount);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newComments" object:self];
  }
}

- (NSArray *)comments
{
  return comments; 
}

- (NSArray *)previousComments
{
  return previousComments; 
}

- (NSInteger)newComments{
  return newComments;
}

#pragma mark XMLRPC

- (void)checkComments
{
  XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost: url];
  
  [request setMethod: @"wp.getComments" withParameters: [NSArray arrayWithObjects: [NSNumber numberWithInt:0], username, password, [NSDictionary dictionaryWithObjectsAndKeys: @"hold", @"status", nil], nil]];
  [request setUserAgent: @"wpnotifier"];
	
  XMLRPCConnection *connection = [[XMLRPCConnection alloc] initWithXMLRPCRequest: request delegate: self];
  
  if (connection == nil) {
    [self setErrorMessage:@"Unknown XML-RPC error."];
    [self notifyError];
  }else{
    //[connection retain];
  }
  
}

- (void)connection: (XMLRPCConnection *)connection didReceiveResponse:(XMLRPCResponse *)response forMethod: (NSString *)method {
  BOOL isFault = NO;
  
  ZLog(@"Response Method: %@", method);
  if (response != nil) {
    if ([response isFault]) {
      switch ([[response faultCode] intValue])
      {
        case WP_ERROR_BAD_LOGIN:
          [self setErrorMessage: @"Bad username/password combination." withFaultCode:WP_ERROR_BAD_LOGIN];
          break;
        case WP_ERROR_UNSUPPORTED:
          [self setErrorMessage: @"Wordpress version unsupported. Please upgrade to Wordpress 2.7." withFaultCode:WP_ERROR_UNSUPPORTED];
          break;
        case WP_ERROR_XMLRPC:
          [self setErrorMessage: @"Wordpress XML-RPC support has not enabled (See Help)." withFaultCode:WP_ERROR_XMLRPC];
          break;          
        default:
          [self setErrorMessage: @"Unknown error."];
          break;
      }
      isFault = YES;
      [self notifyError];
      ELog(@"Response source: %@", [response responseSourceXML]);
      //NSLog(@"Fault code: %@", [response faultCode]);
    } else {
      if(isFault == NO){
        [self processReponse: [response responseObject]];
      }
      ZLog(@"Response object: %@", [response responseObject]);
    }
    // could be useful for debugging
    //NSLog(@"Response source: %@", [response responseSourceXML]);
  } else {
    [self setErrorMessage: @"Unknown Error: Unable to parse XML response."];
    ELog(@"Text: %S",[response responseSourceXML ]);
    [self notifyError];
    //NSLog(@"Unable to parse response.");
  }
    
  [response release];
  [connection release];
}

- (void)connection: (XMLRPCConnection *)connection didFailWithError: (NSError *)error forMethod: (NSString *)method{
  // NSLog(@"Error Code: %i", [error code]);
  if([error code] == 404){
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"wordpressURL"] isEqual:@"http://www.example.com"])
    {
      [self setErrorMessage: @"Preferences not set." withFaultCode:WP_ERROR_PREFS_NOT_SET];
    }else{   
      [self setErrorMessage: @"Wordpress URL is incorrect. HTTP 404 page not found error." withFaultCode:WP_ERROR_404];
    }
  }else{
      [self setErrorMessage:[error localizedDescription] withFaultCode:WP_ERROR_CONNECTION];
  }
  [self notifyError];
  [connection release];
}

@end
