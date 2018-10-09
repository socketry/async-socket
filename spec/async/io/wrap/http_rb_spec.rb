# Copyright, 2018, by Thibaut Girka
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

require 'http'
require 'openssl'

require 'async/io/wrap/tcp_socket'
require 'async/io/wrap/ssl_socket'

RSpec.describe Async::IO::Wrap do
	let(:wrappers) do
		{socket_class: Async::IO::Wrap::TCPSocket, ssl_socket_class: Async::IO::Wrap::SSLSocket}
	end
	
	describe "inside reactor" do
		include_context Async::RSpec::Reactor
		
		it "should fetch page" do
			expect(Async::IO::TCPSocket).to receive(:new).and_call_original
			
			expect do
				response = HTTP.get('https://www.google.com', wrappers)
				response.connection.close
			end.to_not raise_error
		end
	end
	
	describe "outside reactor" do
		it "should fetch page" do
			expect do
				response = HTTP.get('https://www.google.com', wrappers)
				response.connection.close
			end.to_not raise_error
		end
	end
end
