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


#import "PreferenceController.h"


@implementation PreferenceController

- (id)init
{
	if (![super initWithWindowNibName:@"Preferences"]){
		return nil;
  }
  
  [login setState:NSOffState];
	
	return self;
}

- (IBAction)checkSettings:(id)sender
{
  ZLog(@"Check settings called");
}

- (void)toggleStartOnLogin
{
}

- (void)savePreferences
{
  EMKeychainProxy *keychainProxy = [EMKeychainProxy sharedProxy];
  EMGenericKeychainItem *keychain = [keychainProxy genericKeychainItemForService:@"WordpressNotifier" withUsername:[username stringValue]];
  
  if(keychain == nil && [[username stringValue] length] != 0){
    [[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:@"WordpressNotifier" withUsername:[username stringValue] password:[password stringValue]];
  }else if(keychain && [[username stringValue] length] != 0){
    [keychain setUsername:[username stringValue]];
    [keychain setPassword:[password stringValue]];
  }
  
  NSString *path = [[NSBundle mainBundle] bundlePath];
  if([login state] == NSOnState){
    ZLog(@"Autologin on");
    if([self autoLoginEnabled] == NO){
      [UKLoginItemRegistry addLoginItemWithPath:path hideIt:NO];
      ZLog(@"Adding login item");
    }
  }else{ 
    if([self autoLoginEnabled] == YES){
      [UKLoginItemRegistry removeLoginItemWithPath:path];
      ZLog(@"removing login item");
    }
  }
  
  [defaultsController save:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"preferencesUpdated" object:self];
    
}

- (void)loadPreferences
{
  [login setState:([self autoLoginEnabled]? NSOnState : NSOffState)];

  EMKeychainProxy *keychainProxy = [EMKeychainProxy sharedProxy];
  EMGenericKeychainItem *keychain = [keychainProxy genericKeychainItemForService:@"WordpressNotifier" withUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"wordpressUsername"]];
  if(keychain){
    [username setStringValue: [keychain username]];
    [password setStringValue: [keychain password]];
  }
}

- (BOOL)autoLoginEnabled{
  NSString *path = [[NSBundle mainBundle] bundlePath];
  if([UKLoginItemRegistry indexForLoginItemWithPath:path] == -1){
    return NO;
  }else{
    return YES;
  }
}

- (void)windowWillClose:(NSNotification *)notification
{
  [self savePreferences];
  ZLog(@"Prefs closing");
}

- (IBAction)showWindow:(id)sender
{
  [[self window] center];
  [super showWindow:sender];
  [self loadPreferences];
}
@end
