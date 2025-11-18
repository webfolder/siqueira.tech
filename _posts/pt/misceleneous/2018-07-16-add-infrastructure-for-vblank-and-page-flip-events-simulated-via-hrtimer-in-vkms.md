---
layout: post
title:  "Adicionar infraestrutura para Vblank e page flip no vkms com hrtimer"
date:   2018-07-16
categories: [misceleneous, freedesktop, feed-pt]
published: true
lang: pt
permalink: /pt/2018-07-16-add-infrastructure-for-vblank-and-page-flip-events-simulated-via-hrtimer-in-vkms/
---

{% include add_ref.html id="drmmisc"
    title="DRM misc-next"
    url="https://cgit.freedesktop.org/drm/drm-misc/" %}

{% include add_ref.html id="igtforce"
    title="Opção de forçar no IGT"
    url="https://www.spinics.net/lists/intel-gfx/msg170670.html" %}

{% include add_ref.html id="vkmsvblank"
    title="Adding infrastructure for Vblank and page flip events in vkms"
    title="Adicionando infraestrutura para eventos de Vblank e Page Flip no VKMS"
    url="https://www.spinics.net/lists/dri-devel/msg182903.html" %}

{% include add_ref.html id="calcperiod"
    title="Cálculo do período"
    url="https://www.spinics.net/lists/dri-devel/msg182037.html" %}

{% include add_ref.html id="hrtimerchris"
    title="Comentário do Chris Wilson sobre hrtimer"
    url="https://www.spinics.net/lists/dri-devel/msg182037.html" %}

{% include add_ref.html id="vetter"
    title="Comentário do Daniel Vetter na V2"
    url="https://www.spinics.net/lists/dri-devel/msg182037.html" %}

Desde o início de maio de 2018, tenho me aprofundado no subsistema do DRM. No
começo, nada fazia sentido para mim e tive que me esforçar muito para entender
como as coisas funcionam. Felizmente, não estava sozinho e tive grande apoio de
Gustavo Padovan, Daniel Vetter, Haneen Mohammed e de toda a comunidade.
Como resultado, finalmente entreguei um novo recurso para o VKMS: a
infraestrutura para eventos de Vblank e de Page Flip.

O VKMS possui eventos Vblank regulares simulados por meio de hrtimers (consulte
drm-misc-next), recurso esse necessário para que o VKMS imite o hardware real
{% include cite.html id="drmmisc" %}. A abordagem de desenvolvimento foi
inteiramente orientada pelos testes fornecidos pela IGT, mais especificamente o
`kms_flip`. Modifiquei o IGT para fazer com que a ferramenta leia o nome de um
módulo via linha de comando e forçar o uso dele, em vez de usar apenas os
módulos definidos no código (patch enviado para o IGT {% include cite.html id="igtforce" %}).
Com essa modificação no IGT, meu processo de desenvolvimento para adicionar uma
infraestrutura Vblank ao VKMS teve três etapas principais, conforme descrito na
figura abaixo:

{% include image-post.html
  src="posts/tdd-drm.png"
  caption="My work cycle in VKMS" %}

Primeiramente, concentrei-me apenas no subteste "basic-plain-flip" do IGT e,
após cada execução do teste, verifiquei as mensagens de falha. Em segundo
lugar, tentei escrever o código necessário para que o teste passasse; é
essencial destacar que essa fase, por vezes, levou dias devido ao processo de
entender o problema e implementar a correção. Finalmente, após superar a falha
de cada teste, me esforcei ainda mais para aprimorar a implementação. Como pode
ser visto no conjunto de patches enviado para adicionar o suporte a Vblank
{% include cite.html id="vkmsvblank" %}, o primeiro conjunto de patches não
estava diretamente relacionado ao Vblank em si, mas era uma infraestrutura
necessária para que o `kms_flip` funcionasse.

{% include image-post.html
  src="posts/basic-plain-flip_passing.png"
  caption="sudo ./tests/kms_flip  --run-subtest basic-plain-flip --force-module vkms" %}

Após um longo período de trabalho para fazer o VKMS passar no teste
`basic-plain-flip`, eu finalmente obtive sucesso, tudo isso graças a todo o
suporte que recebi da comunidade DRM.  Em seguida, comecei a trabalhar no
subteste `wf_vblank-ts-check`, e aqui passei muito tempo depurando problemas.
Meu problema aqui era devido ao comportamento estocástico do teste, às vezes
passava e outras vezes falhava, e eu presumi que o problema estava relacionado
ao acúmulo de erros durante a etapa de virada de página. Como resultado, me
concentrei um bom tempo para tornar o tempo na virada o mais preciso possível,
e acabei com um patch que calcula o momento exato para o próximo período
{% include cite.html id="calcperiod" %}. No entanto, depois que enviei o patch,
Chris Wilson destacou que eu estava reinventando a roda, já que o hrtimer já
fazia os cálculos necessários {% include cite.html id="hrtimerchris" %}; Ele
estava 100% certo. Após seu comentário, examinei linha por linha o
`hrtimer_forward` e concluí que havia implementado o mesmo algoritmo. Perdi
alguns dias recriando algo que, no final, não é útil; no entanto, foi realmente
valioso para mim, pois aprendi como o hrtimer funciona e também expandi minha
compreensão sobre o Vblank. Finalmente, Daniel Vetter apontou precisamente uma
série de problemas no patch {% include cite.html id="vetter" %} que não apenas
melhoraram os testes, mas também fizeram com que a maioria dos testes no
`kms_flip` passassem.

Concluindo, adicionar a infraestrutura para o Vblank e eventos de virada de
página no vkms foi um recurso interessante para o VKMS, mas também foi uma
tarefa importante para me ensinar como as coisas funcionam no DRM. Ainda estou
focado nesta parte do VKMS, mas agora estou começando a pensar em como posso
adicionar hardware virtual que não suporta interrupção do Vblank. Por fim,
quero escrever um post detalhado sobre como implementei o suporte a Vblank no
VKMS e outro sobre temporizadores (usuários e espaço do kernel); acredito que
esse tipo de post pode ser útil para alguém que está começando no subsistema
DRM.

Agradeço a toda a comunidade DRM que é sempre gentil e fornece grande ajuda
para um novato como eu :)

{% include print_bib.html %}
