MACHINE 
    DoisDois
    
SETS 
    CONTA; FATURA; CARTAO; TRANSACAO;
    STATUSFATURA = {paga, vencida, aberta};
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
    limite, statusFatura, totalFatura,
    titular, tipoCartao, bloqueados, origemTransacoes, destinoTransacoes,
    valorTransacoes, historico, transacoesFatura, faturaAtual, faturaOrdem, faturaCartao
    
INVARIANT
    contas <: CONTA &
    cartoes <: CARTAO &
    faturas <: FATURA &
    transacoes <: TRANSACAO &
    saldoCorrente : contas --> NAT &
    saldoPoupanca : contas --> NAT &
    limite : cartoes +-> NAT  &
    titular : cartoes --> contas &
    tipoCartao : cartoes --> TIPOCARTAO &
    bloqueados <: cartoes &
    origemTransacoes : transacoes --> contas &
    destinoTransacoes: transacoes --> contas &
    valorTransacoes : transacoes --> NAT &
    historico : contas --> POW(transacoes) &
    statusFatura : faturas --> STATUSFATURA &
    totalFatura : faturas --> NAT &
    faturaCartao: faturas --> cartoes &
    faturaOrdem : faturas --> NAT &
    transacoesFatura: faturas --> POW(transacoes) &
    faturaAtual : cartoes >+> faturas &
    tipoCartao~[{credito}] = dom(faturaAtual) &
    tipoCartao~[{credito}] = ran(faturaCartao) &
    tipoCartao~[{credito}] = dom(limite) & /* Todo cr estabelece ordem das faturas */
    !(c1,c2).( c1 : cartoes & c2 : cartoes 
          & titular(c1) = titular(c2) & tipoCartao(c1) = tipoCartao(c2) => c1 = c2 ) &
    !(f1, f2).((f1 : faturas & f2 : faturas & f1 /= f2 & faturaCartao(f1) = faturaCartao(f2)) => 
        faturaOrdem(f1) /= faturaOrdem(f2))
    
INITIALISATION
    contas := {} || cartoes := {} || faturas := {} || transacoes := {} || saldoCorrente := {} || saldoPoupanca := {} || 
    limite := {} || statusFatura := {} || totalFatura := {}  || faturaOrdem := {} || faturaCartao := {} ||
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
    END;

adicionarCartao(cc, tc, acc) =
    PRE
     cc : CARTAO & cc /: cartoes & tc : TIPOCARTAO & acc : contas & tipoCartao~[{tc}] /\ titular~[{acc}] = {}
    THEN
      cartoes := cartoes \/ {cc} ||
      tipoCartao(cc) := tc ||
      titular(cc) := acc ||
      IF 
          tc = credito 
      THEN
        limite(cc) := limitePadrao  ||
        ANY ff WHERE ff : FATURA & ff /: faturas 
        THEN
          faturas := faturas \/ {ff} ||
          faturaAtual(cc) := ff  ||
          statusFatura(ff) := aberta ||
          totalFatura(ff) := 0 ||
          transacoesFatura(ff) := {} ||     
          faturaCartao(ff) := cc || faturaOrdem(ff) := 0
        END
      END
    END
          
END




