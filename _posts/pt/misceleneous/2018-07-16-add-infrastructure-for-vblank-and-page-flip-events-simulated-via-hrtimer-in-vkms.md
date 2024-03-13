---
layout: post
title:  "Adicionar infraestrutura para eventos Vblank e page flip em vkms simulados pelo hrtimer"
date:   2018-07-16
categories: [pt-misceleneous, pt-freedesktop]
published: true
lang: pt
---

Desde o início de maio de 2018, tenho me aprofundado no subsistema DRM.  No
começo, nada fazia sentido para mim e tive que me esforçar muito para entender
como as coisas funcionam. Felizmente, não estava sozinho e tive grande apoio de
Gustavo Padovan, Daniel Vetter, Haneen Mohammed e de toda a comunidade.
Recentemente, finalmente entreguei um novo recurso para o VKMS: a
infraestrutura para eventos Vblank e de virada de página.

Neste momento, o VKMS possui eventos Vblank regulares simulados por meio de
hrtimers (consulte drm-misc-next), um recurso necessário para que o VKMS imite
o hardware real [6].  A abordagem de desenvolvimento foi inteiramente orientada
pelos testes fornecidos pela IGT, mais especificamente o kms_flip. Modifiquei o
IGT para ler o nome de um módulo via linha de comando e forçar o uso dele, em
vez de usar apenas os módulos definidos no código (patch enviado à IGT,
consulte [1]). Com essa modificação no IGT, meu processo de desenvolvimento
para adicionar uma infraestrutura Vblank ao VKMS teve três etapas principais,
conforme descrito na Figura 1.

{% include image-post.html
  src="posts/tdd-drm.png"
  caption="My work cycle in VKMS" %}

Primeiramente, concentrei-me apenas no subteste "basic-plain-flip" do IGT e,
após cada execução do teste, verifiquei as mensagens de falha. Em segundo
lugar, tentei escrever o código necessário para que o teste fosse aprovado; é
essencial destacar que essa fase às vezes me levou dias para entender o
problema e implementar a correção. Finalmente, após superar a falha, me
esforcei ainda mais para aprimorar a implementação. Como pode ser visto no
conjunto de patches enviado para adicionar o suporte a Vblank [2], o primeiro
conjunto de patches não estava diretamente relacionado ao Vblank em si, mas era
uma infraestrutura necessária para que o kms_flip funcionasse.

{% include image-post.html
  src="posts/basic-plain-flip_passing.png"
  caption="sudo ./tests/kms_flip  --run-subtest basic-plain-flip --force-module vkms" %}

Após um longo período de trabalho para fazer o VKMS passar no teste básico-plano-de-virar, eu
finalmente consegui, graças a todo o suporte que recebi da comunidade DRM.  Em
seguida, comecei a trabalhar no subteste "wf_vblank-ts-check", e aqui passei
muito tempo depurando problemas. Meu problema aqui era devido ao comportamento
estocástico do teste, às vezes passava e outras vezes falhava, e eu presumi que
o problema estava relacionado ao acúmulo de erros durante a etapa de virada de
página. Como resultado, me esforcei consideravelmente para tornar o
temporizador na virada de página preciso, e acabei com um patch que calcula o
momento exato para o próximo período (veja [5]). No entanto, depois que enviei
o patch, Chris Wilson destacou que eu estava reinventando a roda, já que o
hrtimer já fazia os cálculos necessários [4]; Ele estava 100% certo. Após seu
comentário, examinei linha por linha o hrtimer_forward e concluí que havia
implementado o mesmo algoritmo. Perdi alguns dias recriando algo que, no final,
não é útil; no entanto, foi realmente valioso para mim, pois aprendi como o
hrtimer funciona e também expandi minha compreensão sobre o Vblank. Finalmente,
Daniel Vetter apontou precisamente uma série de problemas no patch (veja [3])
que não apenas melhoraram os testes, mas também fizeram com que a maioria dos
testes no kms_flip passassem.

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

## Referência

1. [Force option in IGT](https://www.spinics.net/lists/intel-gfx/msg170670.html)
2. [Adding infrastructure for Vblank and page flip events in vkms](https://www.spinics.net/lists/dri-devel/msg182903.html)
3. [Daniel Vetter comments in V2](https://www.spinics.net/lists/dri-devel/msg182042.html)
4. [Chris Wilson comments about hrtimer](https://www.spinics.net/lists/dri-devel/msg182043.html)
5. [Calculating the period](https://www.spinics.net/lists/dri-devel/msg182037.html)
6. [DRM misc-next](https://cgit.freedesktop.org/drm/drm-misc/)
