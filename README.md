# explorerBTC

[![GitHub top language](https://img.shields.io/github/languages/top/m4lal0/explorerBTC?logo=gnu-bash&style=flat-square)](#)
[![GitHub repo size](https://img.shields.io/github/repo-size/m4lal0/explorerBTC?logo=webpack&style=flat-square)](#)
[![Debian Supported](https://img.shields.io/badge/Debian-Supported-blue?style=flat-square&logo=debian)](#)
[![Kali Supported](https://img.shields.io/badge/Kali-Supported-blue?style=flat-square&logo=linux)](#)
[![Parrot Supported](https://img.shields.io/badge/Parrot-Supported-blue?style=flat-square&logo=linux)](#)
[![By](https://img.shields.io/badge/By-m4lal0-green?style=flat-square&logo=github)](#)

<p align="center" style="color:#4169e1">
┏━━━┓━━━━━━━━┏┓━━━━━━━━━━━━━━━┏━━┓━┏━━━━┓┏━━━┓
┃┏━━┛━━━━━━━━┃┃━━━━━━━━━━━━━━━┃┏┓┃━┃┏┓┏┓┃┃┏━┓┃
┃┗━━┓┏┓┏┓┏━━┓┃┃━┏━━┓┏━┓┏━━┓┏━┓┃┗┛┗┓┗┛┃┃┗┛┃┃━┗┛
┃┏━━┛┗╋╋┛┃┏┓┃┃┃━┃┏┓┃┃┏┛┃┏┓┃┃┏┛┃┏━┓┃━━┃┃━━┃┃━┏┓
┃┗━━┓┏╋╋┓┃┗┛┃┃┗┓┃┗┛┃┃┃━┃┃━┫┃┃━┃┗━┛┃━┏┛┗┓━┃┗━┛┃
┗━━━┛┗┛┗┛┃┏━┛┗━┛┗━━┛┗┛━┗━━┛┗┛━┗━━━┛━┗━━┛━┗━━━┛
━━━━━━━━━┃┃━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━┗┛━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
</p>

<p align="center" style="color:#4169e1">
¿Quieres saber cuánto dinero en Bitcoin se mueve por el mundo?
</p>
La herramienta explorerBTC hecha en Bash es ideal para explorar las transacciones en el servicio de Bitcoin, conocido como Blockchain (**blockchain.com**).

## ¿Cómo funciona la herramienta?
Para ejecutar la herramienta colocamos lo siguiente:
```bash
chmod +x explorerBTC.sh
./explorerBTC.sh
```
Tras ejecutar la herramienta, veremos el menú de ayuda:

<p align="center">
<img src="Images/helpPanel.png"
	alt="Help"
	style="float: left; margin-right: 10px;" />
</p>

La herramienta cuenta con 3 modos de exploración:

* unconfirmed_transactions
* inspect
* address

El modo de exploración **unconfirmed_transactions**, nos permite listar las transacciones que se están realizando en tiempo real, pudiendo indicar a través del parámetro '**-n**' el número de transacciones totales a representar, ya que por default nos arrojará 100 resultados:

<p align="center">
<img src="Images/Option1.png"
	alt="Exploration1"
	style="float: left; margin-right: 10px;" />
</p>

El modo de exploración **inspect** y haciendo necesario el uso del parámetro '**-i**', nos permite inspeccionar una transacción, colocando el identificador de la transacción:

<p align="center">
<img src="Images/Option2.png"
	alt="Exploration2"
	style="float: left; margin-right: 10px;" />
</p>

En caso de querer investigar las direcciones involucradas (tanto de entrada y de salida) en la transacción, a través del modo de exploración **address** y haciendo uso del parámetro '**-a**' para especificar la dirección, podremos listar la información más relevante de la dirección especificada:

<p align="center">
<img src="Images/Option3.png"
	alt="Exploration3"
	style="float: left; margin-right: 10px;" />
</p>