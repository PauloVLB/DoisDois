MACHINE 
    DoisDois
    
SEES
    DoisDois_Ctx
    
VARIABLES
    contas, cartoes, faturas, transacoes, saldoCorrente, saldoPoupanca, 
    origemTransacoes, destinoTransacoes, valorTransacoes, limite, titular,
    tipoCartao, bloqueados, faturaAtual, statusFatura, totalFatura, faturaCartao, 
    faturaOrdem, tipoTransacoes, limiteMax, contasRemovidas
    
INVARIANT
    contas <: CONTA &
    contasRemovidas <: CONTA & 
    cartoes <: CARTAO &
    faturas <: FATURA &
    transacoes <: TRANSACAO &
    saldoCorrente : contas --> NAT &
    saldoPoupanca : contas --> NAT &
    origemTransacoes : transacoes --> CONTA &
    destinoTransacoes: transacoes --> CONTA &
    valorTransacoes : transacoes --> NAT &
    tipoTransacoes : transacoes --> TIPOTRANSACAO &
    titular : cartoes --> contas &
    tipoCartao : cartoes --> TIPOCARTAO &
    
    limite : creditos --> NAT  &
    limiteMax : creditos --> NAT &
    bloqueados <: cartoes &
    statusFatura : faturas --> STATUSFATURA &
    totalFatura : faturas --> NAT &
    faturaCartao: faturas --> creditos &
    faturaOrdem : faturas --> NAT &
    faturaAtual : creditos >-> faturas &
    
    !(f1, f2).((f1 : faturas & f2 : faturas & f1 /= f2 & faturaCartao(f1) = faturaCartao(f2)) => 
        faturaOrdem(f1) /= faturaOrdem(f2)) &
    !(c1,c2).( c1 : cartoes & c2 : cartoes 
         & titular(c1) = titular(c2) & tipoCartao(c1) = tipoCartao(c2) => c1 = c2 ) &
    !ct.(ct : creditos => (ordensFaturas(ct) = 0 .. (card( faturaCartao~[{ct}] ) - 1 ))) &
    (faturaAtual;faturaCartao) = id(creditos) &
    !ct.(ct : creditos => limite(ct) <= limiteMax(ct)) &
    
    contas /\ contasRemovidas = {}

DEFINITIONS     
    creditos == tipoCartao~[{credito}];    
    transCredito == tipoTransacoes~[{tranCredito}];
    ordemAtual(ct) == faturaOrdem(faturaAtual(ct));      
    /* faturas que receberão parcelas */
    faturasExistentes(ct, parcelas) == 
        { fe | fe : faturas & faturaCartao(fe) = ct &
                              faturaOrdem(fe) : (ordemAtual(ct) .. (ordemAtual(ct) + parcelas - 1))};
    ordensFaturas(ct) == ran(faturaCartao~[{ct}] <| faturaOrdem);
    transacoesDuplicadas(cc) == 
        (( origemTransacoes~[{cc}] /\ tipoTransacoes~[{depositoCorrente}] ) - destinoTransacoes~[{cc}])
        \/ (( destinoTransacoes~[{cc}] /\ tipoTransacoes~[{tranCredito}] ) - origemTransacoes~[{cc}]);
    conjuntoHistorico == (origemTransacoes~[{cc}] \/ destinoTransacoes~[{cc}]) - transacoesDuplicadas(cc)

INITIALISATION
    contas := {} || contasRemovidas := {} || cartoes := {} || faturas := {} || 
    transacoes := {} || saldoCorrente := {} || saldoPoupanca := {} || 
    origemTransacoes := {} || destinoTransacoes := {} ||  valorTransacoes := {} ||
    limite := {} || titular := {} || tipoCartao := {} || bloqueados := {} ||
    faturaAtual := {} || statusFatura := {} || totalFatura := {} ||
    faturaCartao := {} || faturaOrdem := {} || tipoTransacoes := {} || 
    limiteMax := {}

OPERATIONS
    
