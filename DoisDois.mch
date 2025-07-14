MACHINE 
    DoisDois
    
SETS 
    CONTA; FATURA; CARTAO; TRANSACAO;
    STATUSFATURA = {paga, vencida, aberta};
    TIPOCARTAO = {credito, debito};
    TIPOTRANSACAO = {saqueCorrente, saquePoupanca, depositoCorrente, depositoPoupanca, tranCredito, tranDebito, tranPix, tranDepositoCartao}

CONSTANTS         
    taxaRendimento, jurosFatura, maxParcelas, limiteMaxPadrao, 
    saqueMinCorrente, saqueMinPoupanca, limitePix,
    contaDummy, cartaoDummy, faturaDummy, 
    maxConta, maxCartao, maxFatura, maxTransacao
    

PROPERTIES        
    maxConta : NAT & card(CONTA) = maxConta + 1 &
    maxCartao : NAT & card(CARTAO) = maxCartao + 1 &
    maxFatura : NAT & card(FATURA) = maxFatura + 1 &
    maxTransacao : NAT & card(TRANSACAO) = maxTransacao + 1 &
    taxaRendimento : NAT1 & jurosFatura : NAT1 & 
    limiteMaxPadrao : NAT & maxParcelas : NAT1 &
    saqueMinCorrente : NAT1& saqueMinPoupanca : NAT1 &
    limitePix : NAT1 & contaDummy : CONTA & cartaoDummy : CARTAO &
    faturaDummy : FATURA 

VARIABLES
    contas, cartoes, faturas, transacoes, saldoCorrente, saldoPoupanca, 
    origemTransacoes, destinoTransacoes, valorTransacoes, limite, titular,
    tipoCartao, bloqueados, faturaAtual, statusFatura, totalFatura, faturaCartao, 
    faturaOrdem, tipoTransacoes, limiteMax, contasRemovidas

    
INVARIANT
    contas <: CONTA & contas : FIN(contas) &
    contasRemovidas <: CONTA & contasRemovidas : FIN(contasRemovidas) &
    cartoes <: CARTAO & cartoes : FIN(cartoes) &
    
    faturas <: FATURA & faturas : FIN(faturas) &
    transacoes <: TRANSACAO & transacoes : FIN(transacoes) &
    
    saldoCorrente : contas --> NAT &
    saldoPoupanca : contas --> NAT &
    
    origemTransacoes : transacoes --> (contas \/ contasRemovidas) &
    destinoTransacoes: transacoes --> (contas \/ contasRemovidas) &
    valorTransacoes : transacoes --> NAT &
    tipoTransacoes : transacoes --> TIPOTRANSACAO &
    
    titular : cartoes --> contas &
    tipoCartao : cartoes --> TIPOCARTAO &
    bloqueados <: cartoes &
    
    limite : cartoes +-> NAT  &
    limiteMax : cartoes +-> NAT &
    dom(limite) = creditos &
    dom(limiteMax) = creditos &
    
    statusFatura : faturas --> STATUSFATURA &
    totalFatura : faturas --> NAT &
    faturaCartao: faturas --> creditos &
    faturaOrdem : faturas --> NAT &
    faturaAtual : cartoes >+> faturas &
    
    dom(faturaAtual) = creditos &
    
    contas /\ contasRemovidas = {} &
    
    /* saques em conta corrente e poupança respeitam mínimo */
    ran((tipoTransacoes~[{saqueCorrente}]) <| valorTransacoes) <: NAT - (0..saqueMinCorrente - 1) &
    ran((tipoTransacoes~[{saquePoupanca}]) <| valorTransacoes) <: NAT - (0..saqueMinPoupanca - 1) &
    
    /* cada conta só pode ter um cartão de cada tipo */
    !(c1,c2).( c1 : cartoes & c2 : cartoes 
         & titular(c1) = titular(c2) & tipoCartao(c1) = tipoCartao(c2) => c1 = c2 ) &
    
    /* o limite de um cartão não ultrapassa o limiteMaximo */
    !cts.(cts : creditos => limite(cts) <= limiteMax(cts)) &
    
    /* nenhum pix passa do limite*/
    valorTransacoes[dom(tipoTransacoes |> {tranPix})] <: 0 .. limitePix &
    
     /* a fatura atual de um cartão é uma fatura desse cartão*/
    !cts.(cts : creditos => faturaCartao(faturaAtual(cts)) = cts) &
    
    /*ordens de faturas formam uma sequência*/
    !cts.(cts : creditos => (ran(faturaCartao~[{cts}] <| faturaOrdem) = 0 .. (card(faturaCartao |> {cts}) - 1 ))) &
    /* nenhuma ordem de fatura se repete no mesmo cartão */
    !(f1, f2).((f1 : faturas & f2 : faturas & f1 /= f2 & faturaCartao(f1) = faturaCartao(f2)) => 
        faturaOrdem(f1) /= faturaOrdem(f2)) 

