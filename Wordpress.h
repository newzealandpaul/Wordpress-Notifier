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


#import <Cocoa/Cocoa.h>
#import <XMLRPC/XMLRPC.h>
#import "PreferenceController.h"

#define WP_ERROR_BAD_LOGIN 403
#define WP_ERROR_UNSUPPORTED -32601
#define WP_ERROR_XMLRPC 405
#define WP_ERROR_404 404
#define WP_ERROR_URL -2
#define WP_ERROR_NONE 0
#define WP_ERROR_UNKNOWN -1
#define WP_ERROR_CONNECTION -3
#define WP_ERROR_PREFS_NOT_SET -4

@interface Wordpress : NSObject {
  NSURL *url;
  NSString *username;
  NSString *password;
  NSString *lastErrorMessage;
  NSInteger faultCode;
  NSArray *comments;
  NSArray *previousComments;
  NSInteger newComments;
}

+ (Wordpress*)sharedManager;

- (void)updatePreferences: (NSNotification *)notification;
- (void)updatePreferences;

- (NSString *)lastErrorMessage;
- (NSInteger)faultCode;
- (NSInteger)newComments;

- (void)setErrorMessage:(NSString *)message;
- (void)setErrorMessage:(NSString *)message withFaultCode:(NSInteger)code;
- (void)notifyError;
- (void)processReponse:(NSObject *)object;
- (void)setComments:(NSArray *)_comments;
- (NSArray *)comments;
- (NSArray *)previousComments;
- (void)checkComments;
- (void)checkCommentsForNewComments;
- (void)connection: (XMLRPCConnection *)connection didReceiveResponse:(XMLRPCResponse *)response forMethod: (NSString *)method;
- (void)connection: (XMLRPCConnection *)connection didReceiveResponse:(XMLRPCResponse *)response forMethod: (NSString *)method;

@end
