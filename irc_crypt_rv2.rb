require 'thread'
require 'socket'
require 'aes'
require 'rubygems'
exit if Object.const_defined?(:Ocra) #allow ocra to create an exe without executing the entire script

print "Enter User: "
$user = gets.chomp
print "Enter IRC Server: "
$server = gets.chomp
print "Enter Channel: "
$chan = gets.chomp
print "Enter Key: "
$userkey = gets.chomp

class Irc
  def initialize(server, port, nick, channel)
    @server  = server
    @port    = port
    @nick    = nick
    @channel = channel
    @socket  = nil
  end
  
  def connect()
    @socket = TCPSocket.open(@server, @port)
    @socket.puts "USER testing 0 * Testing"
    @socket.puts "NICK #{@nick}"
    @socket.puts "JOIN #{@channel}"
  end
  
  def msg_loop()
    until @socket.eof? do
      msg = @socket.gets
      self.msg_dis(msg)
	 	    end
  end
  
  def msg_dis(msg)
  		if msg.match(/^PING :(.*)$/)
		@socket.puts "PONG #{$~[1]}"
			end
	Thread.new do
	msg.gsub!(/.*[:]/, '')
    #array = msg.split(' ')
	#puts msg
   	$irc.decrypt(msg) if msg =~ /06x06x45x49x4206x06x45x49x42/ #[~] is the descriptor for encrypted data coming in
	end
	
	def encrypt(msg)
	$key = "#{$userkey}"
	$iv = "06x06x45x49x4206x06x45x49x42"
	b64 = AES.encrypt("#{$user}: #{msg}", $key, {:iv => $iv})
	self.send_data(b64)
	end
	
	def decrypt(msg)
	decrypted = AES.decrypt(msg, $key, {:iv => $iv})
	puts decrypted
	end
	
	
  end
  
  	def send_data(data)
		@socket.puts "PRIVMSG #{@channel} :#{data}"
		end
end


$irc = Irc.new("#{$server}", 6667, "#{$user}", "#{$chan}")
$irc.connect
Thread.new do
loop do
#print ">"
msgout = gets.chomp
$irc.encrypt("#{msgout}")
end
end
$irc.msg_loop
#$irc.send_data("testing")
#[~]g446BLzA7JhmlJjAloXSgA==




