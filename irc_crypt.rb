#fuck the examples.. they don't work... do it from scratch you asshat
#if msx[1] == "PRIVMSG"
#if mse.start_with?("[~]")
#mse = mse.gsub('[~]','').chomp()



##Create a cipher/crypt function
##This function will contain the details needed to encrypt AND decrypt a message
##Create a function for encrypt and for decrypt... To grab the needed details you can call  the function
## self.cipher --This will give those encrypt and decrypt functions the data they need.
## The cipher/crypt class must contain the key and other cipher details.

##create a second class for IRC with 
##Send/Recieve/Ping-Pong functions, use threading for the recieve/puts to screen from IRC.



require 'thread'
require 'socket'
require 'openssl'
require 'base64'
require 'digest/sha1'

print "Enter User: "
$user = gets.chomp

 class Crypto
	def initialize(key, key64, iv)
		@key 		= $key
		@key64	= key64
		@iv 			= iv
   end
	
	def crypting
		$alg = "AES-256-CBC"
		digest = Digest::SHA256.new
		digest.update("#{$key}")
		@key = digest.digest
		#puts "Our key"
		@key
		# Base64 the key
		#puts "Our key base 64"
		@key64 = [@key].pack('m')
		#puts @key64
		# Base64 decode the key
		#puts "Our key retrieved from base64"
		@key64.unpack('m')[0]
		raise 'Key Error' if(@key.nil? or @key.size != 32)
	end
	
	def encrypt(data)
		self.crypting()
		aes = OpenSSL::Cipher::Cipher.new($alg)
		aes.encrypt
		aes.key = @key
		aes.iv = @iv		
		cipher = aes.update("#{$user}: #{data}")
		#cipher << aes.update("This is some other string without linebreak.")
		cipher << aes.final
		#puts "AES DATA"
		#puts cipher
		#puts " "
		#puts "Our Encrypted data in base64"
		$cipher64 = [cipher].pack('m')
		#puts $cipher64
		#puts " "
		$irc.send_data("[~]#{$cipher64}")
	end
	
	def decrypt(msg)
		self.crypting()
		decode_cipher = OpenSSL::Cipher::Cipher.new($alg)
		decode_cipher.decrypt
		#decode_cipher.padding = 0
		decode_cipher.key = @key
		decode_cipher.iv = @iv
		plain = decode_cipher.update("#{msg}".unpack('m')[0])
		#puts "Base64 back to AES"
		#puts plain
		#puts " "
		plain << decode_cipher.final
		#puts "Decrypted Text"
		puts plain
	end
end	


$crypto = Crypto.new("123keyeeasfesafaesffaefa", "123key64efaesesfasefasfasfeasfdfaewfrasef", "123aesfaesfasfivfwefasfeafdawefa") #Starts crypto so IRC can use it


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
		if msg.match(/^PING :(.*)$/)
		@socket.puts "PONG #{$~[1]}"
		
	end
    end
  end
  
  def msg_dis(msg)
	Thread.new do
	msg.gsub!(/.*[:]/, '')
    #array = msg.split(' ')
	#puts msg
   	$crypto.decrypt(msg) if msg =~ /[~]/ #[~] is the descriptor for encrypted data coming in
	end
  end
  
  	def send_data(data)
		@socket.puts "PRIVMSG #{@channel} :#{data}"
		end
end
$nick = @nick


$irc = Irc.new("irc.starchat.net", 6667, "#{$user}", "#Metrion")
$irc.connect
Thread.new do
loop do
#print ">"
msgout = gets.chomp
$crypto.encrypt("#{msgout}")
end
end
$irc.msg_loop
#$irc.send_data("testing")
#[~]g446BLzA7JhmlJjAloXSgA==