DEFINITIONS     
    creditos == (tipoCartao~[{credito}]);       
    debitos == tipoCartao~[{debito}];    
    transCredito == tipoTransacoes~[{tranCredito}];
    
    /* faturas que receberão parcelas */
    faturasExistentes(ct, parcelas) == 
        {fe | fe : faturas & faturaCartao(fe) = ct &
                              faturaOrdem(fe) : (faturaOrdem(faturaAtual(ct)) .. (faturaOrdem(faturaAtual(ct)) + parcelas - 1))};
    
    conjuntoHistorico(cc) == (origemTransacoes~[{cc}] - tipoTransacoes~[{tranDepositoCartao}])
      \/ (destinoTransacoes~[{cc}] - tipoTransacoes~[{tranCredito}])
    

INITIALISATION
    contas := {} || contasRemovidas := {} || cartoes := {} || faturas := {} || 
    transacoes := {} || saldoCorrente := {} || saldoPoupanca := {} || 
    origemTransacoes := {} || destinoTransacoes := {} ||  valorTransacoes := {} ||
    limite := {} || titular := {} || tipoCartao := {} || bloqueados := {} ||
    faturaAtual := {} || statusFatura := {} || totalFatura := {} ||
    faturaCartao := {} || faturaOrdem := {} || tipoTransacoes := {} || 
    limiteMax := {}
    
OPERATIONS 
    
ok <-- adicionarConta(cc) =
    PRE
        cc : CONTA 
    THEN
        IF 
            cc /: contas & cc /: contasRemovidas & cc /= contaDummy &
            CONTA - contas - contasRemovidas /= {}
        THEN
            contas := contas \/ {cc} ||
            saldoCorrente(cc) := 0 ||
            saldoPoupanca(cc) := 0 ||
            ok := TRUE
        ELSE
            ok := FALSE
        END
    END;

ok <-- depositarCorrente(cc, valor) =
    PRE
        cc : CONTA & valor : NAT1  
    THEN
        IF cc : contas & saldoCorrente(cc) + valor : NAT1 &
            cc /= contaDummy & TRANSACAO - transacoes /= {}
        THEN
            saldoCorrente(cc) := saldoCorrente(cc) + valor   ||
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
            END ||
            ok := TRUE
        ELSE
            ok := FALSE    
        END
    END;

ok <-- depositarPoupanca(cc, valor) =
    PRE
        cc : CONTA & valor : NAT1  
    THEN
        IF cc : contas & saldoPoupanca(cc) + valor : NAT1 &
            cc /= contaDummy & TRANSACAO - transacoes /= {}
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
            END ||
            ok := TRUE
        ELSE
            ok := FALSE    
        END 
    END;
        
ok <-- sacarCorrente(cc, valor) =
    PRE 
        cc : CONTA & valor : NAT
    THEN 
        IF cc: contas & valor >= 1 & valor >= saqueMinCorrente & 
            valor <= saldoCorrente(cc) & TRANSACAO - transacoes /= {} &
            cc /= contaDummy
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
            END ||
            ok := TRUE
        ELSE
            ok := FALSE
        END
    END;

ok <-- sacarPoupanca(cc, valor) =
    PRE
        cc : CONTA & valor : NAT
    THEN
        IF 
            cc : contas & valor >= 1 & valor >= saqueMinPoupanca &
            valor <= saldoPoupanca(cc) & saldoCorrente(cc) + valor : NAT & 
            TRANSACAO - transacoes /= {} & cc /= contaDummy
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
           END ||
           ok := TRUE
        ELSE
           ok := FALSE
        END
    END;
    
