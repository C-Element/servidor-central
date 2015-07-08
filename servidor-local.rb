require 'socket'

cliente = UDPSocket.new
cliente.connect('localhost', 2100)

cliente.print 'REG NOME 10.10.1.10'
puts cliente.recvfrom(1024)[0]

cliente.print 'IP NOME'
puts cliente.recvfrom(1024)[0]

cliente.close