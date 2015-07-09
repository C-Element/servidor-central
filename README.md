## servidor-central
Trabalho do Primeiro Bimestre da Disciplina de Programação Para redes

Implementação de um servidor de nomes de domínios, baseado em UDP e utilizando a porta 2100.

### Protocolo do servidor:

#### Registrando o nome:
**Cliente** *=== REG nome_do_dominio ip_no_formato_ipv4 ==>* **Servidor**
###### Se os parâmetros estiverem correto:
**Cliente** *<=============== REGOK ==================* **Servidor**
###### Caso contrário:
**Cliente** *<================ REGFALHA ==============* **Servidor**

#### Consultado o nome:
**Cliente** *====== IP nome_do_dominio =====>* **Servidor**
###### Se o nome já estiver sido registrado:
**Cliente** *<==== IPOK ip_no_formato_ipv4 ====* **Servidor**
###### Caso contrário:
**Cliente** *<=========== IPFALHA ==========* **Servidor**

#### Requisições inválidas:
**Cliente** *====== requisicao invalida =====>* **Servidor**
#
**Cliente** *<========== FALHA =========* **Servidor**

