# encoding: UTF-8
require 'socket'
require 'test/unit'

class Test_servidor_central < Test::Unit::TestCase
  
  $central_ip = '127.0.0.1'
  $central_porta = 2100
  $dominio_registrado = 'acari'
  $ip_registrado = '127.0.0.1'
  
  #Testa a msg IP com resposta IPOK
  def test_IP_IPOK
    msg_out = "IP #{$dominio_registrado}"
    msg_esperada = "IPOK #{$ip_registrado}"
    sock = UDPSocket.new
    sock.connect($central_ip, $central_porta)
    sock.print(msg_out)
    msg_in = sock.recvfrom(20)[0]
    assert_equal(msg_esperada, msg_in)
  end
  
  #Testa a msg IP com resposta IPFALHA
  def test_IP_IPFALHA
    msg_out = "IP oslo"
    msg_esperada = "IPFALHA"
    sock = UDPSocket.new
    sock.connect($central_ip, $central_porta)
    sock.print(msg_out)
    msg_in = sock.recvfrom(20)[0]
    assert_equal(msg_esperada, msg_in)
  end
  
  #Testa uma msg IP mal formada
  def test_IP_FALHA_1
    msg_out = "IPacari"
    msg_esperada = "FALHA"
    sock = UDPSocket.new
    sock.connect($central_ip, $central_porta)
    sock.print(msg_out)
    msg_in = sock.recvfrom(20)[0]
    assert_equal(msg_esperada, msg_in)
  end
  
  #Testa uma msg IP mal formada
  def test_IP_FALHA_2
    msg_out = "IP "
    msg_esperada = "FALHA"
    sock = UDPSocket.new
    sock.connect($central_ip, $central_porta)
    sock.print(msg_out)
    msg_in = sock.recvfrom(20)[0]
    assert_equal(msg_esperada, msg_in)
  end
  
  #Testa uma msg IP mal formada
  def test_IP_FALHA_3
    msg_out = "IP acari lixo"
    msg_esperada = "FALHA"
    sock = UDPSocket.new
    sock.connect($central_ip, $central_porta)
    sock.print(msg_out)
    msg_in = sock.recvfrom(20)[0]
    assert_equal(msg_esperada, msg_in)
  end
    
  #Testa uma msg REG com resposta REGFALHA
  def test_REG_REGFALHA
    msg_out = "REG #{$dominio_registrado} 127.0.0.1"
    msg_esperada = "REGFALHA"
    sock = UDPSocket.new
    sock.connect($central_ip, $central_porta)
    sock.print(msg_out)
    msg_in = sock.recvfrom(20)[0]
    assert_equal(msg_esperada, msg_in)
  end

  #Testa uma msg REG mal formada
  def test_REG_FALHA
    msg_out = "REG lajes "
    msg_esperada = "FALHA"
    sock = UDPSocket.new
    sock.connect($central_ip, $central_porta)
    sock.print(msg_out)
    msg_in = sock.recvfrom(20)[0]
    assert_equal(msg_esperada, msg_in)
  end

  #Testa uma msg REG com resposta REGOK
  def test_REG_REGOK
    msg_out = "REG macau 10.0.1.28"
    msg_esperada = "REGOK"
    sock = UDPSocket.new
    sock.connect($central_ip, $central_porta)
    sock.print(msg_out)
    msg_in = sock.recvfrom(20)[0]
    assert_equal(msg_esperada, msg_in)
  end

end