
#include <ncurses.h>
#include <string>
#include <vector>
#include <map>
#include <sstream>
#include <functional>
#include <locale>
#include <cstdlib>
#include <optional>
#include <iomanip>

extern "C" {
    #include "DoisDois.h"
}

#define CUSTOM_REVERSE_PAIR 1
#define COLOR_LIGHT_GRAY 16

std::map<std::string, DoisDois__CONTA> g_accountMap;
std::map<DoisDois__CONTA, std::string> g_reverseAccountMap;

std::map<std::string, DoisDois__CARTAO> g_cardMap;
std::map<DoisDois__CARTAO, std::string> g_reverseCardMap;

std::map<DoisDois__CONTA, std::string> g_deletedAccountNames;

int32_t nextAccount = 1;

void drawHeader(const std::string& title);
void showTemporaryMessage(int y, int x, const std::string& message);
void showFullScreenMessage(const std::string& title, const std::string& message);
DoisDois__CONTA getAccountFromTitular(int y, int x, const std::string& prompt);
DoisDois__CARTAO getCardFromApelido(int y, int x, const std::string& prompt);

std::wstring to_wstring(const std::string& str) {
    if (str.empty()) return std::wstring();
    std::wstring wstr(str.length() + 1, L'\0');
    size_t converted_chars = mbstowcs(&wstr[0], str.c_str(), str.length());
    if (converted_chars == (size_t)-1) return L"ERRO";
    wstr.resize(converted_chars);
    return wstr;
}

size_t wstring_width(const std::wstring& wstr) {
    return wcswidth(wstr.c_str(), wstr.size());
}

const char* statusFaturaToString(DoisDois__STATUSFATURA s) {
    switch (s) {
        case DoisDois__paga: return "Paga";
        case DoisDois__vencida: return "Vencida";
        case DoisDois__aberta: return "Aberta";
        default: return "Desconhecido";
    }
}

const char* tipoCartaoToString(DoisDois__TIPOCARTAO t) {
    switch (t) {
        case DoisDois__credito: return "Crédito";
        case DoisDois__debito: return "Débito";
        default: return "Desconhecido";
    }
}

const char* tipoTransacaoToString(DoisDois__TIPOTRANSACAO t) {
    switch (t) {
        case DoisDois__saqueCorrente: return "Saque (Corrente)";
        case DoisDois__saquePoupanca: return "Saque (Poupança)";
        case DoisDois__depositoCorrente: return "Depósito (Corrente)";
        case DoisDois__depositoPoupanca: return "Depósito (Poupança)";
        case DoisDois__tranCredito: return "Transação (Crédito)";
        case DoisDois__tranDebito: return "Transação (Débito)";
        case DoisDois__tranPix: return "PIX";
        case DoisDois__tranDepositoCartao: return "Depósito (Cartão)";
        default: return "Desconhecido";
    }
}

void drawHeader(const std::string& title_str) {
    clear();
    std::string header_text_str = "  " + title_str + "  ";
    std::wstring header_text_w = to_wstring(header_text_str);
    int x_center = (COLS - wstring_width(header_text_w)) / 2;
    if (x_center < 0) x_center = 0;
    attron(COLOR_PAIR(CUSTOM_REVERSE_PAIR));
    mvwaddwstr(stdscr, 0, x_center, header_text_w.c_str());
    attroff(COLOR_PAIR(CUSTOM_REVERSE_PAIR));
    move(2, 2);
}

void showTemporaryMessage(int y, int x, const std::string& message) {
    std::wstring w_message = to_wstring(message);
    attron(COLOR_PAIR(CUSTOM_REVERSE_PAIR));
    mvwaddwstr(stdscr, y, x, w_message.c_str());
    attroff(COLOR_PAIR(CUSTOM_REVERSE_PAIR));
    mvprintw(y + 2, x, "Pressione qualquer tecla...");
    getch();
    for (size_t i = 0; i < wstring_width(w_message); ++i) {
        mvwaddch(stdscr, y, x + i, ' ');
    }
    move(y + 2, x);
    clrtoeol();
}

void waitForEnter() {
    mvprintw(LINES - 1, 0, "Pressione qualquer tecla para voltar...");
    getch();
}

void showFullScreenMessage(const std::string& title, const std::string& message) {
    drawHeader(title);
    mvwaddwstr(stdscr, 3, 2, to_wstring(message).c_str());
    waitForEnter();
}

std::string getStringInput(int y, int x, const std::string& prompt_str) {
    char buffer[100] = {0};
    mvwaddwstr(stdscr, y, x, to_wstring(prompt_str).c_str());
    echo();
    getstr(buffer);
    noecho();
    return std::string(buffer);
}

int getIntInput(int y, int x, const std::string& prompt_str) {
    int value = 0;
    mvwaddwstr(stdscr, y, x, to_wstring(prompt_str).c_str());
    echo();
    scanw("%d", &value);
    noecho();
    return value;
}

