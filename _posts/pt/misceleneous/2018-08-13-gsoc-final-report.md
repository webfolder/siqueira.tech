---
layout: post
title:  "GSoC Final Report"
date:   2018-08-13
categories: [misceleneous, freedesktop, feed-pt]
published: true
lang: pt
---

Nada dura para sempre, e isso também se aplica a projetos GSoC. Neste relatório,
tentei resumir minha experiência na comunidade DRI e minhas contribuições.

## Recapitulando a ideia do projeto

Primeiramente, é importante lembrar o assunto principal do meu Projeto GSoC:

> O Kernel Mode-Setting (KMS) é um mecanismo que permite a um processo
comandar o kernel para definir um modo (resolução de tela, profundidade de cor e taxa)
que está em uma faixa de valores suportados por placas gráficas e pela tela
de vídeo. A criação de um KMS Virtual (VKMS) tem benefícios. Primeiro, ele pode ser usado para
testes; segundo, pode ser valioso para executar o X ou o Wayland em uma
máquina sem interface gráfica,
permitindo o uso de GPU. Este módulo é semelhante ao VGEM e, em alguns
momentos, ao VIRTIO. Assim que o VKMS estiver maduro o suficiente, ele será usado para
executar casos de teste i-g-t e automatizar os testes em espaço de usuário.

Ouvi falar do VKMS na lista de tarefas do DRM e decidi me candidatar ao GSoC com este
projeto. Uma desenvolvedora muito talentosa da Arábia Saudita, chamada Haneen Mohammed, teve
a mesma ideia, mas se candidatou ao programa Outreachy. Trabalhamos juntos com o
desejo de impulsionar o KMS Virtual ao máximo.

## Superando a curva de aprendizado íngreme

Na minha opinião, o principal motivo para a curva de aprendizado íngreme veio da falta
de experiência prévia sobre o funcionamento da pilha gráfica. Por exemplo, quando eu
tive aulas de sistema operacional, estudei muitas coisas relacionadas a escalonadores,
gerenciamento de memória e disco, e assim por diante; por outro lado, eu tinha uma visão
abrangente dos sistemas gráficos. Depois de longas horas de estudo e codificação, comecei a
entender melhor como as coisas funcionam. É incrível todo o progresso e
avanços que os desenvolvedores do DRI trouxeram nos últimos anos! Gostaria que as
novas versões dos livros sobre sistemas operacionais tivessem um capítulo inteiro
para este assunto.

Ainda tenho dificuldades para entender todos os mecanismos disponíveis no DRM;
no entanto, agora me sinto confiante em como ler o código/documentação e entrar
nos detalhes do subsistema DRM. Tenho planos de compilar todo o
conhecimento adquirido durante o projeto em uma série de posts no blog.

## Contribuições

Durante meu trabalho no GSoC, envio meus patches para a lista de discussão do DRI e
recebo feedback constantemente para aprimorar meu trabalho; como resultado, retrabalho a maioria dos meus
patches. A maneira natural e confiável de acompanhar as contribuições é usando
“git log --author="Rodrigo Siqueira" em um dos repositórios abaixo:

* Para patches de DRM: git://anongit.freedesktop.org/drm-misc
* Para patches já aplicados à branch Torvalds: https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
* Para patches do IGT: git://anongit.freedesktop.org/drm/igt-gpu-tools

Em resumo, seguem os principais patches que obtive aceitação:

* drm/vkms: Corrigir vazamento de conector na remoção do módulo
* drm/vkms: Adicionar auxiliares de framebuffer e plane
* drm/vkms: Adicionar eventos vblank simulados por hrtimers
* drm/vkms: Adicionar auxiliares de conector
* drm/vkms: Adicionar operações simples
* drm/vkms: Adicionar informações extras sobre vkms
* drm/vkms: Adicionar inicialização básica do CRTC
* drm/vkms: Adicionar inicialização do mode_config

Recebemos duas contribuições de pessoas externas; revisei ambos os patches:

* drm/vkms: Usar novo tipo de retorno vm_fault_t
* drm/vkms: Corrigir o tratamento de erros em vkms_init()

Estou usando o IGT para testar o VKMS, por isso decidi enviar algumas
contribuições a eles. Enviei uma série de patches para corrigir o aviso do GCC:

* Corrigir a comparação que sempre resulta em falso
* Evitar truncar string em __igt_lsof_fds
* Remover aliases de parâmetros com outro argumento
* Mover a declaração para o topo do código
* Considerar o caractere NULL ao usar strncpy
* Tornar os comandos de string alocados dinamicamente (aguardando revisão)
* Corrigir a string truncada no snprintf (aguardando revisão)

Também enviei um conjunto de patches com o objetivo de adicionar suporte para forçar o uso de um
módulo específico pelos testes do IGT:

* Adicionar suporte para forçar o carregamento de um módulo específico
* Aumentar o tamanho da string para o nome de um módulo (aguardando revisão)
* Adicionar suporte para forçar o módulo específico (aguardando revisão)

Como contribuição diversa, criei uma série de scripts para automatizar o
fluxo de trabalho de desenvolvimento do Kernel Linux. Este pequeno projeto foi baseado em uma série
de scripts fornecidos pelo meu mentor e espero que seja útil para iniciantes.

Segue o link do projeto:

1. [Kworkflow](https://github.com/rodrigosiqueira/kworkflow)

## Trabalho em Andamento

Estou feliz em dizer que concluí todas as tarefas inicialmente propostas e fiz
muito mais. Agora estou trabalhando para fazer o VKMS funcionar sem o vblank. Este ainda é um trabalho
em andamento, mas estou confiante de que poderei concluí-lo em breve. Finalmente, é
importante destacar que minha participação no GSoC terminará no final de
agosto, pois viajei por duas semanas para participar da debconf2018.

## __Agora, este não é o fim. Não é nem o começo do fim. Mas é, talvez, o fim do começo__ - Winston Churchill

O GSoC me proporcionou algo que eu buscava há muito tempo: um subsistema no
Kernel Linux no qual eu possa me concentrar por anos. Estou feliz por ter encontrado um
lugar para me concentrar e continuarei trabalhando no VKMS até que ele esteja concluído.

Finalmente, o governo brasileiro abriu uma chamada para incentivar o desenvolvimento de software livre
e decidi me inscrever no projeto VKMS. Na semana passada, recebi a
ótima notícia de que fui selecionado na primeira fase e agora estou aguardando
os resultados finais. Se tudo correr bem para mim, receberei financiamento para trabalhar
por 5 meses no subsistema VKMS e DRM.

## Meus imensos agradecimentos a...

Recebi apoio de muitas pessoas no canal dri-devel e na lista de e-mails.
Quero agradecer a todos pelo apoio e paciência.

Quero agradecer a Daniel Vetter por todo o feedback e assistência no trabalho com o VKMS.
Também quero agradecer a Gustavo Padovan por todo o suporte que ele
me deu (incluindo algumas ligações com ótimas explicações sobre o
DRM). Por fim, quero agradecer a Haneen por toda a ajuda e ótimo trabalho.

## Bibliografia

1. [Use new return type vm_fault_t](https://lkml.org/lkml/2018/7/26/549)
2. [Fix the error handling in vkms_init()](https://lkml.org/lkml/2018/8/2/951)
3. [Add support to force specific module load](https://www.spinics.net/lists/intel-gfx/msg170670.html)
