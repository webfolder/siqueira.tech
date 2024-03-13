---
layout: post
title:  "Status Update, Junho 2019"
date:   2019-07-09
categories: [pt-status_update, pt-freedesktop]
published: true
lang: pt
---

{% include add_ref.html id="crcproblemFirst"
    title="First discussion in the Shayenne's patch about the CRC problem"
    url="https://lkml.org/lkml/2019/3/10/197" %}

{% include add_ref.html id="crcproblemSecond"
    title="Patch fix for the CRC issue"
    url="https://patchwork.freedesktop.org/patch/308617/" %}

{% include add_ref.html id="danielFixCRC"
    title="Daniel final fix for CRC"
    url="https://patchwork.freedesktop.org/patch/308881/?series=61703&rev=1" %}

{% include add_ref.html id="danielReworkCRC"
    title="Rework crc worker"
    url="https://patchwork.freedesktop.org/series/61737/" %}

{% include add_ref.html id="wbV1"
    title="Introduces writeback support"
    url="https://patchwork.freedesktop.org/series/61738/" %}

{% include add_ref.html id="configfs"
    title="Introduce basic support for configfs"
    url="https://patchwork.freedesktop.org/series/63010/" %}

{% include add_ref.html id="novblank"
    title="Change EINVAL by EOPNOTSUPP when vblank is not supported"
    url="https://patchwork.freedesktop.org/patch/314399/?series=50697&rev=7" %}

{% include add_ref.html id="novblankIGT"
    title="Skip VBlank tests in modules without VBlank"
    url="https://gitlab.freedesktop.org/drm/igt-gpu-tools/commit/2d244aed69165753f3adbbd6468db073dc1acf9a" %}

{% include add_ref.html id="igtWb"
    title="Add support for testing writeback connectors"
    url="https://patchwork.freedesktop.org/series/39229/" %}