void drawSectionHeader(int y, const std::string& title) {
    std::string text_to_draw = " " + title + " ";
    std::wstring w_text = to_wstring(text_to_draw);
    int x_center = (COLS - wstring_width(w_text)) / 2;
    if (x_center < 0) x_center = 0;

    attron(COLOR_PAIR(CUSTOM_REVERSE_PAIR));
    mvwhline(stdscr, y, 0, ' ', COLS); 
    mvwaddwstr(stdscr, y, x_center, w_text.c_str());
    attroff(COLOR_PAIR(CUSTOM_REVERSE_PAIR));
}


int draw_menu(const std::string& title, const std::vector<std::string>& choices) {
    int highlight = 1;
    int choice = 0;
    while (true) {
        drawHeader(title);
        int y = 3, x = 4;
        for (size_t i = 0; i < choices.size(); ++i) {
            std::wstring choice_w = to_wstring(choices[i]);
            if (highlight == (int)i + 1) {
                attron(COLOR_PAIR(CUSTOM_REVERSE_PAIR));
                mvwaddwstr(stdscr, y + i, x, choice_w.c_str());
                attroff(COLOR_PAIR(CUSTOM_REVERSE_PAIR));
            } else {
                mvwaddwstr(stdscr, y + i, x, choice_w.c_str());
            }
        }
        refresh();
        int c = getch();
        switch (c) {
            case KEY_UP: highlight = (highlight == 1) ? choices.size() : highlight - 1; break;
            case KEY_DOWN: highlight = (highlight == (int)choices.size()) ? 1 : highlight + 1; break;
            case 10: choice = highlight; break;
            case 'q': case '0':
                for(size_t i = 0; i < choices.size(); ++i) {
                    if (choices[i].rfind("0. ", 0) == 0) return i + 1;
                }
                break;
        }
        if (choice != 0) break;
    }
    return choice;
}

DoisDois__CONTA getAccountFromTitular(int y, int x, const std::string& prompt) {
    std::string titular = getStringInput(y, x, prompt);
    if (g_accountMap.count(titular)) {
        return g_accountMap[titular];
    }
    showTemporaryMessage(y + 2, x, "FALHA: Titular '" + titular + "' não encontrado.");
    return DoisDois__contaDummy;
}

DoisDois__CARTAO getCardFromApelido(int y, int x, const std::string& prompt) {
    std::string apelido = getStringInput(y, x, prompt);
    if (g_cardMap.count(apelido)) {
        return g_cardMap[apelido];
    }
    showTemporaryMessage(y + 2, x, "FALHA: Apelido de cartão '" + apelido + "' não encontrado.");
    return DoisDois__cartaoDummy;
}


void handleAdicionarConta() {
    drawHeader("Adicionar Nova Conta");
    std::string titular = getStringInput(2, 2, "Digite o nome do titular para a nova conta: ");
    if (titular.empty()) { showTemporaryMessage(4, 2, "FALHA: O nome do titular não pode ser vazio."); return; }
    if (g_accountMap.count(titular)) { showTemporaryMessage(4, 2, "FALHA: Já existe uma conta com este titular."); return; }

    if (nextAccount > DoisDois__CONTA__max) { showTemporaryMessage(4, 2, "FALHA: Limite máximo de contas no sistema foi atingido."); return; }
    
    bool ok_add;
    DoisDois__adicionarConta(nextAccount, &ok_add);
    if (ok_add) {
        g_accountMap[titular] = nextAccount;
        g_reverseAccountMap[nextAccount] = titular;
        std::stringstream ss;
        ss << "SUCESSO: Conta para '" << titular << "' adicionada com ID " << nextAccount << ".";
        nextAccount++;
        showTemporaryMessage(4, 2, ss.str());
    } else {
        showTemporaryMessage(4, 2, "FALHA: Não foi possível adicionar a conta no sistema base.");
    }
}

void handleRemoverConta() {
    drawHeader("Remover Conta");
    DoisDois__CONTA cc = getAccountFromTitular(2, 2, "Nome do titular da conta a remover: ");
    if (cc == DoisDois__contaDummy) return;
    bool ok;
    DoisDois__removerConta(cc, &ok);
    if(ok) {
        std::string titular = g_reverseAccountMap[cc];
        g_deletedAccountNames[cc] = titular;
        g_accountMap.erase(titular);
        g_reverseAccountMap.erase(cc);
        showTemporaryMessage(4, 2, "SUCESSO: Conta removida.");
    } else {
        showTemporaryMessage(4, 2, "FALHA: Não foi possível remover a conta.");
    }
}

void handleGenericAccountOperation(const std::string& title, std::function<void(DoisDois__CONTA, int, bool*)> operation) {
    drawHeader(title);
    DoisDois__CONTA cc = getAccountFromTitular(2, 2, "Nome do titular da conta: ");
    if (cc == DoisDois__contaDummy) return;
    int valor = getIntInput(3, 2, "Digite o valor: ");
    bool ok;
    operation(cc, valor, &ok);
    if (ok) showTemporaryMessage(5, 2, "SUCESSO: Operação realizada.");
    else showTemporaryMessage(5, 2, "FALHA: Não foi possível realizar a operação.");
}

