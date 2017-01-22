# Crossbar HTTP

[![Gem Version](https://badge.fury.io/rb/crossbar-http.svg)](https://badge.fury.io/rb/crossbar-http)

Module that provides methods for accessing Crossbar.io HTTP Bridge Services

## Revision History

  - v0.1:
    - Initial version

## Installation

``` ruby
gem 'crossbar-http'
```

## Usage

### Call
To call a Crossbar HTTP bridge, do the following

``` ruby
client = Crossbar::HTTP::Client("http://127.0.0.1/call")
result = client.call("com.example.add", 2, 3, offset=10)
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
client = Crossbar::HTTP::Client("http://127.0.0.1/publish")
result = client.publish("com.example.event", event="new event")
```
    
The receiving subscription would look like

``` python
def onJoin(self, details):
        
    def subscribe_something(event=None, **kwargs):
        print "Publish was called with event %s" % event

    self.subscribe(subscribe_something, "com.example.event")
```

### Key/Secret
For bridge services that have a key and secret defined, simply include the key and secret in the instantiation of the
client.

``` ruby
client = Crossbar::HTTP::Client("http://127.0.0.1/publish", key: "key", secret: "secret")
```

## Contributing
To contribute, fork the repo and submit a pull request.

## Testing
TODO

##License
MIT