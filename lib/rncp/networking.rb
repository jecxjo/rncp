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
require 'socket'
require 'ipaddr'
require 'rncp/params'

module RNCP
  module Networking
    def bind_tcp
      sock = Socket::new Socket::AF_INET, Socket::SOCK_STREAM, 0
      opts = [1].pack("i")
      addr = [Socket::AF_INET, RNCP::PORT, 0, 0, 0, 0, 0, 0]
        .pack("snCCCCNN")

      sock.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEADDR, opts
      sock.bind addr
      sock.listen 1
      return sock
    end # bind_tcp

    def join_multicast
      msock = UDPSocket.new
      membership = IPAddr.new(RNCP::IPV4_GROUP).hton +
                   IPAddr.new("0.0.0.0").hton

      puts "[#] Joining Multicast group"
      msock.setsockopt :IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership
      msock.setsockopt :SOL_SOCKET, :SO_REUSEADDR, 1 
      msock.bind "0.0.0.0", RNCP::PORT

      return msock
    end # join_multicast

    def bind_multicast
      msock = UDPSocket.open
      msock.setsockopt :IPPROTO_IP, :IP_MULTICAST_TTL, [32].pack("i")
      msock.setsockopt :SOL_SOCKET, :SO_REUSEADDR, 1 
      msock.bind '', RNCP::PORT
      msock.setsockopt :IPPROTO_IP, :IP_MULTICAST_LOOP, 1
      return msock
    end # bind_multicast
  end # Networking
end # RNCP
