require 'socket'
require 'sqlite3'

# Tabela create table name_ip (id int not null unique, name char not null unique, ip char not null, primary key(id))

BASE_DE_DADOS = 'central.bd'

$reg_ip = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
$tabela_dns = {}
$f_bd = false

if ARGV.include? '-b' or ARGV.include? '--banco' then
  $f_bd = true
end

servidor = UDPSocket.new
servidor.bind('', 2100)
puts "Iniciando o servidor no modo: %s" % ($f_bd ? "Base de Dados" : "Memoria")

# Funções de Base de Dados

def atualizar_linha(nome, ip)
  SQLite3::Database.new(BASE_DE_DADOS) do |bd|
    bd.execute("update name_ip set ip = '#{ip}' where name = '#{nome}'")
  end
end

def consultar_bd(nome)
  SQLite3::Database.new(BASE_DE_DADOS) do |bd|
    linhas = bd.execute("select ip from name_ip where name = '#{nome}'")
    if linhas.length > 0 then
      return linhas[0][0]
    else
      return nil
    end
  end
end

def inserir_linha(nome, ip)
  SQLite3::Database.new(BASE_DE_DADOS) do |bd|
    bd.execute("insert into name_ip (id, name, ip) values ((select ifnull(max(id),0) + 1 from name_ip), '#{nome}', '#{ip}')")
  end
end

def registrar_bd(nome, ip)
  if consultar_bd(nome) then
    atualizar_linha(nome, ip)
  else
    inserir_linha(nome, ip)
  end
end

# Funções de memoria

def consultar_memoria(nome)
  if $tabela_dns.key?(nome)
    return $tabela_dns[nome]
  else
    return nil
  end
end

def registrar_memoria(nome, ip)
  $tabela_dns[nome] = ip
end

# Funções ds sistema

def consultar(nome)
  if $f_bd then
    return consultar_bd(nome)
  else
    return consultar_memoria(nome)
  end
end

def processar(linha)
  req_conhecidas = %w(REG IP) # Requisições conhecidas
  dados = linha.split(' ') # Quebra a requisição para melhor analise dos dados
  if req_conhecidas.include? dados[0] then
    if dados[0] == req_conhecidas[0] then
      if dados.length != 3 || !$reg_ip.match(dados[2]) then
        return 'REGFALHA'
      else
        registrar(dados[1], dados[2])
        return 'REGOK'
      end
    else
      if dados.length != 2 || !consultar(dados[1]) then
        return 'IPFALHA'
      else
        return 'IP %s' % consultar(dados[1])
      end
    end
  else
    return 'FALHA'
  end
end

def registrar(nome, ip)
  if $f_bd then
    registrar_bd(nome, ip)
  else
    registrar_memoria(nome, ip)
  end
end


loop {
  linha, cliente = servidor.recvfrom(1024)
  servidor.send(processar(linha), 0, cliente[3], cliente[1])
}