//
//  SystemDirectory.swift
//  BurntFoundation
//
//  Created by Patrick Smith on 26/07/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Foundation


public class SystemDirectory {
	public typealias ErrorReceiver = (NSError) -> Void
	
	public let pathComponents: [String]
	public let errorReceiver: ErrorReceiver
	private let directoryURLResolver: (fm: NSFileManager, inout error: NSError?) -> NSURL?
	private let group: dispatch_group_t
	private var createdDirectoryURL: NSURL?
	
	public init(var pathComponents: [String], inUserDirectory directoryBase: NSSearchPathDirectory, errorReceiver: ErrorReceiver, useBundleIdentifier: Bool = true) {
		if useBundleIdentifier {
			if let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier {
				pathComponents.insert(bundleIdentifier, atIndex: 0)
			}
		}
		
		self.pathComponents = pathComponents
		self.errorReceiver = errorReceiver
		
		directoryURLResolver = { (fm, inout error: NSError?) in
			return fm.URLForDirectory(directoryBase, inDomain:.UserDomainMask, appropriateForURL:nil, create:true, error:&error)
		}
		
		group = dispatch_group_create()
		
		createDirectory()
	}
	
	private func createDirectory() {
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
		dispatch_group_async(group, queue) {
			let fm = NSFileManager.defaultManager()
			var error: NSError?
			
			if let directoryURL = self.directoryURLResolver(fm: fm, error: &error) {
				
				// Convert path to its components, so we can add more components
				// and convert back into a URL.
				var pathComponents = (directoryURL.pathComponents) as! [String]
				
				pathComponents.extend(self.pathComponents)
				
				// Convert components back into a URL.
				if let directoryURL = NSURL.fileURLWithPathComponents(pathComponents) {
					if fm.createDirectoryAtURL(directoryURL, withIntermediateDirectories:true, attributes:nil, error:&error) {
						self.createdDirectoryURL = directoryURL
						// Return, finishing the dispatch_group_async
						return
					}
				}
			}
			
			if let error = error {
				self.errorReceiver(error)
			}
		}
	}
	
	public func useOnQueue(queue: dispatch_queue_t, closure: (directoryURL: NSURL) -> Void) {
		dispatch_group_notify(group, queue) {
			if let createdDirectoryURL = self.createdDirectoryURL {
				closure(directoryURL: createdDirectoryURL)
			}
		}
	}
}