void handleDepositarCorrente() { handleGenericAccountOperation("Depositar em Conta Corrente", DoisDois__depositarCorrente); }
void handleDepositarPoupanca() { handleGenericAccountOperation("Depositar na Poupança", DoisDois__depositarPoupanca); }
void handleSacarCorrente() { handleGenericAccountOperation("Sacar da Conta Corrente", DoisDois__sacarCorrente); }
void handleSacarPoupanca() { handleGenericAccountOperation("Sacar da Poupança", DoisDois__sacarPoupanca); }

void handlePix() {
    drawHeader("Transferência PIX");
    DoisDois__CONTA co = getAccountFromTitular(2, 2, "Nome do titular da conta de ORIGEM: ");
    if (co == DoisDois__contaDummy) return;
    DoisDois__CONTA cd = getAccountFromTitular(3, 2, "Nome do titular da conta de DESTINO: ");
    if (cd == DoisDois__contaDummy) return;
    int valor = getIntInput(4, 2, "Digite o valor: ");
    bool ok;
    DoisDois__pix(co, cd, valor, &ok);
    if(ok) showTemporaryMessage(6, 2, "SUCESSO: PIX realizado.");
    else showTemporaryMessage(6, 2, "FALHA: Não foi possível realizar a transferência.");
}

void handleAdicionarCartao() {
    drawHeader("Adicionar Novo Cartão");
    std::string apelido = getStringInput(2, 2, "Digite um apelido para o novo cartão: ");
    if (apelido.empty()) { showTemporaryMessage(5, 2, "FALHA: O apelido não pode ser vazio."); return; }
    if (g_cardMap.count(apelido)) { showTemporaryMessage(5, 2, "FALHA: Já existe um cartão com este apelido."); return; }
    DoisDois__CONTA cc = getAccountFromTitular(3, 2, "Nome do titular da conta do cartão: ");
    if (cc == DoisDois__contaDummy) return;
    int tipo_int = getIntInput(4, 2, "Digite o tipo (0 - Crédito, 1 - Débito): ");
    DoisDois__TIPOCARTAO tipo = (tipo_int == 0) ? DoisDois__credito : DoisDois__debito;
    
    bool ok_prox;
    DoisDois__CARTAO proximo_cartao_id;
    DoisDois__proximoCartao(&ok_prox, &proximo_cartao_id);

    if (!ok_prox) {
        showTemporaryMessage(6, 2, "FALHA: Limite máximo de cartões no sistema foi atingido.");
        return;
    }

    bool ok_add;
    DoisDois__adicionarCartao(proximo_cartao_id, tipo, cc, &ok_add);
    if (ok_add) {
        g_cardMap[apelido] = proximo_cartao_id;
        g_reverseCardMap[proximo_cartao_id] = apelido;
        std::stringstream ss;
        ss << "SUCESSO: Cartão '" << apelido << "' adicionado com ID " << proximo_cartao_id << ".";
        showTemporaryMessage(6, 2, ss.str());
    } else {
        showTemporaryMessage(6, 2, "FALHA: Não foi possível adicionar o cartão.");
    }
}

void handleRemoverCartao() {
    drawHeader("Remover Cartão");
    DoisDois__CARTAO ct = getCardFromApelido(2, 2, "Apelido do cartão a remover: ");
    if (ct == DoisDois__cartaoDummy) return;
    bool ok;
    DoisDois__removerCartao(ct, &ok);
    if(ok) {
        std::string apelido = g_reverseCardMap[ct];
        g_cardMap.erase(apelido);
        g_reverseCardMap.erase(ct);
        showTemporaryMessage(4, 2, "SUCESSO: Cartão removido.");
    } else {
        showTemporaryMessage(4, 2, "FALHA: Não foi possível remover o cartão.");
    }
}

void handleBloquearCartao() {
    drawHeader("Bloquear Cartão");
    DoisDois__CARTAO ct = getCardFromApelido(2, 2, "Apelido do cartão a bloquear: ");
    if (ct == DoisDois__cartaoDummy) return;
    bool ok;
    DoisDois__bloquearCartao(ct, &ok);
    if(ok) showTemporaryMessage(4, 2, "SUCESSO: Cartão bloqueado.");
    else showTemporaryMessage(4, 2, "FALHA: Não foi possível bloquear o cartão.");
}

void handleDesbloquearCartao() {
    drawHeader("Desbloquear Cartão");
    DoisDois__CARTAO ct = getCardFromApelido(2, 2, "Apelido do cartão a desbloquear: ");
    if (ct == DoisDois__cartaoDummy) return;
    bool ok;
    DoisDois__desbloquearCartao(ct, &ok);
    if(ok) showTemporaryMessage(4, 2, "SUCESSO: Cartão desbloqueado.");
    else showTemporaryMessage(4, 2, "FALHA: Não foi possível desbloquear o cartão.");
}

