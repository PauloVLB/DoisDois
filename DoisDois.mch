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
    historico : contas --> POW(transacoes) &
    statusFatura : faturas --> STATUSFATURA &
    totalFatura : faturas --> NAT &
    ordemFatura: cartoes +-> (NAT >+> faturas) &
    transacoesFatura: faturas  -->  transacoes &
    faturaAtual : cartoes +-> faturas &
    tipoCartao~[{credito}] = dom(limite) &
    tipoCartao~[{credito}] = dom(faturaAtual) & /* Todo cr deve ter fatura atual e toda fatura é de um cr */
    tipoCartao~[{credito}] = dom(ordemFatura) & /* Todo cr estabelece ordem das faturas */
    !(c1,c2).( c1 : cartoes & c2 : cartoes 
          & titular(c1) = titular(c2) & tipoCartao(c1) = tipoCartao(c2) => c1 = c2 ) &
    !ff.( ff : faturas => #(cc,nn) .( cc : cartoes & nn : dom(ordemFatura(cc)) & (ordemFatura(cc))(nn) = ff ) ) & /*Toda fatura de um cartão deve estar associada a um índice de ordem */
    !cc.(cc : contas => historico(cc) = origemTransacoes~[{cc}] \/ destinoTransacoes~[{cc}])
    
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
        saldoPoupanca := saldoPoupanca \/ {cc |-> 0} ||
        historico := historico \/ {cc |-> {}}
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




