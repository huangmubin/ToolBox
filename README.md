# ToolBox
My Tool box.

# Json.swift

```
// Json Object
let data = {
    "string": "myron_json",
    "int": 100,
    "float": 100.1,
    "boolean": true,
    "null": null,
    "object": {
        "string": "myron_json_object",
    },
    "array": [
        {
            "string": "myron_json_array_object0",
        },
        {
            "string": "myron_json_array_object1",
        },
        {
            "string": "myron_json_array_object2",
        },
    ],
}
```

```
// Simple use
let json = Json(data: json_data)
json["string"].string               // myron_json
json["int"].int                     // 100
json["object", "string"].string     // myron_json_object
json["array", 1, "string"].string   // myron_json_array_object1
```

```
// Auto to Model
class Value: NSObject, JsonModelProtocol {
    var string = ""
    func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("\(self) -> key: \(key) is Undefined; value: \(value);")
    }
}
class Model: NSObject, JsonModelProtocol {
    var string = ""
    var int = 0
    var float = 0.0
    var boolean = false
    var object: Value?
    var array: [Value] = []
    func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("\(self) -> key: \(key) is Undefined; value: \(value);")
    }
}

Json.classList["object"] = Value.self
Json.classList["array"]  = Value.self

let model: Model? = Json.toModel(data)
model.string            // myron_json
model.int               // 100
model.object.string     // myron_json_object
model.array[1].string   // myron_json_array_object1
```

```
// Custom to model
class Value: JsonAdaptProtocol {
    var string = ""
    request init?(adapt json: Json) {
        if let str = json["string"].string {
            string = str
        } else {
            return nil
        }
    }
}
class Model: JsonAdaptProtocol {
    var string = ""
    var int = 0
    var float = 0.0
    var boolean = false
    var object: Value?
    var array: [Value] = []
    request init?(adapt json: Json) {
        string = json["string"].string
        int = json["int"].int
        float = json["float"].float
        boolean = json["boolean"].boolean
        object = Value(adapt:json["object"])
        for json in json["array"].array {
            if let v = Value(adapt:json) {
                array.append(v)
            }
        }
    }
}

let model: Model? = Json.toObject(data)
model.string            // myron_json
model.int               // 100
model.object.string     // myron_json_object
model.array[1].string   // myron_json_array_object1
```