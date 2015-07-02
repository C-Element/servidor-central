require 'socket'

servidor = TCPServer.new(2100)
tabela_dns = {}

def processar(linha)
	req_conhecidas = ["REG", "IP"] # Requisições conhecidas
	dados = linha.split(" ")       # Quebra a requisição para melhor analise dos dados

	if req_conhecidas.include? dados[0] then
		return "Ok"
	else
		return "FALHA"
	end
end

loop {
	cliente = servidor.accept
	while linha = cliente.gets.chomp  
		cliente.puts(processar(linha))
	end
	cliente.close
}