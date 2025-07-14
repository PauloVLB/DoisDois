# DoisDois 

**DoisDois** é um sistema bancário baseado em terminal que oferece gerenciamento de contas, cartões e faturas, com uma interface interativa construída sobre a biblioteca `ncurses`.

---


## 🛠️ Requisitos

- `g++` 
- `gcc` 
- `make`
- `libncursesw` 

### Para obter os requisitos:

```bash
sudo apt install g++ gcc make libncursesw5-dev
```

---

## ⚙️ Compilação

Abra o terminal na raiz do projeto e execute:

```bash
make
```

Isso compilará o projeto e gerará o executável `DoisDois`.

---

## ▶️ Como rodar

Após compilar, execute o programa com:

```bash
make run
```

Ou diretamente:

```bash
./DoisDois
```

O sistema abrirá uma interface de terminal interativa com menus e opções navegáveis por teclado.

---

## 🧹 Limpeza

Para remover os arquivos objeto (`.o`) e o binário gerado (`DoisDois`), execute:

```bash
make clean
```

---

## 📁 Estrutura do Projeto

- `DoisDois.cpp`: Interface e lógica principal em C++
- `DoisDois_i.c`: Implementação das operações bancárias em C
- `DoisDois.h`: Cabeçalho com definições compartilhadas entre C e C++
- `Makefile`: Automatiza compilação, execução e limpeza do projeto
