MACHINE
    DoisDois_Ctx
    
SETS 
    CONTA; FATURA; CARTAO; TRANSACAO;
    STATUSFATURA = {paga, vencida, aberta};
    TIPOCARTAO = {credito, debito};
    TIPOTRANSACAO = {saqueCorrente, saquePoupanca, depositoCorrente, depositoPoupanca, tranCredito, tranDebito}

CONSTANTS         
    taxaRendimento, jurosFatura, maxParcelas, limiteMaxPadrao    

PROPERTIES        
    taxaRendimento : NAT1 & jurosFatura : NAT1 & 
    limiteMaxPadrao : NAT & maxParcelas : NAT1 

END
