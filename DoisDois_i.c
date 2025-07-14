/* WARNING if type checker is not performed, translation could contain errors ! */

#include "DoisDois.h"

/* Clause CONCRETE_CONSTANTS */
/* Basic constants */

#define DoisDois__ativa 1
#define DoisDois__removida 2
#define DoisDois__livre 0
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

static int32_t DoisDois__i_contas[DoisDois__maxConta+1];
static bool DoisDois__i_cartoes[DoisDois__maxCartao+1];
static bool DoisDois__i_faturas[DoisDois__maxFatura+1];
static bool DoisDois__i_transacoes[DoisDois__maxTransacao+1];
static bool DoisDois__i_bloqueados[DoisDois__maxCartao+1];
static int32_t DoisDois__i_saldoCorrente[DoisDois__maxConta+1];
static int32_t DoisDois__i_saldoPoupanca[DoisDois__maxConta+1];
static int32_t DoisDois__i_valorTransacoes[DoisDois__maxTransacao+1];
static DoisDois__TIPOTRANSACAO DoisDois__i_tipoTransacoes[DoisDois__maxTransacao+1];
static DoisDois__TIPOCARTAO DoisDois__i_tipoCartao[DoisDois__maxCartao+1];
static int32_t DoisDois__i_limite[DoisDois__maxCartao+1];
static int32_t DoisDois__i_limiteMax[DoisDois__maxCartao+1];
static int32_t DoisDois__i_faturaOrdem[DoisDois__maxFatura+1];
static DoisDois__STATUSFATURA DoisDois__i_statusFatura[DoisDois__maxFatura+1];
static int32_t DoisDois__i_totalFatura[DoisDois__maxFatura+1];
static int32_t DoisDois__i_titular[DoisDois__maxCartao+1];
static int32_t DoisDois__i_faturaAtual[DoisDois__maxCartao+1];
static int32_t DoisDois__i_origem[DoisDois__maxTransacao+1];
static int32_t DoisDois__i_destino[DoisDois__maxTransacao+1];
static int32_t DoisDois__i_faturaCartao[DoisDois__maxFatura+1];
static int32_t DoisDois__tamFatura;
static int32_t DoisDois__tamTransacao;
static int32_t DoisDois__tamCredito;
static int32_t DoisDois__tamCartao;
static int32_t DoisDois__tamConta;
/* Clause INITIALISATION */
void DoisDois__INITIALISATION(void)
{
    
    unsigned int i = 0;
    for(i = 0; i <= DoisDois__maxConta;i++)
    {
        DoisDois__i_contas[i] = DoisDois__livre;
    }
    for(i = 0; i <= DoisDois__maxCartao;i++)
    {
        DoisDois__i_cartoes[i] = false;
    }
    for(i = 0; i <= DoisDois__maxFatura;i++)
    {
        DoisDois__i_faturas[i] = false;
    }
    for(i = 0; i <= DoisDois__maxTransacao;i++)
    {
        DoisDois__i_transacoes[i] = false;
    }
    for(i = 0; i <= DoisDois__maxConta;i++)
    {
        DoisDois__i_saldoCorrente[i] = 0;
    }
    for(i = 0; i <= DoisDois__maxConta;i++)
    {
        DoisDois__i_saldoPoupanca[i] = 0;
    }
    for(i = 0; i <= DoisDois__maxCartao;i++)
    {
        DoisDois__i_bloqueados[i] = false;
    }
    for(i = 0; i <= DoisDois__maxTransacao;i++)
    {
        DoisDois__i_valorTransacoes[i] = 0;
    }
    for(i = 0; i <= DoisDois__maxTransacao;i++)
    {
        DoisDois__i_tipoTransacoes[i] = DoisDois__depositoCorrente;
    }
    for(i = 0; i <= DoisDois__maxCartao;i++)
    {
        DoisDois__i_tipoCartao[i] = DoisDois__debito;
    }
    for(i = 0; i <= DoisDois__maxCartao;i++)
    {
        DoisDois__i_limite[i] = 0;
    }
    for(i = 0; i <= DoisDois__maxCartao;i++)
    {
        DoisDois__i_limiteMax[i] = DoisDois__limiteMaxPadrao;
    }
    for(i = 0; i <= DoisDois__maxFatura;i++)
    {
        DoisDois__i_statusFatura[i] = DoisDois__aberta;
    }
    for(i = 0; i <= DoisDois__maxFatura;i++)
    {
        DoisDois__i_totalFatura[i] = 0;
    }
    for(i = 0; i <= DoisDois__maxCartao;i++)
    {
        DoisDois__i_titular[i] = DoisDois__contaDummy;
    }
    for(i = 0; i <= DoisDois__maxCartao;i++)
    {
        DoisDois__i_faturaAtual[i] = DoisDois__faturaDummy;
    }
    for(i = 0; i <= DoisDois__maxTransacao;i++)
    {
        DoisDois__i_origem[i] = DoisDois__contaDummy;
    }
    for(i = 0; i <= DoisDois__maxTransacao;i++)
    {
        DoisDois__i_destino[i] = DoisDois__contaDummy;
    }
    for(i = 0; i <= DoisDois__maxFatura;i++)
    {
        DoisDois__i_faturaCartao[i] = DoisDois__cartaoDummy;
    }
    for(i = 0; i <= DoisDois__maxFatura;i++)
    {
        DoisDois__i_faturaOrdem[i] = 0;
    }
    DoisDois__tamFatura = 0;
    DoisDois__tamTransacao = 0;
    DoisDois__tamCredito = 0;
    DoisDois__tamCartao = 0;
    DoisDois__tamConta = 0;
}

/* Clause OPERATIONS */

void DoisDois__adicionarConta(DoisDois__CONTA cc, bool *ok)
{
    {
        int32_t status;
        
        status = DoisDois__i_contas[cc];
        if(((((cc) <= (DoisDois__maxConta)) &&
                (status == DoisDois__livre)) &&
            ((cc) != (DoisDois__contaDummy))) &&
        ((DoisDois__tamConta) < (DoisDois__maxConta)))
        {
            DoisDois__i_contas[cc] = DoisDois__ativa;
            DoisDois__i_saldoCorrente[cc] = 0;
            DoisDois__i_saldoPoupanca[cc] = 0;
            DoisDois__tamConta = DoisDois__tamConta+1;
            (*ok) = true;
        }
        else
        {
            (*ok) = false;
        }
    }
}

