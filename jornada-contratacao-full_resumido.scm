(jornadaContratacao
  (home
    (tap "Seguros" -> seguroEPlanos))
  (seguroEPlanos
    (tap "Simular" -> seguroCelular))
  (seguroCelular
    (GET /seguro/celular/device
      (response
        (modeloCelular       string)
        (memoriaGB           number)
        (primeiraContratacao boolean)))
    (tap "Proteger meu iPhone" -> seguroCelularPlano))
  (seguroCelularPlano
    (GET /seguro/celular/precificacao
      (request
        (modeloCelular string)
        (memoriaGB     number)
        (coberturas    ["danos_acidentais" "roubo_furto"])
        (tipoFranquia  :normal))
      (response
        (mensalidadeBase     number)
        (mensalidadeCartao   number)
        (parcelasDisponiveis list)
        (limiteIndenizacao   number)))
    (tap "Alterar modelo"   -> bottomSheetModelo)
    (tap "Alterar franquia" -> bottomSheetFranquia)
    (tap "toggle Danos acidentais"
      (GET /seguro/celular/precificacao
        (request  (coberturas [...atualizado]) (tipoFranquia ...atual))
        (response (mensalidadeBase number) (mensalidadeCartao number))))
    (tap "toggle Roubo e furto"
      (GET /seguro/celular/precificacao
        (request  (coberturas [...atualizado]) (tipoFranquia ...atual))
        (response (mensalidadeBase number) (mensalidadeCartao number))))
    (tap "Continuar"
      (GET /clientes/me/perfil-seguro
        (response
          (clienteExclusivoC6  boolean)
          (possuiCartaoCredito boolean)
          (saldoContaCorrente  number))
        (decision
          (case (and clienteExclusivoC6 possuiCartaoCredito)       -> confirmacaoPagamento)
          (case (and clienteExclusivoC6 (not possuiCartaoCredito)) -> resumoContratacaoDebito)
          (case (not clienteExclusivoC6)                           -> bottomSheetIMEI)))))
  (confirmacaoPagamento
    (tap "Débito em conta"           -> resumoContratacaoDebito)
    (tap "Cartão de crédito"         -> resumoContratacaoCartao)
    (tap "Parcela selecionada"       -> resumoContratacaoCartao))
  (resumoContratacaoCartao
    (POST /seguro/celular/propostas
      (request
        (modeloCelular  string)
        (memoriaGB      number)
        (coberturas     list)
        (tipoFranquia   enum)
        (formaPagamento :cartao_credito)
        (numeroParcelas number))
      (response
        (propostaId         string)
        (propostaExpiraEm   datetime)
        (vigenciaInicio     date)
        (vigenciaFim        date)
        (valorReservaLimite number)))
    (tap "Cobertura e carência" -> abaCobertura)
    (tap "Contratar plano"      -> autenticacao))
  (resumoContratacaoDebito
    (POST /seguro/celular/propostas
      (request
        (modeloCelular  string)
        (memoriaGB      number)
        (imei           string :optional)
        (coberturas     list)
        (tipoFranquia   enum)
        (formaPagamento :debito))
      (response
        (propostaId       string)
        (propostaExpiraEm datetime)
        (vigenciaInicio   date)
        (vigenciaFim      date)
        (agencia          string)
        (contaCorrente    string)
        (diaCobranca      number)))
    (tap "Cobertura e carência" -> abaCobertura)
    (tap "Contratar plano"      -> bottomSheetConfirmePagamento))
  (abaCobertura)
  (bottomSheetConfirmePagamento
    (tap "Cancelar" -> resumoContratacaoDebito)
    (tap "Pagar"    -> autenticacao))
  (autenticacao
    (input "PIN" :tipo "pin-4-digitos")
    (tap "Concluir"
      (POST /seguro/celular/contratacoes
        (guard (propostaId not-expired))
        (request
          (propostaId string)
          (pin        string :encrypted))
        (response
          (contratacaoId  string)
          (status         enum)
          (vigenciaInicio date)
          (emailEnviado   boolean))
        (side-effect :email
          (template "seguro-celular-contratado")
          (dados #{contratacaoId vigenciaInicio vigenciaFim mensalidadeBase}))
        (-> sucesso))))
  (sucesso
    (tap "Consultar detalhes" -> telaConsulta)
    (tap "Ir para o Início"   -> home)
    (tap "Ir para Seguros"    -> seguroEPlanos))
  (telaConsulta)
  (bottomSheetIMEI
    (input "IMEI" :maxlength 15)
    (tap "Continuar"
      (POST /seguro/celular/imei/validar
        (guard (imei.length == 15))
        (request
          (imei          string)
          (modeloCelular string))
        (response
          (imeiValido boolean)
          (motivoErro string :optional))
        (case imeiValido          -> resumoContratacaoDebito)
        (case (not imeiValido)    -> bottomSheetIMEI)))
    (tap "Ainda não encontrei o IMEI" -> comoEncontrarIMEI))
  (comoEncontrarIMEI
    (tap "Ir para discador"       -> discadorCelular)
    (tap "Ir para configurações"  -> configuracoesCelular))
  (bottomSheetModelo
    (input "Modelo do celular" string)
    (tap "chip 128 GB")
    (tap "chip 256 GB")
    (tap "Confirmar"
      (GET /seguro/celular/precificacao
        (request
          (modeloCelular string)
          (memoriaGB     number)
          (coberturas    list)
          (tipoFranquia  enum))
        (response
          (mensalidadeBase     number)
          (mensalidadeCartao   number)
          (parcelasDisponiveis list))
        (-> seguroCelularPlano))))
  (bottomSheetFranquia
    (tap "radio Franquia normal")
    (tap "radio Franquia reduzida")
    (tap "Selecionar"
      (GET /seguro/celular/precificacao
        (request
          (modeloCelular string)
          (memoriaGB     number)
          (coberturas    list)
          (tipoFranquia  enum))
        (response
          (mensalidadeBase     number)
          (mensalidadeCartao   number)
          (parcelasDisponiveis list))
        (-> seguroCelularPlano)))))
