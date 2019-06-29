# ![](../../assets/ModernUI_Tooltip48x48.png) ModernUI_Tooltip

The ModernUI_Tooltip is a small popup window that displays text. It can display a single line of text, similar to a standard win32 tooltip control, but can also display a title and additional lines of text below the title. The title text font can be different from the body text font. The back color and text color can be specified via the ModernUI_Tooltip's properties.

The tooltip position can also be customized to appear at the mouse cursor position, or above, below, to the right or to the left of the associated control, and can be offset by an x or y amount as well.

[![](https://img.shields.io/badge/ModernUI-x86-blue.svg?style=flat-square&colorB=6DA4F8&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAQAAAAAYLlVAAAC1UlEQVR42u3WA9AjWRSA0bu2bdu2bdssrm3btm3btm3bmX+Ms7rLTiW9NUmvcsL7XuELu6Ojoz5DWcc5nvKp2kBdPvesi21m1Pgr7OxjrfWtgw0VZZjKM9rjXfNHM+bWWzutGo2YSH/tNm+jgNe1XzdDR322V41Tox5D6K4qY0WRtVRnjyhysercH0VeVJ13o8hXqvNNFOlSna4oUlOd2r8moBPwoQfd6THfoLweauqp6aJ8wInmMmjujWAFtwMeNJup5cXsVnWYDyDtajQjmMp7QOoypxGMbMtyAe+Ztf5/JTaJAkM6mjRXrj0KpE9zdZIyAV8bLX5lBIPlszXAVlGXMwAr5fwskL4wdPzAfGUC5o9kJy+o+dCVloiwJNg2907wimddZrqcB9GtNQF3RXI+kI5yCcgADwF6yvfLNa0JWD7n5dWXAa4lbZwrR7UioKdhc76vdEB+KxzbioAncxpGr9IBM+XKDa0IuCanaWkS8BzguEhqrQg4P6e5mgasbV+7WCySvWlFwIU5zdYooMhytCbghpzGLh9gAodCWjFXXwDSV4aJH5inWcBLkbzTOMBa9rWvk92jH5BWqBvwjSHKBfQ3as4HlvoSFq2b+zcB6bXIj6pZABvnPKzPgPSJlxV/hkUH5v7SUPiv2LN5wKuRjO82wDdON6xFSwW8XvhdcGYkrzUPYJf4lcktZh4jxg8sViqA9SKZxDo2NH0km1ImgE2jDjuBLXK6FPX1N1fUYQnKBnCeGeN3jGdPfUC+P27TyO7GjN8xoUMpHZCecKZ97etE9+hD6vKQOz1jgMa6u90J+VO9V//OaXnzgE5Al+p0iyLfqM63UeRV1Xk/ilylOo9Gkc1U55AoMrz+qjJJ1OMQ1bgq6jOYr1Rh9EgFZtd+q0QjVtFeW0UzFvGJ9uhhrSjDSE7UX6tdaMIoz0R2cbvXfKE2UJevvOEe+5kuOjr+qb4H0/HV/SQ0YjEAAAAASUVORK5CYII=)](https://github.com/mrfearless/ModernUI/releases) [![](https://img.shields.io/badge/Assembler-MASM%206.14.8444-brightgreen.svg?style=flat-square&logo=visual-studio-code&logoColor=white&colorB=C9931E)](http://www.masm32.com/download.htm) [![](https://img.shields.io/badge/RadASM%20-v2.2.2.x%20-red.svg?style=flat-square&colorB=C94C1E&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAgCAYAAAASYli2AAACcklEQVR42tWVXWiPURzHz/FyQZOiVuatuFEoKzfKSCs35EJeCqFcEEa5s2heNrXiApuXFDYveUlKSywlIRfczM0WjZvJlGKTRLb5fHvOU6fT+T/PY3bj1Kff8z8vn+f8znPO+dshihnBYv8L4awRcl2FRTarBy8bQzgEjdbabzl9nxCW2IwOFYTrsBTKEH7PET4lLLYlGpcTrkC5qxqL8HeO8CVhoQ0qRxMOw34Y5TVVIPyYI+whTLVehZ9iWgZAL1mN8G6GbArhA/TZEilqKx2HCbADXkAV0oESwhOEfdChbXOUh1ovxS+wlcH3aNvC82VX3wx7Qyl9NhEugXZEU7ixX8E6Br13nTVDPU927R3QCl0wTX2h2rUNQqUv/ATLkHUGM1hLuBF8pFipZ+zBcIZKpw1O0vjYk24mnIXxEZHGNMIBxgxJ2M2P2PF7DafhGh1/0G8Gzzv1cWASfIZn0EJ7VzpIQqWyUguulFUXiDXwApxhYE9O2ibc2PMJNbAxkp5Oyh3NGvHzQkJPrK/aANtLjNNuOAU3kf/KFTrpGsJtaIdxbu3C0gvn4Dzi3qLCI3Su4/cCnnfDBvcCv/yEW0a7o6gwWI5tJvniMwutYZbQa9elsUqzgun/JKStjKAzvAvmDXuG1M1xqerkTAyG6Cy3FREeM8k2kag6MomvcBGaefG7LOF6k1wK6SUbFl0iOpqt/v+NjYjmEva4NQpPi9K6b5JN/UiXQTg+vbF1nlc4USytPpNcok1Iuk1G0eWgS0Hnd3akXbeIbuqWvP9lXxhOW2k9cOvzMJZWUWG/Sf4/lNbbv5GEwjeSSIaof7iitPwBoSgbVud1Jo0AAAAASUVORK5CYII=)](http://www.softpedia.com/get/Programming/File-Editors/RadASM.shtml) ![](https://img.shields.io/badge/Win32%20API-Custom%20Control-blue.svg?style=flat-square&logo=windows&logoColor=white) 

For the x64 version of the ModernUI_Tooltip control, visit [here](https://github.com/mrfearless/ModernUI64/tree/master/Controls/ModernUI_Tooltip).


## Setup ModernUI_Tooltip

* Download the latest version of the ModernUI_Tooltip and extract the files. The latest release can be found via the [releases](https://github.com/mrfearless/ModernUI/releases) section of this Github repository or from the downloads section below.
* Copy the `ModernUI_Tooltip.inc` file to your `masm32\include` folder (or wherever your includes are located)
* Copy the `ModernUI_Tooltip.lib` file to your `masm32\lib` folder (or wherever your libraries are located)
* Add the main ModernUI library to your project (if you haven't done so already):
```assembly
include ModernUI.inc
includelib ModernUI.lib
```
* Add the ModernUI_Tooltip control to your project:
```assembly
include ModernUI_Tooltip.inc
includelib ModernUI_Tooltip.lib
```


## ModernUI_Tooltip API Help

Documentation is available for the ModernUI_Tooltip functions, styles and properties used by the control on the wiki: [ModernUI_Tooltip Control](https://github.com/mrfearless/ModernUI/wiki/ModernUI_Tooltip-Control)

## ModernUI_Tooltip Downloads
- Release: [ModernUI_Tooltip.zip](https://github.com/mrfearless/ModernUI/blob/master/Release/ModernUI_Tooltip.zip?raw=true)
- Source: [ModernUI_Tooltip_Source.zip](https://github.com/mrfearless/ModernUI/blob/master/Release/ModernUI_Tooltip_Source.zip?raw=true)