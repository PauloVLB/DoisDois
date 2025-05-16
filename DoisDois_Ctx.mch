MACHINE
    DoisDois_Ctx
    
SETS 
    CONTA; FATURA; CARTAO; TRANSACAO;
    STATUSFATURA = {paga, vencida, aberta};
    TIPOCARTAO = {credito, debito};
    TIPOTRANSACAO = {saqueCorrente, saquePoupanca, depositoCredito, depositoCorrente, tranCredito, tranDebito}

CONSTANTS         
    taxaRendimento, jurosFatura, limitePadrao, maxParcelas    

PROPERTIES        
    taxaRendimento : NAT1 & jurosFatura : NAT1 & 
    limitePadrao : NAT & maxParcelas : NAT1 

END
