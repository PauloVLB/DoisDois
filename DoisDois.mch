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
     
    /* as transações da fatura atual de um cartão não ultrapassam o limite */
    !ff.(ff : ran(faturaAtual) => totalFatura(ff) <= limite(faturaCartao(ff))) & 
    
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
    
    transacoesDuplicadas(cc) == 
        (( origemTransacoes~[{cc}] /\ tipoTransacoes~[{depositoCorrente}] ) - destinoTransacoes~[{cc}])
        \/ (( destinoTransacoes~[{cc}] /\ tipoTransacoes~[{tranCredito}] ));
    conjuntoHistorico(cc) == (origemTransacoes~[{cc}] \/ destinoTransacoes~[{cc}]) - transacoesDuplicadas(cc)
    

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
        cc : CONTA & cc : contas & valor : NAT1 & saldoCorrente(cc) + valor : NAT1
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
        cc : CONTA & cc : contas & valor : NAT1 & saldoPoupanca(cc) + valor : NAT1
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
        cc : CONTA & cc: contas & valor : NAT1 &
        valor >= saqueMinCorrente & valor <= saldoCorrente(cc)
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
        cc : CONTA & cc : contas & valor : NAT1 &
        valor >= saqueMinPoupanca & valor <= saldoPoupanca(cc) &
        saldoCorrente(cc) + valor : NAT
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
        totalFatura(ff) > 0 & saldoCorrente(cc) >= totalFatura(ff) &
        titular(faturaCartao(ff)) = cc
    THEN
        saldoCorrente(cc) := saldoCorrente(cc) - totalFatura(ff) ||
        statusFatura(ff) := paga 
    END;
    
compraParcelada(co, cd, valor, parcelas) =
    PRE co : CARTAO & cd : CONTA &
        co : creditos & cd : contas & 
        titular(co) /= cd & 
        valor : NAT1 & parcelas : 1..maxParcelas & 
        (valor / parcelas) : NAT &
        co /: bloqueados &
        (valor / parcelas) + totalFatura(faturaAtual(co)) <= limite(co) &
	    saldoCorrente(cd) + valor : NAT  &
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
               tipoTransacoes := tipoTransacoes \/ {tDestino |-> depositoCorrente} \/ (tOrigem * {tranCredito})  ||
               saldoCorrente(cd) := saldoCorrente(cd) + valor ||
               /*criar faturas novas*/
               faturas := faturas \/ novasFaturas ||
               statusFatura := statusFatura \/ (novasFaturas * {aberta}) ||
               faturaCartao := faturaCartao \/ (novasFaturas * {co}) ||
               faturaOrdem := faturaOrdem \/ novaOrdem ||
               totalFatura := totalFatura <+ (%ff.(ff : faturasExistentes(co, parcelas) | totalFatura(ff) + parcela) \/  (novasFaturas * {parcela}))  
           END 
       END 
    END;
    
pix(co, cd, valor) =
    PRE
        co : CONTA & cd : CONTA &
        co : contas & cd : contas & valor : 1..saldoCorrente(co) & saldoCorrente(cd) + valor : NAT &
        co /= cd &
        valor : 1..limitePix
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
            tipoTransacoes(tt) := tranPix
        END
    END;
    
compraDebito(co, cd, valor) =
    PRE
        co : CARTAO & cd : CONTA &
        co : debitos & co /: bloqueados &
        cd : contas & valor : 1..saldoCorrente(titular(co)) & saldoCorrente(cd) + valor : NAT &
        titular(co) /= cd
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
        END
   END;
   
hh <-- historico(cc) = 
   PRE 
       cc : CONTA & cc : contas
   THEN
      ANY hhList
      WHERE
          hhList : 0..card(conjuntoHistorico(cc))-1 +-> TRANSACAO &
          ran(hhList) = conjuntoHistorico(cc)
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
        ct : CARTAO & ct: creditos & ct /: bloqueados & valor : NAT & valor <= MAXINT & 
        totalFatura(faturaAtual(ct)) <= valor
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
      ct : CARTAO & ct : creditos & ct /: bloqueados & valor : 0..limiteMax(ct) & 
      totalFatura(faturaAtual(ct)) <= valor
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
    
