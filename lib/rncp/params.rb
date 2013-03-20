# RNCP - a fast file copy tool for LANs port in Ruby
#
# Copyright (c) 2013 Jeff Parent
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
require 'rncp/version'

module RNCP
  # IPv4 Multicast Group
  IPV4_GROUP = '224.110.99.112'

  # IPv4 Broadcast Address
  IPV4_BC = '255.255.255.255'

  # ncp Server Port
  PORT = 8002

  # Message sent when connecting via multicast
  MC_MSG = "Multicasting for rncp Version #{RNCP::VERSION}"

  # Message sentw hen connecting via broadcast
  BC_MSG = "Broadcasting for rncp Version #{RNCP::VERSION}"
end
