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
    limitePadrao : NAT &
    maxParcelas : NAT & maxParcelas > 0
VARIABLES
    contas, cartoes, faturas, transacoes, saldoCorrente, saldoPoupanca, 
    origemTransacoes, destinoTransacoes, valorTransacoes, limite, titular,
    tipoCartao, bloqueados, statusFatura, totalFatura, faturaCartao, 
    faturaOrdem, faturaAtual, transacoesFatura
    
INVARIANT
    contas <: CONTA &
    cartoes <: CARTAO &
    faturas <: FATURA &
    transacoes <: TRANSACAO &
    saldoCorrente : contas --> NAT &
    saldoPoupanca : contas --> NAT &
    origemTransacoes : transacoes --> contas &
    destinoTransacoes: transacoes --> contas &
    valorTransacoes : transacoes --> INTEGER &
    limite : cartoes +-> NAT  &
    titular : cartoes --> contas &
    tipoCartao : cartoes --> TIPOCARTAO &
    bloqueados <: cartoes &
    statusFatura : faturas --> STATUSFATURA &
    totalFatura : faturas --> NAT &
    faturaCartao: faturas --> tipoCartao~[{credito}] &
    faturaOrdem : faturas --> NAT &
    tipoCartao~[{credito}] = ran(faturaCartao) &
    tipoCartao~[{credito}] = dom(limite) &
    !(c1,c2).( c1 : cartoes & c2 : cartoes 
         & titular(c1) = titular(c2) & tipoCartao(c1) = tipoCartao(c2) => c1 = c2 )&
    !(f1, f2).((f1 : faturas & f2 : faturas & f1 /= f2 & faturaCartao(f1) = faturaCartao(f2)) => 
        faturaOrdem(f1) /= faturaOrdem(f2)) &
    faturaAtual : tipoCartao~[{credito}] --> faturas &
    transacoesFatura : faturas <-> transacoes  

INITIALISATION
    contas := {} || cartoes := {} || faturas := {} || 
    transacoes := {} || saldoCorrente := {} || saldoPoupanca := {} || 
    origemTransacoes := {} || destinoTransacoes := {} ||  valorTransacoes := {} ||
    limite := {} || titular := {} || tipoCartao := {} || bloqueados := {} ||
    statusFatura := {} || totalFatura := {} || faturaCartao := {} || 
    faturaOrdem := {} || faturaAtual := {} || transacoesFatura := {}

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

sacarCorrente(cc, valor) =
    PRE 
        cc: contas & valor : NAT & valor <= saldoCorrente(cc)
    THEN 
        saldoCorrente(cc) := saldoCorrente(cc) - valor ||
        ANY 
            tt 
        WHERE 
            tt : TRANSACAO & tt /: transacoes
        THEN
            transacoes := transacoes \/ {tt} ||
            origemTransacoes(tt) := cc ||
            destinoTransacoes(tt) := cc ||
            valorTransacoes(tt) := -(valor)
        END
    END;

sacarPoupanca(cc, valor) =
    PRE
        cc : contas & valor : NAT & valor <= saldoPoupanca(cc)
    THEN
        saldoPoupanca(cc) := saldoPoupanca(cc) - valor ||
        saldoCorrente(cc) := saldoCorrente(cc) + valor ||
        ANY
            tt
        WHERE
            tt : TRANSACAO & tt /: transacoes
        THEN
           transacoes := transacoes \/ {tt} ||
           origemTransacoes(tt) := cc ||
           destinoTransacoes(tt) := cc ||
           valorTransacoes(tt) := valor
       END
    END;

adicionarCartao(ct, tp, cc) =
    PRE
        ct : CARTAO & ct /: cartoes & tp : TIPOCARTAO & cc : contas & tipoCartao~[{tp}] /\ titular~[{cc}] = {}
    THEN
        cartoes := cartoes \/ {ct} ||
        tipoCartao(ct) := tp ||
        titular(ct) := cc ||
      IF 
          tp = credito 
      THEN
          limite(ct) := limitePadrao  ||
          ANY 
              ff 
          WHERE 
              ff : FATURA & ff /: faturas 
          THEN
              faturas := faturas \/ {ff} ||
              faturaAtual(ct) := ff  ||
              statusFatura(ff) := aberta ||
              totalFatura(ff) := 0 ||   
              faturaCartao(ff) := ct || faturaOrdem(ff) := 0
            END
      END
    END;

hh <-- historico(cc) = 
   PRE 
       cc : contas
   THEN
       hh := origemTransacoes~[{cc}] \/ destinoTransacoes~[{cc}]
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




