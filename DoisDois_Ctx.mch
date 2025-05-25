MACHINE
    DoisDois_Ctx
    
SETS 
    CONTA; FATURA; CARTAO; TRANSACAO;
    STATUSFATURA = {paga, vencida, aberta};
    TIPOCARTAO = {credito, debito};
    TIPOTRANSACAO = {saqueCorrente, saquePoupanca, depositoCorrente, depositoPoupanca, tranCredito, tranDebito, tranPix}

CONSTANTS         
    taxaRendimento, jurosFatura, maxParcelas, limiteMaxPadrao, 
    saqueMinCorrente, saqueMinPoupanca    

PROPERTIES        
    taxaRendimento : NAT1 & jurosFatura : NAT1 & 
    limiteMaxPadrao : NAT & maxParcelas : NAT1 &
    saqueMinCorrente : NAT1& saqueMinPoupanca : NAT1 

END