void handleGenericLimitOperation(const std::string& title, std::function<void(DoisDois__CARTAO, int, bool*)> operation) {
    drawHeader(title);
    DoisDois__CARTAO ct = getCardFromApelido(2, 2, "Apelido do cartão de crédito: ");
    if (ct == DoisDois__cartaoDummy) return;
    int valor = getIntInput(3, 2, "Digite o novo valor do limite: ");
    bool ok;
    operation(ct, valor, &ok);
    if(ok) showTemporaryMessage(5, 2, "SUCESSO: Limite atualizado.");
    else showTemporaryMessage(5, 2, "FALHA: Não foi possível atualizar o limite.");
}

void handleAtualizarLimite() { handleGenericLimitOperation("Atualizar Limite Disponível", DoisDois__atualizarLimite); }
void handleAtualizarLimiteMax() { handleGenericLimitOperation("Atualizar Limite Máximo", DoisDois__atualizarLimiteMax); }

void handleCompraDebito() {
    drawHeader("Compra no Débito");
    DoisDois__CARTAO co = getCardFromApelido(2, 2, "Apelido do cartão de débito: ");
    if (co == DoisDois__cartaoDummy) return;
    DoisDois__CONTA cd = getAccountFromTitular(3, 2, "Nome do titular da conta de destino: ");
    if (cd == DoisDois__contaDummy) return;
    int valor = getIntInput(4, 2, "Digite o valor da compra: ");
    bool ok;
    DoisDois__compraDebito(co, cd, valor, &ok);
    if(ok) showTemporaryMessage(6, 2, "SUCESSO: Compra realizada.");
    else showTemporaryMessage(6, 2, "FALHA: Não foi possível realizar a compra.");
}

void handleCompraParcelada() {
    drawHeader("Compra Parcelada no Crédito");
    DoisDois__CARTAO co = getCardFromApelido(2, 2, "Apelido do cartão de crédito: ");
    if (co == DoisDois__cartaoDummy) return;
    DoisDois__CONTA cd = getAccountFromTitular(3, 2, "Nome do titular da conta de destino: ");
    if (cd == DoisDois__contaDummy) return;
    int valor = getIntInput(4, 2, "Digite o valor da compra: ");
    int parcelas = getIntInput(5, 2, "Digite o número de parcelas: ");
    bool ok;
    DoisDois__compraParcelada(co, cd, valor, parcelas, &ok);
    if(ok) showTemporaryMessage(7, 2, "SUCESSO: Compra parcelada realizada.");
    else showTemporaryMessage(7, 2, "FALHA: Não foi possível realizar a compra parcelada.");
}

std::optional<int> selectFaturaFromCard(DoisDois__CARTAO ct) {
    drawHeader("Selecione a Fatura");

    bool ok_faturas, ftCartao[DoisDois__FATURA__max + 1];
    DoisDois__consultarFaturasCartao(ct, &ok_faturas, ftCartao);

    if (!ok_faturas) {
        showTemporaryMessage(3, 2, "FALHA: Cartão não existe ou não é de crédito.");
        return std::nullopt;
    }

    std::vector<std::string> choices;
    std::vector<int> fatura_ids; 

    for (int i = 1; i <= DoisDois__FATURA__max; i++) {
        if (ftCartao[i]) {
            bool ok_f, atual_f; 
            DoisDois__CARTAO ct_f; 
            int32_t tt_f, oo_f; 
            DoisDois__STATUSFATURA st_f;
            DoisDois__consultarFatura(i, &ok_f, &ct_f, &tt_f, &oo_f, &st_f, &atual_f);

            if (ok_f) {
                std::stringstream ss;
                ss << "ID: "   << std::left << std::setw(5) << i
                   << "Status: " << std::left << std::setw(10) << statusFaturaToString(st_f)
                   << "Total: "  << std::left << std::setw(8) << tt_f
                   << (atual_f ? " (FATURA ATUAL)" : "");
                
                choices.push_back(ss.str());
                fatura_ids.push_back(i);
            }
        }
    }

    if (choices.empty()) {
        showTemporaryMessage(3, 2, "Nenhuma fatura encontrada para este cartão.");
        return std::nullopt;
    }

    choices.push_back("< Voltar");

    int menu_choice = draw_menu("Faturas Disponíveis", choices);

    if (menu_choice == (int)choices.size()) {
        return std::nullopt;
    }

    return fatura_ids[menu_choice - 1];
}

void handlePagarFatura() {
    drawHeader("Pagar Fatura");

    DoisDois__CARTAO ct = getCardFromApelido(2, 2, "Apelido do cartão de crédito a pagar: ");
    if (ct == DoisDois__cartaoDummy) return;

    std::optional<int> fatura_selecionada_opt = selectFaturaFromCard(ct);
    
    if (!fatura_selecionada_opt) {
        return; 
    }
    int ff = *fatura_selecionada_opt;

    bool ok;
    DoisDois__pagarFatura(ct, ff, &ok);

    if(ok) {
        showTemporaryMessage(7, 2, "SUCESSO: Fatura paga.");
    } else {
        showTemporaryMessage(7, 2, "FALHA: Não foi possível pagar a fatura");
    }
}

