#!/bin/bash
# script created in 2020 by RN
# modified to use smaller bubbles and prevent overlapping

gnuplot <<- EOF
set terminal png enhanced truecolor size 7200,7200 font ",100"
set title "B-C-chain"

# 设置颜色映射
set palette defined (-1 "blue", 0 "purple", 1 "red")

set border linewidth 6
set output 'k-dependentCOHP.png'
set ylabel "Energy (eV)" offset 0.5,0,0 font ",100"
set ytics nomirror
set yrange [-15:10]
set xlabel "wave vector" offset 0,-1.0,0 font ",100"
set xtics ("GAMMA" 0.000,"X" 0.5,"S" 1,"Y" 1.5,"GAMMA" 2,"Z" 2.5,"U" 3,"R" 3.5,"T" 4,"Z|X" 4.5,"U|Y" 5,"T|S" 5.5,"R" 6) font ",100" offset 0,-0.5,0
set xrange [0:6]
# 添加颜色条
set cblabel "COHP" font ",100" offset 1,0,0
set cbtics font ",100"

E_F=4.3675
#unset xtics

plot '${1}' u 4:(\$5 - E_F):(abs(\$6)*0.03):6 w circles lc palette fill solid notitle, \
     '${1}' u 4:(\$5 - E_F) w lines lc rgb "#808080" lw 3 notitle, \
      0 w lines lt 2 lc rgb "black" notitle
EOF
