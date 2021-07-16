# frozen_string_literal: true

# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'socket'
require_relative 'stream'
require 'fcntl'

module Async
	module IO
		# Asynchronous TCP socket wrapper.
		class TCPSocket < IPSocket
			wraps ::TCPSocket, :gets, :puts
			
			def initialize(remote_host, remote_port = nil, local_host = nil, local_port = nil)
				if remote_host.is_a? ::TCPSocket
					super(remote_host)
				else
					super(::TCPSocket.new(remote_host, remote_port, local_host, local_port))
				end
			end
			
			class << self
				alias open new
			end
			
			include Peer
		end
		
		# Asynchronous TCP server wrappper.
		class TCPServer < TCPSocket
			wraps ::TCPServer, :listen
			
			def initialize(*args)
				if args.first.is_a? ::TCPServer
					super(args.first)
				else
					# We assume this operation doesn't block (for long):
					super(::TCPServer.new(*args))
				end
			end
			
			def accept(timeout: nil, task: Task.current)
				peer, address = async_send(:accept_nonblock, timeout: timeout)
				
				wrapper = TCPSocket.new(peer)
				
				wrapper.timeout = self.timeout
				
				return wrapper, address unless block_given?
				
				begin
					yield wrapper, address
				ensure
					wrapper.close
				end
			end
			
			alias accept_nonblock accept
			alias sysaccept accept
			
			include Server
		end
	end
end
