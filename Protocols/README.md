# QueueProtocol.swift

An Array container, implement some stack and queue methods.

## QueueProtocol

normal stack and queue action.

## QueueControlProtocol

auto control the current data.

## QueueControl

a class implement QueueControlProtocol

# NotifierProtocol.swift

## NotifierProtocol

A protocol to implement some simply methods about the NotificationCenter.

## extention Notification

Extension the Notification to simply get the userInfo.

## Examples

```
extension Notification.Name {
    static let Test = Notification.Name.init("test")
}

class Test: NotifierProtocol {
    @objc func test(notify: Notification) {
        let s1: String? = notify.get("info")
        let s2 = notify.get("other", null: "error")
        print("s1 = \(s1); s2 = \(s2)")
    }
}

let test = Test()
test.observer(name: .Test, selector: #selector(test.test(notify:)))
test.post(name: .Test, infos: ["info": "A test message.""info": "A test message.", "other": "2 A test message."
//: s1 = Optional("A test message."); s2 = 2 A test message.
```
