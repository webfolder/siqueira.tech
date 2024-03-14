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

.. container:: flex

  .. container:: half

    .. figure:: _static/me.png
       :width: 25%

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
* Remove a necessidade de saber otimizar para determinado dispositivo
* Separação entre User e Kernel space
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

Exemplos de produtos: Marte
---------------------------

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

A Organização de Graphics
=========================

Visão geral partindo do subsistema de gráficos
----------------------------------------------

.. container:: flex

  .. container:: half

    .. figure:: _static/Linux_AMD_graphics_stack.png
       :width: 100%

Separação entre Mecânismo e Política
------------------------------------

O mecanismo não deve se misturar com as políticas nas quais decisões são
tomadas.

Exemplos: Syscall
-----------------

.. container:: flex

  .. container:: half

    .. figure:: _static/syscalls.png
       :width: 40%

Exemplos: IOCTL
---------------

.. container:: flex

  .. container:: half

    .. figure:: _static/IOCTL-drm.png
       :width: 100%

Schedulers
----------

.. container:: flex

  .. container:: half

    .. figure:: _static/drm-overview.png
       :width: 100%

Paralelismo
-----------

.. container:: flex

  .. container:: half

    .. figure:: _static/true-paralelismo.png
       :width: 100%


Obrigado
========

