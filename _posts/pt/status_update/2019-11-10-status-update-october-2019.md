---
layout: post
title: "Atualizações e XDC 2019, Outubro 2019"
date: 2019-11-10
categories: [status_update, freedesktop, feed-pt]
published: true
lang: pt
---

{% include add_ref.html id="xdcsite"
    title="First discussion in the Shayenne's patch about the CRC problem"
    url="https://xdc2019.x.org" %}

{% include add_ref.html id="wbV1"
    title="Introduces writeback support"
    url="https://patchwork.freedesktop.org/series/61738/" %}

{% include add_ref.html id="freesync"
    title="FreeSync"
    url="https://en.wikipedia.org/wiki/FreeSync" %}

Já faz um tempo desde meu último post, mas há um motivo simples para isso: no
dia 5 de agosto, tive que me mudar do Brasil para o Canadá. Por que me mudei?
Graças à recomendação de Harry Wentland, consegui uma entrevista para um cargo
de engenharia de software na AMD (Markham) e fui contratado para trabalhar na
equipe de monitores.  De agora em diante, suponho que estarei envolvido com o
subsistema DRM por um longo tempo :).  Embora eu agora seja funcionário da AMD,
este post reflete apenas minhas opiniões pessoais e não deve ser interpretado
como uma representação da AMD de forma alguma.

Tenho algumas atualizações sobre meu trabalho com a comunidade, já que tenho estado ocupado
com minha mudança e adaptação. No entanto, minhas principais atualizações vieram do XDC 2019
{% include cite.html id="xdcsite" %} e quero compartilhá-las aqui.

## XDC 2019 - Montreal (Conferência da Universidade Concordia)

Este ano, tive a grande sorte de participar do XDC novamente. No entanto, nessa
época, eu estava com Harry Wentland, Nicholas Kazlauskas e Leo Li (trabalhamos
juntos na AMD). Nos esforçamos para aprender com as experiências de outras
pessoas e tentamos saber o que os desenvolvedores do compositor queriam ver em
nosso driver. Também aproveitamos a oportunidade para tentar explicar um pouco
mais sobre os recursos do nosso hardware.  Em particular, conversamos sobre
Freesync, MST, DKMS e assim por diante.  Pensando nisso, compartilharei minha
visão dos momentos mais emocionantes que tivemos.

### VKMS

Como de costume, tentei o meu melhor para entender o que as pessoas querem ver
no VKMS em breve ou mais tarde. Por exemplo, no XDC 2018, concentrei-me em
corrigir alguns bugs, mas principalmente em adicionar suporte a writeback, pois
isso poderia fornecer uma saída visual (este trabalho está quase concluído,
veja {% include cite.html id="wbV1" %}). Este ano, coletei feedback de várias
pessoas (agradecimentos especiais a Marten, Lyude, Hiler e Harry) e, a partir
dessas conversas, costumo trabalhar nas seguintes tarefas:

1. Concluir o recurso de write-back e habilitar a saída visual;
2. Adicionar suporte para taxa de atualização adaptável;
3. Adicionar suporte para "conectores dinâmicos", que podem habilitar o teste MST.

Além disso, Martin Peres deu uma palestra na qual compartilhou suas opiniões
sobre o CI e o teste. Em sua apresentação, ele sugeriu o uso do VKMS para
validar a API, e tenho que admitir que estou muito animado com essa ideia.
Espero poder ajudar com isso.

## Freesync

Os drivers `amdgpu` suportam uma tecnologia chamada Freesync {% include cite.html id="freesync" %}.
Em poucas palavras, esse recurso permite a alteração dinâmica da taxa de
atualização, o que pode trazer benefícios para jogos e economia de energia.
Harry Wayland falou sobre esse recurso e você pode vê-lo aqui:

{% include youtube-player.html
id="HYa4UvVtMOE?t=30120"
caption="Vídeo 1: Freesync, Sincronização Adaptativa e VRR" %}

