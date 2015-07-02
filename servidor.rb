require 'socket'

servidor = TCPServer.new(2100)

def processar(linha)
	print('Linha recebida: ')
	puts(linha)
	return "Ok"
end

loop {
	cliente = servidor.accept
	while linha = cliente.gets.chomp  
		cliente.puts(processar(linha))
	end
	cliente.close
}