ok <-- adicionarCartao(ct, tp, cc) =
    PRE
        ct : CARTAO & tp : TIPOCARTAO & cc : CONTA
    THEN
        IF 
           ct /: cartoes & cc : contas & tipoCartao~[{tp}] /\ titular~[{cc}] = {} & 
        (tp = credito => (FATURA - faturas /= {})) & ct /= cartaoDummy & cc /= contaDummy &
        CARTAO - cartoes /= {}
        
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
                  ff : FATURA - faturas 
              THEN
                  faturas := faturas \/ {ff} ||
                  faturaAtual(ct) := ff  ||
                  statusFatura(ff) := aberta ||
                  totalFatura(ff) := 0 ||   
                  faturaCartao(ff) := ct || 
    	          faturaOrdem(ff) := 0 
              END
          END ||
              ok := TRUE
         ELSE
             ok := FALSE
         END
    END;
    
ok <-- removerCartao(ct) =
    PRE
        ct : CARTAO 
    THEN
        IF  
            ct : cartoes & (tipoCartao(ct) = credito => dom(faturaCartao |> {ct}) <: (dom(statusFatura |> {paga}) \/ dom (totalFatura  |> {0}))) & ct /= cartaoDummy
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
            END ||
            ok := TRUE
           ELSE
            ok := FALSE
           END
     END;
     
ok <-- pagarFatura(cc, ff) = 
    PRE 
        cc : CONTA & ff : FATURA 
    THEN
        IF 
            cc : contas & ff : faturas & statusFatura(ff) /= paga & 
            totalFatura(ff) > 0 & saldoCorrente(cc) >= totalFatura(ff) &
            titular(faturaCartao(ff)) = cc & cc /= contaDummy & ff /= faturaDummy
        THEN
            saldoCorrente(cc) := saldoCorrente(cc) - totalFatura(ff) ||
            statusFatura(ff) := paga || ok := TRUE
        ELSE
            ok := FALSE
        END
    END;


// dps add proibição de dummy
ok <-- compraParcelada(co, cd, valor, parcelas) =
    PRE co : CARTAO & cd : CONTA &
        valor : NAT1 & parcelas : NAT
    THEN
        IF 
            co : creditos & cd : contas & titular(co) /= cd & parcelas : 1..maxParcelas & 
            (valor / parcelas) : NAT & (valor / parcelas) <= limite(co) &
            saldoCorrente(cd) + valor : NAT &
            !ff.(ff : faturasExistentes(co, parcelas) => (totalFatura(ff) + valor/parcelas) : NAT)
        THEN
            LET 
                ordensAusentes, parcela
            BE 
                ordensAusentes = card(faturaCartao |> {co})..(faturaOrdem(faturaAtual(co)) + parcelas - 1) &
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
                    origemTransacoes := origemTransacoes \/ {tDestino |-> titular(co)} \/ (tOrigem * {titular(co)}) ||
                    destinoTransacoes := destinoTransacoes \/ {tDestino |-> cd} \/ (tOrigem * {cd}) ||
                    valorTransacoes := valorTransacoes \/ {tDestino |-> valor} \/ (tOrigem * {parcela}) ||
                    tipoTransacoes := tipoTransacoes \/ {tDestino |-> tranDepositoCartao} \/ (tOrigem * {tranCredito})  ||
                    saldoCorrente(cd) := saldoCorrente(cd) + valor ||
                    
                    limite(co) := limite(co) - parcela ||
                    /*criar faturas novas*/
                    faturas := faturas \/ novasFaturas ||
                    statusFatura := statusFatura \/ (novasFaturas * {aberta}) ||
                    faturaCartao := faturaCartao \/ (novasFaturas * {co}) ||
                    faturaOrdem := faturaOrdem \/ novaOrdem ||
                    totalFatura := totalFatura <+ (%ff.(ff : faturasExistentes(co, parcelas) | totalFatura(ff) + parcela) \/  (novasFaturas * {parcela}))  
                END 
            END ||
            ok := TRUE
        ELSE
            ok := FALSE
        END
    END
       