void handleConsultarContas() {
    drawHeader("Detalhes das Contas Ativas");
    int y = 3;
    int contas_exibidas = 0;
    bool ccs[DoisDois__CONTA__max + 1];
    DoisDois__consultarContas(ccs);
    for (int id = 1; id <= DoisDois__CONTA__max; ++id) {
        if (ccs[id]) {
            contas_exibidas++;
            std::string titular = g_reverseAccountMap.count(id) ? g_reverseAccountMap[id] : "[Titular Desconhecido]";
            attron(A_BOLD);
            mvwaddwstr(stdscr, y++, 2, to_wstring("Titular: '" + titular + "' (ID: " + std::to_string(id) + ")").c_str());
            attroff(A_BOLD);
            int32_t sc, sp;
            bool ok_saldos;
            DoisDois__consultarSaldos(id, &sc, &sp, &ok_saldos);
            if (ok_saldos) {
                mvprintw(y++, 4, "Saldo Corrente: %d", sc);
                mvprintw(y++, 4, "Saldo Poupança: %d", sp);
            }
            y++;
        }
    }
    if (contas_exibidas == 0) mvprintw(y, 2, "Nenhuma conta ativa encontrada no sistema.");
    waitForEnter();
}

void handleConsultarConta() {
    drawHeader("Consultar Conta");
    DoisDois__CONTA cc = getAccountFromTitular(2, 2, "Digite o nome do titular da conta a consultar: ");
    if (cc == DoisDois__contaDummy) return;

    std::string titular = g_reverseAccountMap.count(cc) ? g_reverseAccountMap[cc] : "[Titular Desconhecido]";
    drawHeader("Detalhes da Conta '" + titular + "'");

    int32_t sc, sp; bool ok;
    DoisDois__consultarSaldos(cc, &sc, &sp, &ok);
    mvprintw(2, 2, "Saldos:");
    mvprintw(3, 4, "Corrente: %d", sc);
    mvprintw(4, 4, "Poupança: %d", sp);

    mvprintw(6, 2, "Cartões Associados:");
    bool cts[DoisDois__CARTAO__max + 1]; bool ok_cartoes;
    DoisDois__consultarCartoesConta(cc, &ok_cartoes, cts);
    
    int y = 7; 
    int count = 0;

    if(ok_cartoes){
        for (auto const& [apelido, id] : g_cardMap) {
            if(id <= DoisDois__CARTAO__max && cts[id]){
                count++;
                
                bool ok_c, block; 
                DoisDois__TIPOCARTAO tipo; 
                int32_t ll, llMax;
                DoisDois__consultarCartao(id, &ok_c, &tipo, &ll, &llMax, &block);

                if (ok_c) {
                    std::stringstream card_details;
                    card_details << "-> '" << apelido << "' (" << tipoCartaoToString(tipo) << ") - "
                                 << (block ? "Bloqueado" : "Desbloqueado");
                    
                    
                    mvwaddwstr(stdscr, y++, 4, to_wstring(card_details.str()).c_str());
                }
            }
        }
    }
    
    if (count == 0) {
        mvprintw(y, 4, "Nenhum cartão encontrado.");
    }

    waitForEnter();
}

void handleConsultarCartao() {
    drawHeader("Consultar Cartão");
    DoisDois__CARTAO ct = getCardFromApelido(2, 2, "Digite o apelido do cartão a consultar: ");
    if (ct == DoisDois__cartaoDummy) return;
    std::string apelido_found = g_reverseCardMap.count(ct) ? g_reverseCardMap[ct] : "[Apelido Desconhecido]";
    drawHeader("Detalhes do Cartão '" + apelido_found + "'");
    bool ok_c, block; DoisDois__TIPOCARTAO tipo; int32_t ll, llMax;
    DoisDois__consultarCartao(ct, &ok_c, &tipo, &ll, &llMax, &block);
    mvprintw(2, 2, "Tipo: %s", tipoCartaoToString(tipo));
    mvprintw(3, 2, "Status: %s", block ? "Bloqueado" : "Desbloqueado");
    if (tipo == DoisDois__credito) {
        mvprintw(4, 2, "Limite Disponível: %d", ll);
        mvprintw(5, 2, "Limite Máximo: %d", llMax);
    }
    waitForEnter();
}

void handleConsultarValorFatura() {
    drawHeader("Consultar Valor da Fatura Atual");
    DoisDois__CARTAO ct = getCardFromApelido(2, 2, "Digite o apelido do cartão de crédito: ");
    if (ct == DoisDois__cartaoDummy) return;
    bool ok; int32_t vf;
    DoisDois__consultarValorFatura(ct, &ok, &vf);
    if(ok) {
        std::stringstream ss;
        ss << "O valor da fatura atual é: " << vf;
        showFullScreenMessage("Valor Fatura Atual", ss.str());
    } else {
        showFullScreenMessage("Valor Fatura Atual", "Falha ao consultar valor (cartão não existe ou não é de crédito).");
    }
}

