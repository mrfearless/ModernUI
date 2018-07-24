
# ![](ModernUI.png) 
# ModernUI
ModernUI is a framework library and a collection of custom controls for win32 assembler, created to help modernize the  standard win32 controls, and to add or emulate new control types and features of modern UX/UI designs and other graphical frameworks.

For the x64 version of this project, visit [here](https://github.com/mrfearless/ModernUI64).

If you like this project and would like to support me, consider buying me a coffee: [buymeacoffee.com/mrfearless](https://www.buymeacoffee.com/mrfearless)

## Setup ModernUI Library

* Download the latest version of the main ModernUI library and extract the files. The latest release can be found in the [Release](https://github.com/mrfearless/ModernUI/tree/master/Release) folder, or via the [releases](https://github.com/mrfearless/ModernUI/releases) section of this Github repository or can be downloaded directly from [here](https://github.com/mrfearless/ModernUI/blob/master/Release/ModernUI.zip?raw=true).
* Copy the `ModernUI.inc` file to your `masm32\include` folder (or wherever your includes are located)
* Copy the `ModernUI.lib` file to your `masm32\lib` folder (or wherever your libraries are located)
* Add the following to your project:
```assembly
include ModernUI.inc
includelib ModernUI.lib
```

## Setup ModernUI Controls

* All ModernUI controls require the inclusion of the ModernUI Library as outlined in the previous section.
* Download any ModernUI Controls you wish to use. Each ModernUI control is packaged separately, and can be found in the [Release](https://github.com/mrfearless/ModernUI/tree/master/Release) folder, or via the [releases](https://github.com/mrfearless/ModernUI/releases) section of this Github repository.
* Copy the ModernUI Control's include file (`.inc`) to your `masm32\include` folder (or wherever your includes are located)
* Copy the ModernUI Control's library file (`.lib`)  to your `masm32\lib` folder (or wherever your libraries are located)
* Add the following to your project, for example if you are adding the ModernUI_Button control:
```assembly
include ModernUI_Button.inc
includelib ModernUI_Button.lib
```
* Repeat for all other ModernUI Controls that you wish to add to your project.

## General Information

* The main ModernUI Library is stored in the [ModernUI](https://github.com/mrfearless/ModernUI/tree/master/ModernUI) folder. It comes with a RadASM project to help with building the library from the source files. Manual build instructions can be found in the [wiki](https://github.com/mrfearless/ModernUI/wiki).
* ModernUI controls are separated in their own folders found in the [Controls](https://github.com/mrfearless/ModernUI/tree/master/Controls) folder. Each control comes with a RadASM project to help with building the control from the source files.
* There are a number of examples included in this Github repository that highlight the usage of using the various ModernUI Controls, these can be found in the [Examples](https://github.com/mrfearless/ModernUI/tree/master/Examples) folder. Each example has a RadASM project to help build the example.
* The ModernUI Library and the ModernUI Controls can be found pre-packaged in the [Release](https://github.com/mrfearless/ModernUI/tree/master/Release) folder. Also included in this folder are RadASM auto-complete api files, some design time ModernUI RadASM controls, and some useful ModernUI style icons.
* Some documentation is available for some of the ModernUI functions and properties used in the ModernUI Library or ModernUI Controls. See the [wiki](https://github.com/mrfearless/ModernUI/wiki) for more details.

## Additional Resources

* [RadASM IDE](http://www.softpedia.com/get/Programming/File-Editors/RadASM.shtml)
* [Masm32](http://www.masm32.com/masmdl.htm)
* [UASM](http://www.terraspace.co.uk/uasm.html)