// dps add proibição de dummy
ok <-- pix(co, cd, valor) =
    PRE
        co : CONTA & cd : CONTA & valor : NAT
    THEN
        IF
            co : contas & cd : contas & valor : 1..saldoCorrente(co) &
            saldoCorrente(cd) + valor : NAT & co /= cd & valor : 1..limitePix &
            co /= contaDummy & cd /= contaDummy & TRANSACAO - transacoes /= {}
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
                tipoTransacoes(tt) := tranPix ||
                ok := TRUE
            END
        ELSE
            ok := FALSE
        END
    END;
    
ok <-- compraDebito(co, cd, valor) =
    PRE
        co : CARTAO & cd : CONTA & valor : NAT
    THEN
        IF 
            co : debitos & co /: bloqueados &
            cd : contas & valor : 1..saldoCorrente(titular(co)) & saldoCorrente(cd) + valor : NAT &
            titular(co) /= cd & TRANSACAO - transacoes /= {} &
            co /= cartaoDummy & cd /= contaDummy
        THEN
           saldoCorrente := saldoCorrente <+ {titular(co) |-> saldoCorrente(titular(co)) - valor, cd |-> saldoCorrente(cd) + valor} ||
            ANY
                tt
            WHERE
                tt : TRANSACAO & tt /: transacoes
            THEN
                transacoes := transacoes \/ {tt} ||
                origemTransacoes(tt) := titular(co) ||
                destinoTransacoes(tt) := cd ||
                valorTransacoes(tt) := valor ||
                tipoTransacoes(tt) := tranDebito
            END ||
            ok := TRUE
       ELSE
           ok := FALSE
       END
   END;
   
  
ok <-- bloquearCartao(ct) =
    PRE 
        ct : CARTAO 
    THEN 
        IF 
            ct : cartoes & ct /: bloqueados & ct /= cartaoDummy
        THEN
            bloqueados := bloqueados \/ {ct} || ok := TRUE
        ELSE
            ok := FALSE
        END
    END;

ok <-- desbloquearCartao(ct) = 
    PRE 
        ct : CARTAO
    THEN
        IF 
            ct : cartoes & ct : bloqueados & ct /= cartaoDummy
        THEN
           bloqueados := bloqueados - {ct} || ok := TRUE
        ELSE
            ok := FALSE
        END
    END;
    
ok <-- atualizarLimiteMax(ct, valor) =
    PRE 
        ct : CARTAO & 
        valor : NAT 
    THEN
        IF ct: creditos & ct /: bloqueados & valor <= MAXINT & ct /= cartaoDummy THEN
            limiteMax(ct) := valor ||
            IF 
                limite(ct) > valor
            THEN
                limite(ct) := valor
            END ||
            ok := TRUE
        ELSE
            ok := FALSE    
        END
        
    END;
    
ok <-- atualizarLimite(ct, valor) = 
    PRE 
      ct : CARTAO &
      valor : NAT 
    THEN
      IF ct : creditos & ct /: bloqueados & valor : 0..limiteMax(ct) & ct /= cartaoDummy THEN    
          limite(ct) := valor ||
          ok := TRUE
      ELSE
          ok := FALSE
      END
    END;
    

ok <-- removerConta(cc) = 
    PRE
        cc : CONTA 
    THEN
        IF 
            cc : contas & cc /: contasRemovidas &
            !ct . ((ct : creditos & titular(ct) = cc) => (faturaCartao~[{ct}] <: statusFatura~[{paga}] \/ totalFatura~[{0}])) &
            cc /= contaDummy
        THEN
            LET
                cts
            BE
                cts = titular~[{cc}]
            IN
                cartoes := cartoes - cts ||
                bloqueados := bloqueados - cts ||
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
            contasRemovidas := contasRemovidas \/ {cc} ||
            ok := TRUE
        ELSE
            ok := FALSE    
        END
    END;


