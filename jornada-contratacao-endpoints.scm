(endpoints
  (GET /seguro/celular/device
    ;; seguroCelular — ao carregar a tela
    (response
      (modeloCelular       string)
      (memoriaGB           number)
      (primeiraContratacao boolean)))

  (GET /seguro/celular/precificacao
    ;; seguroCelularPlano — ao carregar, a cada toggle de cobertura e ao confirmar modelo ou franquia
    (request
      (modeloCelular string)
      (memoriaGB     number)
      (coberturas    list)
      (tipoFranquia  enum))
    (response
      (mensalidadeBase     number)
      (mensalidadeCartao   number)
      (parcelasDisponiveis list)
      (limiteIndenizacao   number)))

  (GET /clientes/me/perfil-seguro
    ;; seguroCelularPlano — ao tocar "Continuar"
    (response
      (clienteExclusivoC6  boolean)
      (possuiCartaoCredito boolean)
      (saldoContaCorrente  number)))

  (POST /seguro/celular/imei/validar
    ;; bottomSheetIMEI — ao tocar "Continuar"
    (request
      (imei          string)
      (modeloCelular string))
    (response
      (imeiValido boolean)
      (motivoErro string :optional)))

  (POST /seguro/celular/propostas
    ;; resumoContratacaoCartao e resumoContratacaoDebito — ao carregar a tela
    (request
      (modeloCelular  string)
      (memoriaGB      number)
      (imei           string :optional)
      (coberturas     list)
      (tipoFranquia   enum)
      (formaPagamento enum) ;; :cartao_credito | :debito
      (numeroParcelas number :optional))
    (response
      (propostaId         string)
      (propostaExpiraEm   datetime)
      (vigenciaInicio     date)
      (vigenciaFim        date)
      (valorReservaLimite number :optional)
      (agencia            string :optional)
      (contaCorrente      string :optional)
      (diaCobranca        number :optional)))

  (POST /seguro/celular/contratacoes
    ;; autenticacao — ao tocar "Concluir"
    (request
      (propostaId string)
      (pin        string :encrypted))
    (response
      (contratacaoId  string)
      (status         enum) ;; :ativo | :pendente | :erro
      (vigenciaInicio date)
      (emailEnviado   boolean))))