ld <-- consultarLimiteDisponivel(ct) =
    PRE 
        ct : CARTAO & ct : creditos
    THEN
        ld := limite(ct) - totalFatura(faturaAtual(ct))
    END;
    
    
oo, dd, vv, tp <-- consultarTransacao(tt) = 
    PRE
        tt : TRANSACAO & tt : transacoes
    THEN
        vv := valorTransacoes(tt) || 
        tp := tipoTransacoes(tt) ||
        ANY ot, dt
        WHERE 
            ot : CONTA & dt : CONTA &
            ot = origemTransacoes(tt) & dt = destinoTransacoes(tt)
        THEN
            oo := ot || dd := dt
        END
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
    


passarMes =
    PRE
        !cc.(cc : contas => saldoPoupanca(cc) * taxaRendimento : NAT) &
        !ff.((ff : faturas & faturaOrdem(ff) <= faturaOrdem(faturaAtual(faturaCartao(ff))) & (statusFatura(ff) : {vencida, aberta})) 
            => totalFatura(ff) * jurosFatura : NAT)
    THEN
        saldoPoupanca := %cc.(cc : contas | saldoPoupanca(cc) * taxaRendimento) ||
        
        ANY
            cartoesComProximaFatura, cartoesSemProximaFatura, 
            proximaFaturaExistente,
            novasFaturas, faturaCartaoNovo, faturaOrdemNovo, ordensCartoesSemProxima
        WHERE
            cartoesSemProximaFatura = {ct | ct : creditos & faturaOrdem(faturaAtual(ct)) = card(faturaCartao |> {ct}) - 1} &
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
        END
    END;
    
/* --- operações para confirmar pré-condição ---*/

ok <-- pre_adicionarConta(cc) =
    PRE
        cc : CONTA
    THEN
        IF 
            cc /: contas &
            cc /: contasRemovidas
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END
        
    END;

ok <-- pre_depositarCorrente(cc, valor) =
    PRE
        cc : CONTA & valor : NAT1
    THEN
        IF 
          cc : contas & saldoCorrente(cc) + valor : NAT1
	THEN
            ok := TRUE
        ELSE
            ok := FALSE
        END
    END;

ok <-- pre_depositarPoupanca(cc, valor) =
    PRE
        cc : CONTA & valor : NAT1
    THEN
        IF 
            cc : contas &
            saldoPoupanca(cc) + valor : NAT1
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END
        
    END;

ok <-- pre_sacarCorrente(cc, valor) =
    PRE
        cc : CONTA & valor : NAT1
    THEN
        IF 
            cc : contas &
            valor : NAT1 &
            valor >= saqueMinCorrente & valor <= saldoCorrente(cc)
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END
        
    END;

ok <-- pre_sacarPoupanca(cc, valor) =
    PRE
        cc : CONTA & valor : NAT1
    THEN
        IF 
            cc : contas &
            valor : 1..saldoPoupanca(cc) &
            valor >= saqueMinPoupanca & valor <= saldoPoupanca(cc) &
            saldoCorrente(cc) + valor : NAT
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END
        
    END;

ok <-- pre_adicionarCartao(ct, tp, cc) =
    PRE
        ct : CARTAO & tp : TIPOCARTAO & cc : CONTA
    THEN
        IF 
            ct /: cartoes &
            cc : contas &
            tipoCartao~[{tp}] /\ titular~[{cc}] = {}
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END
        
    END;

ok <-- pre_removerCartao(ct) =
    PRE
        ct : CARTAO
    THEN
        IF 
            ct : cartoes &
            ((tipoCartao(ct) = credito) => 
                (faturaCartao~[{ct}] <: statusFatura~[{paga}] \/ totalFatura~[{0}])
            )
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END
        
    END;