adicionarConta(cc) =
    PRE
        cc : CONTA &
        cc /: contas &
        cc /: contasRemovidas
    THEN
        contas := contas \/ {cc} ||
        saldoCorrente(cc) := 0 ||
        saldoPoupanca(cc) := 0 
    END;

depositarCorrente(cc, valor) =
    PRE
        cc : CONTA & cc : contas & valor : NAT & saldoCorrente(cc) + valor : NAT
    THEN
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
            tipoTransacoes(tt) := depositoCorrente
        END
    END;

depositarPoupanca(cc, valor) =
    PRE
        cc : CONTA & cc : contas & valor : NAT & saldoPoupanca(cc) + valor : NAT
    THEN
        saldoPoupanca(cc) := saldoPoupanca(cc) + valor ||
        ANY
            tt
        WHERE
            tt : TRANSACAO & tt /: transacoes
        THEN
            transacoes := transacoes \/ {tt} ||
            origemTransacoes(tt) := cc ||
            destinoTransacoes(tt) := cc ||
            valorTransacoes(tt) := valor ||
            tipoTransacoes(tt) := depositoPoupanca
        END
    END;
        
sacarCorrente(cc, valor) =
    PRE 
        cc : CONTA & cc: contas & valor : 1..saldoCorrente(cc)
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
        cc : CONTA & cc : contas & valor : 1..saldoPoupanca(cc) & saldoCorrente(cc) + valor : NAT
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
        ct : CARTAO & ct /: cartoes & tp : TIPOCARTAO & cc : CONTA & 
        cc : contas & tipoCartao~[{tp}] /\ titular~[{cc}] = {}
    THEN
        cartoes := cartoes \/ {ct} ||
        tipoCartao(ct) := tp ||
        titular(ct) := cc ||
      IF 
          tp = credito
      THEN
          limiteMax(ct) := limiteMaxPadrao ||
          limite(ct) := limiteMaxPadrao ||
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
        ct : CARTAO & ct : cartoes & ((tipoCartao(ct) = credito) => (faturaCartao~[{ct}] <: statusFatura~[{paga}] \/ totalFatura~[{0}]))
    THEN
        cartoes := cartoes - {ct} ||
        bloqueados := cartoes - {ct} ||
        tipoCartao := {ct} <<| tipoCartao ||
        titular := {ct} <<| titular ||
        LET 
            faturasCartao 
        BE 
            faturasCartao = faturaCartao~[{ct}] 
        IN
            limite := {ct} <<| limite ||
            limiteMax := {ct} <<| limiteMax ||
            faturas := faturas - faturasCartao ||
            statusFatura := faturasCartao <<| statusFatura ||
            totalFatura := faturasCartao <<| totalFatura ||
            faturaCartao := faturasCartao <<| faturaCartao ||
            faturaOrdem := faturasCartao <<| faturaOrdem ||
            faturaAtual := {ct} <<| faturaAtual 
        END
     END;
     
pagarFatura(cc, ff) = 
    PRE 
        cc : CONTA & cc : contas & 
        ff : FATURA & ff : faturas & statusFatura(ff) /= paga & 
        totalFatura(ff) > 0 & saldoCorrente(cc) >= totalFatura(ff)
    THEN
        saldoCorrente(cc) := saldoCorrente(cc) - totalFatura(ff) ||
        statusFatura(ff) := paga 
    END;
    
