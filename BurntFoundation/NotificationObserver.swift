//
//  NotificationObserver.swift
//  BurntFoundation
//
//  Created by Patrick Smith on 11/05/2015.
//  Copyright (c) 2015 Patrick Smith. All rights reserved.
//

import Foundation


public class NotificationObserver<NotificationType: RawRepresentable where NotificationType.RawValue == String, NotificationType: Hashable> {
	public let object: AnyObject
	public let notificationCenter: NSNotificationCenter
	let operationQueue: NSOperationQueue
	
	public var observers = [NotificationType: AnyObject]()
	
	public init(object: AnyObject, notificationCenter: NSNotificationCenter, queue: NSOperationQueue) {
		self.object = object
		self.notificationCenter = notificationCenter
		self.operationQueue = queue
	}
	
	public convenience init(object: AnyObject) {
		self.init(object: object, notificationCenter: NSNotificationCenter.defaultCenter(), queue: NSOperationQueue.mainQueue())
	}
	
	public func addObserver(notificationIdentifier: NotificationType, block: (NSNotification!) -> Void) {
		let observer = notificationCenter.addObserverForName(notificationIdentifier.rawValue, object: object, queue: operationQueue, usingBlock: block)
		observers[notificationIdentifier] = observer
	}
	
	public func removeObserver(notificationIdentifier: NotificationType) {
		if let observer: AnyObject = observers[notificationIdentifier] {
			notificationCenter.removeObserver(observer)
			observers.removeValueForKey(notificationIdentifier)
		}
	}
	
	public func removeAllObservers() {
		for (notificationIdentifier, observer) in observers {
			notificationCenter.removeObserver(observer)
		}
		observers.removeAll()
	}
	
	 deinit {
		removeAllObservers()
	}
}


public extension NSNotificationCenter {
	public func postNotification
		<NotificationType: RawRepresentable where NotificationType.RawValue == String>
		(notificationIdentifier: NotificationType, object: AnyObject, userInfo: [String:AnyObject]? = nil)
	{
		postNotificationName(notificationIdentifier.rawValue, object: object, userInfo: userInfo)
	}
}
