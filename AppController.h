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
#import "PreferenceController.h"
#import "Wordpress.h"

@interface AppController : NSObject {
  // The Status Icon
  NSStatusItem *statusItem;
  // The menu attatched to the above
  IBOutlet NSMenu *statusMenu;
  // the timer to check for new comments
  NSTimer *timer;  
  // for copying and pasting
  IBOutlet NSMenu *systemMenu;
  // prefs
  PreferenceController *preferenceController;
  //icons
  NSImage *blueImage;
  NSImage *blueImageWithCount;
  NSImage *greyImage;
  NSImage *redImage;
  
  Wordpress *wordpress;
}

// main
- (void)awakeFromNib;
- (IBAction)checkComments:(id)sender;
- (void)wordpressError: (NSNotification *)notification;
- (void)commentsUpdated: (NSNotification *)notification;
- (void)newComments: (NSNotification *)notification;
- (void)wordpressFinishedUpdatingPreferences: (NSNotification *)notification;
- (void)clearMenu;
- (void)checkComments;

// status item
- (void)setGreyIcon;
- (void)setRedIcon;
- (void)setBlueIconWithCommentCount:(int)count;
- (void)setBlueIconWithString:(NSString *)text;
- (void)setIcon:(NSImage *)image;


// prefs
-(IBAction)showPreferences:(id)sender;

// misc 
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)openComments:(id)sender;
- (void)setupTimer;
- (IBAction)openHelp:(id)sender;

@end
