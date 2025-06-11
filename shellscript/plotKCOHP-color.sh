#!/bin/bash
# script created in 2020 by RN

    gnuplot <<- EOF
set terminal png enhanced truecolor size 7200,7200 font ",100"
#
set palette defined ( 0 "blue", 1 "green", 2 "purple", 3 "red", 4 "brown")
set macro
set border linewidth 6
set output 'k-dependentCOHP.png'
set ylabel "Energy (eV)" offset 0.5,0,0 font ",100"
set ytics nomirror
set yrange [-10:10]
set xlabel "wave vector" offset 0,-1.0,0 font ",100"
#set ytics nomirror
#set xtics ("Γ" 0.0,"M" 1.18,"K" 1.862,"Γ" 3.224,"A" 4.113) font ",100" offset 0,-0.5,0
#
E_F=4.3971
unset xtics
plot '${1}' u 4:(\$5 - E_F):6 w l lw 10 palette t ''
EOF

