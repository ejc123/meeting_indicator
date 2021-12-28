# Fw

This is the firmware module for the meeting indicator project
It sets up and controls the hardware

## Targets

Set the MIX_TARGET environment variable according to the hardware you are
using.  For example:

`export MIX_TARGET=rpi0`

For more information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## WIFI setup

If you put your hardware in a box, it becomes tedious to swap out SD cards.
Nerves supports over-the-air updates with the ([ssh_subsystem_fwup](https://hex.pm/packages/ssh_subsystem_fwup)) 
package.  

Your hardware needs to support networking, and you need to set
some environment variables. 

`NERVES_NETWORK_SSID` is the SSID for the wireless network
`NERVES_NETWORK_PSK` is the shared secret for the wireless network

The mix configuration checks for these and will fail if they are not
set.

If you do not need wireless, you can set

`NERVES_NETWORK_NO_WIFI`

to ignore the wifi settings.


## Getting Started

To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi0`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`

## Learn more

  * Official docs: https://hexdocs.pm/nerves/getting-started.html
  * Official website: https://nerves-project.org/
  * Forum: https://elixirforum.com/c/nerves-forum
  * Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
  * Source: https://github.com/nerves-project/nerves