Há muito tempo, venho cultivando o desejo de ter o hábito de escrever
atualizações mensais de status. De alguma forma, [as postagens do blog de Drew
DeVault](https://drewdevault.com/) e os conselhos de [Martin
Peres](http://mupuf.org/blog/authors/mupuf/) me impulsionam nessa direção.
Então, aqui estou! Decidi abraçar o desafio de redigir um relatório por mês.
Espero que esse novo hábito me ajude a aprimorar minhas habilidades de escrita
e comunicação, mas, acima de tudo, me ajude a acompanhar meu trabalho. Quero
começar esta atualização descrevendo minhas condições de trabalho e, em
seguida, me concentrar nas questões técnicas.

Nos últimos dois meses, tenho enfrentado um problema de infraestrutura para
trabalhar. Estou lidando com obstáculos como acesso restrito à internet e
longas horas no transporte público de casa para o trabalho. Infelizmente, não
posso trabalhar em casa devido à falta de espaço, e o melhor lugar para
trabalhar é uma biblioteca pública da Universidade de Brasília (UnB). Ir à UnB
todos os dias me faz perder cerca de 3 horas por dia em um ônibus. A biblioteca
tem um ótimo ambiente, mas também tem milhares de restrições de internet. O
fato de eu não conseguir acessar sites com domínio '.me' e me conectar ao meu
IRC bouncer é um exemplo disso.  Resumindo: Tem sido difícil trabalhar
ultimamente. Então, vamos parar de falar de coisas não técnicas e ir direto ao
ponto.

Eu realmente gosto de trabalhar no VKMS. Sei que isso não é novidade para
ninguém e, em junho, a maior parte dos meus esforços foi dedicada ao VKMS. Um
dos meus principais esforços foi encontrar e corrigir um bug no VKMS que fazia
com que kms_cursor_crc e kms_pipe_crc_basic falhassem. Eu estava perseguindo
esse bug há muito tempo, como pode ser visto aqui {% include cite.html
id="crcproblemFirst" %}. Depois de muitas horas depurando, enviei um patch para
lidar com esse problema {% include cite.html id="crcproblemSecond" %}.  No
entanto, após a análise do Daniel, percebi que meu patch não corrigiu
corretamente o problema. Então, Daniel decidiu investigar o problema para
encontrar a raiz do problema e, posteriormente, enviou uma correção final. Se
você quiser ver a solução, dê uma olhada em {% include cite.html id="danielFixCRC" %}.
Um dia, quero escrever um post sobre essa correção, pois é um assunto
interessante para discutir.

Daniel também notou alguns problemas de simultaneidade no código CRC e enviou
um conjunto de patches composto por 10 patches que abordam o problema. Esses
patches se concentraram em criar uma melhor manipulação de framebuffers e
evitar condições de corrida. Levei cerca de 4 dias para dar uma olhada e testar
esta série. Durante minha análise, perguntei muitas coisas relacionadas à
simultaneidade e outros esclarecimentos sobre DRM.  Daniel sempre respondia com
uma explicação muito boa e detalhada. Se você quiser aprender um pouco mais
sobre bloqueios, recomendo que dê uma olhada em {% include cite.html id="danielReworkCRC" %}.
Sério, é muito bom!

Também trabalhei para adicionar o suporte a writeback no VKMS; desde o XDC2018,
não conseguia parar para pensar na ideia de adicionar um conector de writeback
no VKMS devido aos benefícios que isso poderia trazer, como novos testes e
auxílio aos desenvolvedores com saída visual. Como resultado, comecei algumas
tentativas desajeitadas de implementá-lo em janeiro; mas mergulhei de cabeça
nessa questão em meados de abril e, em junho, estava focado em fazê-lo
funcionar. Foi difícil para mim implementar esses recursos pelos seguintes
motivos:

1. Não há teste i-g-t para write-back no repositório principal; tive que usar
   um patchset WIP criado por Brian e Liviu.
2. Eu não estava familiarizado com framebuffer, conectores e manipulações
   sofisticadas.

Como resultado das limitações acima, tive que investir muitas horas lendo a
documentação e o código DRM/IGT. No final, acho que adicionar conectores
write-back me rendeu bem, pois me sinto muito mais confortável com muitas
coisas relacionadas a DRM atualmente. O suporte a write-back ainda não foi
implementado, no entanto, neste momento, o patch está em revisão (V3) e mudou
bastante desde a primeira versão; para detalhes sobre esta série, consulte
{%include cite.html id="wbV1" %}. Escreverei um post sobre esse recurso após a
integração.

Depois de ter os conectores write-back funcionando no VKMS, fiquei muito grato
a Brian, Liviu e Daniel por toda a assistência que me deram. Em particular,
fiquei entusiasmado com o fato de Brian e Liviu terem criado o teste
`kms_writeback`, que funcionou como um guia de implementação para mim. Como
resultado, atualizei seus patchsets para que funcionasse na versão mais recente
do IGT e fiz algumas pequenas correções. Meu objetivo era ajudá-los a
implementar o `kms_writeback`. Enviei a série com a esperança de vê-la
disponível no IGT {% include cite.html id="igtWb" %}.

Paralelamente ao meu trabalho com 'writeback', eu estava tentando descobrir
como poderia expor as configurações do VKMS ao espaço do usuário via configfs.
Depois de muito esforço, enviei a primeira versão do suporte ao configfs; neste
patchset, expus os conectores virtuais e de writeback. Dê uma olhada em {%
include cite.html id="configfs" %} para obter mais informações sobre esse
recurso e, com certeza, escreverei um post sobre ele assim que for
disponibilizado.

Por fim, ainda estou tentando criar um patch que faça com que
`drm_wait_vblank_ioctl` retorne `EOPNOTSUPP` em vez de `EINVAL` caso o driver
não suporte vblank seja implementado. Como essa alteração está no núcleo do DRM
e também altera o espaço do usuário, não é fácil implementar esse patch. Para
detalhes sobre este patch, você pode conferir aqui
{% include cite.html id="novblank" %}. Também implementei algumas alterações no
`kms_flip` para validar as alterações que fiz na função `drm_wait_vblank_ioctl`
e ele foi implementado {% include cite.html id="novblankIGT" %}.

## Objetivos de Julho

Em junho, eu estava totalmente dedicado ao VKMS. Agora, quero desacelerar um
pouco e estudar mais sobre o espaço do usuário. Quero dar um passo para trás e
criar alguns programas minúsculos usando libdrm com o objetivo de entender a
interação entre o espaço do usuário e o espaço do kernel. Também quero dar uma
olhada na parte teórica relacionada à computação gráfica.

Quero me esforçar para aprimorar uma ferramenta chamada
[kw](https://github.com/rodrigosiqueira/kworkflow) que me ajude durante meu
trabalho com o Kernel Linux. Também quero dar uma olhada no suporte a planos de
sobreposição reais no VKMS. Percebi que preciso encontrar um "protocolo de
contribuição" (revisar/escrever código) que funcione para mim nas minhas atuais
condições de trabalho; caso contrário, o trabalho se tornará penoso para mim e
meus parentes. Por fim, e mais importante, quero tirar alguns dias de folga
para aproveitar minha família.

**Informações:**
Se você encontrar algum problema com este texto, por favor, me avise. Terei
prazer em consertá-lo.
{: .info}

{% include print_bib.html %}
