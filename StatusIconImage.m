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


#import "StatusIconImage.h"

#define _RECT_ROUNDED_RAIDUS 8
#define _RECT_HEIGHT 14
#define _RECT_LOGNER_THAN_TEXT_AND_IMAGE 15

@implementation StatusIconImage

+ (NSImage *) makeIconWIthImage:(NSImage *)image string:(NSString *)text
{
  NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont boldSystemFontOfSize:11.0], NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, nil];                            
  NSSize textSize = [text sizeWithAttributes: fontAttributes];
  
  int statusWidth = [image size].width + textSize.width + _RECT_LOGNER_THAN_TEXT_AND_IMAGE;
  int statusHeight = [image size].height;
  
  NSBitmapImageRep *offScreenRep = [NSBitmapImageRep alloc];
  [offScreenRep initWithBitmapDataPlanes:nil
    pixelsWide:statusWidth
    pixelsHigh:statusHeight
    bitsPerSample:8
    samplesPerPixel:4
    hasAlpha:YES
    isPlanar:NO
    colorSpaceName:NSCalibratedRGBColorSpace
    bytesPerRow:(4 * statusWidth)
    bitsPerPixel:32];
    
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext: [NSGraphicsContext graphicsContextWithBitmapImageRep: offScreenRep]];
  [[NSColor clearColor] set];
  NSRectFill(NSMakeRect(0,0,statusWidth, statusHeight));
  
  [image drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1]; 
  [StatusIconImage drawRectangleWithTextSize:textSize iconSize:[image size]];
  [text drawAtPoint:NSMakePoint(image.size.width + 10, 1) withAttributes:fontAttributes];
  [NSGraphicsContext restoreGraphicsState];
  
  NSData *data = [offScreenRep TIFFRepresentation];
  NSImage *statusIcon = [[NSImage alloc] initWithData:data];

  //[text release];
  //text = nil;
  //[fontAttributes release];
  //fontAttributes = nil;
  [offScreenRep release];
  offScreenRep = nil;
  //[data release];
  //data = nil;
  [statusIcon autorelease];
  
  return statusIcon;
}

+ (void)drawRectangleWithTextSize:(NSSize)textSize iconSize:(NSSize)iconSize
{
  NSColor *backgroundColor = [NSColor colorWithCalibratedRed:13/256.0 green:54/256.0 blue:253/256.0 alpha:0.5];
  NSColor *foregroundColor = [NSColor colorWithCalibratedRed:78/256.0 green:114/256.0 blue:254/256.0 alpha:1.0];
  
  NSRect position = NSMakeRect(iconSize.width+5, 2, textSize.width+10, _RECT_HEIGHT);
  NSRect backgroundPosition = NSMakeRect(position.origin.x, position.origin.y-1, position.size.width, position.size.height);
  
  [backgroundColor set];
  NSBezierPath* rectanglePath = [NSBezierPath bezierPathWithRoundRectInRect:backgroundPosition radius:_RECT_ROUNDED_RAIDUS];
  [rectanglePath fill];
  //[rectanglePath release];
  rectanglePath = nil;
  
  [foregroundColor set];
  rectanglePath = [NSBezierPath bezierPathWithRoundRectInRect:position radius:_RECT_ROUNDED_RAIDUS];
  [rectanglePath fill];
 // [rectanglePath release];
  rectanglePath = nil;
  
  //[backgroundColor release];
  backgroundColor = nil;
  //[foregroundColor release];
  //foregroundColor = nil;
}


@end
