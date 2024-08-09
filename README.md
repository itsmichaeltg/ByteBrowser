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
$ git clone https://github.com/itsmichaeltg/jsip-final-project.git
```
```
$ mv jsip-final-project/ /home/ubuntu
```
```
$ echo "" >> /home/ubuntu/.bashrc && echo "alias bb='source /home/ubuntu/jsip-final-project/bb \$@'" >> /home/ubuntu/.bashrc
```
```
$ source /home/ubuntu/.bashrc
```
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
<script src="https://asciinema.org/a/HPjIIxW14dDIN3w9BFKiRkBtG.js" id="asciicast-HPjIIxW14dDIN3w9BFKiRkBtG" async="true"></script>

# Previewing
<script src="https://asciinema.org/a/rC50JEs3y6SfakLVaRhpN0oy7.js" id="asciicast-rC50JEs3y6SfakLVaRhpN0oy7" async="true"></script>

# Querying
<script src="https://asciinema.org/a/B6RpAinEZUtXtem2QaplJXzoX.js" id="asciicast-B6RpAinEZUtXtem2QaplJXzoX" async="true"></script>

# Relative Dirs
<script src="https://asciinema.org/a/G1GaN1gAKPA8IrsD8ulEOZWFw.js" id="asciicast-G1GaN1gAKPA8IrsD8ulEOZWFw" async="true"></script>

# Rename/Remove
<script src="https://asciinema.org/a/DPTBgzVw6Y1G3IsFS8LOT4lPa.js" id="asciicast-DPTBgzVw6Y1G3IsFS8LOT4lPa" async="true"></script>

# Change Directory
<script src="https://asciinema.org/a/9aE5vVWIvqWu25h3D094m1me2.js" id="asciicast-9aE5vVWIvqWu25h3D094m1me2" async="true"></script>

# Search
<script src="https://asciinema.org/a/h3T66FlsX9fdY1G9t8Ak37UC3.js" id="asciicast-h3T66FlsX9fdY1G9t8Ak37UC3" async="true"></script>

# Open file
<script src="https://asciinema.org/a/jtn0UHQVYHdN0Ix0IY90cmMQJ.js" id="asciicast-jtn0UHQVYHdN0Ix0IY90cmMQJ" async="true"></script>

# Reduce Tree
<script src="https://asciinema.org/a/scwgkZVHmanMfDe5TrZAM4rA7.js" id="asciicast-scwgkZVHmanMfDe5TrZAM4rA7" async="true"></script>

# Jump
<script src="https://asciinema.org/a/38kw8mU0HBdSbMHmRVvlzd27i.js" id="asciicast-38kw8mU0HBdSbMHmRVvlzd27i" async="true"></script>

# Version Control
<script src="https://asciinema.org/a/L4VrJxRyabUllsztnHxuLEQK7.js" id="asciicast-L4VrJxRyabUllsztnHxuLEQK7" async="true"></script>

## <a name="_ai0y08qey181"></a>**Implementation Phases**
The features are independent from each other, so the order of feature implementations does not matter too much. Generally, we are thinking of implementing the ability to take in inputs, visualize, and display some of our more interesting features.

|**Task**|**Assigned To**|**Start Date**|**End Date**|**Status**|
| :- | :- | :- | :- | :- |
|Visualization (tree, statistics, preview)|Jity Woldemichael|07/22/2024|07/26/2024|Completed|
|MintTea integration (basic implementation of navigation) + Modifications of files (rename, delete, and move)|Michael Girma|07/22/2024|07/26/2024|Completed|
|Summarization (get data, implementing RAG pipeline)|Jity Woldemichael|07/29/2024|08/2/2024|Completed|
|Visual optimizations (sorting based on recency, scaling tree based on location, hiding unwanted directories)|Michael Girma|07/29/2024|08/2/2024|Completed|
|<p>Navigation optimizations</p><p>(jumping to files based on numbers, searching files by keywords)</p>|Jity Woldemichael|08/05/2024|08/09/2024|Completed|
|Finalization program flow + reliable use of bash + search|Michael Girma|08/05/2024|08/09/2024|Completed|
## <a name="_b7i8bpeae152"></a>**Testing**
Aside from unit testing individual components and testing our program with users every time we add a meaningful feature, we have a test directory that contains nested directories and files where we test our program in our development process.  
## <a name="_pe36v5b5x5jh"></a>**Technical Must Haves**

- Keep a test directory testing every meaningful file we add. This is good for testing organization and ensuring that no new feature breaks old features.
- Keep visualization and navigation code separated. The project neatly breaks itself into interactivity and visualization - we would like to organize our codebase around this divide as well!
