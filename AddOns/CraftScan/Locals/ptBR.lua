local CraftScan = select(2, ...)

CraftScan.LOCAL_PT = {}

function CraftScan.LOCAL_PT:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                             = "CraftScan",
        [LID.CRAFT_SCAN]                          = "CraftScan",
        [LID.CHAT_ORDERS]                         = "Ordens no Chat",
        [LID.DISABLE_ADDONS]                      = "Desativar Addons",
        [LID.RENABLE_ADDONS]                      = "Reativar Addons",
        [LID.DISABLE_ADDONS_TOOLTIP]              =
        "Salve sua lista de addons e, em seguida, desative-os, permitindo uma troca rápida para um personagem alternativo. Este botão pode ser clicado novamente para reativar os addons a qualquer momento.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]           = "Posso criar {item}.",                                       -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]         = "Meu personagem alternativo, {crafter}, pode criar {item}.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]                = "isso",
        [LID.GREETING_I_HAVE_PROF]                = "Eu tenho {profession}.",                                    -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]               = "Meu personagem alternativo, {crafter}, tem {profession}.",  -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]                 = "Me avise se você enviar um pedido para que eu possa fazer login.",
        [LID.MAIN_BUTTON_BINDING_NAME]            = "Alternar Página de Pedido",
        [LID.GREET_BUTTON_BINDING_NAME]           = "Saudar Cliente com Banner",
        [LID.DISMISS_BUTTON_BINDING_NAME]         = "Dispensar Cliente com Banner",
        [LID.TOGGLE_CHAT_TOOLTIP]                 = "Alternar ordens no chat%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]                 = "Mostrar CraftScan",
        [LID.SCANNER_CONFIG_HIDE]                 = "Esconder CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]                  = "Opções do CraftScan",
        [LID.ITEM_SCAN_CHECK]                     = "Verificar chat para este item",
        [LID.HELP_PROFESSION_KEYWORDS]            =
        "Uma mensagem deve conter um destes termos. Para coincidir com uma mensagem como 'LF Lariat', 'lariet' deve estar listado aqui. Para gerar um link de item para o Elemental Lariat na resposta, 'lariat' também deve ser incluído nas palavras-chave de configuração do item para o Elemental Lariat.",
        [LID.HELP_PROFESSION_EXCLUSIONS]          =
        "Uma mensagem será ignorada se contiver um destes termos, mesmo que fosse uma coincidência. Para evitar responder a 'LF JC Lariat' com 'Eu tenho Joalheria' quando você não tem a receita Lariat, 'lariat' deve ser listado aqui.",
        [LID.HELP_SCAN_ALL]                       = "Ativar verificação para todas as receitas na mesma expansão que a receita selecionada.",
        [LID.HELP_PRIMARY_EXPANSION]              =
        "Use esta saudação ao responder a uma solicitação genérica como 'LF Ferreiro'. Quando uma nova expansão é lançada, você provavelmente desejará uma saudação descrevendo quais itens você pode criar em vez de declarar que possui conhecimento máximo da expansão anterior.",
        [LID.HELP_EXPANSION_GREETING]             =
        "Uma introdução inicial é sempre gerada afirmando que você pode criar o item. Este texto é adicionado a ele. Novas linhas são permitidas e serão enviadas como uma resposta separada. Se o texto for muito longo, ele será dividido em várias respostas.",
        [LID.HELP_CATEGORY_KEYWORDS]              =
        "Se uma profissão foi encontrada, verifique estas palavras-chave específicas da categoria para refinar a saudação. Por exemplo, você pode colocar 'tóxico' ou 'viscoso' aqui para tentar detectar padrões de Couraria que requerem o Altar da Decomposição.",
        [LID.HELP_CATEGORY_GREETING]              =
        "Quando esta categoria é detectada em uma mensagem, seja por palavra-chave ou um link de item, esta saudação adicional será adicionada após a saudação da profissão.",
        [LID.HELP_CATEGORY_OVERRIDE]              = "Omita a saudação da profissão e comece com a saudação da categoria.",
        [LID.HELP_ITEM_KEYWORDS]                  =
        "Se uma profissão foi encontrada, verifique estas palavras-chave específicas do item para refinar a saudação. Quando coincidir, a resposta incluirá o link do item em vez da saudação genérica da profissão. Se 'lariat' for uma palavra-chave da profissão, mas não uma palavra-chave do item, a resposta dirá 'Eu tenho Joalheria.' Se 'lariat' for apenas uma palavra-chave do item, 'LF Lariat' não corresponderá a uma profissão e não será considerado uma coincidência. Se 'lariat' for uma palavra-chave tanto da profissão quanto do item, a resposta para 'LF Lariat' será 'Posso criar [Lariat Elemental].'",
        [LID.HELP_ITEM_GREETING]                  =
        "Quando este item é detectado em uma mensagem, seja por palavra-chave ou pelo link do item, esta saudação adicional será adicionada após as saudações da profissão e da categoria.",
        [LID.HELP_ITEM_OVERRIDE]                  = "Omita a saudação da profissão e da categoria e comece com a saudação do item.",
        [LID.HELP_GLOBAL_KEYWORDS]                = "Uma mensagem deve incluir um destes termos.",
        [LID.HELP_GLOBAL_EXCLUSIONS]              = "Uma mensagem será ignorada se contiver um destes termos.",
        [LID.SCAN_ALL_RECIPES]                    = 'Verificar todas as receitas',
        [LID.SCANNING_ENABLED]                    = "A verificação está ativada porque '%s' está marcado.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                   = "A verificação está desativada.",
        [LID.PRIMARY_KEYWORDS]                    = "Palavras-chave Primárias",
        [LID.HELP_PRIMARY_KEYWORDS]               =
        "Todas as mensagens são filtradas por esses termos, que são comuns em todas as profissões. Uma mensagem correspondente é posteriormente processada para buscar conteúdo relacionado à profissão.",
        [LID.HELP_CATEGORY_SECTION]               =
        "A categoria é a seção expansível que contém a receita na lista à esquerda. 'Favoritos' não é uma categoria. Isso é destinado principalmente para coisas como as receitas de Couraria tóxicas que são mais difíceis de criar. Também pode ser útil no início das expansões, quando você só pode se especializar em uma única categoria.",
        [LID.HELP_EXPANSION_SECTION]              =
        "As árvores de conhecimento diferem por expansão, então a saudação também pode diferir.",
        [LID.HELP_PROFESSION_SECTION]             =
        "Do ponto de vista do cliente, não há diferença entre expansões. Esses termos se combinam com a seleção 'Expansão primária' para fornecer uma saudação genérica (por exemplo, 'Eu tenho <profissão>.') quando não podemos corresponder a algo mais específico.",
        [LID.RECIPE_NOT_LEARNED]                  = "Você não aprendeu esta receita. A verificação está desativada.",
        [LID.PING_SOUND_LABEL]                    = "Som de Alerta",
        [LID.PING_SOUND_TOOLTIP]                  = "O som que toca quando um cliente é detectado.",
        [LID.BANNER_SIDE_LABEL]                   = "Direção do Banner",
        [LID.BANNER_SIDE_TOOLTIP]                 = "O banner crescerá do botão nesta direção.",
        Left                                      = "Esquerda",
        Right                                     = "Direita",
        Minute                                    = "Minuto",
        Minutes                                   = "Minutos",
        Second                                    = "Segundo",
        Seconds                                   = "Segundos",
        Millisecond                               = "Milissegundo",
        Milliseconds                              = "Milissegundos",
        Version                                   = "Novo em",
        ["CraftScan Release Notes"]               = "Notas da Versão do CraftScan",
        [LID.CUSTOMER_TIMEOUT_LABEL]              = "Tempo Limite do Cliente",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]            = "Dispensar clientes automaticamente após tantos minutos.",
        [LID.BANNER_TIMEOUT_LABEL]                = "Tempo Limite do Banner",
        [LID.BANNER_TIMEOUT_TOOLTIP]              =
        "O banner de notificação do cliente permanecerá exibido por esta duração após uma correspondência ser detectada.",
        ["All crafters"]                          = "Todos os Criadores",
        ["Crafter Name"]                          = "Nome do Criador",
        ["Profession"]                            = "Profissão",
        ["Customer Name"]                         = "Nome do Cliente",
        ["Replies"]                               = "Respostas",
        ["Keywords"]                              = "Palavras-chave",
        ["Profession greeting"]                   = "Saudação da Profissão",
        ["Category greeting"]                     = "Saudação da Categoria",
        ["Item greeting"]                         = "Saudação do Item",
        ["Primary expansion"]                     = "Expansão Primária",
        ["Override greeting"]                     = "Saudação de Substituição",
        ["Excluded keywords"]                     = "Palavras-chave Excluídas",
        [LID.EXCLUSION_INSTRUCTIONS]              = "Não corresponder a mensagens contendo esses tokens separados por vírgula.",
        [LID.KEYWORD_INSTRUCTIONS]                = "Corresponder a mensagens contendo uma destas palavras-chave separadas por vírgula.",
        [LID.GREETING_INSTRUCTIONS]               = "Uma saudação para enviar aos clientes que procuram uma criação.",
        [LID.GLOBAL_INCLUSION_DEFAULT]            = "LF, LFC, Compra, recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]            = "LFW, Venda, LF trabalho",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]      = "FE, Ferraria, Ferreiro de Armaduras, Ferreiro de Armas",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]     = "Couraria, Curtidor",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]            = "Alquimia, Alquimista, Pedra",
        [LID.DEFAULT_KEYWORDS_TAILORING]          = "Costureiro",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]        = "Engenheiro, Eng",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]         = "Encantador, Emblema",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]      = "JC, Joalheiro",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]        = "Inscrição, Escriba, Calígrafo",

        -- Notas de Versão
        [LID.RN_WELCOME]                          = "Bem-vindo ao CraftScan!",
        [LID.RN_WELCOME + 1]                      =
        "Este addon escaneia o chat em busca de mensagens que parecem pedidos de criação. Se a configuração indicar que você pode criar o item solicitado, uma notificação será acionada e as informações do cliente serão armazenadas para facilitar a comunicação.",

        [LID.RN_INITIAL_SETUP]                    = "Configuração Inicial",
        [LID.RN_INITIAL_SETUP + 1]                =
        "Para começar, abra uma profissão e clique no novo botão 'Mostrar CraftScan' na parte inferior.",
        [LID.RN_INITIAL_SETUP + 2]                =
        "Role até o final desta nova janela e vá subindo. As coisas que você raramente muda estão no final, mas essas são as configurações a se preocupar primeiro.",
        [LID.RN_INITIAL_SETUP + 3]                =
        "Clique no ícone de ajuda no canto superior esquerdo da janela se precisar de uma explicação de qualquer entrada.",

        [LID.RN_INITIAL_TESTING]                  = "Teste Inicial",
        [LID.RN_INITIAL_TESTING + 1]              =
        "Depois de configurado, digite uma mensagem no chat /dizer, como 'LF FE' para Ferraria, assumindo que você tenha as palavras-chave 'LF' e 'FE'. Uma notificação deve aparecer.",
        [LID.RN_INITIAL_TESTING + 2]              =
        "Clique na notificação para enviar imediatamente uma resposta, clique com o botão direito para dispensar o cliente ou clique no próprio botão circular da profissão para abrir a janela de pedidos.",
        [LID.RN_INITIAL_TESTING + 3]              =
        "Notificações duplicadas são suprimidas a menos que já tenham sido dispensadas, então clique com o botão direito na sua notificação de teste para dispensá-la se quiser tentar novamente.",

        [LID.RN_MANAGING_CRAFTERS]                = "Gerenciando Seus Criadores",

        [LID.RN_MANAGING_CRAFTERS + 1]            =
        "O lado esquerdo da janela de pedidos lista seus criadores. Esta lista será preenchida à medida que você fizer login em seus vários personagens e configurar suas profissões. Você pode selecionar quais personagens devem ser escaneados ativamente a qualquer momento, bem como se as notificações visuais e auditivas estão habilitadas para cada um de seus criadores.",

        [LID.RN_MANAGING_CUSTOMERS]               = "Gerenciando Clientes",
        [LID.RN_MANAGING_CUSTOMERS + 1]           =
        "O lado direito da janela de pedidos será preenchido com pedidos de criação detectados no chat. Clique com o botão esquerdo em uma linha para enviar a saudação se você ainda não o fez pelo banner pop-up. Clique novamente para abrir um sussurro para o cliente. Clique com o botão direito para dispensar a linha.",
        [LID.RN_MANAGING_CUSTOMERS + 2]           =
        "As linhas nesta tabela persistirão em todos os personagens, então você pode fazer login em um personagem alternativo e depois clicar no cliente novamente para restaurar a comunicação. As linhas expiram após 10 minutos por padrão. Esta duração pode ser configurada na página de configurações principais (Esc -> Opções -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]           =
        "Esperançosamente, a maior parte da tabela é autoexplicativa. A coluna 'Respostas' possui 3 ícones. O X ou marca de seleção à esquerda é se você enviou uma mensagem para o cliente. O X ou marca de seleção à direita é se o cliente respondeu. O balão de chat é um botão que abrirá uma janela de sussurro temporária com o cliente e a preencherá com seu histórico de bate-papo.",

        [LID.RN_KEYBINDS]                         = "Atalhos de Teclado",
        [LID.RN_KEYBINDS + 1]                     =
        "Atalhos de teclado estão disponíveis para abrir a página de pedidos, responder ao último cliente e dispensar o último cliente. Procure por 'CraftScan' para encontrar todas as configurações disponíveis.",

        [LID.RN_CLEANUP]                          = "Limpeza de Configuração",
        [LID.RN_CLEANUP + 1]                      =
        "Seus artesãos no lado esquerdo da página 'Ordens de Chat' agora têm um menu de contexto ao clicar com o botão direito. Use este menu para manter a lista limpa e remover personagens/profissões desatualizados.",
        ["Disable"]                               = "Desativar",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]          =
        "Exclua permanentemente qualquer dado %s salvo para %s.\n\nUm botão 'Habilitar CraftScan' estará presente na página da profissão para habilitá-lo novamente com as configurações padrão.\n\nUse isso se você quiser continuar usando a profissão, mas sem a interação do CraftScan (por exemplo, quando você tem Alquimia em todos os alts para frascos longos).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]               = "Digite 'DELETE' para continuar:",
        [LID.SCANNER_CONFIG_DISABLED]             = "Habilitar CraftScan",

        ["Cleanup"]                               = "Limpeza",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]         =
        "Exclua permanentemente qualquer dado %s salvo para %s.\n\nA profissão será deixada em um estado como se nunca tivesse sido configurada. Simplesmente abrir a profissão novamente restaurará uma configuração padrão.\n\nUse isso se você quiser redefinir completamente uma profissão, excluiu o personagem ou abandonou a profissão.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]              = "Digite 'CLEANUP' para continuar:",
        ["Primary Crafter"]                       = "Artesão Principal",
        [LID.PRIMARY_CRAFTER_TOOLTIP]             =
        "Marque %s como seu artesão principal para %s. Este artesão terá prioridade sobre os outros se houver várias correspondências com a mesma solicitação.",
        ["Chat History"]                          = "Histórico de bate-papo com %s", -- customer, left-click-help
        ["Greet Help"]                            = "|cffffd100Clique esquerdo: Cumprimentar o cliente%s|r",
        ["Chat Help"]                             = "|cffffd100Clique esquerdo: Abrir sussurro|r",
        ["Chat Override"]                         = "|cffffd100Clique do meio: Abrir sussurro%s|r",
        ["Dismiss"]                               = "|cffffd100Clique direito: Dispensar%s|r",
        ["Proposed Greeting"]                     = "Cumprimento proposto:",
        [LID.CHAT_BUTTON_BINDING_NAME]            = "Cliente do Banner Sussurro",
        ["Customer Request"]                      = "Pedido de %s",
        [LID.ADDON_WHITELIST_LABEL]               = "Lista branca de addons",
        [LID.ADDON_WHITELIST_TOOLTIP]             =
        "Ao pressionar o botão para desativar temporariamente todos os addons, mantenha os addons selecionados aqui ativados. CraftScan sempre permanecerá ativado. Mantenha apenas o que você precisa para fabricar de forma eficiente.",
        [LID.MULTI_SELECT_BUTTON_TEXT]            = "%d selecionados", -- Count

        [LID.ACCOUNT_LINK_DESC]                   =
        "Compartilhe artesãos entre várias contas.\n\nAo entrar ou após uma alteração na configuração, o CraftScan irá propagar as informações mais recentes para e dos artesãos configurados em ambas as contas para garantir que ambos os lados de uma conta vinculada estejam sempre sincronizados.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]       = "Digite o nome de um personagem online em sua outra conta:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]        = "Digite um apelido para a outra conta:",
        ["Link Account"]                          = "Vincular Conta",
        ["Linked Accounts"]                       = "Contas Vinculadas",
        ["Accept Linked Account"]                 = "Aceitar Conta Vinculada",
        ["Delete Linked Account"]                 = "Excluir Conta Vinculada",
        ["OK"]                                    = "OK",
        [LID.VERSION_MISMATCH]                    =
        "|cFFFF0000Erro: incompatibilidade de versão do CraftScan. Versão da outra conta: %s. Sua versão: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]              =
        "Este personagem pertence a uma conta vinculada. Ele só pode ser desativado na conta à qual pertence. Você pode remover completamente este personagem via 'Limpeza', mas precisará fazê-lo manualmente em todas as contas vinculadas, ou ele será restaurado por uma conta vinculada ao entrar.",
        [LID.REMOTE_CRAFTER_SUMMARY]              = "Sincronizado com %s.",
        ["proxy_send_enabled"]                    = "Pedidos por Proxy",
        ["proxy_send_enabled_tooltip"]            = "Quando um pedido de cliente é detectado, envie-o para contas vinculadas.",
        ["proxy_receive_enabled"]                 = "Receber Pedidos por Proxy",
        ["proxy_receive_enabled_tooltip"]         =
        "Quando outra conta detectar e enviar um pedido de cliente, esta conta o receberá. O botão CraftScan será exibido para mostrar o banner de alerta se necessário.",
        [LID.LINK_ACTIVE]                         = "|cFF00FF00%s (visto por último %s)|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]            =
        "Excluir a vinculação com '%s' e todos os personagens importados. Esta conta cessará todas as comunicações com a outra parte. A outra parte ainda tentará estabelecer conexões até que a vinculação seja removida manualmente também lá.\n\nArtesãos importados que serão removidos:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]               =
        "Por padrão, o personagem que você inicialmente vinculou, qualquer artesão e qualquer personagem que tenha feito login enquanto esta conta estava online são conhecidos pelo CraftScan. Adicione personagens adicionais pertencentes à outra conta para que possam ser usados também. '/reload' para forçar a sincronização com o novo personagem, se estiver online.",
        ["Backup characters"]                     = "Personagens Adicionais",
        ["Unlink account"]                        = "Desvincular Conta",
        ["Add"]                                   = "Adicionar",
        ["Remove"]                                = "Remover",
        ["Rename account"]                        = "Renomear Conta",
        ["New name"]                              = "Novo Nome:",

        [LID.RN_LINKED_ACCOUNTS]                  = "Contas Vinculadas",
        [LID.RN_LINKED_ACCOUNTS + 1]              =
        "Vincule várias contas WoW juntas para compartilhar informações de fabricação e escanear qualquer conta de qualquer conta.",
        [LID.RN_LINKED_ACCOUNTS + 2]              =
        "Opcionalmente, envie pedidos de clientes de uma conta para as outras para que você possa estacionar uma conta de teste na cidade enquanto seu personagem principal está fora.",
        [LID.RN_LINKED_ACCOUNTS + 3]              =
        "Para começar, clique no botão 'Vincular Conta' no canto inferior esquerdo da janela CraftScan e siga as instruções.",
        [LID.RN_LINKED_ACCOUNTS + 4]              = "Demo: https://www.youtube.com/watch?v=x1JLEph6t_c",

        ["Open Settings"]                         = "Abrir Configurações",
        ["Customize Greeting"]                    = "Personalizar Saudação",
        [LID.CUSTOM_GREETING_INFO]                =
        "CraftScan usa estas frases para criar a saudação inicial enviada aos clientes dependendo da situação. Substitua algumas ou todas abaixo para criar sua própria saudação.",
        ["Default"]                               = "Padrão",
        [LID.MISSING_PLACEHOLDERS]                = "Os seguintes espaços reservados também são suportados: %s.",
        [LID.EXTRA_PLACEHOLDERS]                  = "Erro: %s não são marcadores de posição válidos.",
        [LID.LEGACY_PLACEHOLDERS]                 =
        "Aviso: O uso de %s agora está obsoleto. Use placeholders nomeados, como: {placeholder}",

        ["Pixels"]                                = "Pixels",
        ["Show button height"]                    = "Mostrar altura do botão",
        ["Alert icon scale"]                      = "Escala do ícone de alerta",
        ["Total"]                                 = "Total",
        ["Repeat"]                                = "Repetir",
        ["Avg Per Day"]                           = "Média/Dia",
        ["Peak Per Hour"]                         = "Pico/Hora",
        ["Median Per Customer"]                   = "Mediana/Cliente",
        ["Median Per Customer Filtered"]          = "Mediana/Cliente Repetido",
        ["No analytics data"]                     = "Sem dados de análise",
        ["Reset Analytics"]                       = "Redefinir Análise",
        ["Analytics Options"]                     = "Opções de Análise",

        ["1 minute"]                              = "1 minuto",
        ["15 minutes "]                           = "15 minutos ",
        ["1 hour"]                                = "1 hora",
        ["1 day"]                                 = "1 dia",
        ["1 week "]                               = "1 semana ",
        ["30 days"]                               = "30 dias",
        ["180 days"]                              = "180 dias",
        ["1 year"]                                = "1 ano",
        ["Clear recent data"]                     = "Limpar dados recentes",
        ["Newer than"]                            = "Mais recente que",
        ["Clear old data"]                        = "Limpar dados antigos",
        ["Older than"]                            = "Mais velho que",
        ["1 Minute Bins"]                         = "1 Minuto",
        ["5 Minute Bins"]                         = "5 Minutos",
        ["10 Minute Bins"]                        = "10 Minutos",
        ["30 Minute Bins"]                        = "30 Minutos",
        ["1 Hour Bins"]                           = "1 Hora",
        ["6 Hour Bins"]                           = "6 Horas",
        ["12 Hour Bins"]                          = "12 Horas",
        ["24 Hour Bins"]                          = "24 Horas",
        ["1 Week Bins"]                           = "1 Semana",

        [LID.ANALYTICS_ITEM_TOOLTIP]              =
        "Os itens são correspondidos verificando se a mensagem corresponde a palavras-chave globais de inclusão e exclusão, e então procurando o ícone de qualidade no link do item. Não há como verificar uma lista global de itens criados ou se um item foi criado por um itemID, então essa é a melhor que podemos fazer.",
        [LID.ANALYTICS_PROFESSION_TOOLTIP]        =
        "Não há funcionalidade de pesquisa reversa para encontrar a profissão que criou o item. Se um dos seus personagens pode criar o item, a profissão será atribuída automaticamente. Quando a profissão é aberta, um item desconhecido associado a essa profissão será atribuído. Você também pode atribuir a profissão manualmente.",
        [LID.ANALYTICS_TOTAL_TOOLTIP]             =
        "Este é o número total de solicitações para este item. Solicitações duplicadas do mesmo cliente dentro do mesmo período não são incluídas.",
        [LID.ANALYTICS_REPEAT_TOOLTIP]            =
        "Este é o número total de solicitações para este item, feito várias vezes pelo mesmo cliente dentro do mesmo período.\n\nSe este valor estiver próximo do total, há uma alta chance de que a oferta deste item esteja escassa.\n\nSolicitações duplicadas feitas dentro de 15 segundos após o primeiro pedido são ignoradas.",
        [LID.ANALYTICS_AVERAGE_TOOLTIP]           = "Este é o número médio de solicitações diárias para este item.",
        [LID.ANALYTICS_PEAK_TOOLTIP]              = "Este é o número máximo de solicitações por hora para este item.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP]            =
        "Este é o valor mediano das solicitações para este item, feitas pelo mesmo cliente dentro do mesmo período.\n\nSe o valor for 1, isso indica que pelo menos metade de todos os pedidos foram atendidos por alguém, indicando que a demanda por este item está sendo atendida.\n\nSe esse valor for maior, pode haver uma boa oportunidade para fabricar este item.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]   =
        "Este é o valor mediano das solicitações para este item, feitas pelo mesmo cliente dentro do mesmo período, filtrando apenas os pedidos que foram feitos várias vezes.\n\nSe este valor não for 1, mas o valor mediano não filtrado for 1, isso indica que pode haver casos em que a demanda não está sendo atendida.",
        ["Request Count"]                         = "Contagem de Solicitações",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]        =
        "'%s' enviou um pedido para conectar contas.\n\nPermissões solicitadas:\n\n%s\n\nNão aceite permissões totais a menos que tenha enviado o pedido.",
        [LID.LINKED_ACCOUNT_REJECTED]             = "CraftScan: Falha ao conectar conta. Razão: %s",
        [LID.LINKED_ACCOUNT_USER_REJECTED]        = "A conta de destino rejeitou o pedido.",

        [LID.LINKED_ACCOUNT_PERMISSION_FULL]      = "Controle Total",
        [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS] = "Sincronização de Análise",
        [LID.ACCOUNT_LINK_PERMISSIONS_DESC]       = "Permissões solicitadas da conta conectada.",
        [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]      =
        "Sincroniza todos os dados de personagens e suporta todas as outras permissões.",
        [LID.ACCOUNT_LINK_ANALYTICS_DESC]         =
        "Sincroniza apenas dados de análise entre as duas contas manualmente. Qualquer conta pode iniciar a sincronização bidirecional a qualquer momento. Nunca acontece automaticamente. Não importa qual personagem você está trazendo, apenas os que estão especificados aqui serão sincronizados. Personagens adicionais na conta conectada podem ser adicionados manualmente a partir do menu da conta.",
        ["Sync Analytics"]                        = "Sincronizar Análise",
        ["Sync Recent Analytics"]                 = "Sincronizar Análise Recente",
        [LID.ANALYTICS_PROF_MISMATCH]             =
        "|cFFFF0000CraftScan: Aviso: Desvio de profissão na sincronização de análise. Item: %s. Profissão local: %s. Profissão conectada: %s.|r",
        [LID.RN_ANALYTICS]                        = "Análises",
        [LID.RN_ANALYTICS + 1]                    =
        "CraftScan agora escaneia tudo que é combinado entre itens criados no chat e palavras-chave globais (ex: LF, WTB, recraft, etc...). Mesmo se você não puder criar um item, o tempo é registrado e os itens detectados aparecem sob pedidos normais no chat.",
        [LID.RN_ANALYTICS + 2]                    =
        "O conceito de 'repetição' é usado para determinar a escassez de oferta de itens. O CraftScan se lembra de quem pediu o que na última hora, e se você solicitar o mesmo item novamente, ele será registrado como uma repetição. O cabeçalho das colunas da nova grade tem uma dica de ferramenta explicando a intenção.",
        [LID.RN_ANALYTICS + 3]                    =
        "Com um personagem estacionado em comércio por um período suficiente, você pode saber onde vale a pena investir em um ponto da árvore de profissões.",
        [LID.RN_ANALYTICS + 4]                    =
        "Análises podem ser sincronizadas entre contas. Você pode estacionar uma conta de teste para coletar dados ao longo do dia em comércio e sincronizar esses dados com a conta principal. Agora você pode criar links de conta dedicados à análise com amigos, com suporte para sincronização bidirecional, unindo as análises. Com mais dados sendo coletados, há uma opção para sincronizar apenas os dados desde a última sincronização.",
        [LID.RN_ALERT_ICON_ANCHOR]                = "Atualização de âncora do ícone de alerta",
        [LID.RN_ALERT_ICON_ANCHOR + 1]            =
        "O ícone de alerta se esconderá corretamente quando a UI estiver oculta. A mudança resultou em um pequeno movimento e redução na minha tela. Se isso moveu o botão da tela, há uma opção de redefinir clicando com o botão direito no botão 'Abrir Configurações' no canto superior direito da página de pedidos do chat.",
        [LID.BUSY_RIGHT_NOW]                      = "Modo Ocupado",
        [LID.GREETING_BUSY]                       = "Estou ocupado agora. Mas poderei fazer isso mais tarde.",
        [LID.BUSY_HELP]                           =
        "|cFFFFFFFFSe selecionado, adicione uma saudação ocupada à sua resposta. Edite sua saudação ocupada com o botão abaixo.\n\nIsso é destinado ao uso com uma segunda conta que faz proxy de pedidos para que você possa capturar pedidos enquanto estiver fora com sua conta principal.\n\nSaudação ocupada atual: |cFF00FF00%s|r|r",
        ["Custom Explanations"]                   = "Explicações Personalizadas",
        ["Create"]                                = "Criar",
        ["Modify"]                                = "Modificar",
        ["Delete"]                                = "Excluir",
        [LID.EXPLANATION_LABEL_DESC]              =
        "Insira um rótulo que você verá ao clicar com o botão direito no nome do cliente no chat.",
        [LID.EXPLANATION_DUPLICATE_LABEL]         = "Esse rótulo já está em uso.",
        [LID.EXPLANATION_TEXT_DESC]               =
        "Insira uma mensagem para enviar ao cliente quando o rótulo for clicado. Novas linhas são enviadas como mensagens separadas. Linhas longas são quebradas para se adequar ao comprimento máximo da mensagem.",
        ["Create an Explanation"]                 = "Criar uma Explicação",
        ["Save"]                                  = "Salvar",
        ["Reset"]                                 = "Redefinir",
        [LID.MANUAL_MATCHING_TITLE]               = "Correspondência Manual",
        [LID.MANUAL_MATCH]                        = "%s - %s", -- artesão, profissão
        [LID.MANUAL_MATCHING_DESC]                =
        "Ignora palavras-chave primárias e força uma correspondência para esta mensagem. CraftScan tentará encontrar o artesão correto com base na mensagem, mas se nenhuma correspondência for encontrada, a saudação padrão para o artesão especificado será usada. A correspondência é relatada pelos meios habituais, permitindo que você clique no banner ou na linha da tabela para enviar a saudação.",

        [LID.RN_MANUAL_MATCH]                     = "Correspondência Manual",
        [LID.RN_MANUAL_MATCH + 1]                 =
        "O menu de contexto ao clicar com o botão direito no nome de um jogador no chat agora inclui opções do CraftScan.",
        [LID.RN_MANUAL_MATCH + 2]                 =
        "Este menu inclui todos os seus artesãos e profissões. Ao clicar em um deles, você forçará outra passada na mensagem para procurar uma correspondência sem considerar as 'Palavras-chave Primárias' (por exemplo, LF, WTB, recraft, etc...), caso o cliente esteja usando uma terminologia não padrão.",
        [LID.RN_MANUAL_MATCH + 3]                 =
        "Se a mensagem ainda não corresponder, uma correspondência será forçada com a saudação padrão para o artesão e profissão que você clicou.",
        [LID.RN_MANUAL_MATCH + 4]                 =
        "Esse clique não enviará automaticamente uma mensagem ao cliente. Depois de gerar a correspondência por métodos normais, você pode revisar a resposta gerada e decidir se deseja enviar ou não.",
        [LID.RN_MANUAL_MATCH + 5]                 = "(Desculpe, não há aprendizado de máquina.)",
        [LID.RN_CUSTOM_EXPLANATIONS]              = "Explicações Personalizadas",
        [LID.RN_CUSTOM_EXPLANATIONS + 1]          =
        "Um novo botão 'Explicações Personalizadas' foi adicionado à página de 'Pedidos de Chat'. As explicações configuradas aqui também aparecerão no menu de contexto do chat e serão enviadas imediatamente quando clicadas.",
        [LID.RN_CUSTOM_EXPLANATIONS + 2]          =
        "As explicações são ordenadas alfabeticamente, então você pode forçá-las a aparecer em uma determinada ordem numerando-as.",
        [LID.RN_BUSY_MODE]                        = "Modo Ocupado",
        [LID.RN_BUSY_MODE + 1]                    =
        "Este recurso existiu durante várias versões, mas não foi documentado. Há uma nova caixa de seleção 'Modo Ocupado' na página de 'Pedidos de Chat'. Se marcada, adicionará uma saudação ocupada à sua resposta. Você pode editar sua saudação ocupada com o botão 'Personalizar Saudação'.",
        [LID.RN_BUSY_MODE + 2]                    =
        "Esse recurso é destinado a ser usado com uma segunda conta de proxy para que você possa capturar pedidos enquanto estiver fora com sua conta principal.",
        ["Release Notes"]                         = "Notas de Lançamento",

        ["Secondary Keywords"]                    = "Palavras-chave secundárias",
        [LID.SECONDARY_KEYWORD_INSTRUCTIONS]      =
        "Por exemplo: 'pvp, 610, algari' ou '606, 610, 636' ou '590', para diferenciar a mesma palavra-chave em vários itens.",
        [LID.HELP_ITEM_SECONDARY_KEYWORDS]        =
        "Após encontrar uma palavra-chave, verifique palavras-chave secundárias para refinar a correspondência, permitindo diferenciar os vários ofícios para o mesmo slot de item.",
        [LID.RN_SECONDARY_KEYWORDS]               = "Palavras-chave secundárias",
        [LID.RN_SECONDARY_KEYWORDS + 1]           =
        "Os itens agora suportam palavras-chave secundárias para refinar uma correspondência. Cada slot de item geralmente tem uma versão Faísca, PVP e Azul. As palavras-chave secundárias podem ser configuradas para diferenciá-las.",
        [LID.RN_SECONDARY_KEYWORDS + 2]           = "Exemplo de palavras-chave secundárias:",
        [LID.RN_SECONDARY_KEYWORDS + 3]           = "606, 619, 636",
        [LID.RN_SECONDARY_KEYWORDS + 4]           = "610, pvp, algari",
        [LID.RN_SECONDARY_KEYWORDS + 5]           = "590",
        ["Find Crafter"]                          = "Encontrar Artesão",
        ["No Crafters Found"]                     = "Nenhum artesão encontrado",
        [LID.FOUND_CRAFTER_NAME_ENTRY]            = "%s [%s]",
        [LID.GREET_FOUND_CRAFTER]                 = "|cffffd100Clique esquerdo: Solicitar criação|r",
        ["Crafter Greeting"]                      = "|cFFFFFFFFSaudação do artesão|r",
        [LID.BUSY_ICON]                           =
        "|cFFFFFFFFO artesão indicou que está atualmente ocupado, mas poderá criar o item mais tarde.\n\nVerifique sua saudação para mais detalhes.|r",
        ["Potential Crafters"]                    = "Artesãos Potenciais",
        [LID.FOUND_VIA_CRAFT_SCAN]                =
        "Encontrei você pelo CraftScan e vi sua saudação. Você pode criar %s para mim agora?",
        [LID.COMMISSION_INSTRUCTIONS]             =
        "ex: '10000g', Padrão: 'Qualquer'\nEste texto aparece na tabela 'Encontrar Artesão' do cliente.",
        ["Commission"]                            = "Comissão",
        ["Crafter [Currently Playing]"]           = "Artesão [Atualmente Jogando]",
        ["Profession commission"]                 = "Comissão de profissão",
        [LID.DEFAULT_COMMISSION]                  = "Qualquer",
        [LID.HELP_ITEM_COMMISSION]                =
        "O CraftScan fornece aos clientes um botão 'Encontrar Artesão' em pedidos pessoais. Seu nome, saudação e essa comissão aparecerão na tabela junto com outros artesãos. O comprimento é limitado a 12 caracteres para caber na tabela do cliente.",
        ["Discoverable"]                          = "Descobrível pelos clientes",
        [LID.DISCOVERABLE_SETTING]                =
        "Quando ativado, quando um cliente clicar em 'Encontrar Artesão', seu nome aparecerá na tabela gerada se você puder criar o item.",
        [LID.RN_CUSTOMER_SEARCH]                  = "Encontrar Artesão",
        [LID.RN_CUSTOMER_SEARCH + 1]              =
        "A página para enviar um Pedido Pessoal agora possui um botão 'Encontrar Artesão'. Este botão envia uma solicitação a todos os usuários do CraftScan para ver quem pode criar o item e apresenta os resultados em uma tabela com a comissão configurada do artesão.",
        [LID.RN_CUSTOMER_SEARCH + 2]              =
        "Cada profissão e item agora tem uma caixa de 'Comissão' para configurar o que aparecerá nesta tabela, e o texto é limitado a 12 caracteres para caber na tabela.",
        [LID.RN_CUSTOMER_SEARCH + 3]              =
        "Você entrou no canal 'CraftScan', mas não precisa ativá-lo ou ver nenhuma mensagem no canal. Ele existe para permitir que o CraftScan envie solicitações privadas, como os jogadores normalmente fazem no chat de Comércio.",
        [LID.RN_CUSTOMER_SEARCH + 4]              =
        "Como artesão, você agora pode receber sussurros inesperados de clientes que já sabem o que você pode criar.",
        [LID.RN_CUSTOMER_SEARCH + 5]              =
        "Este recurso é um pouco difícil de testar, pois contas de teste não têm acesso à tabela de criação. Se você encontrar algum problema, pode desativar o recurso até que eu possa corrigi-lo.",
        [LID.RN_CUSTOMER_SEARCH + 6]              =
        "Você pode optar por não ser incluído nesta tabela através da nova configuração 'Descobrível' no menu principal de Configurações da Blizzard.",
        [LID.RN_CUSTOMER_SEARCH + 7]              =
        "Como os clientes podem começar a usar o addon, o recurso de Análise pode ser totalmente desativado e agora está desativado por padrão. Se você já coletou dados, eles permanecerão ativados.",
        ["Permissive keyword matching"]           = "Correspondência permissiva de palavras-chave",
        [LID.PERMISSIVE_MATCH_SETTING]            =
        "Quando marcado, o CraftScan deixará de se preocupar com espaços e outros delimitadores ao verificar correspondências de palavras-chave. Por padrão, o CraftScan só corresponderá a uma palavra-chave se estiver claramente delimitada do texto ao redor, para evitar corresponder incorretamente palavras-chave curtas embutidas em outras palavras. Para idiomas que não usam espaços para delimitar palavras-chave, ative esta opção.",
        ["Show chat orders tab"]                  = "Mostrar aba de pedidos do chat",
        [LID.SHOW_CHAT_ORDER_TAB]                 =
        "Mostra ou oculta a aba 'Pedidos do Chat' na janela de profissão. Se oculta, você pode abrir a página de pedidos do chat clicando no botão CraftScan onde os alertas aparecem.",
        [LID.IGNORE]                              = "Ignorar",
        [LID.IGNORE_TOOLTIP]                      =
        "Adiciona este jogador à sua lista de ignorados do CraftScan. CraftScan ignorará todas as mensagens enviadas por este jogador. Este menu pode ser usado para remover o jogador da lista.",
        [LID.UNIGNORE]                            = "Remover Ignorado",
        [LID.UNIGNORE_TOOLTIP]                    =
        "Este jogador está na sua lista de ignorados do CraftScan. Esta opção o remove da lista.",
        ["Collapse chat context menu"]            = "Recolher menu de contexto do chat",
        [LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP]       =
        "Ao clicar com o botão direito em um nome de jogador no chat, recolhe todas as opções do menu de contexto em um único submenu do CraftScan.",

        [LID.PROXY_ORDERS_TOOLTIP]                =
        "Envia os pedidos detectados por esta conta para contas vinculadas com permissões de 'Controle Total'. A conta receptora mostrará a notificação padrão como se tivesse detectado o pedido.",
        [LID.RECEIVE_PROXY_ORDERS_TOOLTIP]        =
        "Recebe pedidos detectados e enviados por uma conta vinculada com 'Controle Total'. Quando um pedido é recebido da conta vinculada, a notificação padrão aparecerá nesta conta.",
        [LID.LOCAL_ALERTS_TOOLTIP]                =
        "As notificações visuais e sonoras para este artesão e profissão só serão exibidas quando você estiver jogando com este personagem. Isso é apenas um filtro e não ativa ou desativa notificações em geral. As notificações ainda são gerenciadas pelos ícones de missão e fone de ouvido no lado direito da lista de artesãos.",
        ["Local Notifications Only"]              = "Apenas notificações locais",

    }
end
