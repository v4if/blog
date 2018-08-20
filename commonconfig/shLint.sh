#!/bin/bash
set -eo pipefail


'-c string If  the  -c  option  is  present, then commands are read from
          string.  If there are arguments after the  string,  they  are
          assigned to the positional parameters, starting with $0.
         
 sh -c ls'
 
ps -p $$
会显示当前shell的进程信息，简单点： ps $$ 也可以，用-p参数更严谨一些。
