require 'socket'

servidor = TCPServer.new(2100)
$reg_ip = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
$tabela_dns = {}

def processar(linha)
	req_conhecidas = ["REG", "IP"] # Requisições conhecidas
	falha = 'FALHA'
	reg_falha = 'REGFALHA'
	dados = linha.split(" ")       # Quebra a requisição para melhor analise dos dados

	if req_conhecidas.include? dados[0] then
		if dados[0] == req_conhecidas[0] then
			if dados.length != 3 then
				return reg_falha
			else
				if $reg_ip.match(dados[2]) then
					$tabela_dns[dados[1]] = dados[2]
					print($tabela_dns)
					puts
				else
					return reg_falha
				end
			end
		else
			return "Ok"
		end
	else
		return falha
	end
end

loop {
	cliente = servidor.accept
	while linha = cliente.gets.chomp  
		cliente.puts(processar(linha))
	end
	cliente.close
}