void handleConsultarFaturasCartao() {
    drawHeader("Consultar Faturas do Cartão");
    DoisDois__CARTAO ct = getCardFromApelido(2, 2, "Digite o apelido do cartão: ");
    if (ct == DoisDois__cartaoDummy) return;
    std::string apelido_found = g_reverseCardMap.count(ct) ? g_reverseCardMap[ct] : "[Apelido Desconhecido]";
    drawHeader("Faturas do Cartão '" + apelido_found + "'");
    bool ok, ftCartao[DoisDois__FATURA__max + 1];
    DoisDois__consultarFaturasCartao(ct, &ok, ftCartao);
    if (!ok) { showFullScreenMessage("Consultar Faturas", "Falha (cartão não existe ou não é de crédito)."); return; }
    int y = 3;
    int count = 0;
    for (int i = 1; i <= DoisDois__FATURA__max; i++) {
        if (ftCartao[i]) {
            count++;
            bool ok_f, atual_f; DoisDois__CARTAO ct_f; int32_t tt_f, oo_f; DoisDois__STATUSFATURA st_f;
            DoisDois__consultarFatura(i, &ok_f, &ct_f, &tt_f, &oo_f, &st_f, &atual_f);
            if (ok_f) {
                mvprintw(y++, 4, "ID Fatura: %-4d | Status: %-8s | Total: %-5d | %s", i, statusFaturaToString(st_f), tt_f, atual_f ? "ATUAL" : "");
            }
        }
    }
    if (count == 0) mvprintw(y, 2, "Nenhuma fatura encontrada.");
    waitForEnter();
}

void handleConsultarFatura() {
    drawHeader("Consultar Fatura");
    int ff = getIntInput(2, 2, "Digite o ID NUMÉRICO da fatura: ");
    bool ok_f, atual_f; DoisDois__CARTAO ct_f; int32_t tt_f, oo_f; DoisDois__STATUSFATURA st_f;
    DoisDois__consultarFatura(ff, &ok_f, &ct_f, &tt_f, &oo_f, &st_f, &atual_f);
    if (ok_f) {
        drawHeader("Detalhes da Fatura (ID: " + std::to_string(ff) + ")");
        mvprintw(2, 2, "Pertence ao Cartão ID: %d", ct_f);
        mvprintw(3, 2, "Total: %d", tt_f);
        mvprintw(4, 2, "Status: %s", statusFaturaToString(st_f));
        mvprintw(5, 2, "Ordem (mês): %d", oo_f);
        mvprintw(6, 2, "É a fatura atual do cartão? %s", atual_f ? "Sim" : "Não");
        waitForEnter();
    } else {
        showFullScreenMessage("Consultar Fatura", "Fatura não encontrada.");
    }
}

void handleHistorico() {
    drawHeader("Histórico de Transações da Conta");
    DoisDois__CONTA cc = getAccountFromTitular(2, 2, "Digite o nome do titular da conta: ");
    if (cc == DoisDois__contaDummy) return;

    std::string titular = g_reverseAccountMap.count(cc) ? g_reverseAccountMap[cc] : "[Titular Desconhecido]";
    drawHeader("Histórico da Conta '" + titular + "'");

    bool hh[DoisDois__TRANSACAO__max + 1], ok;
    DoisDois__historico(cc, hh, &ok);
    if (!ok) {
        showFullScreenMessage("Histórico", "Conta não encontrada ou inativa.");
        return;
    }

    int y = 3;
    int count = 0;

    const int COL_ID = 2;
    const int COL_TIPO = 9;
    const int COL_ORIGEM = 41;
    const int COL_DESTINO = 66;
    const int COL_VALOR = 91;

    attron(A_BOLD);
    mvwprintw(stdscr, y, COL_ID, "ID");
    mvwprintw(stdscr, y, COL_TIPO, "Tipo");
    mvwprintw(stdscr, y, COL_ORIGEM, "Origem");
    mvwprintw(stdscr, y, COL_DESTINO, "Destino");
    mvwprintw(stdscr, y, COL_VALOR, "Valor");
    attroff(A_BOLD);
    y++;

    for (int i = 0; i <= DoisDois__TRANSACAO__max; i++) {
        if (hh[i]) {
            count++;
            bool ok_t;
            DoisDois__CONTA oo, dd;
            int32_t vv;
            DoisDois__TIPOTRANSACAO tp;
            DoisDois__consultarTransacao(i, &ok_t, &oo, &dd, &vv, &tp);

            if (ok_t) {
                std::string nome_origem;
                if (g_reverseAccountMap.count(oo)) {
                    nome_origem = g_reverseAccountMap[oo];
                } else if (g_deletedAccountNames.count(oo)) {
                    nome_origem = g_deletedAccountNames[oo] + " (Removida)";
                } else {
                    nome_origem = "ID " + std::to_string(oo);
                }

                std::string nome_destino;
                if (g_reverseAccountMap.count(dd)) {
                    nome_destino = g_reverseAccountMap[dd];
                } else if (g_deletedAccountNames.count(dd)) {
                    nome_destino = g_deletedAccountNames[dd] + " (Removida)";
                } else {
                    nome_destino = "ID " + std::to_string(dd);
                }

                if (oo == dd) {
                    if (tp == DoisDois__depositoCorrente || tp == DoisDois__depositoPoupanca || tp == DoisDois__tranDepositoCartao) {
                        nome_origem = "-";
                    } else {
                        nome_destino = "-";
                    }
                }

                mvwprintw(stdscr, y, COL_ID, "%d", i);
                mvwprintw(stdscr, y, COL_VALOR, "%d", vv);

                mvwaddwstr(stdscr, y, COL_TIPO, to_wstring(tipoTransacaoToString(tp)).c_str());
                mvwaddwstr(stdscr, y, COL_ORIGEM, to_wstring(nome_origem).c_str());
                mvwaddwstr(stdscr, y, COL_DESTINO, to_wstring(nome_destino).c_str());

                y++;
            }
        }
    }

    if (count == 0) {
        mvprintw(++y, 2, "Nenhuma transação encontrada.");
    }

    waitForEnter();
}

