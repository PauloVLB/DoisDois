MACHINE 
    DoisDois
    
SETS 
    CONTA; FATURA; CARTAO; TRANSACAO;
    STATUSFATURA = {paga, vencida};
    TIPOCARTAO = {credito, debito}

CONSTANTS         
    taxaRendimento, jurosFatura, limitePadrao, maxParcelas    

PROPERTIES        
    taxaRendimento : NAT & taxaRendimento > 0 &
    jurosFatura : NAT & jurosFatura > 0 &
    limitePadrao : NAT & limitePadrao >= 0 &
    maxParcelas : NAT & maxParcelas > 0
VARIABLES
    contas, cartoes, faturas, transacoes, saldoCorrente, saldoPoupanca, 
    limite, statusFatura, totalFatura, ordemFatura,
    titular, tipoCartao, bloqueados, origemTransacoes, destinoTransacoes,
    valorTransacoes, historico, transacoesFatura, faturaAtual
    
INVARIANT
    contas <: CONTA &
    cartoes <: CARTAO &
    faturas <: FATURA &
    transacoes <: TRANSACAO &
    saldoCorrente : contas  --> NAT &
    saldoPoupanca : contas  --> NAT &
    limite : cartoes --> NAT  &
    titular : cartoes --> contas &
    tipoCartao : cartoes --> TIPOCARTAO &
    bloqueados <: cartoes &
    origemTransacoes : transacoes --> contas &
    destinoTransacoes: transacoes --> contas &
    valorTransacoes : transacoes --> NAT &
    historico = origemTransacoes ~ \/ destinoTransacoes~ &
    statusFatura : faturas --> STATUSFATURA &
    totalFatura : faturas --> NAT &
    ordemFatura: contas +-> (NAT >+> faturas) &
    transacoesFatura: faturas  -->  transacoes &
    faturaAtual : contas  +-> faturas &
    tipoCartao~[{credito}] = dom(limite)
    
INITIALISATION
      contas := {} || cartoes := {} || faturas := {} || transacoes := {} || saldoCorrente := {} || saldoPoupanca := {} || 
    limite := {} || statusFatura := {} || totalFatura := {} || ordemFatura := {} ||
    titular := {} || tipoCartao := {} || bloqueados := {} || origemTransacoes := {} || destinoTransacoes := {} ||
    valorTransacoes := {} || historico := {} || transacoesFatura := {} || faturaAtual := {}
    
OPERATIONS

adicionarConta(cc) =
    PRE
        cc : CONTA &
        cc /: contas 
    THEN
        contas := contas \/ {cc} ||
        saldoCorrente := saldoCorrente \/ {cc |-> 0} ||
        saldoPoupanca := saldoPoupanca \/ {cc |-> 0}
    END;
    

removerConta(cc) = 
    PRE
        cc : CONTA &
        cc : contas
    THEN
        contas := contas - {cc} ||
        cartoes := cartoes - titular~[{cc}] ||
        limite := titular~[{cc}] <<| limite ||
        saldoCorrente := {cc} <<| saldoCorrente ||
        saldoPoupanca := {cc} <<| saldoPoupanca ||
        titular := titular |>> {cc}
    END
    
          
END




