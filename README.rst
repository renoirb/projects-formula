========
projects
========

Formula for managing module release lifecycle from cloning, pulling dependencies to packaging

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``projects``
----------

Maintains internal `projects` grains
Clones to configured directory projects

Example Pillar:

.. code:: yaml

    projects:
      projects:
        renoirb:
          origin: https://github.com/renoirb/site

