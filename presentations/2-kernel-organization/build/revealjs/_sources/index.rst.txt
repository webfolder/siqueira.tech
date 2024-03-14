.. raw:: html

  <!-- Slide -->
  <section>
    <img width="800" height="520" src="_static/siqueira.png" style="background:none; border:none; box-shadow:none;">
    <br>
    <img width="120" height="41" src="_static/by.png" style="background:none; border:none; box-shadow:none;">
  </section>

======================================
Sistemas Operacionais e o Kernel Linux
======================================

2023-05-22

Sobre
=====

* Engenheiro de Desenvolvimento de Software Sênior na AMD
* Engenheiro de Software e Mestre em Ciência da Computação

Discutindo Sistemas Operacionais
================================

O Sistema Operacional é como um biscoito recheado
-------------------------------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/biscoito-como-so.png
       :width: 30%


O Sistema Operacional é como um biscoito recheado
-------------------------------------------------

* Esconde a complexidade do hardware
* Unifica a comunicação entre aplicação e hardware
* Separação entre User e Kernel space
* Remove a necessidade da aplicação saber como otimizar para determinado dispositivo
* Fornece abstrações para o espaço do usuário

Exemplos de Sistemas Operacionais e suas Características
========================================================

Windows
-------

.. container:: flex

  .. container:: half

    .. figure:: _static/Windows.png
       :width: 40%

MacOS
-----

.. container:: flex

  .. container:: half

    .. figure:: _static/macOS.png
       :width: 40%

BSD
---

.. container:: flex

  .. container:: half

    .. figure:: _static/BSD.png
       :width: 40%

Distros Linux
-------------

.. container:: flex

  .. container:: half

    .. figure:: _static/tabela-periodica-distros.jpeg
       :width: 100%

O Ecossistema Linux
-------------------

Vantagens
---------

* GPL v2 (BSD vs. GPL)
* Suporte para mais de 20 arquiteturas diferentes (e.g., x86, ARM, Risc-V, etc.)
* Amplamente testado (Diferentes ferramentas de CI)
* Comunidade entusiasmada

Desvantagens
------------

* Fragmentado
* Carece de soluções verticalmente integradas

Exemplos de produtos: Servidores
--------------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/server.jpg
       :width: 70%

Exemplos de produtos: Steam Deck
--------------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/steamdeck.webp
       :width: 60%

Exemplos de produtos: Android
-----------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/android.png
       :width: 40%

Exemplos de produtos: Filmes
----------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/film.jpg
       :width: 40%

Exemplos de produtos: Sistemas embarcados
-----------------------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/helicopter.png
       :width: 80%

Linux: Visão Geral
==================

O Linux é como um grande quebra-cabeça
--------------------------------------

.. revealjs-section::
    :data-background-image: _static/linux-puzzle.jpg
    :data-background-size: contain

O Linux tem diversos subsistemas
--------------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/all-subsystems.png
       :width: 80%

O Linux tem diversos contribuidores
-----------------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/contributions.png
       :width: 80%

Do subsistema para a distro
===========================

Do repositório para o kernel estável
------------------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/from_repo_to_stable.png
       :width: 40%

Do repositório para o kernel estável
------------------------------------

* amdgpu
* drm
* Torvalds
* Stable

Stable release Vs. Rolling release
----------------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/Debian-vs-Arch.jpg
       :width: 40%

Como contribuir
===============

Ler a documentação
------------------

Independente do que seja dito nessa apresentação, sempre leia a documentação!

* https://www.kernel.org/doc/html/latest/process/submitting-patches.html

Passos básicos: escolha o que fazer
-----------------------------------

* Comece com algo simples. Sugestão: Procure por TODOs.
  - https://docs.kernel.org/next/gpu/amdgpu/display/display-contributing.html
* Se inscreva na lista de email do projeto.
  - https://flusp.ime.usp.br/others/Mailing-list-subscription/
* Certifique-se de que o seu patch segue as boas práticas.
  - `kw codestyle`

Passos básicos: envie a sua contribuição
----------------------------------------

* Identifique quem deve receber os seu patch.
  - kw maintainers
* Tenha paciência, as revisões podem demorar.
* Se você não ouvir nenhum feedback em 3 semanas, tente mandar uma versão nova
  do patch.

Ganhando moral na quebrada: o que não está escrito
==================================================

Respeito é pra quem tem
-----------------------

* Evite atitudes rudes.
* Tente atender a todos os comentários dos revisores.
* Evite entrar em discussões inúteis e off-topic.

Respeito é pra quem tem
-----------------------

* Sempre mantenha as pessoas que comentaram no seu patch com Cc/To nas novas versões do seu patch.
* Sempre mantenha as pessoas que comentaram no seu patch com Cc/To nas novas versões do seu patch.
* A César o que é de César... É sempre bom dar créditos! Co-developed-by, Suggested-by, etc

Firmão, deixa eu ir, quem não é visto, não é lembrado
-----------------------------------------------------

* Mantenha um fluxo constante de contribuições.
* Sempre que possível, faça revisões.
* Crie seu site e escreva. Considere escrever tutoriais para o FLUSP.
* Tente fazer o seu site virar parte de algum planet.
* Aplique para o GSoC e Outreachy.
* Apresente o seu trabalho.

Obrigado
========

