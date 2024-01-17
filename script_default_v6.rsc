# jan/17/2024 09:15:56 by RouterOS 6.49.11
# software id = 
#
#
#
# Adiciona um interface Bridge
/interface bridge add comment="*** BRIDGE LOCAL ***" name=BR-LOCAL

# Comenta na ether1 que e a entrada de link
/interface ethernet set [ find default-name=ether1 ] comment="*** CONECTADO A INTERNET ***"

/interface list add name=ISP
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik

# Altera o tempo de tracking TCP para 6h
/ip firewall connection tracking set tcp-established-timeout=6h

# Retira a opcao Neighbors da Interface-List ISP (Nao deixa a operadora descobrir seu MikroTik)
/ip neighbor discovery-settings set discover-interface-list=!ISP

# Adiciona a ether1 na Lista ISP
/interface list member add interface=ether1 list=ISP
/ip dhcp-client add disabled=no interface=ether1

# Adiciona DNS manualmente
/ip dns set servers=8.8.8.8,1.1.1.1

# Adiciona Address-List de suporte
/ip firewall address-list add address=0.0.0.0/0 list=SUPORTE

# CONFIGURACAO DE FIREWALL
/ip firewall filter add action=accept chain=input comment="===== ACEITA ESTAB" connection-state=established,related,untracked
/ip firewall filter add action=accept chain=input comment="===== ACEITA WINBOX REMOTO" dst-port=9090 in-interface-list=ISP protocol=tcp
/ip firewall filter add action=accept chain=input comment="===== ACEITA WINBOX LOCAL" dst-port=9090 protocol=tcp src-address-list=SUPORTE
/ip firewall filter add action=accept chain=input comment="===== ACEITA ICMP 100/s" limit=100,5:packet protocol=icmp
/ip firewall filter add action=add-src-to-address-list address-list=PORTSCAN address-list-timeout=5d chain=input comment="===== DETECTA PORTSCAN" in-interface-list=ISP protocol=tcp psd=21,5s,3,1
/ip firewall filter add action=add-src-to-address-list address-list=PORTSCAN address-list-timeout=5d chain=input comment="===== DETECTA PORTAS VULNERAVEIS" dst-port=20-25,3389,8291 in-interface-list=ISP protocol=tcp
/ip firewall filter add action=drop chain=input comment="===== DROP INVALIDAS" connection-state=invalid
/ip firewall filter add action=drop chain=input comment="===== DROP GERAL" 
/ip firewall nat add action=masquerade chain=srcnat comment="===== MASQUERADE " out-interface-list=ISP
/ip firewall raw add action=drop chain=prerouting comment="===== DROP PORTSCAN" src-address-list=PORTSCAN

# Desabilita todos os servicos (exceto Winbox) e coloca o Winbox para a porta 9090
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set ssh disabled=yes
/ip service set api disabled=yes
/ip service set winbox port=9090
/ip service set api-ssl disabled=yes

# Adiciona o relogio para o Time-Zone Sao Paulo
/system clock set time-zone-name=America/Sao_Paulo

# Adiciona NTP Client para atualizacao de Data e Hora (Servidores BR)
/system ntp client set enabled=yes primary-ntp=200.160.0.8 secondary-ntp=200.189.40.8


# Criado por Yan Nobrega
# Data: 17/01/2024
# CoreX Tecnologia