Após a apresentação de Harry, muitas pessoas fizeram perguntas interessantes
relacionadas a esse assunto, essa situação me chamou a atenção e, por esse
motivo, adicionei a VRR ao meu roteiro no VKMS. Roman Gilg, do KDE, foi um dos
desenvolvedores que solicitaram uma extensão de protocolo no Wayland para
suportar Freesync; além disso, os desenvolvedores de compositores solicitaram
mecanismos que lhes permitissem saber com antecedência se a experiência de um
painel específico seria boa ou não.  Por fim, houve algumas discussões sobre o
uso do Freesync para economia de energia e em uma aplicação que requer tempo
limitado.

## IGT e CI

Este ano, mantive minha tradição de fazer milhares de perguntas ao Hiler com o
objetivo de aprender mais sobre IGT e, como sempre, ele foi extremamente gentil
e gentil com minhas perguntas (obrigado, Hiler). Um dos conceitos que o Hiler
me explicou foi o uso do `podman` (https://podman.io/) para preparar a imagem
do IGT.  Por exemplo, após alguns minutos de par de códigos com ele, consegui
executar o IGT na minha máquina após executar os seguintes comandos:

```bash
sudo su
podman run --privileged registry.freedesktop.org/drm/igt-gpu-tools/igt:master
podman run --privileged registry.freedesktop.org/drm/igt-gpu-tools/igt:master \
                        igt_runner -t core_auth
podman run --privileged registry.freedesktop.org/drm/igt-gpu-tools/igt:master \
                        igt_runner -t core_auth /tmp
podman run --privileged -v /tmp/results:/results \
  registry.freedesktop.org/drm/igt-gpu-tools/igt:master igt_runner -t core_auth /results
```

Também tivemos a oportunidade de discutir CI com Martin Peres, e ele explicou
seu trabalho para melhorar a maneira como o CI monitora bugs. Em particular,
ele apresentou uma ferramenta fantástica chamada `cibuglog`, responsável por
monitorar falhas de teste e usar esses dados para construir um banco de dados.
O Cibuglog possui muitos filtros úteis que nos permitem ver problemas de teste
associados a uma máquina específica e bugs no Bugzilla. O grande insight do
cibuglog é a ideia de usar dados para auxiliar no monitoramento de bugs.
Obrigado, Martin, por nos mostrar esta ferramenta incrível.

## Atualizações

Quero apenas terminar este post com breves atualizações do meu trabalho com
software livre começando com `kw` e terminando com VKMS.

## Fluxo de Trabalho do Kernel (`kw`)

Quando comecei a trabalhar com VKMS, escrevi uma ferramenta chamada
`kworkflow`, ou simplesmente `kw`, para me ajudar com tarefas básicas
relacionadas ao desenvolvimento do Kernel. Hoje em dia, o `kw` renasceu para
mim, pois eu estava procurando uma maneira de automatizar meu trabalho com o
`amdgpu`; como resultado, implementei os seguintes recursos:

- Implantação do kernel em uma máquina de destino (qualquer máquina acessível via IP);
- Implantação do módulo;
- Captura do arquivo `.config` de uma máquina de destino;

Infelizmente, o código não está pronto para ser mesclado na branch principal.
Estou trabalhando nisso; acho que em algumas semanas, posso lançar uma nova
versão com esses recursos. Se você quiser saber um pouco mais sobre o `kw`, dê
uma olhada em https://siqueira.tech/doc/kw/

## VKMS

Eu não estava trabalhando no VKMS devido à minha mudança de país; no entanto,
agora estou reformulando parte do teste do IGT relacionado ao write-back e,
assim que terminar o, tentarei fazer o upstream novamente. Espero também
conseguir mesclar o writeback do VKMS com o `drm-misc-next` até o final deste
mês. Por fim, mesclei o suporte principal implementado por Oleg Vasilev (muito
obrigado!).

{% include print_bib.html %}
