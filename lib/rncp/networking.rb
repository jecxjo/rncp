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
  # Contains common networking operations shared between listeners and 
  # pushers.
  module Networking
    # Creates a TCP connection to listen for direct connections
    # @return [Socket] listening socket
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

    # Creates a socket bound to the Multicast group. Returns nil if fails.
    # This socket is used to listen for messages sent via Multicast. See
    # {#bind_multicast} to send.
    # @return [UDPSocket] multicast socket
    def join_multicast
      begin
        msock = UDPSocket.new
        membership = IPAddr.new(RNCP::IPV4_GROUP).hton +
                     IPAddr.new("0.0.0.0").hton

        puts "[#] Joining Multicast group"
        msock.setsockopt :IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership
        msock.setsockopt :SOL_SOCKET, :SO_REUSEADDR, 1 
        msock.bind "0.0.0.0", RNCP::PORT

        return msock
      rescue
        puts "[!] Multicast not supported"
        return nil
      end
    end # join_multicast

    # Creates a socket that sends to Multicast group. Returns nil if fails.
    # See {#join_multicast} to listen for Multicast.
    # @return [UDPSocket] multicast socket
    def bind_multicast
      begin
        msock = UDPSocket.open
        msock.setsockopt :IPPROTO_IP, :IP_MULTICAST_TTL, [32].pack("i")
        msock.setsockopt :SOL_SOCKET, :SO_REUSEADDR, 1 
        msock.bind '', RNCP::PORT
        msock.setsockopt :IPPROTO_IP, :IP_MULTICAST_LOOP, 1
        return msock
      rescue
        puts "[!] Multicast not supported"
        return nil
      end
    end # bind_multicast

    # Creates a socket that sends and receives via Broadcast address.
    # Returns nil if fails.
    # @return [UDPSocket] broadcast socket
    def bind_broadcast
      begin
        bsock = UDPSocket.open
        bsock.setsockopt :SOL_SOCKET, :SO_BROADCAST, 1
        bsock.setsockopt :SOL_SOCKET, :SO_REUSEADDR, 1
        bsock.bind '', RNCP::PORT
        return bsock
      rescue
        puts "[!] Broadcast not supported"
        return nil
      end
    end # bind_broadcast
  end # Networking
end # RNCP
