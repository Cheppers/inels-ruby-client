# Inels

Ruby gem to controll Inels smart heating systems

## Getting Started

For example usage see the [Inels CLI](examples/inels_cli.rb)

## USAGE

```
[1] pry(main)> require_relative 'lib/controller'
=> true
```
Create controller with multiple hubs:
```
[2] pry(main)> ips = %w(192.168.1.30 192.168.1.31 192.168.1.32)
=> ["192.168.1.30", "192.168.1.31", "192.168.1.32"]
[3] pry(main)> controller = Inels::Controller.new(ips)
```
Create controller with a single hub:
```
[4] pry(main)> controller = Inels::Controller.new(['192.168.1.32'])
```
Get every room state:
```
[5] pry(main)> controller.get_all_states
=> {"33704"=>
  {"37638"=>
    {"temperature"=>27.5,
     "mode"=>1,
     "correction"=>0.0,
     "power"=>0,
     "battery"=>true,
     "requested temperature"=>24.0,
     "heating"=>false,
     "cooling"=>false,
     "old state"=>1,
     "controll"=>4},
   "41806"=>
    {"temperature"=>26.0,
     "mode"=>1,
     "correction"=>0.0,
     "power"=>0,
     "battery"=>true,
     "requested temperature"=>24.0,
     "heating"=>false,
     "cooling"=>false,
     "old state"=>1,
     "controll"=>1}},
 "36378"=>
  {"45935"=>
    {"temperature"=>25.0,
     "mode"=>1,
     "correction"=>0.0,
     "power"=>0,
     "battery"=>true,
     "requested temperature"=>24.0,
     "heating"=>false,
     "cooling"=>false,
     "old state"=>1,
     "controll"=>1}},
 "37839"=>
  {"49671"=>
    {"temperature"=>25.5,
     "mode"=>1,
     "correction"=>0.0,
     "power"=>0,
     "battery"=>true,
     "requested temperature"=>24.0,
     "heating"=>false,
     "cooling"=>false,
     "old state"=>1,
     "controll"=>1},
   "53952"=>
    {"temperature"=>29.5,
     "mode"=>1,
     "correction"=>0.0,
     "power"=>0,
     "battery"=>true,
     "requested temperature"=>24.0,
     "heating"=>false,
     "cooling"=>false,
     "old state"=>1,
     "controll"=>1},
   "60252"=>
    {"temperature"=>27.0,
     "mode"=>1,
     "correction"=>0.0,
     "power"=>0,
     "battery"=>true,
     "requested temperature"=>24.0,
     "heating"=>false,
     "cooling"=>false,
     "old state"=>1,
     "controll"=>1}},
 "32137"=>
  {"23877"=>
    {"temperature"=>21.5,
     "mode"=>1,
     "correction"=>0.0,
     "power"=>0,
     "battery"=>true,
     "requested temperature"=>23.0,
     "heating"=>false,
     "cooling"=>false,
     "old state"=>1,
     "controll"=>1},
   "33055"=>
    {"temperature"=>23.5,
     "mode"=>1,
     "correction"=>0.0,
     "power"=>0,
     "battery"=>true,
     "requested temperature"=>23.0,
     "heating"=>false,
     "cooling"=>false,
     "old state"=>1,
     "controll"=>1}}}
```
Set the temperature a given room
```
[6] pry(main)> controller.set_temperature '33704', 26
```
Get the state of a specific room:
```
[7] pry(main)> controller.get_states '33704'
=> {"37638"=>                         # Termohead ID
  {"temperature"=>27.5,               # Termohead's current temperature
   "mode"=>1,
   "correction"=>0.0,
   "power"=>0,
   "battery"=>true,
   "requested temperature"=>26.0,     # Termohead's requested temperature
   "heating"=>false,
   "cooling"=>false,
   "old state"=>1,
   "controll"=>4},
 "41806"=>
  {"temperature"=>26.0,
   "mode"=>1,
   "correction"=>0.0,
   "power"=>0,
   "battery"=>true,
   "requested temperature"=>26.0,
   "heating"=>false,
   "cooling"=>false,
   "old state"=>1,
   "controll"=>1}}
```

