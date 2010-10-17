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


#import "AppController.h"
#import "StatusIconImage.h"
#import "Wordpress.h"
#import <Growl/Growl.h>

@implementation AppController

#pragma mark main

-(id)init
{
  [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys: @"http://www.example.com", @"wordpressURL", [NSNumber numberWithInt:2], @"pollInterval", @"admin", @"wordpressUsername", [NSNumber numberWithBool:YES], @"growl", nil]];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordpressError:) name:@"wordpressError" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentsUpdated:) name:@"commentsUpdated" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordpressFinishedUpdatingPreferences:) name:@"wordpressFinishedUpdatingPreferences" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newComments:) name:@"newComments" object:nil];

	return [super init];
}


- (void)awakeFromNib{
  [NSApp setMainMenu:systemMenu];
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
  [statusItem retain];
  [statusItem setHighlightMode:YES];
  [statusItem setMenu:statusMenu];
  
  [[NSURLCache sharedURLCache] setMemoryCapacity:0];
  [[NSURLCache sharedURLCache] setDiskCapacity:0];

  // fixes growl bug
  [GrowlApplicationBridge setGrowlDelegate:@""];
  
  NSBundle *bundle = [NSBundle mainBundle];
  greyImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"wordpress_grey" ofType:@"png"]];
  blueImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"wordpress_blue" ofType:@"png"]];  
  redImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"wordpress_red" ofType:@"png"]];  
  
  wordpress = [Wordpress sharedManager];

  [self setGreyIcon];
  
  [self setupTimer];
  
  if([[[NSUserDefaults standardUserDefaults] stringForKey:@"wordpressURL"] isEqual:@"http://www.example.com"])
  {
    [self showPreferences:self];
  }
  
  [self checkComments];
}

- (void)checkComments
{
  [wordpress checkComments];
}

- (void)wordpressError: (NSNotification *)notification{  
  NSLog(@"Wordpress Error Notification");
  [self clearMenu];
  
  NSString *title = [NSString stringWithFormat:@"Error : %@ (%i)", [wordpress lastErrorMessage], [wordpress faultCode]];
  
  NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
  [menuItem setTarget:self];
  [menuItem setEnabled:YES];
  [statusMenu insertItem:menuItem atIndex:3];  
  [menuItem release];
  menuItem = nil;
  
  [self setRedIcon];
}

- (void)commentsUpdated: (NSNotification *)notification{
  ZLog(@"Comments updated");  
  [self clearMenu];
  
  for (NSDictionary *comment in [wordpress comments]) {
    NSString *content = [comment objectForKey:@"content"];
    if([content length] > 30){
      content = [NSString stringWithFormat:@"%@ ...", [content substringToIndex:30]];
    }
    NSString *title = [NSString stringWithFormat:@"%@ : %@", [comment objectForKey:@"author"], content];
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
    [menuItem setTarget:self];
    [menuItem setEnabled:YES];
    [statusMenu insertItem:menuItem atIndex:3];
    [menuItem release];
    menuItem = nil;
    title = nil;
  }
  
  if([[wordpress comments] count] == 0){
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"No unapproved comments." action:nil keyEquivalent:@""];
    [menuItem setTarget:self];
    [menuItem setEnabled:YES];
    [statusMenu insertItem:menuItem atIndex:3];
    [menuItem release];
    menuItem = nil;
    [self setGreyIcon];
  }else{
    [self setBlueIconWithCommentCount:[[wordpress comments] count]];
  }
  
}

- (void)newComments: (NSNotification *)notification
{
  NSString *growlTitle;
  NSString *growlDescription;
  
  if([wordpress newComments] > 1){
    growlTitle = @"New Comments";
    growlDescription = [NSString stringWithFormat:@"%i new comments.", [wordpress newComments]];
  }else{
    growlTitle = @"New Comment"; 
    growlDescription = @"One new comment.";
  }
  if([[NSUserDefaults standardUserDefaults] integerForKey:@"growl"] == YES){
    [GrowlApplicationBridge
     notifyWithTitle:growlTitle
     description:growlDescription
     notificationName:@"New Comment"
     iconData:nil
     priority:0
     isSticky:NO
     clickContext:nil];
  }
}

- (void)clearMenu
{
  int passedSeparator = 0;
  for (NSMenuItem *item in [statusMenu itemArray]) {
    if([item isSeparatorItem]){
      passedSeparator++;
    }else if(passedSeparator == 1){
      [statusMenu removeItem:item];  
    }
  }  
}

- (IBAction)checkComments:(id)sender
{
  [self checkComments];
}

#pragma mark status

- (void)setGreyIcon
{
  [self setIcon: greyImage];
}

- (void)setRedIcon
{
  [self setIcon:redImage];
}
- (void)setBlueIconWithCommentCount:(int)count
{
  [self setBlueIconWithString:[[NSNumber numberWithInt:count] stringValue]];
}

- (void)setBlueIconWithString:(NSString *)text;
{
  NSImage *newStatusImage = [StatusIconImage makeIconWIthImage:blueImage string:text];
  [newStatusImage retain];
  [self setIcon: newStatusImage];
}
  
  
- (void)setIcon:(NSImage *)image
{
  NSImage *oldImage = [statusItem image];
  if(![oldImage isEqual:image]){
    [statusItem setImage:image];
    if(![oldImage isEqual:greyImage] && ![oldImage isEqual:redImage]){
     [oldImage release]; 
    }
  }
  
}

#pragma mark prefs

- (IBAction)showPreferences:(id)sender
{
	// Is preferenceController nil?
	if (!preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	// NSLog(@"Showing %@", preferenceController);
  [NSApp activateIgnoringOtherApps:YES];
	[preferenceController showWindow:self];
}

- (void)wordpressFinishedUpdatingPreferences: (NSNotification *)notification
{
  //DEBUG
  ZLog(@"AppController Prefs Updated");
  
  [self setupTimer];
  [self checkComments];
}

#pragma mark misc

- (IBAction)showAboutWindow:(id)sender 
{
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp orderFrontStandardAboutPanel:self];
}

- (IBAction)quit:(id)sender 
{
	[NSApp terminate:sender];
}

- (IBAction)openComments:(id)sender
{
  @try {
    NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"wordpressURL"];
    if([urlString length] != 0){
      NSURL *url = [NSURL URLWithString:@"wp-admin/edit-comments.php" relativeToURL:[NSURL URLWithString:urlString]];
      [[NSWorkspace sharedWorkspace] openURL:url];
    }
  } @catch ( NSException *e ) {} 
}

- (IBAction)openHelp:(id)sender
{
  NSURL *url = [NSURL URLWithString:@"http://paulwilliam.github.com/Wordpress-Notifier/help.php.html"];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)setupTimer
{
  int timerInterval = [[NSUserDefaults standardUserDefaults] integerForKey:@"pollInterval"]*60;
  
  
  if([timer timeInterval] != timerInterval){
    ZLog(@"New Timer : %i", timerInterval );
    [timer release];    
    timer = [[NSTimer scheduledTimerWithTimeInterval: timerInterval
                                              target: self
                                            selector: @selector(checkComments:)
                                            userInfo: nil
                                             repeats: YES] retain];
  }
  
    
}


@end
