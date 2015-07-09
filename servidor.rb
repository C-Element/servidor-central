require 'socket'
require 'sqlite3'

# Script de Servidor Central para projeto de PPR.

# Caminho para a o arquivo de base de dados SQLite3.
BASE_DE_DADOS = 'central.bd'
# Expressão regular para validação de IPv4.
$reg_ip = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
# Tabela de armazenamento de nomes na memória.
$tabela_dns = {}
# Flag que armazena se o script está rodando em modo de base de dados.
$f_bd = false

# Verificando se algum argumento válido foi passado na linha de comando.
if ARGV.include? '-b' or ARGV.include? '--banco' then
  $f_bd = true
end

# Inicializando a variável servidor com um socket UDP.
servidor = UDPSocket.new
# Associando o socket a todas as interfaces de rede e à porta 2100.
servidor.bind('', 2100)

puts "Iniciando o servidor no modo: %s" % ($f_bd ? "Base de Dados" : "Memoria")

# Funções de Base de Dados

def atualizar_linha(nome, ip)
  # Função para atualizar um registro na base de dados.
  SQLite3::Database.new(BASE_DE_DADOS) do |bd|
    bd.execute("update name_ip set ip = '#{ip}' where name = '#{nome}'")
  end
end

def consultar_bd(nome)
  # Função para consultar um registro na base de dados pelo se nome, caso não exista nenhum registro retorna nil.
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
  # Função para inserir um registro na base de dados.
  SQLite3::Database.new(BASE_DE_DADOS) do |bd|
    bd.execute("insert into name_ip (id, name, ip) values ((select ifnull(max(id),0) + 1 from name_ip), '#{nome}', '#{ip}')")
  end
end

def registrar_bd(nome, ip)
  # Função para registrar um nome na base de dados, se o nome já existir ele atualiza o valor
  # caso contrário insere um novo.
  if consultar_bd(nome) then
    atualizar_linha(nome, ip)
  else
    inserir_linha(nome, ip)
  end
end

# Funções de memoria

def consultar_memoria(nome)
  # Função para consultar um registro na memória.
  if $tabela_dns.key?(nome)
    return $tabela_dns[nome]
  else
    return nil
  end
end

def registrar_memoria(nome, ip)
  # Função para registrar um registro na memória.
  $tabela_dns[nome] = ip
end

# Funções ds sistema

def consultar(nome)
  # Função que verifica se deverá consultar o nome na base de dados ou na memória.
  if $f_bd then
    return consultar_bd(nome)
  else
    return consultar_memoria(nome)
  end
end

def processar(linha)
  # Função que processa as mensagens recebidas e retorna as mensagens apropriadas.

  # Requisições conhecidas: REG e IP.
  req_conhecidas = %w(REG IP)
  # Quebra a requisição para melhor análise dos dados.
  dados = linha.split(' ')
  # Verificando se a requisição recebida é conhecida, se não for retorna: FALHA
  if req_conhecidas.include? dados[0] then
    # Verificando se é uma requisição REG
    if dados[0] == req_conhecidas[0] then
      # Se a quantidade de palavras for diferente de 3 ou a terceira palavra não for um IPv4 retorna REGFALHA
      if dados.length != 3 || !$reg_ip.match(dados[2]) then
        return 'REGFALHA'
      else
        # Se estiver tudo ok registra o nome no sistema.
        registrar(dados[1], dados[2])
        return 'REGOK'
      end
    else
      # Se a requisição for IP e a quantidade de palavras for diferente de 2 ou o nome informado ainda não foi
      # registrado retorna um IPFALHA
      if dados.length != 2 || !consultar(dados[1]) then
        return 'IPFALHA'
      else
        # Se estiver tudo ok retorna o ip referente ao nome informado.
        return 'IPOK %s' % consultar(dados[1])
      end
    end
  else
    return 'FALHA'
  end
end

def registrar(nome, ip)
  # Função que verifica se deverá registrar o nome na base de dados ou na memória.
  if $f_bd then
    registrar_bd(nome, ip)
  else
    registrar_memoria(nome, ip)
  end
end


loop {
  # Loop que recebe, processa e retorna os dados via o socket UDP.
  linha, cliente = servidor.recvfrom(1024)
  servidor.send(processar(linha.chomp), 0, cliente[3], cliente[1])
}