compraParcelada(origem, destino, valor, parcelas) =
    PRE origem : CARTAO & destino : CONTA &
        origem : cartoes & origem : creditos & destino : contas & 
        titular(origem) /= destino & 
        valor : NAT1 & parcelas : 1..maxParcelas & 
        (valor mod parcelas) = 0 &
        origem /: bloqueados &
        (valor / parcelas) <= limite(origem) 
    THEN
       LET 
           ordensAusentes, parcela
       BE 
           /*ordensAusentes = ordensNecessarias - ordensExistentes*/
           ordensAusentes = (ordemAtual(origem) .. (ordemAtual(origem) + parcelas - 1)) - 
                             faturaOrdem[faturasExistentes(origem, parcelas)] &
           parcela = (valor / parcelas)
       IN
           ANY 
               tDestino, tOrigem,
               novasFaturas, novaOrdem 
           WHERE
               tDestino : TRANSACAO & tDestino /: transacoes &
               tOrigem <: TRANSACAO - (transacoes \/ {tDestino}) &
               tOrigem : FIN(tOrigem) & card(tOrigem) = parcelas &
               
               novasFaturas <: FATURA - faturas & novasFaturas : FIN(novasFaturas) &
               card(novasFaturas) = card(ordensAusentes) &
               novaOrdem : novasFaturas >->> ordensAusentes 
           THEN
               /*transações na conta de origem e destino*/
               transacoes := transacoes \/ {tDestino} \/ tOrigem ||
               origemTransacoes := origemTransacoes \/ {tDestino |-> titular(origem)} \/ (tOrigem * {titular(origem)}) ||
               destinoTransacoes := destinoTransacoes \/ {tDestino |-> destino} \/ (tOrigem * {destino}) ||
               valorTransacoes := valorTransacoes \/ {tDestino |-> valor} \/ (tOrigem * {parcela}) ||
               tipoTransacoes := tipoTransacoes \/ {tDestino |-> depositoCorrente} \/ (tOrigem * {tranCredito})  ||
               saldoCorrente(destino) := saldoCorrente(destino) + valor ||
               
               limite(origem) := limite(origem) - parcela ||
               /*criar faturas novas*/
               faturas := faturas \/ novasFaturas ||
               statusFatura := statusFatura \/ (novasFaturas * {aberta}) ||
               faturaCartao := faturaCartao \/ (novasFaturas * {origem}) ||
               faturaOrdem := faturaOrdem \/ novaOrdem ||
               totalFatura := totalFatura <+ (%ff.(ff : faturasExistentes(origem, parcelas) | totalFatura(ff) + parcela) \/  (novasFaturas * {parcela}))  
           END 
       END 
    END;
    
realizarTranscao(co, cd, valor) =
    PRE
        co : CONTA & cd : CONTA &
        co : contas & cd : contas & valor : 1..saldoCorrente(co) & saldoCorrente(cd) + valor : NAT &
        co /= cd
    THEN
        saldoCorrente := saldoCorrente <+ {co |-> saldoCorrente(co) - valor, cd |-> saldoCorrente(cd) + valor} ||
        ANY
            tt
        WHERE
            tt : TRANSACAO & tt /: transacoes
        THEN
            transacoes := transacoes \/ {tt} ||
            origemTransacoes(tt) := co ||
            destinoTransacoes(tt) := cd ||
            valorTransacoes(tt) := valor ||
            tipoTransacoes(tt) := tranDebito
        END
    END;
    

hh <-- historico(cc) = 
   PRE 
       cc : CONTA & cc : contas
   THEN
      ANY hhList
      WHERE
          hhList : 0..card(conjuntoHistorico)-1 +-> TRANSACAO &
          ran(hhList) = conjuntoHistorico
      THEN
          hh := hhList
      END
   END;
   
sc, sp <-- consultarSaldos(cc) = 
    PRE 
        cc : CONTA & cc : contas
    THEN
        sc := saldoCorrente(cc) || sp := saldoPoupanca(cc)
    END;

bloquearCartao(ct) =
    PRE 
        ct : CARTAO & ct : cartoes & ct /: bloqueados
    THEN 
        bloqueados := bloqueados \/ {ct}
    END;

desbloquearCartao(ct) = 
    PRE 
        ct : CARTAO & ct : cartoes & ct : bloqueados
    THEN
       bloqueados := bloqueados - {ct}
    END;
    
atualizarLimiteMax(ct, valor) =
    PRE 
        ct : CARTAO & ct: creditos & ct /: bloqueados & valor : NAT
    THEN
        limiteMax(ct) := valor ||
        IF 
            limite(ct) > valor
        THEN
            limite(ct) := valor
        END
    END;
    
atualizarLimite(ct, valor) = 
    PRE 
      ct : CARTAO & ct : creditos & ct /: bloqueados & valor : 0..limiteMax(ct)
    THEN
      limite(ct) := valor
    END;

