require 'socket'

servidor = UDPSocket.new
servidor.bind('', 2100)

$reg_ip = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
$tabela_dns = {}

def processar(linha)
  req_conhecidas = %w(REG IP) # Requisições conhecidas
  dados = linha.split(' ') # Quebra a requisição para melhor analise dos dados
  if req_conhecidas.include? dados[0] then
    if dados[0] == req_conhecidas[0] then
      if dados.length != 3 || !$reg_ip.match(dados[2]) then
        return 'REGFALHA'
      else
        $tabela_dns[dados[1]] = dados[2]
        return 'REGOK'
      end
    else
      if dados.length != 2 || !$tabela_dns.key?(dados[1]) then
        return 'IPFALHA'
      else
        return 'IP %s' % $tabela_dns[dados[1]]
      end
    end
  else
    return 'FALHA'
  end
end

loop {
  linha, cliente = servidor.recvfrom(1024)
  servidor.send(processar(linha), 0, cliente[3], cliente[1])
}