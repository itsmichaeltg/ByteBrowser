# jsip-final-project

a command line tool that manages and visualizes directories

## Setup

```
$ sudo cp bb /bin/bb
```
```
$ sudo chmod +x /bin/bb
```
```
$ echo "" >> /home/ubuntu/.bashrc && echo "alias bb='source bb \$@'" >> /home/ubuntu/.bashrc
```
```
$ source /home/ubuntu/.bashrc
```

## Run

```
$ bb visualize pwd

$ bb navigate dir -start "/home/" -max-depth 2
```