void DoisDois__depositarCorrente(DoisDois__CONTA cc, int32_t valor, bool *ok)
{
    int32_t statusConta;
    int32_t saldoCorrente;
    int32_t maxSaldo;
    
    statusConta = DoisDois__i_contas[cc];
    saldoCorrente = DoisDois__i_saldoCorrente[cc];
    maxSaldo = 2147483647-valor;
    if((((statusConta == DoisDois__ativa) &&
            ((saldoCorrente) <= (maxSaldo))) &&
        ((cc) != (DoisDois__contaDummy))) &&
    ((DoisDois__tamTransacao) <= (DoisDois__maxTransacao)))
    {
        DoisDois__i_saldoCorrente[cc] = DoisDois__i_saldoCorrente[cc]+valor;
        DoisDois__i_transacoes[DoisDois__tamTransacao] = true;
        DoisDois__i_origem[DoisDois__tamTransacao] = cc;
        DoisDois__i_destino[DoisDois__tamTransacao] = cc;
        DoisDois__i_valorTransacoes[DoisDois__tamTransacao] = valor;
        DoisDois__i_tipoTransacoes[DoisDois__tamTransacao] = DoisDois__depositoCorrente;
        DoisDois__tamTransacao = DoisDois__tamTransacao+1;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__depositarPoupanca(DoisDois__CONTA cc, int32_t valor, bool *ok)
{
    int32_t statusConta;
    int32_t saldoPoupanca;
    int32_t maxSaldo;
    
    statusConta = DoisDois__i_contas[cc];
    saldoPoupanca = DoisDois__i_saldoPoupanca[cc];
    maxSaldo = 2147483647-valor;
    if((((statusConta == DoisDois__ativa) &&
            ((saldoPoupanca) <= (maxSaldo))) &&
        ((cc) != (DoisDois__contaDummy))) &&
    ((DoisDois__tamTransacao) <= (DoisDois__maxTransacao)))
    {
        DoisDois__i_saldoPoupanca[cc] = DoisDois__i_saldoPoupanca[cc]+valor;
        DoisDois__i_transacoes[DoisDois__tamTransacao] = true;
        DoisDois__i_origem[DoisDois__tamTransacao] = cc;
        DoisDois__i_destino[DoisDois__tamTransacao] = cc;
        DoisDois__i_valorTransacoes[DoisDois__tamTransacao] = valor;
        DoisDois__i_tipoTransacoes[DoisDois__tamTransacao] = DoisDois__depositoPoupanca;
        DoisDois__tamTransacao = DoisDois__tamTransacao+1;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__sacarCorrente(DoisDois__CONTA cc, int32_t valor, bool *ok)
{
    int32_t statusConta;
    int32_t saldoCorrente;
    
    statusConta = DoisDois__i_contas[cc];
    saldoCorrente = DoisDois__i_saldoCorrente[cc];
    if((((((statusConta == DoisDois__ativa) &&
                    ((valor) >= (DoisDois__saqueMinCorrente))) &&
                ((valor) <= (saldoCorrente))) &&
            ((DoisDois__tamTransacao) <= (DoisDois__maxTransacao))) &&
        ((valor) >= (1))) &&
    ((cc) != (DoisDois__contaDummy)))
    {
        DoisDois__i_saldoCorrente[cc] = DoisDois__i_saldoCorrente[cc]-valor;
        DoisDois__i_transacoes[DoisDois__tamTransacao] = true;
        DoisDois__i_origem[DoisDois__tamTransacao] = cc;
        DoisDois__i_destino[DoisDois__tamTransacao] = cc;
        DoisDois__i_valorTransacoes[DoisDois__tamTransacao] = valor;
        DoisDois__i_tipoTransacoes[DoisDois__tamTransacao] = DoisDois__saqueCorrente;
        DoisDois__tamTransacao = DoisDois__tamTransacao+1;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__sacarPoupanca(DoisDois__CONTA cc, int32_t valor, bool *ok)
{
    int32_t statusConta;
    int32_t saldoPoupanca;
    int32_t saldoCorrente;
    int32_t maxSaldo;
    
    statusConta = DoisDois__i_contas[cc];
    saldoPoupanca = DoisDois__i_saldoPoupanca[cc];
    saldoCorrente = DoisDois__i_saldoCorrente[cc];
    maxSaldo = 2147483647-valor;
    if(((((((statusConta == DoisDois__ativa) &&
                        ((valor) >= (DoisDois__saqueMinPoupanca))) &&
                    ((valor) <= (saldoPoupanca))) &&
                ((DoisDois__tamTransacao) <= (DoisDois__maxTransacao))) &&
            ((valor) >= (1))) &&
        ((saldoCorrente) <= (maxSaldo))) &&
    ((cc) != (DoisDois__contaDummy)))
    {
        DoisDois__i_saldoPoupanca[cc] = DoisDois__i_saldoPoupanca[cc]-valor;
        DoisDois__i_saldoCorrente[cc] = DoisDois__i_saldoCorrente[cc]+valor;
        DoisDois__i_transacoes[DoisDois__tamTransacao] = true;
        DoisDois__i_origem[DoisDois__tamTransacao] = cc;
        DoisDois__i_destino[DoisDois__tamTransacao] = cc;
        DoisDois__i_valorTransacoes[DoisDois__tamTransacao] = valor;
        DoisDois__i_tipoTransacoes[DoisDois__tamTransacao] = DoisDois__saquePoupanca;
        DoisDois__tamTransacao = DoisDois__tamTransacao+1;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__adicionarCartao(DoisDois__CARTAO ct, DoisDois__TIPOCARTAO tp, DoisDois__CONTA cc, bool *ok)
{
    int32_t statusConta;
    bool statusCartao;
    bool cartaoDuplicado;
    bool temFatura;
    
    statusConta = DoisDois__i_contas[cc];
    statusCartao = DoisDois__i_cartoes[ct];
    temFatura = (((tp == DoisDois__debito) ||((DoisDois__tamFatura) < (DoisDois__maxFatura))) ? true : false);
    if((((((statusCartao == false) &&
                    (statusConta == DoisDois__ativa)) &&
                (temFatura == true)) &&
            ((cc) != (DoisDois__contaDummy))) &&
        ((ct) != (DoisDois__cartaoDummy))) &&
    ((DoisDois__tamCartao) < (DoisDois__maxCartao)))
    {
        cartaoDuplicado = false;
        {
            int32_t ii;
            
            ii = 0;
            while(((ii) <= (DoisDois__maxCartao)) &&
            (cartaoDuplicado == false))
            {
                {
                    bool cartaoAtual;
                    int32_t titularAtual;
                    DoisDois__TIPOCARTAO tipoAtual;
                    
                    cartaoAtual = DoisDois__i_cartoes[ii];
                    titularAtual = DoisDois__i_titular[ii];
                    tipoAtual = DoisDois__i_tipoCartao[ii];
                    if(((cartaoAtual == true) &&
                        (titularAtual == cc)) &&
                    (tipoAtual == tp))
                    {
                        cartaoDuplicado = true;
                    }
                }
                ii = ii+1;
            }
        }
        if(cartaoDuplicado == false)
        {
            DoisDois__i_cartoes[ct] = true;
            DoisDois__i_tipoCartao[ct] = tp;
            DoisDois__i_titular[ct] = cc;
            DoisDois__tamCartao = DoisDois__tamCartao+1;
            (*ok) = true;
            if(tp == DoisDois__credito)
            {
                {
                    int32_t ii;
                    bool atual;
                    
                    ii = 1;
                    atual = DoisDois__i_faturas[ii];
                    while(((ii) < (DoisDois__maxFatura)) &&
                    (atual == true))
                    {
                        ii = ii+1;
                        atual = DoisDois__i_faturas[ii];
                    }
                    DoisDois__i_faturas[ii] = true;
                    DoisDois__tamFatura = DoisDois__tamFatura+1;
                    DoisDois__i_faturaAtual[ct] = ii;
                    DoisDois__i_statusFatura[ii] = DoisDois__aberta;
                    DoisDois__i_totalFatura[ii] = 0;
                    DoisDois__i_faturaCartao[ii] = ct;
                    DoisDois__i_faturaOrdem[ii] = 0;
                    DoisDois__i_limite[ct] = DoisDois__limiteMaxPadrao;
                    DoisDois__i_limiteMax[ct] = DoisDois__limiteMaxPadrao;
                    DoisDois__tamCredito = DoisDois__tamCredito+1;
                }
            }
        }
        else
        {
            (*ok) = false;
        }
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__removerCartao(DoisDois__CARTAO ct, bool *ok)
{
    bool cartaoAtivo;
    DoisDois__TIPOCARTAO tipoCartao;
    bool pagas;
    
    cartaoAtivo = DoisDois__i_cartoes[ct];
    tipoCartao = DoisDois__i_tipoCartao[ct];
    if(((cartaoAtivo == true) &&
        (tipoCartao == DoisDois__credito)) &&
    ((ct) != (DoisDois__cartaoDummy)))
    {
        {
            int32_t ii;
            bool fatura;
            int32_t faturaCartao;
            DoisDois__STATUSFATURA statusFatura;
            int32_t totalFatura;
            
            ii = 1;
            pagas = true;
            while(((ii) <= (DoisDois__maxFatura)) &&
            (pagas == true))
            {
                fatura = DoisDois__i_faturas[ii];
                faturaCartao = DoisDois__i_faturaCartao[ii];
                statusFatura = DoisDois__i_statusFatura[ii];
                totalFatura = DoisDois__i_totalFatura[ii];
                if((((fatura == true) &&
                        (faturaCartao == ct)) &&
                    ((statusFatura) != (DoisDois__paga))) &&
                ((totalFatura) != (0)))
                {
                    pagas = false;
                }
                ii = ii+1;
            }
        }
        if(pagas == true)
        {
            {
                int32_t ii;
                bool fatura;
                int32_t cartao;
                
                ii = 1;
                while((ii) <= (DoisDois__maxFatura))
                {
                    fatura = DoisDois__i_faturas[ii];
                    cartao = DoisDois__i_faturaCartao[ii];
                    if((fatura == true) &&
                    (cartao == ct))
                    {
                        DoisDois__i_faturas[ii] = false;
                        DoisDois__tamFatura = DoisDois__tamFatura-1;
                    }
                    ii = ii+1;
                }
            }
            DoisDois__i_cartoes[ct] = false;
            DoisDois__i_bloqueados[ct] = false;
            DoisDois__tamCredito = DoisDois__tamCredito-1;
            DoisDois__tamCartao = DoisDois__tamCartao-1;
        }
        (*ok) = pagas;
    }
    else if((cartaoAtivo == true) &&
    (tipoCartao == DoisDois__debito))
    {
        DoisDois__i_cartoes[ct] = false;
        DoisDois__i_bloqueados[ct] = false;
        DoisDois__tamCartao = DoisDois__tamCartao-1;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__pagarFatura(DoisDois__CONTA cc, DoisDois__FATURA ff, bool *ok)
{
    int32_t contaFatura;
    bool faturaAtiva;
    DoisDois__STATUSFATURA statusFatura;
    int32_t totalFatura;
    int32_t saldo;
    int32_t cartao;
    int32_t titular;
    
    contaFatura = DoisDois__i_contas[cc];
    faturaAtiva = DoisDois__i_faturas[ff];
    statusFatura = DoisDois__i_statusFatura[ff];
    totalFatura = DoisDois__i_totalFatura[ff];
    saldo = DoisDois__i_saldoCorrente[cc];
    cartao = DoisDois__i_faturaCartao[ff];
    titular = DoisDois__i_titular[cartao];
    if((((((((contaFatura == DoisDois__ativa) &&
                            (faturaAtiva == true)) &&
                        ((statusFatura) != (DoisDois__paga))) &&
                    ((totalFatura) > (0))) &&
                ((saldo) >= (totalFatura))) &&
            (titular == cc)) &&
        ((cc) != (DoisDois__contaDummy))) &&
    ((ff) != (DoisDois__faturaDummy)))
    {
        DoisDois__i_saldoCorrente[cc] = DoisDois__i_saldoCorrente[cc]-totalFatura;
        DoisDois__i_statusFatura[ff] = DoisDois__paga;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__compraParcelada(DoisDois__CARTAO co, DoisDois__CONTA cd, int32_t valor, int32_t parcelas, bool *ok)
{
    bool cartaoAtivo;
    DoisDois__TIPOCARTAO tipoCartao;
    int32_t contaDestino;
    bool cartaoBloqueado;
    int32_t titular;
    int32_t parcela;
    int32_t limite;
    int32_t saldoDestino;
    int32_t maxSaldo;
    int32_t resto;
    
    cartaoAtivo = DoisDois__i_cartoes[co];
    tipoCartao = DoisDois__i_tipoCartao[co];
    contaDestino = DoisDois__i_contas[cd];
    cartaoBloqueado = DoisDois__i_bloqueados[co];
    titular = DoisDois__i_titular[co];
    saldoDestino = DoisDois__i_saldoCorrente[cd];
    limite = DoisDois__i_limite[co];
    maxSaldo = 2147483647-valor;
    resto = valor % parcelas;
    if(((((((((((((cartaoAtivo == true) &&
                                                (tipoCartao == DoisDois__credito)) &&
                                            (contaDestino == DoisDois__ativa)) &&
                                        (cartaoBloqueado == false)) &&
                                    ((titular) != (cd))) &&
                                ((parcelas) >= (1))) &&
                            ((parcelas) <= (DoisDois__maxParcelas))) &&
                        ((valor) > (0))) &&
                    (resto == 0)) &&
                ((saldoDestino) <= (maxSaldo))) &&
            ((co) != (DoisDois__cartaoDummy))) &&
        ((cd) != (DoisDois__contaDummy))) &&
    ((DoisDois__tamTransacao) <= (DoisDois__maxTransacao)))
    {
        parcela = valor / parcelas;
        if((parcela) <= (limite))
        {
            {
                int32_t faturaAtualCartao;
                int32_t ordemAtual;
                bool overflow;
                int32_t faturasNecessarias;
                int32_t faturasExistentesCount;
                int32_t ordemFinal;
                
                faturaAtualCartao = DoisDois__i_faturaAtual[co];
                ordemAtual = DoisDois__i_faturaOrdem[faturaAtualCartao];
                overflow = false;
                faturasExistentesCount = 0;
                ordemFinal = ordemAtual+parcelas-1;
                {
                    int32_t ii;
                    bool fatura;
                    int32_t faturaCartao;
                    int32_t faturaOrdem;
                    int32_t totalFatura;
                    int32_t maxValorFatura;
                    
                    ii = 1;
                    maxValorFatura = 2147483647-parcela;
                    while(((ii) <= (DoisDois__maxFatura)) &&
                    (overflow == false))
                    {
                        fatura = DoisDois__i_faturas[ii];
                        faturaCartao = DoisDois__i_faturaCartao[ii];
                        faturaOrdem = DoisDois__i_faturaOrdem[ii];
                        totalFatura = DoisDois__i_totalFatura[ii];
                        if((((fatura == true) &&
                                (faturaCartao == co)) &&
                            ((faturaOrdem) >= (ordemAtual))) &&
                        ((faturaOrdem) <= (ordemFinal)))
                        {
                            faturasExistentesCount = faturasExistentesCount+1;
                            if((totalFatura) > (maxValorFatura))
                            {
                                overflow = true;
                            }
                        }
                        ii = ii+1;
                    }
                }
                faturasNecessarias = parcelas-faturasExistentesCount;
                {
                    int32_t totalFaturasNecessarias;
                    
                    totalFaturasNecessarias = DoisDois__tamFatura+faturasNecessarias;
                    if((overflow == false) &&
                    ((totalFaturasNecessarias) <= (DoisDois__maxFatura)))
                    {
                        {
                            int32_t ordem;
                            int32_t ordemInicial;
                            int32_t ordemFinalCriacao;
                            
                            ordemInicial = ordemAtual+faturasExistentesCount;
                            ordemFinalCriacao = ordemAtual+parcelas;
                            ordem = ordemInicial;
                            while((ordem) < (ordemFinalCriacao))
                            {
                                {
                                    int32_t ff;
                                    bool atual;
                                    
                                    ff = 1;
                                    atual = DoisDois__i_faturas[ff];
                                    while(((ff) < (DoisDois__maxFatura)) &&
                                    (atual == true))
                                    {
                                        ff = ff+1;
                                        atual = DoisDois__i_faturas[ff];
                                    }
                                    DoisDois__i_faturas[ff] = true;
                                    DoisDois__i_faturaCartao[ff] = co;
                                    DoisDois__i_faturaOrdem[ff] = ordem;
                                    DoisDois__i_statusFatura[ff] = DoisDois__aberta;
                                    DoisDois__i_totalFatura[ff] = 0;
                                    DoisDois__tamFatura = DoisDois__tamFatura+1;
                                }
                                ordem = ordem+1;
                            }
                        }
                        {
                            int32_t ii;
                            bool fatura;
                            int32_t faturaCartao;
                            int32_t faturaOrdem;
                            
                            ii = 1;
                            while((ii) <= (DoisDois__maxFatura))
                            {
                                fatura = DoisDois__i_faturas[ii];
                                faturaCartao = DoisDois__i_faturaCartao[ii];
                                faturaOrdem = DoisDois__i_faturaOrdem[ii];
                                if((((fatura == true) &&
                                        (faturaCartao == co)) &&
                                    ((faturaOrdem) >= (ordemAtual))) &&
                                ((faturaOrdem) <= (ordemFinal)))
                                {
                                    DoisDois__i_totalFatura[ii] = DoisDois__i_totalFatura[ii]+parcela;
                                }
                                ii = ii+1;
                            }
                        }
                        {
                            int32_t transacaoDestino;
                            int32_t kk;
                            
                            transacaoDestino = DoisDois__tamTransacao;
                            DoisDois__i_transacoes[transacaoDestino] = true;
                            DoisDois__i_origem[transacaoDestino] = titular;
                            DoisDois__i_destino[transacaoDestino] = cd;
                            DoisDois__i_valorTransacoes[transacaoDestino] = valor;
                            DoisDois__i_tipoTransacoes[transacaoDestino] = DoisDois__tranDepositoCartao;
                            DoisDois__tamTransacao = DoisDois__tamTransacao+1;
                            kk = 0;
                            while((kk) < (parcelas))
                            {
                                DoisDois__i_transacoes[DoisDois__tamTransacao] = true;
                                DoisDois__i_origem[DoisDois__tamTransacao] = titular;
                                DoisDois__i_destino[DoisDois__tamTransacao] = cd;
                                DoisDois__i_valorTransacoes[DoisDois__tamTransacao] = parcela;
                                DoisDois__i_tipoTransacoes[DoisDois__tamTransacao] = DoisDois__tranCredito;
                                DoisDois__tamTransacao = DoisDois__tamTransacao+1;
                                kk = kk+1;
                            }
                        }
                        DoisDois__i_saldoCorrente[cd] = DoisDois__i_saldoCorrente[cd]+valor;
                        DoisDois__i_limite[co] = DoisDois__i_limite[co]-parcela;
                        (*ok) = true;
                    }
                    else
                    {
                        (*ok) = false;
                    }
                }
            }
        }
        else
        {
            (*ok) = false;
        }
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__pix(DoisDois__CONTA co, DoisDois__CONTA cd, int32_t valor, bool *ok)
{
    int32_t contaOrigem;
    int32_t contaDestino;
    int32_t maxSaldo;
    int32_t saldoOrigem;
    int32_t saldoDestino;
    
    contaOrigem = DoisDois__i_contas[co];
    contaDestino = DoisDois__i_contas[cd];
    saldoOrigem = DoisDois__i_saldoCorrente[co];
    saldoDestino = DoisDois__i_saldoCorrente[cd];
    maxSaldo = 2147483647-valor;
    if(((((((((contaOrigem == DoisDois__ativa) &&
                                (contaDestino == DoisDois__ativa)) &&
                            ((valor) >= (1))) &&
                        ((valor) <= (saldoOrigem))) &&
                    ((saldoDestino) <= (maxSaldo))) &&
                ((valor) <= (DoisDois__limitePix))) &&
            ((co) != (DoisDois__contaDummy))) &&
        ((cd) != (DoisDois__contaDummy))) &&
    ((DoisDois__tamTransacao) <= (DoisDois__maxTransacao)))
    {
        DoisDois__i_saldoCorrente[co] = DoisDois__i_saldoCorrente[co]-valor;
        DoisDois__i_saldoCorrente[cd] = DoisDois__i_saldoCorrente[cd]+valor;
        DoisDois__i_transacoes[DoisDois__tamTransacao] = true;
        DoisDois__i_origem[DoisDois__tamTransacao] = co;
        DoisDois__i_destino[DoisDois__tamTransacao] = cd;
        DoisDois__i_valorTransacoes[DoisDois__tamTransacao] = valor;
        DoisDois__i_tipoTransacoes[DoisDois__tamTransacao] = DoisDois__tranPix;
        DoisDois__tamTransacao = DoisDois__tamTransacao+1;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__compraDebito(DoisDois__CARTAO co, DoisDois__CONTA cd, int32_t valor, bool *ok)
{
    int32_t contaDestino;
    bool cartaoAtivo;
    bool cartaoBloqueado;
    DoisDois__TIPOCARTAO tipoCartao;
    int32_t titular;
    int32_t saldoOrigem;
    int32_t saldoDestino;
    int32_t maxSaldo;
    
    contaDestino = DoisDois__i_contas[cd];
    cartaoAtivo = DoisDois__i_cartoes[co];
    cartaoBloqueado = DoisDois__i_bloqueados[co];
    tipoCartao = DoisDois__i_tipoCartao[co];
    titular = DoisDois__i_titular[co];
    saldoOrigem = DoisDois__i_saldoCorrente[co];
    saldoDestino = DoisDois__i_saldoCorrente[cd];
    maxSaldo = 2147483647-valor;
    if(((((((((((contaDestino == DoisDois__ativa) &&
                                        (cartaoAtivo == true)) &&
                                    (cartaoBloqueado == false)) &&
                                (tipoCartao == DoisDois__debito)) &&
                            ((titular) != (cd))) &&
                        ((valor) >= (1))) &&
                    ((valor) <= (saldoOrigem))) &&
                ((saldoDestino) <= (maxSaldo))) &&
            ((DoisDois__tamTransacao) <= (DoisDois__maxTransacao))) &&
        ((co) != (DoisDois__cartaoDummy))) &&
    ((cd) != (DoisDois__contaDummy)))
    {
        DoisDois__i_saldoCorrente[titular] = DoisDois__i_saldoCorrente[titular]-valor;
        DoisDois__i_saldoCorrente[cd] = DoisDois__i_saldoCorrente[cd]+valor;
        DoisDois__i_transacoes[DoisDois__tamTransacao] = true;
        DoisDois__i_origem[DoisDois__tamTransacao] = titular;
        DoisDois__i_destino[DoisDois__tamTransacao] = cd;
        DoisDois__i_valorTransacoes[DoisDois__tamTransacao] = valor;
        DoisDois__i_tipoTransacoes[DoisDois__tamTransacao] = DoisDois__tranDebito;
        DoisDois__tamTransacao = DoisDois__tamTransacao+1;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__bloquearCartao(DoisDois__CARTAO ct, bool *ok)
{
    bool cartaoAtivo;
    bool cartaoBloqueado;
    
    cartaoAtivo = DoisDois__i_cartoes[ct];
    cartaoBloqueado = DoisDois__i_bloqueados[ct];
    if(((cartaoAtivo == true) &&
        (cartaoBloqueado == false)) &&
    ((ct) != (DoisDois__cartaoDummy)))
    {
        DoisDois__i_bloqueados[ct] = true;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__desbloquearCartao(DoisDois__CARTAO ct, bool *ok)
{
    bool cartaoAtivo;
    bool cartaoBloqueado;
    
    cartaoAtivo = DoisDois__i_cartoes[ct];
    cartaoBloqueado = DoisDois__i_bloqueados[ct];
    if(((cartaoAtivo == true) &&
        (cartaoBloqueado == true)) &&
    ((ct) != (DoisDois__cartaoDummy)))
    {
        DoisDois__i_bloqueados[ct] = false;
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__atualizarLimiteMax(DoisDois__CARTAO ct, int32_t valor, bool *ok)
{
    DoisDois__TIPOCARTAO tipoCartao;
    bool cartaoBloqueado;
    bool cartaoAtivo;
    
    cartaoAtivo = DoisDois__i_cartoes[ct];
    cartaoBloqueado = DoisDois__i_bloqueados[ct];
    tipoCartao = DoisDois__i_tipoCartao[ct];
    if(((((cartaoAtivo == true) &&
                (cartaoBloqueado == false)) &&
            (tipoCartao == DoisDois__credito)) &&
        ((valor) <= (2147483647))) &&
    ((ct) != (DoisDois__cartaoDummy)))
    {
        DoisDois__i_limiteMax[ct] = valor;
        {
            int32_t limiteAtual;
            
            limiteAtual = DoisDois__i_limite[ct];
            if((limiteAtual) > (valor))
            {
                DoisDois__i_limite[ct] = valor;
            }
        }
        (*ok) = true;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__atualizarLimite(DoisDois__CARTAO ct, int32_t valor, bool *ok)
{
    DoisDois__TIPOCARTAO tipoCartao;
    bool cartaoBloqueado;
    bool cartaoAtivo;
    int32_t limiteMaxCartao;
    
    tipoCartao = DoisDois__i_tipoCartao[ct];
    cartaoBloqueado = DoisDois__i_bloqueados[ct];
    cartaoAtivo = DoisDois__i_cartoes[ct];
    limiteMaxCartao = DoisDois__i_limiteMax[ct];
    if(((((tipoCartao == DoisDois__credito) &&
                (cartaoBloqueado == false)) &&
            (cartaoAtivo == true)) &&
        ((0) <= (valor))) &&
    ((valor) <= (limiteMaxCartao)))
    {
        (*ok) = true;
        DoisDois__i_limite[ct] = valor;
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__removerConta(DoisDois__CONTA cc, bool *ok)
{
    int32_t statusConta;
    bool pagas;
    
    statusConta = DoisDois__i_contas[cc];
    pagas = true;
    if((statusConta == DoisDois__ativa) &&
    ((cc) != (DoisDois__contaDummy)))
    {
        {
            int32_t ii;
            bool cartaoAtivo;
            int32_t titularCartao;
            
            ii = 1;
            cartaoAtivo = DoisDois__i_cartoes[ii];
            titularCartao = DoisDois__i_titular[ii];
            while(((ii) <= (DoisDois__maxCartao)) &&
            (pagas == true))
            {
                if((cartaoAtivo == true) &&
                (titularCartao == cc))
                {
                    {
                        int32_t jj;
                        bool fatura;
                        int32_t faturaCartao;
                        DoisDois__STATUSFATURA statusFatura;
                        int32_t totalFatura;
                        
                        jj = 1;
                        while(((jj) <= (DoisDois__maxFatura)) &&
                        (pagas == true))
                        {
                            fatura = DoisDois__i_faturas[jj];
                            faturaCartao = DoisDois__i_faturaCartao[jj];
                            statusFatura = DoisDois__i_statusFatura[jj];
                            totalFatura = DoisDois__i_totalFatura[jj];
                            if((((fatura == true) &&
                                    (faturaCartao == ii)) &&
                                ((statusFatura) != (DoisDois__paga))) &&
                            ((totalFatura) != (0)))
                            {
                                pagas = false;
                            }
                            jj = jj+1;
                        }
                    }
                }
                ii = ii+1;
            }
        }
        if(pagas == true)
        {
            DoisDois__i_contas[cc] = DoisDois__removida;
            {
                int32_t ii;
                bool cartaoAtivo;
                int32_t titularCartao;
                
                ii = 0;
                cartaoAtivo = DoisDois__i_cartoes[ii];
                titularCartao = DoisDois__i_titular[ii];
                while((ii) <= (DoisDois__maxCartao))
                {
                    if((cartaoAtivo == true) &&
                    (titularCartao == cc))
                    {
                        DoisDois__i_cartoes[ii] = false;
                        DoisDois__i_bloqueados[ii] = false;
                        {
                            int32_t jj;
                            int32_t faturaCartao;
                            
                            jj = 1;
                            pagas = true;
                            while((jj) <= (DoisDois__maxFatura))
                            {
                                faturaCartao = DoisDois__i_faturaCartao[jj];
                                if(faturaCartao == ii)
                                {
                                    DoisDois__i_faturas[jj] = false;
                                }
                                jj = jj+1;
                            }
                        }
                    }
                    ii = ii+1;
                }
            }
            (*ok) = true;
        }
        else
        {
            (*ok) = false;
        }
    }
    else
    {
        (*ok) = false;
    }
}

void DoisDois__passarMes(bool *ok)
{
    unsigned int i = 0;
    {
        bool poupancaPassou;
        bool faturaPassou;
        int32_t copiaSaldoPoupanca[DoisDois__maxConta+1];
        int32_t copiaTotalFatura[DoisDois__maxFatura+1];
        int32_t proximasFaturas[DoisDois__maxCartao+1];
        int32_t cartoesComProxima;
        int32_t faturasNecessarias;
        
        poupancaPassou = true;
        memmove(copiaSaldoPoupanca,DoisDois__i_saldoPoupanca,(DoisDois__maxConta+1)* sizeof(int32_t));
        {
            int32_t ii;
            int32_t contaAtual;
            int32_t saldoAtual;
            int32_t limite;
            
            ii = 0;
            saldoAtual = 0;
            while(((ii) <= (DoisDois__maxConta)) &&
            (poupancaPassou == true))
            {
                contaAtual = DoisDois__i_contas[ii];
                saldoAtual = copiaSaldoPoupanca[ii];
                limite = 2147483647 / DoisDois__taxaRendimento;
                if((contaAtual == DoisDois__ativa) &&
                ((saldoAtual) > (limite)))
                {
                    poupancaPassou = false;
                }
                else
                {
                    copiaSaldoPoupanca[ii] = DoisDois__i_saldoPoupanca[ii] * DoisDois__taxaRendimento;
                }
                ii = ii+1;
            }
        }
        if(poupancaPassou == true)
        {
            faturaPassou = true;
            for(i = 0; i <= DoisDois__maxCartao;i++)
            {
                proximasFaturas[i] = DoisDois__faturaDummy;
            }
            memmove(copiaTotalFatura,DoisDois__i_totalFatura,(DoisDois__maxFatura+1)* sizeof(int32_t));
            cartoesComProxima = 0;
            {
                int32_t ii;
                bool atual;
                int32_t cartaoFatura;
                int32_t faturaAtualCartao;
                int32_t ordemAtual;
                int32_t ordemFaturaAtual;
                DoisDois__STATUSFATURA statusFaturaAtual;
                int32_t totalFaturaAtual;
                int32_t maxJuros;
                int32_t proximaOrdem;
                
                ii = 1;
                while(((ii) <= (DoisDois__maxFatura)) &&
                (faturaPassou == true))
                {
                    atual = DoisDois__i_faturas[ii];
                    if(atual == true)
                    {
                        cartaoFatura = DoisDois__i_faturaCartao[ii];
                        faturaAtualCartao = DoisDois__i_faturaAtual[cartaoFatura];
                        ordemAtual = DoisDois__i_faturaOrdem[ii];
                        ordemFaturaAtual = DoisDois__i_faturaOrdem[faturaAtualCartao];
                        proximaOrdem = ordemFaturaAtual+1;
                        statusFaturaAtual = DoisDois__i_statusFatura[ii];
                        totalFaturaAtual = DoisDois__i_totalFatura[ii];
                        maxJuros = 2147483647 / DoisDois__jurosFatura;
                        if(((ordemAtual) <= (ordemFaturaAtual)) &&
                        (((statusFaturaAtual == DoisDois__aberta) ||
                                (statusFaturaAtual == DoisDois__vencida))))
                        {
                            if((totalFaturaAtual) > (maxJuros))
                            {
                                faturaPassou = false;
                            }
                            else
                            {
                                copiaTotalFatura[ii] = copiaTotalFatura[ii] * DoisDois__jurosFatura;
                            }
                        }
                        if(ordemAtual == proximaOrdem)
                        {
                            proximasFaturas[cartaoFatura] = ii;
                            cartoesComProxima = cartoesComProxima+1;
                        }
                    }
                    ii = ii+1;
                }
            }
            faturasNecessarias = DoisDois__tamFatura+(DoisDois__tamCredito-cartoesComProxima);
            if((faturasNecessarias) <= (DoisDois__maxFatura))
            {
                {
                    int32_t ii;
                    bool cartaoAtivo;
                    DoisDois__TIPOCARTAO tipoAtual;
                    int32_t faturaAtualCartao;
                    DoisDois__STATUSFATURA statusAtual;
                    int32_t totalAtual;
                    int32_t ff;
                    bool atual;
                    int32_t ordemAtual;
                    int32_t proximaFatura;
                    
                    ii = 0;
                    while((ii) <= (DoisDois__maxCartao))
                    {
                        cartaoAtivo = DoisDois__i_cartoes[ii];
                        tipoAtual = DoisDois__i_tipoCartao[ii];
                        if((cartaoAtivo == true) &&
                        (tipoAtual == DoisDois__credito))
                        {
                            faturaAtualCartao = DoisDois__i_faturaAtual[ii];
                            statusAtual = DoisDois__i_statusFatura[faturaAtualCartao];
                            totalAtual = DoisDois__i_totalFatura[faturaAtualCartao];
                            if((statusAtual == DoisDois__aberta) &&
                            ((totalAtual) > (0)))
                            {
                                DoisDois__i_statusFatura[faturaAtualCartao] = DoisDois__vencida;
                            }
                            else if((statusAtual == DoisDois__aberta) &&
                            (totalAtual == 0))
                            {
                                DoisDois__i_statusFatura[faturaAtualCartao] = DoisDois__paga;
                            }
                            proximaFatura = proximasFaturas[ii];
                            if(proximaFatura == DoisDois__faturaDummy)
                            {
                                ff = 1;
                                atual = DoisDois__i_faturas[ff];
                                while(((ff) < (DoisDois__maxFatura)) &&
                                (atual == true))
                                {
                                    ff = ff+1;
                                    atual = DoisDois__i_faturas[ff];
                                }
                                ordemAtual = DoisDois__i_faturaOrdem[faturaAtualCartao];
                                DoisDois__i_faturas[ff] = true;
                                DoisDois__i_faturaCartao[ff] = ii;
                                DoisDois__i_faturaAtual[ii] = ff;
                                DoisDois__i_faturaOrdem[ff] = ordemAtual+1;
                                DoisDois__i_statusFatura[ff] = DoisDois__aberta;
                                copiaTotalFatura[ff] = 0;
                                DoisDois__tamFatura = DoisDois__tamFatura+1;
                            }
                            else
                            {
                                DoisDois__i_faturaAtual[ii] = proximaFatura;
                            }
                        }
                        ii = ii+1;
                    }
                }
                memmove(DoisDois__i_saldoPoupanca,copiaSaldoPoupanca,(DoisDois__maxConta+1)* sizeof(int32_t));
                memmove(DoisDois__i_totalFatura,copiaTotalFatura,(DoisDois__maxFatura+1)* sizeof(int32_t));
                (*ok) = true;
            }
            else
            {
                (*ok) = false;
            }
        }
        else
        {
            (*ok) = false;
        }
    }
}

void DoisDois__consultarContas(bool *ccs)
{
    unsigned int i = 0;
    {
        int32_t ii;
        
        ii = 0;
        for(i = 0; i <= DoisDois__maxConta;i++)
        {
            ccs[i] = false;
        }
        while((ii) <= (DoisDois__maxConta))
        {
            {
                int32_t atual;
                
                atual = DoisDois__i_contas[ii];
                if(atual == DoisDois__ativa)
                {
                    ccs[ii] = true;
                }
                ii = ii+1;
            }
        }
    }
}

void DoisDois__consultarSaldos(DoisDois__CONTA cc, int32_t *sc, int32_t *sp, bool *ok)
{
    int32_t statusConta;
    
    statusConta = DoisDois__i_contas[cc];
    if((statusConta == DoisDois__ativa) &&
    ((cc) != (DoisDois__contaDummy)))
    {
        (*sc) = DoisDois__i_saldoCorrente[cc];
        (*sp) = DoisDois__i_saldoPoupanca[cc];
        (*ok) = true;
    }
    else
    {
        (*sc) = 0;
        (*sp) = 0;
        (*ok) = false;
    }
}

void DoisDois__historico(DoisDois__CONTA cc, bool *hh, bool *ok)
{
    unsigned int i = 0;
    {
        int32_t statusConta;
        
        for(i = 0; i <= DoisDois__maxTransacao;i++)
        {
            hh[i] = false;
        }
        statusConta = DoisDois__i_contas[cc];
        if((statusConta == DoisDois__ativa) &&
        ((cc) != (DoisDois__contaDummy)))
        {
            {
                int32_t ii;
                
                ii = 0;
                while((ii) <= (DoisDois__maxTransacao))
                {
                    {
                        bool atual;
                        int32_t origem;
                        int32_t destino;
                        DoisDois__TIPOTRANSACAO tipo;
                        
                        atual = DoisDois__i_transacoes[ii];
                        origem = DoisDois__i_origem[ii];
                        destino = DoisDois__i_destino[ii];
                        tipo = DoisDois__i_tipoTransacoes[ii];
                        if((atual == true) &&
                        (((((origem == cc) &&
                                        ((tipo) != (DoisDois__tranDepositoCartao)))) ||
                                (((destino == cc) &&
                                        ((tipo) != (DoisDois__tranCredito)))))))
                        {
                            hh[ii] = true;
                        }
                        ii = ii+1;
                    }
                }
            }
            (*ok) = true;
        }
        else
        {
            (*ok) = false;
        }
    }
}

void DoisDois__consultarTransacao(DoisDois__TRANSACAO tt, bool *ok, DoisDois__CONTA *oo, DoisDois__CONTA *dd, int32_t *vv, DoisDois__TIPOTRANSACAO *tp)
{
    bool transacaoAtiva;
    
    transacaoAtiva = DoisDois__i_transacoes[tt];
    if(transacaoAtiva == true)
    {
        (*oo) = DoisDois__i_origem[tt];
        (*dd) = DoisDois__i_destino[tt];
        (*vv) = DoisDois__i_valorTransacoes[tt];
        (*tp) = DoisDois__i_tipoTransacoes[tt];
        (*ok) = true;
    }
    else
    {
        (*oo) = DoisDois__contaDummy;
        (*dd) = DoisDois__contaDummy;
        (*vv) = 0;
        (*tp) = DoisDois__saqueCorrente;
        (*ok) = false;
    }
}

void DoisDois__consultarFaturasCartao(DoisDois__CARTAO ct, bool *ok, bool *ftCartao)
{
    unsigned int i = 0;
    {
        bool cartaoAtivo;
        DoisDois__TIPOCARTAO tipo;
        
        cartaoAtivo = DoisDois__i_cartoes[ct];
        for(i = 0; i <= DoisDois__maxFatura;i++)
        {
            ftCartao[i] = false;
        }
        tipo = DoisDois__i_tipoCartao[ct];
        if(((cartaoAtivo == true) &&
            (tipo == DoisDois__credito)) &&
        ((ct) != (DoisDois__cartaoDummy)))
        {
            {
                int32_t ii;
                
                ii = 0;
                while((ii) <= (DoisDois__maxFatura))
                {
                    {
                        bool atual;
                        int32_t cartaoFatura;
                        
                        atual = DoisDois__i_faturas[ii];
                        cartaoFatura = DoisDois__i_faturaCartao[ii];
                        if((atual == true) &&
                        (cartaoFatura == ct))
                        {
                            ftCartao[ii] = true;
                        }
                        ii = ii+1;
                    }
                }
            }
            (*ok) = true;
        }
        else
        {
            (*ok) = false;
        }
    }
}

void DoisDois__consultarFatura(DoisDois__FATURA ff, bool *ok, DoisDois__CARTAO *ct, int32_t *tt, int32_t *oo, DoisDois__STATUSFATURA *st, bool *atual)
{
    bool faturaAtiva;
    int32_t faturaAtual;
    
    faturaAtiva = DoisDois__i_faturas[ff];
    if(faturaAtiva == true)
    {
        (*ct) = DoisDois__i_faturaCartao[ff];
        (*tt) = DoisDois__i_totalFatura[ff];
        (*oo) = DoisDois__i_faturaOrdem[ff];
        (*st) = DoisDois__i_statusFatura[ff];
        faturaAtual = DoisDois__i_faturaAtual[(*ct)];
        (*atual) = ((faturaAtual == ff) ? true : false);
        (*ok) = true;
    }
    else
    {
        (*ct) = DoisDois__cartaoDummy;
        (*tt) = 0;
        (*oo) = 0;
        (*st) = DoisDois__aberta;
        (*atual) = false;
        (*ok) = false;
    }
}

void DoisDois__consultarValorFatura(DoisDois__CARTAO ct, bool *ok, int32_t *vf)
{
    bool cartaoAtivo;
    DoisDois__TIPOCARTAO tipoCartao;
    
    cartaoAtivo = DoisDois__i_cartoes[ct];
    tipoCartao = DoisDois__i_tipoCartao[ct];
    if(((cartaoAtivo == true) &&
        (tipoCartao == DoisDois__credito)) &&
    ((ct) != (DoisDois__cartaoDummy)))
    {
        {
            int32_t faturaAtual;
            
            faturaAtual = DoisDois__i_faturaAtual[ct];
            (*vf) = DoisDois__i_totalFatura[faturaAtual];
            (*ok) = true;
        }
    }
    else
    {
        (*vf) = 0;
        (*ok) = false;
    }
}

void DoisDois__consultarCartoesConta(DoisDois__CONTA cc, bool *ok, bool *cts)
{
    unsigned int i = 0;
    {
        int32_t contaAtiva;
        
        contaAtiva = DoisDois__i_contas[cc];
        for(i = 0; i <= DoisDois__maxCartao;i++)
        {
            cts[i] = false;
        }
        if((contaAtiva == DoisDois__ativa) &&
        ((cc) != (DoisDois__contaDummy)))
        {
            {
                int32_t ii;
                
                ii = 0;
                while((ii) <= (DoisDois__maxCartao))
                {
                    {
                        bool atual;
                        int32_t titularCartao;
                        
                        atual = DoisDois__i_cartoes[ii];
                        titularCartao = DoisDois__i_titular[ii];
                        if((atual == true) &&
                        (titularCartao == cc))
                        {
                            cts[ii] = true;
                        }
                        ii = ii+1;
                    }
                }
            }
            (*ok) = true;
        }
        else
        {
            (*ok) = false;
        }
    }
}

void DoisDois__consultarCartao(DoisDois__CARTAO ct, bool *ok, DoisDois__TIPOCARTAO *tipo, int32_t *ll, int32_t *llMax, bool *block)
{
    bool cartaoAtivo;
    DoisDois__TIPOCARTAO tipoCartao;
    
    cartaoAtivo = DoisDois__i_cartoes[ct];
    tipoCartao = DoisDois__i_tipoCartao[ct];
    if((cartaoAtivo == true) &&
    ((ct) != (DoisDois__cartaoDummy)))
    {
        if(tipoCartao == DoisDois__credito)
        {
            (*ll) = DoisDois__i_limite[ct];
            (*llMax) = DoisDois__i_limiteMax[ct];
        }
        else
        {
            (*ll) = 0;
            (*llMax) = 0;
        }
        (*tipo) = tipoCartao;
        (*block) = DoisDois__i_bloqueados[ct];
        (*ok) = true;
    }
    else
    {
        (*ll) = 0;
        (*llMax) = 0;
        (*block) = false;
        (*ok) = false;
    }
}

void DoisDois__proximoCartao(bool *ok, DoisDois__CARTAO *prox)
{
    if((DoisDois__tamCartao) < (DoisDois__maxCartao))
    {
        {
            int32_t ii;
            bool atual;
            
            ii = 1;
            atual = DoisDois__i_cartoes[ii];
            while(((ii) < (DoisDois__maxCartao)) &&
            (atual == true))
            {
                ii = ii+1;
                atual = DoisDois__i_cartoes[ii];
            }
            (*prox) = ii;
        }
        (*ok) = true;
    }
    else
    {
        (*prox) = DoisDois__cartaoDummy;
        (*ok) = false;
    }
}

