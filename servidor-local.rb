require 'socket'

cliente = UDPSocket.new
cliente.connect('localhost', 2100)

cliente.print 'REG acari 127.0.0.1'
puts cliente.recvfrom(1024)[0]

cliente.close
