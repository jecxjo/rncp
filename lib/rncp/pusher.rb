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
require 'rncp/networking'
require 'stringio'
require 'fileutils'
require 'zlib'
require 'archive/tar/minitar'
require 'tempfile'

module RNCP
  class NcpPusher
    include RNCP::Networking

    def initialize
    end

    def directory_list(path)
      return [path].flatten if File.directory?(path) == false

      data = []
      Dir["#{path}**/*", "#{path}**/.*"].each do |entry|
        next if entry[/^.*\/\.+$/]
        data << directory_list(entry)
      end

      return data.flatten
    end

    def send_to(ip, files)
      begin
        puts "[*] copying #{files} to ip : #{ip}"
        sock = TCPSocket::new ip, RNCP::PORT
        sock.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1
        
        data = StringIO.new("")
        sgz = Zlib::GzipWriter.new(data)
        tar = Archive::Tar::Minitar::Output.new sgz

        puts "[#] start writing files"
        files.each do |f|
          directory_list(f).each do |entry|
            puts "[*] adding: #{entry}"
            Archive::Tar::Minitar.pack_file(entry, tar)
          end
        end

        sgz.flush
        sgz.close
        sgz = nil

        data.rewind
        sock.send data.string, 0
        sock.flush

      rescue Exception => e
        puts "[!] cannot create connection to host, bailing out"
        puts e
      ensure
        sock.close if sock.nil? == false
        puts "[#] finished"
        sgz.close if sgz.nil? == false
      end
    end # send_to

    def push(files)
      begin
        sock = nil
        addr = nil
        msock = bind_multicast

        # check broadcast
        
        if msock.nil? == true
          puts "[!] cannot continue without atleast one announcement socket!"
          return 1
        end

        dsock = bind_tcp

        if dsock.nil? == true
          puts "[!] cannot continue without data socket"
          return -1
        end

        puts "[*] starting X-Casting, waiting for TCP connect"
        while sock.nil? == true
          if msock.nil? == false
            msock.send RNCP::MC_MSG, 0, RNCP::IPV4_GROUP, RNCP::PORT
          end
          # Broadcast
          puts "."
          result = select( [dsock], nil, nil, 2 )

          next if result.nil? == true
          for inp in result[0]
            if inp == dsock
              sock, addr = dsock.accept
              printf "[*] connection from %s:%s\n",
                  addr.ip_address, addr.ip_port
              puts "[*] Client answer: #{sock.recv 1024}"
            end # if
          end # for inp
        end # while sock.nil?

        msock.close if msock.nil? == false
        msock = nil
        dsock.close if dsock.nil? == false
        dsock = nil

        data = StringIO.new("")
        sgz = Zlib::GzipWriter.new(data)
        tar = Archive::Tar::Minitar::Output.new sgz

        puts "[#] pushing #{files} to #{addr.ip_address}:#{addr.ip_port}"
        files.each do |f|
          directory_list(f).each do |entry|
            puts "[*] adding: #{entry}"
            Archive::Tar::Minitar.pack_file(entry, tar)
          end
        end # files.each

        sgz.flush
        sgz.close
        sgz = nil

        data.rewind
        sock.send data.string, 0
        sock.flush
      rescue Exception => e
        puts "[!] cannot push data, bailing out"
        puts e
      ensure
        sock.close if sock.nil? == false
        puts "[*] finished"
        sgz.close if sgz.nil? == false
        msock.close if msock.nil? == false
        dsock.close if dsock.nil? == false
      end # begin
    end # push
  end # NcpPusher
end # RNCP