int displaySystemState(int start_y) {
    int y = start_y;

    const int ACC_COL_TITULAR = 2;
    const int ACC_COL_SC = 25;
    const int ACC_COL_SP = 44;

    drawSectionHeader(y, "Contas");
    attron(A_BOLD);
    y++;
    mvwprintw(stdscr, y, ACC_COL_TITULAR, "Titular");
    mvwprintw(stdscr, y, ACC_COL_SC, "Saldo Corrente");
    mvwprintw(stdscr, y, ACC_COL_SP, "Saldo Poupança");
    attroff(A_BOLD);
    y++;

    bool ccs[DoisDois__CONTA__max + 1];
    DoisDois__consultarContas(ccs);
    int contas_exibidas = 0;
    for (int id = 1; id <= DoisDois__CONTA__max; ++id) {
        if (ccs[id]) {
            contas_exibidas++;
            std::string titular_str = g_reverseAccountMap.count(id) ? g_reverseAccountMap[id] : "ID " + std::to_string(id);
            int32_t sc, sp;
            bool ok_saldos;
            DoisDois__consultarSaldos(id, &sc, &sp, &ok_saldos);

            if (ok_saldos) {
                mvwaddwstr(stdscr, y, ACC_COL_TITULAR, to_wstring(titular_str).c_str());
                mvwprintw(stdscr, y, ACC_COL_SC, "%d", sc);
                mvwprintw(stdscr, y, ACC_COL_SP, "%d", sp);
                y++;
            }
        }
    }
    if (contas_exibidas == 0) mvprintw(y++, 2, "Nenhuma conta ativa.");

    y+=2;

    const int FAT_COL_ID = 2;   
    const int FAT_COL_ORDEM = 10;  
    const int FAT_COL_STATUS = 19;  
    const int FAT_COL_TOTAL = 32;  
    const int FAT_COL_OBS = 44;  
    
    drawSectionHeader(y++, "Faturas de Cartões de Crédito");

    int faturas_exibidas_total = 0;
    for (const auto& [apelido, card_id] : g_cardMap) {
        bool ok_c, block; DoisDois__TIPOCARTAO tipo; int32_t ll, llMax;
        DoisDois__consultarCartao(card_id, &ok_c, &tipo, &ll, &llMax, &block);

        if (ok_c && tipo == DoisDois__credito) {
            bool ok_faturas, ftCartao[DoisDois__FATURA__max + 1];
            DoisDois__consultarFaturasCartao(card_id, &ok_faturas, ftCartao);

            int faturas_neste_cartao = 0;
            for (int i = 1; i <= DoisDois__FATURA__max; i++) {
                if (ftCartao[i]) faturas_neste_cartao++;
            }

            if (ok_faturas && faturas_neste_cartao > 0) {
                mvwprintw(stdscr, y++, 2, "Cartão '%s' (ID: %d):", apelido.c_str(), card_id);

                attron(A_BOLD);
                mvwprintw(stdscr, y, FAT_COL_ID, "ID");
                mvwprintw(stdscr, y, FAT_COL_ORDEM, "Ordem");
                mvwprintw(stdscr, y, FAT_COL_STATUS, "Status");
                mvwprintw(stdscr, y, FAT_COL_TOTAL, "Total");
                mvwprintw(stdscr, y, FAT_COL_OBS, "Obs.");
                attroff(A_BOLD);
                y++;

                for (int fatura_id = 1; fatura_id <= DoisDois__FATURA__max; fatura_id++) {
                    if (ftCartao[fatura_id]) {
                        faturas_exibidas_total++;
                        bool ok_f, atual_f; DoisDois__CARTAO ct_f; int32_t tt_f, oo_f; DoisDois__STATUSFATURA st_f;
                        DoisDois__consultarFatura(fatura_id, &ok_f, &ct_f, &tt_f, &oo_f, &st_f, &atual_f);
                        if (ok_f) {
                            mvwprintw(stdscr, y, FAT_COL_ID, "%d", fatura_id);
                            mvwprintw(stdscr, y, FAT_COL_ORDEM, "%d", oo_f);
                            mvwaddwstr(stdscr, y, FAT_COL_STATUS, to_wstring(statusFaturaToString(st_f)).c_str());
                            mvwprintw(stdscr, y, FAT_COL_TOTAL, "%d", tt_f);
                            if(atual_f) mvwprintw(stdscr, y, FAT_COL_OBS, "ATUAL");
                            y++;
                        }
                    }
                }
                y++;
            }
        }
    }
    if (faturas_exibidas_total == 0) mvprintw(++y, 4, "Nenhuma fatura de crédito ativa encontrada.");

    return y;
}


