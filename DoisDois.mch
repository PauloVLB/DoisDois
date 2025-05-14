MACHINE 
    DoisDois
    
SETS 
    CONTA; FATURA; CARTAO; TRANSACAO;
    STATUSFATURA = {paga, vencida, aberta};
    TIPOCARTAO = {credito, debito};
    TIPOTRANSACAO = {saqueCorrente, saquePoupanca, depositoCredito, depositoCorrente, tranCredito, tranDebito}

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
    tipoCartao, bloqueados, faturaAtual, statusFatura, totalFatura, faturaCartao, 
    faturaOrdem, tipoTransacoes
    
INVARIANT
    contas <: CONTA &
    cartoes <: CARTAO &
    faturas <: FATURA &
    transacoes <: TRANSACAO &
    saldoCorrente : contas --> NAT &
    saldoPoupanca : contas --> NAT &
    origemTransacoes : transacoes --> contas &
    destinoTransacoes: transacoes --> contas &
    valorTransacoes : transacoes --> NAT &
    tipoTransacoes : transacoes --> TIPOTRANSACAO &
    limite : cartoes +-> NAT  &
    titular : cartoes >-> contas &
    tipoCartao : cartoes --> TIPOCARTAO &
    bloqueados <: cartoes &
    statusFatura : faturas --> STATUSFATURA &
    totalFatura : faturas --> NAT &
    faturaCartao: faturas --> cartoes &
    faturaOrdem : faturas --> NAT &
    tipoCartao~[{credito}] = dom(limite) &
    tipoCartao~[{credito}] = ran(faturaCartao) &
    !(f1, f2).((f1 : faturas & f2 : faturas & f1 /= f2 & faturaCartao(f1) = faturaCartao(f2)) => 
        faturaOrdem(f1) /= faturaOrdem(f2)) &
    faturaAtual : tipoCartao~[{credito}] --> faturas 

INITIALISATION
    contas := {} || cartoes := {} || faturas := {} || 
    transacoes := {} || saldoCorrente := {} || saldoPoupanca := {} || 
    origemTransacoes := {} || destinoTransacoes := {} ||  valorTransacoes := {} ||
    limite := {} || titular := {} || tipoCartao := {} || bloqueados := {} ||
    faturaAtual := {} || statusFatura := {} || totalFatura := {} ||
    faturaCartao := {} || faturaOrdem := {} || tipoTransacoes := {}

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
            valorTransacoes(tt) := valor ||
            tipoTransacoes(tt) := saqueCorrente
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
           valorTransacoes(tt) := valor ||
           tipoTransacoes(tt) := saquePoupanca
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
              faturaCartao(ff) := ct || 
	          faturaOrdem(ff) := 0 
            END
      END
    END;
    
removerCartao(ct) =
    PRE
        ct : cartoes & ((tipoCartao(ct) = credito) => (faturaCartao~[{ct}] <: statusFatura~[{paga}] \/ totalFatura~[{0}]))
    THEN
        cartoes := cartoes - {ct} ||
        bloqueados := cartoes - {ct} ||
        tipoCartao := {ct} <<| tipoCartao ||
        titular := {ct} <<| titular ||
        IF 
            tipoCartao(ct) = credito
        THEN 
            limite := {ct} <<| limite ||
            LET 
                fCartao BE fCartao = faturaCartao~[{ct}]
            IN
                faturas := faturas - fCartao ||
                statusFatura := fCartao <<| statusFatura ||
                totalFatura := fCartao <<| totalFatura ||
                faturaCartao := fCartao <<| faturaCartao ||
                faturaOrdem := fCartao <<| faturaOrdem ||
                faturaAtual := {ct} <<| faturaAtual
            END
        END
     END;
     
pagarFatura(cc, ff) = 
    PRE 
        cc : contas & ff : faturas & statusFatura(ff) /= paga & 
        totalFatura(ff) > 0 & saldoCorrente(cc) >= totalFatura(ff)
    THEN
        saldoCorrente(cc) := saldoCorrente(cc) - totalFatura(ff) ||
        statusFatura(ff) := paga
    END;
    
ida <-- compraParcelada(origem, destino, valor, parcelas) =
    PRE origem : cartoes & destino : contas & titular(origem) /= destino & 
        valor : NAT & parcelas : NAT & parcelas <= maxParcelas & 
        limite(origem) >= valor & origem /: bloqueados 
        /*Conta tem que possuir cartão*/
        /*Valor dentro do limite do cartão*/
    THEN
        /*Transação unica para destino*/
        /* parcelas para origem, cada uma em uma fatura*/
        ida := 0
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