ok <-- passarMes =
    IF
        ran(saldoPoupanca) <: 0..(MAXINT/taxaRendimento) &
        !ff.((ff : faturas & faturaOrdem(ff) <= faturaOrdem(faturaAtual(faturaCartao(ff))) & (statusFatura(ff) : {vencida, aberta})) 
            => totalFatura(ff) * jurosFatura : NAT)
    THEN
        saldoPoupanca := %cc.(cc : contas | saldoPoupanca(cc) * taxaRendimento) ||
        
        LET
            cartoesSemProximaFatura
        BE
            cartoesSemProximaFatura = {ct | ct : creditos & faturaOrdem(faturaAtual(ct)) = card(faturaCartao |> {ct}) - 1}
        IN
            IF 
                cartoesSemProximaFatura : FIN(cartoesSemProximaFatura) & card(cartoesSemProximaFatura) <= card(TRANSACAO - transacoes)
            THEN
                ANY
                    cartoesComProximaFatura, proximaFaturaExistente,
                    novasFaturas, faturaCartaoNovo, faturaOrdemNovo, ordensCartoesSemProxima
                WHERE
                    cartoesComProximaFatura = creditos - cartoesSemProximaFatura &
                    cartoesSemProximaFatura : FIN(cartoesSemProximaFatura) &
                    cartoesComProximaFatura : FIN(cartoesComProximaFatura) &
                    
                    novasFaturas <: FATURA - faturas & 
                    novasFaturas : FIN(novasFaturas) &
                    card(novasFaturas) = card(cartoesSemProximaFatura) &
                    
                    faturaCartaoNovo : novasFaturas >->> cartoesSemProximaFatura &
                    
                    ordensCartoesSemProxima = %ct.(ct : cartoesSemProximaFatura | faturaOrdem(faturaAtual(ct))) &
                    faturaOrdemNovo = %ff.(ff : novasFaturas | ordensCartoesSemProxima (faturaCartaoNovo(ff)) + 1) &
                    //faturaOrdemNovo = %ff.(ff : novasFaturas | faturaOrdem(faturaAtual(faturaCartaoNovo(ff))) + 1) &
                    //faturaOrdemNovo = %ff.(ff : novasFaturas | 12) &
                    
                    proximaFaturaExistente = {ct, ff | ct : cartoesComProximaFatura & 
                                                       ff : faturas & 
                                                       faturaOrdem(ff) = faturaOrdem(faturaAtual(ct)) + 1 &
                                                       faturaCartao(ff) = ct }
                THEN
                    faturas := faturas \/ novasFaturas ||
                    faturaCartao := faturaCartao \/ faturaCartaoNovo ||
                    faturaOrdem := faturaOrdem \/ faturaOrdemNovo ||
                    faturaAtual := faturaAtual <+ 
                                   (%ct.(ct : cartoesComProximaFatura | proximaFaturaExistente(ct)) \/
                                    %ct.(ct : cartoesSemProximaFatura | faturaCartaoNovo~(ct))) ||
                    statusFatura := statusFatura <+ 
                                %ff.(ff : ran(faturaAtual) & statusFatura(ff) = aberta & totalFatura(ff) > 0 | vencida) <+
                                %ff.(ff : ran(faturaAtual) & statusFatura(ff) = aberta & totalFatura(ff) = 0 | paga) \/
                                novasFaturas * {aberta} ||
                    totalFatura := totalFatura <+ 
                               %ff.(ff : faturas & faturaOrdem(ff) <= faturaOrdem(faturaAtual(faturaCartao(ff))) 
                                     & statusFatura(ff) : {vencida, aberta}
                                   | totalFatura(ff) * jurosFatura) \/ 
                               novasFaturas * {0}
                END ||
                ok := TRUE
             ELSE
                ok := FALSE
             END
         END
    ELSE
        ok := FALSE
    END;
    
    
 ccs <-- consultarContas = 
    ANY ccList
    WHERE
          ccList : CONTA --> BOOL &
          dom(ccList |> {TRUE}) = contas
    THEN
          ccs := ccList
    END;
    
hh, ok <-- historico(cc) = 
   PRE 
       cc : CONTA 
   THEN
      IF 
          cc : contas & cc /= contaDummy
      THEN
          ANY hhList
          WHERE
              hhList : TRANSACAO --> BOOL &
              dom(hhList |> {TRUE}) = conjuntoHistorico(cc)
          THEN
              hh := hhList
          END ||
          ok := TRUE
       ELSE
           hh := TRANSACAO*{FALSE} ||
           ok := FALSE
       END
   END;
    