void handlePassarMes() {
    drawHeader("Passar o Mês - Estado ANTES");
    displaySystemState(4); 
    
    mvprintw(LINES - 1, 0, "Pressione qualquer tecla para EXECUTAR a passagem do mês...");
    getch();

    bool ok;
    DoisDois__passarMes(&ok);

    if (!ok) {
        showFullScreenMessage("Erro", "FALHA na operação 'passarMes'. O estado não foi alterado.");
        return;
    }

    drawHeader("Passar o Mês - Estado DEPOIS");
    displaySystemState(4);

    waitForEnter(); 
}


void showMenuContas() {
    std::vector<std::string> choices = {
        "1. Adicionar Conta", "2. Remover Conta", "3. Depositar (Corrente)",
        "4. Depositar (Poupança)", "5. Sacar (Corrente)", "6. Sacar (Poupança)",
        "7. PIX", "< Voltar"
    };
    while(true) {
        int choice = draw_menu("Operações de Conta", choices);
        switch(choice) {
            case 1: handleAdicionarConta(); break;
            case 2: handleRemoverConta(); break;
            case 3: handleDepositarCorrente(); break;
            case 4: handleDepositarPoupanca(); break;
            case 5: handleSacarCorrente(); break;
            case 6: handleSacarPoupanca(); break;
            case 7: handlePix(); break;
            case 8: return;
        }
    }
}

void showMenuCartoes() {
    std::vector<std::string> choices = {
        "1. Adicionar Cartão", "2. Remover Cartão", "3. Bloquear Cartão", "4. Desbloquear Cartão",
        "5. Atualizar Limite Disponível", "6. Atualizar Limite Máximo",
        "7. Compra no Débito", "8. Compra Parcelada no Crédito",
        "9. Pagar Fatura", "< Voltar"
    };
    while(true) {
        int choice = draw_menu("Operações de Cartão e Fatura", choices);
        switch(choice) {
            case 1: handleAdicionarCartao(); break;
            case 2: handleRemoverCartao(); break;
            case 3: handleBloquearCartao(); break;
            case 4: handleDesbloquearCartao(); break;
            case 5: handleAtualizarLimite(); break;
            case 6: handleAtualizarLimiteMax(); break;
            case 7: handleCompraDebito(); break;
            case 8: handleCompraParcelada(); break;
            case 9: handlePagarFatura(); break;
            case 10: return;
        }
    }
}

void showMenuConsultas() {
    std::vector<std::string> choices = {
        "1. Listar Contas", "2. Consultar Conta", "3. Consultar Cartão",
        "4. Consultar Valor da Fatura Atual", "5. Consultar Faturas de um Cartão",
        "6. Consultar Fatura", "7. Consultar Histórico da Conta", "< Voltar"
    };
     while(true) {
        int choice = draw_menu("Consultas", choices);
        switch(choice) {
            case 1: handleConsultarContas(); break;
            case 2: handleConsultarConta(); break;
            case 3: handleConsultarCartao(); break;
            case 4: handleConsultarValorFatura(); break;
            case 5: handleConsultarFaturasCartao(); break;
            case 6: handleConsultarFatura(); break;
            case 7: handleHistorico(); break;
            case 8: return;
        }
    }
}

int main() {
    setlocale(LC_ALL, "");
    initscr();
    clear();
    
    if (has_colors() == FALSE) {
        endwin();
        return 1;
    }

    start_color();
    use_default_colors();
    if (can_change_color()) {
        init_color(COLOR_LIGHT_GRAY, 900, 900, 900);
    }
    init_pair(CUSTOM_REVERSE_PAIR, COLOR_BLACK, COLOR_LIGHT_GRAY);
    
    noecho();
    cbreak();
    keypad(stdscr, TRUE);
    curs_set(0);

    DoisDois__INITIALISATION();

    std::vector<std::string> main_choices = {
        "1. Operações de Conta", "2. Operações de Cartão e Fatura",
        "3. Consultas", "4. Passar o Mês", "[x] Sair"
    };

    while(true) {
        int choice = draw_menu("DoisDois - Menu Principal", main_choices);
        switch(choice) {
            case 1: showMenuContas(); break;
            case 2: showMenuCartoes(); break;
            case 3: showMenuConsultas(); break;
            case 4: handlePassarMes(); break;
            case 5: goto exit_loop;
        }
    }

exit_loop:
    endwin();
    return 0;
}