ok <-- pre_pagarFatura(cc, ff) =
    PRE
        cc : CONTA & ff : FATURA
    THEN
        IF 
            cc : contas &
            ff : faturas &
            statusFatura(ff) /= paga &
            totalFatura(ff) > 0 &
            saldoCorrente(cc) >= totalFatura(ff) &
            titular(faturaCartao(ff)) = cc
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_compraParcelada(co, cd, valor, parcelas) =
    PRE
        co : CARTAO & cd : CONTA & valor : NAT & parcelas : NAT
    THEN
        IF 
            co : creditos &
            cd : contas &
            titular(co) /= cd &
            valor : NAT1 &
            parcelas : 1..maxParcelas &
            (valor / parcelas) : NAT &
            co /: bloqueados &
            (valor / parcelas) + totalFatura(faturaAtual(co)) <= limite(co) &
            saldoCorrente(cd) + valor : NAT &
            !ff.(ff : faturasExistentes(co, parcelas) => (totalFatura(ff) + valor/parcelas) : NAT)
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_pix(co, cd, valor) =
    PRE
        co : CONTA & cd : CONTA & valor : NAT
    THEN
        IF 
            co : contas &
            cd : contas &
            valor : 1..saldoCorrente(co) &
            saldoCorrente(cd) + valor : NAT &
            co /= cd
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_compraDebito(co, cd, valor) =
    PRE
        co : CARTAO & cd : CONTA & valor : NAT
    THEN
        IF 
            co : debitos &
            co /: bloqueados &
            cd : contas &
            valor : 1..saldoCorrente(titular(co)) &
            saldoCorrente(cd) + valor : NAT &
            titular(co) /= cd
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_historico(cc) =
    PRE
        cc : CONTA
    THEN
        IF 
            cc : contas
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_consultarSaldos(cc) =
    PRE
        cc : CONTA
    THEN
        IF 
            cc : contas
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_bloquearCartao(ct) =
    PRE
        ct : CARTAO
    THEN
        IF 
            ct : cartoes &
            ct /: bloqueados
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_desbloquearCartao(ct) =
    PRE
        ct : CARTAO
    THEN
        IF 
            ct : cartoes &
            ct : bloqueados
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_atualizarLimiteMax(ct, valor) =
    PRE
        ct : CARTAO & valor : NAT
    THEN
        IF 
            ct: creditos & 
            ct /: bloqueados & valor : NAT & 
            valor <= MAXINT & 
            totalFatura(faturaAtual(ct)) <= valor
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_atualizarLimite(ct, valor) =
    PRE
        ct : CARTAO & valor : NAT
    THEN
        IF 
            ct : creditos & 
            ct /: bloqueados & 
            valor : 0..limiteMax(ct) & 
            totalFatura(faturaAtual(ct)) <= valor
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_consultarValorFatura(ct) =
    PRE
        ct : CARTAO
    THEN
        IF 
            ct : creditos
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_consultarCartoesConta(cc) =
    PRE
        cc : CONTA
    THEN
        IF 
            cc : contas
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;
ok <-- pre_consultarLimite(ct) =
    PRE
        ct : CARTAO
    THEN
        IF 
            ct : creditos
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_consultarLimiteMax(ct) =
    PRE
        ct : CARTAO
    THEN
        IF 
            ct : creditos
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_consultarLimiteDisponivel(ct) =
    PRE 
        ct : CARTAO 
    THEN
        IF 
            ct : creditos
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END
    END;

ok <-- pre_consultarTransacao(tt) =
    PRE
        tt : TRANSACAO
    THEN
        IF 
            tt : transacoes
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_removerConta(cc) =
    PRE
        cc : CONTA
    THEN
        IF 
            cc : contas &
            cc /: contasRemovidas &
            !ct.((ct : creditos & titular(ct) = cc) =>
                (faturaCartao~[{ct}] <: statusFatura~[{paga}] \/ totalFatura~[{0}]))
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_consultarFaturasCartao(ct) =
    PRE
        ct : CARTAO
    THEN
        IF 
            ct : cartoes &
            faturaCartao~[{ct}] : FIN(faturaCartao~[{ct}])
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_consultarContas = ok := TRUE;

ok <-- pre_consultarFatura(ff) =
    PRE
        ff : FATURA
    THEN
        IF 
            ff : faturas
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

    END;

ok <-- pre_passarMes =
        IF 
            !cc.(cc : contas => saldoPoupanca(cc) * taxaRendimento : NAT) &
            !ff.((ff : faturas & faturaOrdem(ff) <= faturaOrdem(faturaAtual(faturaCartao(ff))) &
                  (statusFatura(ff) : {vencida, aberta})) => 
                  totalFatura(ff) * jurosFatura : NAT)
        THEN
            ok := TRUE    
        ELSE
            ok := FALSE
        END

END