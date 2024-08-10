# <a name="_62fv5lk97jpe"></a>**ByteBrowser**
Date Updated: August 10, 2024

Written By: Jity Woldemichael, Michael Girma


**Overview**

ByteBrowser is an interactive command line tool that visualizes and manages directories. It allows users to visualize, navigate, rename, delete, preview files and directories and many more things. The application will be built using a combination of OCaml for the visualizations and internal logic and Bash for the execution of commands outside of the project directory.
## <a name="_6trt8alw6vi6"></a>**Goals**
The aim of the project is to provide an easy way for devs to see and interact with their files/directories. This is designed especially in mind for beginners with the command line (such as ourselves)!

There are tools out there that have nice ways of visualizing and manipulating directories; our desire is to expand on those abilities by adding what we think are cool and helpful extensions.

It would be clear that the project is useful if we start using it consistently! (And maybe some of the other JSIPers too :)) Particularly, we know we have succeeded if the program accurately visualizes directory structures and helps users navigate more efficiently.
## <a name="_i5lq26x7ubzj"></a>**Feature List**

- Tree visualization (based on relevancy and user specification)
- Previewing files
- Viewing file statistics
- Manipulation of files
- Search
- Directory summarization + querying
## <a name="_misvzlr2dqww"></a>**Quick look into some of our features**
This is generally how our tree visualization will look like.

We plan for users to have the ability to not see certain children.

We plan for users to have the ability to modify the tree in place with commands like remove and rename.

We plan to add visual optimizations so that users can get to a certain directory / files faster.

Additionally, we plan to add options to preview files, display statistics of files, and view + query summarizations of directories.

## Setup
```
$ git clone https://github.com/itsmichaeltg/ByteBrowser.git
```
```
$ cd ByteBrowser/
```
For Bash Systems (Ubuntu)
```
$ echo "" >> $HOME/.bashrc && echo "alias bb='source '"${PWD}"'/bb \$@'" >> $HOME/.bashrc
```
```
$ source $HOME/.bashrc
```
<!-- For Zsh Systems (Mac)
```
$ echo "" >> $HOME/.zshrc && echo "alias bb='source '"${PWD}"'/bb \$@'" >> $HOME/.zshrc
```
```
$ source $HOME/.zshrc
```
-->
## Run
```
$ bb [path] [max-depth] [show-hidden] [sort-by-time]
```

## <a name="_xltvo3k6rkho"></a>**Key Specifications**
Users will not have to press anything to initially visualize the tree.

|**Key**|**Description**|
| :- | :- |
|Ctrl + r|Rename|
|Ctrl + n|Toggle Position Numbers|
|Ctrl + d|Delete|
|Ctrl + p|Preview|
|Ctrl + f|Search|
|Ctrl + b|Go to initial tree|
|Ctrl + a|Reduce Tree|
|Ctrl + o then Enter|Move (Press Enter on the new directory)|
|Enter|Change directory|
|L, R, U, D|Navigate the tree|
|Esc|Quits ByteBrowser|
|Ctrl + h|Collapse|
|Ctrl + k|Provide general summarizations of directories (what sorts of files it contains, overview of values exposed by interfaces)|
|Ctrl + w|Query the summarizations we provide|

## Demos
# Collapse
[![asciicast](https://asciinema.org/a/3P36gnW8l9bQkD9FfcUcndhpI.svg)](https://asciinema.org/a/3P36gnW8l9bQkD9FfcUcndhpI)

# Demo
[![asciicast](https://asciinema.org/a/ged53OWdGRDrf0wKvuuwsBjza.svg)](https://asciinema.org/a/ged53OWdGRDrf0wKvuuwsBjza)

# Previewing
[![asciicast](https://asciinema.org/a/GbmGm8WDg5sIHzxUqHGeYA10a.svg)](https://asciinema.org/a/GbmGm8WDg5sIHzxUqHGeYA10a)

# Querying
[![asciicast](https://asciinema.org/a/pdVr40qmQU8OLhJonjORa68hc.svg)](https://asciinema.org/a/pdVr40qmQU8OLhJonjORa68hc)

# Relative Dirs
[![asciicast](https://asciinema.org/a/NHkXOVMDX5YIcEK7ce6iRERHf.svg)](https://asciinema.org/a/NHkXOVMDX5YIcEK7ce6iRERHf)

# Rename/Remove
[![asciicast](https://asciinema.org/a/MMlcR5OSbsossH9w1eT3kb4cZ.svg)](https://asciinema.org/a/MMlcR5OSbsossH9w1eT3kb4cZ)

# Change Directory
[![asciicast](https://asciinema.org/a/XrtoVKlVy2HRq9slAthTCIKJX.svg)](https://asciinema.org/a/XrtoVKlVy2HRq9slAthTCIKJX)

# Search
[![asciicast](https://asciinema.org/a/IOwPU2CA1SpTdWnjCefGiIyGO.svg)](https://asciinema.org/a/IOwPU2CA1SpTdWnjCefGiIyGO)

# Open file
[![asciicast](https://asciinema.org/a/FIMRdvrpfWRHntkiMlf2a247g.svg)](https://asciinema.org/a/FIMRdvrpfWRHntkiMlf2a247g)

# Reduce Tree
[![asciicast](https://asciinema.org/a/rCDgk93VmxCctC4xEEslCLIPA.svg)](https://asciinema.org/a/rCDgk93VmxCctC4xEEslCLIPA)

# Jump
[![asciicast](https://asciinema.org/a/GAv5yI7MuxmGmLJWvn9v97zqZ.svg)](https://asciinema.org/a/GAv5yI7MuxmGmLJWvn9v97zqZ)

# Version Control
[![asciicast](https://asciinema.org/a/h6bvoSNrvGKNrVzwoMihpjMwv.svg)](https://asciinema.org/a/h6bvoSNrvGKNrVzwoMihpjMwv)

## <a name="_ai0y08qey181"></a>**Implementation Phases**
The features are independent from each other, so the order of feature implementations does not matter too much. Generally, we are thinking of implementing the ability to take in inputs, visualize, and display some of our more interesting features.

|**Task**|**Assigned To**|**Start Date**|**End Date**|**Status**|
| :- | :- | :- | :- | :- |
|Visualization (tree, statistics, preview)|Jity Woldemichael|07/22/2024|07/26/2024|Completed|
|MintTea integration (basic implementation of navigation) + Modifications of files (rename, delete, and move)|Michael Girma|07/22/2024|07/26/2024|Completed|
|Summarization (get data, implementing RAG pipeline)|Jity Woldemichael|07/29/2024|08/2/2024|Completed|
|Visual optimizations (sorting based on recency, scaling tree based on location, hiding unwanted directories)|Michael Girma|07/29/2024|08/2/2024|Completed|
|<p>Navigation optimizations</p><p>(jumping to files based on numbers)</p>|Jity Woldemichael|08/05/2024|08/09/2024|Completed|
|Finalization program flow + reliable use of bash + fuzzy search + version control|Michael Girma|08/05/2024|08/09/2024|Completed|
## <a name="_b7i8bpeae152"></a>**Testing**
Aside from unit testing individual components and testing our program with users every time we add a meaningful feature, we have a test directory that contains nested directories and files where we test our program in our development process.  
## <a name="_pe36v5b5x5jh"></a>**Technical Must Haves**

- Keep a test directory testing every meaningful file we add. This is good for testing organization and ensuring that no new feature breaks old features.
- Keep visualization and navigation code separated. The project neatly breaks itself into interactivity and visualization - we would like to organize our codebase around this divide as well!
