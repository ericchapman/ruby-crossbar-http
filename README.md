# Crossbar HTTP

[![Gem Version](https://badge.fury.io/rb/crossbar-http.svg)](https://badge.fury.io/rb/crossbar-http)
[![Circle CI](https://circleci.com/gh/ericchapman/ruby-crossbar-http/tree/master.svg?&style=shield&circle-token=d1d127456bc9210c10f34db5b6fd573fb228bed7)](https://circleci.com/gh/ericchapman/ruby-crossbar-http/tree/master)
[![Codecov](https://img.shields.io/codecov/c/github/ericchapman/ruby-crossbar-http/master.svg)](https://codecov.io/github/ericchapman/ruby-crossbar-http)

Module that provides methods for accessing Crossbar.io HTTP Bridge Services

## Revision History

  - v0.1.2:
    - Added the ability to override the date serialization
  - v0.1.1:
    - Fixed typos in README
    - Added support for https
  - v0.1.0:
    - Initial version

## Installation

``` ruby
gem 'crossbar-http'
```

## Usage

### Call
To call a Crossbar HTTP bridge, do the following

``` ruby
client = Crossbar::HTTP::Client.new("http://127.0.0.1/call")
result = client.call("com.example.add", 2, 3, offset: 10)
```
    
This will call the following method

``` python
def onJoin(self, details):
        
    def add_something(x, y, offset=0):
        print "Add was called"
        return x+y+offset

    self.register(add_something, "com.example.add")
```
        
### Publish
To publish to a Crossbar HTTP bridge, do the following

``` ruby
client = Crossbar::HTTP::Client.new("http://127.0.0.1/publish")
result = client.publish("com.example.event", event: "new event")
```
    
The receiving subscription would look like

``` python
def onJoin(self, details):
        
    def subscribe_something(event=None, **kwargs):
        print "Publish was called with event %s" % event

    self.subscribe(subscribe_something, "com.example.event")
```

### Key/Secret
For bridge services that have a key and secret defined, simply include the key and secret 
in the instantiation of the client.

``` ruby
client = Crossbar::HTTP::Client.new("http://127.0.0.1/publish", key: "key", secret: "secret")
```

### Pre-Serialize Callback
The library provides a "pre-serialize" callback which will allow the user to
modify certain object types before the payload is serialized.  This can be used
for things like changing the date/time to a custom value.  See an example of
doing this below

``` ruby
pre_serialize = lambda { |value|
  if value.is_a? Date
    return value.strftime("%Y/%m/%d %H:%M:%S.%L %Z")
  end
}
client = Crossbar::HTTP::Client.new("http://127.0.0.1/publish", pre_serialize: pre_serialize)
```

## Contributing
To contribute, fork the repo and submit a pull request.

## Testing
To run the unit tests, execute the following

```
%> rake spec
```

## License
MIT