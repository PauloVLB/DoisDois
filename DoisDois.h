#ifndef _DoisDois_h
#define _DoisDois_h

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


#define DoisDois__CONTA__max DoisDois__maxConta
#define DoisDois__FATURA__max DoisDois__maxFatura
#define DoisDois__CARTAO__max DoisDois__maxCartao
#define DoisDois__TRANSACAO__max DoisDois__maxTransacao
/* Clause SETS */
typedef int DoisDois__CONTA;
typedef int DoisDois__FATURA;
typedef int DoisDois__CARTAO;
typedef int DoisDois__TRANSACAO;
typedef enum
{
    DoisDois__paga,
    DoisDois__vencida,
    DoisDois__aberta
    
} DoisDois__STATUSFATURA;
#define DoisDois__STATUSFATURA__max 3
typedef enum
{
    DoisDois__credito,
    DoisDois__debito
    
} DoisDois__TIPOCARTAO;
#define DoisDois__TIPOCARTAO__max 2
typedef enum
{
    DoisDois__saqueCorrente,
    DoisDois__saquePoupanca,
    DoisDois__depositoCorrente,
    DoisDois__depositoPoupanca,
    DoisDois__tranCredito,
    DoisDois__tranDebito,
    DoisDois__tranPix,
    DoisDois__tranDepositoCartao
    
} DoisDois__TIPOTRANSACAO;
#define DoisDois__TIPOTRANSACAO__max 8

/* Clause CONCRETE_CONSTANTS */
/* Basic constants */
#define DoisDois__taxaRendimento 2
#define DoisDois__jurosFatura 2
#define DoisDois__maxParcelas 10
#define DoisDois__limiteMaxPadrao 15
#define DoisDois__saqueMinCorrente 10
#define DoisDois__saqueMinPoupanca 15
#define DoisDois__limitePix 50
#define DoisDois__contaDummy 0
#define DoisDois__cartaoDummy 0
#define DoisDois__faturaDummy 0
#define DoisDois__maxConta 50
#define DoisDois__maxCartao 100
#define DoisDois__maxFatura 100
#define DoisDois__maxTransacao 200
/* Array and record constants */















/* Clause CONCRETE_VARIABLES */

extern void DoisDois__INITIALISATION(void);

/* Clause OPERATIONS */

extern void DoisDois__adicionarConta(DoisDois__CONTA cc, bool *ok);
extern void DoisDois__depositarCorrente(DoisDois__CONTA cc, int32_t valor, bool *ok);
extern void DoisDois__depositarPoupanca(DoisDois__CONTA cc, int32_t valor, bool *ok);
extern void DoisDois__sacarCorrente(DoisDois__CONTA cc, int32_t valor, bool *ok);
extern void DoisDois__sacarPoupanca(DoisDois__CONTA cc, int32_t valor, bool *ok);
extern void DoisDois__adicionarCartao(DoisDois__CARTAO ct, DoisDois__TIPOCARTAO tp, DoisDois__CONTA cc, bool *ok);
extern void DoisDois__removerCartao(DoisDois__CARTAO ct, bool *ok);
extern void DoisDois__pagarFatura(DoisDois__CONTA cc, DoisDois__FATURA ff, bool *ok);
extern void DoisDois__compraParcelada(DoisDois__CARTAO co, DoisDois__CONTA cd, int32_t valor, int32_t parcelas, bool *ok);
extern void DoisDois__pix(DoisDois__CONTA co, DoisDois__CONTA cd, int32_t valor, bool *ok);
extern void DoisDois__compraDebito(DoisDois__CARTAO co, DoisDois__CONTA cd, int32_t valor, bool *ok);
extern void DoisDois__bloquearCartao(DoisDois__CARTAO ct, bool *ok);
extern void DoisDois__desbloquearCartao(DoisDois__CARTAO ct, bool *ok);
extern void DoisDois__atualizarLimiteMax(DoisDois__CARTAO ct, int32_t valor, bool *ok);
extern void DoisDois__atualizarLimite(DoisDois__CARTAO ct, int32_t valor, bool *ok);
extern void DoisDois__removerConta(DoisDois__CONTA cc, bool *ok);
extern void DoisDois__passarMes(bool *ok);
extern void DoisDois__consultarContas(bool *ccs);
extern void DoisDois__historico(DoisDois__CONTA cc, bool *hh, bool *ok);
extern void DoisDois__consultarSaldos(DoisDois__CONTA cc, int32_t *sc, int32_t *sp, bool *ok);
extern void DoisDois__consultarTransacao(DoisDois__TRANSACAO tt, bool *ok, DoisDois__CONTA *oo, DoisDois__CONTA *dd, int32_t *vv, DoisDois__TIPOTRANSACAO *tp);
extern void DoisDois__consultarFaturasCartao(DoisDois__CARTAO ct, bool *ok, bool *ftCartao);
extern void DoisDois__consultarFatura(DoisDois__FATURA ff, bool *ok, DoisDois__CARTAO *ct, int32_t *tt, int32_t *oo, DoisDois__STATUSFATURA *st, bool *atual);
extern void DoisDois__consultarValorFatura(DoisDois__CARTAO ct, bool *ok, int32_t *vf);
extern void DoisDois__consultarCartoesConta(DoisDois__CONTA cc, bool *ok, bool *cts);
extern void DoisDois__consultarCartao(DoisDois__CARTAO ct, bool *ok, DoisDois__TIPOCARTAO *tipo, int32_t *ll, int32_t *llMax, bool *block);
extern void DoisDois__proximaConta(bool *ok, DoisDois__CONTA *prox);
extern void DoisDois__proximoCartao(bool *ok, DoisDois__CARTAO *prox);

#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* _DoisDois_h */
