// 
// Copyright (c) 2008 Eric Czarny <eczarny@gmail.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of  this  software  and  associated documentation files (the "Software"), to
// deal  in  the Software without restriction, including without limitation the
// rights  to  use,  copy,  modify,  merge,  publish,  distribute,  sublicense,
// and/or sell copies  of  the  Software,  and  to  permit  persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED,  INCLUDING  BUT  NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY,  WHETHER  IN  AN  ACTION  OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
// 

// 
// Cocoa XML-RPC Framework
// XMLRPCRequest.h
// 
// Created by Eric Czarny on Wednesday, January 14, 2004.
// Copyright (c) 2008 Divisible by Zero.
// 

#import <Foundation/Foundation.h>

@class XMLRPCEncoder;

@interface XMLRPCRequest : NSObject {
	NSMutableURLRequest *mutableRequest;
	XMLRPCEncoder *requestXMLEncoder;
}

- (id)initWithHost: (NSURL *)host;

#pragma mark -

- (void)setHost: (NSURL *)host;
- (NSURL *)host;

#pragma mark -

- (void)setUserAgent: (NSString *)userAgent;
- (NSString *)userAgent;

#pragma mark -

- (void)setMethod: (NSString *)method;

- (void)setMethod: (NSString *)method withParameter: (id)parameter;

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters;

#pragma mark -

- (NSString *)method;
- (NSArray *)parameters;

#pragma mark -

- (NSString *)requestSourceXML;

#pragma mark -

- (NSURLRequest *)request;

@end