vf <-- consultarValorFatura(ct) =
    PRE
        ct : CARTAO & ct : creditos
    THEN
        vf := totalFatura(faturaAtual(ct))
    END;
    
ctConta <-- consultarCartoesConta(cc) = 
    PRE 
        cc : CONTA & cc : contas
    THEN
        ANY ctContaList
        WHERE
            titular~[{cc}]: FIN(titular~[{cc}]) &
            ctContaList : 0..card(titular~[{cc}])-1 +-> CARTAO &
            ran(ctContaList) = titular~[{cc}]
        THEN
            ctConta := ctContaList    
        END
    END;
    
ll <-- consultarLimite(ct) = 
    PRE
        ct : CARTAO & ct : creditos
    THEN
        ll := limite(ct)
    END;

lm <-- consultarLimiteMax(ct) = 
    PRE
        ct : CARTAO & ct : creditos
    THEN
        lm := limiteMax(ct)
    END;
    
oo, dd, vv, tp <-- consultarTransacao(tt) = 
    PRE
        tt : TRANSACAO & tt : transacoes
    THEN
        oo := origemTransacoes(tt) || dd := destinoTransacoes(tt) || 
        vv := valorTransacoes(tt) || tp := tipoTransacoes(tt)
    END;

removerConta(cc) = 
    PRE
        cc : CONTA &
        cc : contas &
        cc /: contasRemovidas &
        !ct . ((ct : creditos & titular(ct) = cc) => (faturaCartao~[{ct}] <: statusFatura~[{paga}] \/ totalFatura~[{0}]))
    THEN
        LET
            cts
        BE
            cts = titular~[{cc}]
        IN
            cartoes := cartoes - cts ||
            bloqueados := cartoes - cts ||
            tipoCartao := cts <<| tipoCartao ||
            titular := titular |>> {cc} ||
            LET 
                faturasCartao 
            BE 
                faturasCartao = faturaCartao~[cts] 
            IN
                limite := cts <<| limite ||
                limiteMax := cts <<| limiteMax ||
                faturas := faturas - faturasCartao ||
                statusFatura := faturasCartao <<| statusFatura ||
                totalFatura := faturasCartao <<| totalFatura ||
                faturaCartao := faturasCartao <<| faturaCartao ||
                faturaOrdem := faturasCartao <<| faturaOrdem ||
                faturaAtual := cts <<| faturaAtual 
                
            END
        END ||
        contas := contas - {cc} ||
        saldoCorrente := {cc} <<| saldoCorrente ||
        saldoPoupanca := {cc} <<| saldoPoupanca ||
        contasRemovidas := contasRemovidas \/ {cc}
    END;

ccs <-- consultarContas = 
    ANY ccList
    WHERE
          ccList : 0..card(contas)-1 +-> CONTA &
          ran(ccList) = contas
    THEN
          ccs := ccList
    END;
    
ftCartao <-- consultarFaturasCartao(ct) = 
    PRE 
        ct : CARTAO & ct : cartoes & faturaCartao~[{ct}] : FIN(faturaCartao~[{ct}])
    THEN
        ANY ffList
        WHERE
              ffList : 0..card(faturaCartao~[{ct}])-1 +-> FATURA &
              ran(ffList) = faturaCartao~[{ct}]
        THEN
              ftCartao := ffList
        END
    END;

ct, tt, oo, st, atual <-- consultarFatura(ff) =
    PRE 
        ff : FATURA & ff : faturas
    THEN
        tt := totalFatura(ff) ||
        oo := faturaOrdem(ff) || st := statusFatura(ff) ||
        ANY 
            cartao 
        WHERE 
            cartao : CARTAO & cartao : cartoes & cartao = faturaCartao(ff)
        THEN
            ct := cartao ||
            IF 
                faturaAtual(cartao) = ff
            THEN
                atual := TRUE
            ELSE
                atual := FALSE
            END
        END
    END;
    

passarTempo = skip

END