sc, sp, ok <-- consultarSaldos(cc) = 
    PRE 
        cc : CONTA 
    THEN
        IF 
            cc : contas & cc /= contaDummy
        THEN
            sc := saldoCorrente(cc) || sp := saldoPoupanca(cc) || ok := TRUE
        ELSE 
            sc := 0 || sp := 0 ||
            ok := FALSE
        END
    END;
    
ok, oo, dd, vv, tp <-- consultarTransacao(tt) = 
    PRE
        tt : TRANSACAO
    THEN
        IF 
            tt : transacoes 
        THEN
            vv := valorTransacoes(tt) || 
            tp := tipoTransacoes(tt) ||
            ANY ot, dt
            WHERE 
                ot : CONTA & dt : CONTA &
                ot = origemTransacoes(tt) & dt = destinoTransacoes(tt)
            THEN
                oo := ot || dd := dt
            END ||
            ok := TRUE
         ELSE
             oo := contaDummy || dd := contaDummy || 
             vv := 0 || tp := saqueCorrente ||
             ok := FALSE
         END      
    END;
    
ok, ftCartao <-- consultarFaturasCartao(ct) = 
    PRE 
        ct : CARTAO 
    THEN
        IF 
            ct : cartoes & ct /= cartaoDummy & tipoCartao(ct) = credito
        THEN
            ANY ffList
            WHERE
                  ffList : FATURA --> BOOL &
                  dom(ffList |> {TRUE}) = dom(faturaCartao |> {ct})
            THEN
                  ftCartao := ffList
            END ||
            ok := TRUE
       ELSE
           ftCartao := FATURA*{FALSE} || ok := FALSE
       END
    END;
    
    
ok, ct, tt, oo, st, atual <-- consultarFatura(ff) =
    PRE 
        ff : FATURA 
    THEN
        IF 
            ff : faturas
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
            END ||
            ok := TRUE
        ELSE
            ct := cartaoDummy || tt := 0 || oo := 0 ||
            st := aberta || atual := FALSE || ok := FALSE
        END
    END;
    
ok, vf <-- consultarValorFatura(ct) =
    PRE
        ct : CARTAO 
    THEN
        IF 
            ct : creditos & ct /= cartaoDummy
        THEN
            vf := totalFatura(faturaAtual(ct)) ||
            ok := TRUE
        ELSE
            vf := 0 ||
            ok := FALSE
        END
    END;
    
ok, cts <-- consultarCartoesConta(cc) = 
    PRE 
        cc : CONTA
    THEN
        IF 
            cc : contas & cc /= contaDummy
        THEN
            ANY ctsList
            WHERE
                  ctsList : CARTAO --> BOOL &
                  dom(ctsList |> {TRUE}) = dom(titular |> {cc})
            THEN
                  cts := ctsList
            END ||
            ok := TRUE
        ELSE
            cts := CARTAO*{FALSE} ||
            ok := FALSE
        END
    END;
    
ok, tipo, ll, llMax, block <-- consultarCartao(ct) =
    PRE
        ct : CARTAO
    THEN
        IF
            ct : cartoes & ct /= cartaoDummy
        THEN
            IF 
                tipoCartao(ct) = credito
            THEN
                ll := limite(ct) ||
                llMax := limiteMax(ct) 
            ELSE
                ll := 0 || llMax := 0 
            END ||
            tipo := tipoCartao(ct) ||
            block := bool(ct : bloqueados) ||
            ok := TRUE 
        ELSE
            ll := 0 || llMax := 0 || tipo := debito ||
            block := FALSE || ok := FALSE
        END
    END;


ok, prox <-- proximaConta =
    IF
        CONTA - contas - contasRemovidas /= {}
    THEN
        ANY
            cc
        WHERE
            cc : CONTA & cc /: contas & cc /: contasRemovidas
        THEN
            prox := cc
        END ||
        ok := TRUE
    ELSE
        prox := contaDummy ||
        ok := FALSE
    END;
    
ok, prox <-- proximoCartao =
    IF
        CARTAO - cartoes /= {}
    THEN
        ANY
            ct
        WHERE
            ct : CARTAO & ct /: cartoes
        THEN
            prox := ct
        END ||
        ok := TRUE
    ELSE
        prox := cartaoDummy ||
        ok := FALSE
    END
    
    
    


END