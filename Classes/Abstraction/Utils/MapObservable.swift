private let kObserveOncePrefix = "ObserveOnce_"

/**
This is a naive implementation for observing model changes. We'll just keep the closures on a dictionary and
call them one by one when the event is fired. Note that order is not guaranteed.
*/
public final class MapObservable<T> {
    public typealias ObserverClosure = (model: T, previousModel: T) -> Void
    private var observers = [String: ObserverClosure]()

    public init() {}

    /**
    Adds an entry to the dispatch table with a block to add to the queue.

    - parameter observer: Object registering as an observer.
    - parameter closure:  The block to be executed when the notification is received. The block is held until
                          the observer is called.
    */
    public func observe(from observer: AnyObject, closure: ObserverClosure) {
        self.observe(fromName: self.keyForObserver(observer), closure: closure)
    }

    /**
    Similar to observe(from:closure:) but instead of associating an object it uses a string for the
    association. Please be careful with this method. Collisions names will get overriden without a warning.

    - parameter name:    The name of the identifier that will be associated to the closure.
    - parameter closure: The block to be executed when the notification is received. The block is held until
                         the observer is called.
    */
    public func observe(fromName name: String, closure: ObserverClosure) {
        self.observers[name] = closure
    }

    /**
    This method will create an observer that will only be called once and then removed from the queue.

    :note: Be careful on how you use it. This should only be used when the event is guaranteed to be called
           once. Otherwise the closure will remain in the queue forever.

    - parameter closure: The block to be executed when the notification is received. The block is held until
                         the observer is called.
    */
    public func observeOnce(closure: ObserverClosure) {
        let identifier = kObserveOncePrefix + String(random())
        self.observe(fromName: identifier, closure: closure)
    }

    /**
    Removes all the entries specifying a given observer from the receiver’s dispatch table.

    - parameter observer: The observer to remove.
    */
    public func disregard(observer: AnyObject) {
        self.disregard(self.keyForObserver(observer))
    }

    /**
    Similar to disregard(observer:) but instead of taking an object it takes a string that should
    math the string given to observe(fromName:closure:).

    - parameter name: The observer name to remove.
    */
    public func disregard(name: String) {
        self.observers[name] = nil
    }

    /**
    Sends a notification to all observers. This is called when a model changes.

    - parameter model:         The current version of the modal after the update.
    - parameter previousModel: The previous version of the modal before the update.
    */
    public func notify(model: T, previousModel: T) {
        for (identifier, observer) in self.observers {
            let needsDisregarding = identifier.hasPrefix(kObserveOncePrefix)

            // To avoid observers interfering with each other by changing something that would trigger a new
            // set of observers to be notified, use a serial queue (main queue) to schedule the notifications
            dispatch_async(dispatch_get_main_queue()) {
                let observerExists = self.observers[identifier] != nil
                if observerExists || needsDisregarding {
                    observer(model: model, previousModel: previousModel)
                }
            }

            if needsDisregarding {
                self.disregard(identifier)
            }
        }
    }

    // MARK: Helpers

    private func keyForObserver(observer: AnyObject) -> String {
        let className = NSStringFromClass(observer.dynamicType)
        return "\(className)-\(ObjectIdentifier(observer).hashValue)"
    }
}
