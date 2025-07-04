# VASP and QE script
Here are some scripts for VASP and QE calculations.

Gnuplot is required to use the scripts in the gnuplot folder, please make sure you have Gnuplot installed on your supercomputer or server,

If you want to install gnuplot please visit: http://gnuplot.sourceforge.net

where the input file of script plotband、plotdos、plotpdos and plot-band+dos is a .dat format file that has been processed by vaspkit,and the input file for plotCohp is generated by the Lobster program

If you want to install Vaspkit please visit:https://vaspkit.com/

If you want to install Lobster please visit:https://schmeling.ac.rwth-aachen.de/cohp/index.php?menuID=6

In folder pythonscript:

The extract_vectors_phonopy.py script  is used to extract the vibration patterns of phonons.
Usage:First, use the Vesta software to convert POSCAR into a POSCAR.vesta file.Then use the command：python extract_vectors_phonopy.py 

The fband-generate.py script is used to generate a KPOINTS file that is used to calculate the fatband file in Lobster.And if you can't build once, be sure to use the script twice.Note: To use this script, make sure you have pymatgen present on your computer https://github.com/materialsproject/pymatgen

The getTKCOHP.py and getbσKCOHP.py scripts are used to sum the data in the file processed by getKspaceCOHP.x so that plotKCOHP-bubble.sh or plotKCOHP-color.sh can be drawn later

The getcohpfile.py is used to generate Lobster's input file lobsterin。It is not recommended to use it here, as it is more convenient to use the existing lobsterin file directly.

The getdistanceinf.py is a script that extracts atomic positions from POSCAR

The QEtoolkit-2.sh is the script that generates the QE input file. This script was reproduced by me from the following URL.
http://bbs.keinsci.com/forum.php?mod=viewthread&tid=28755&highlight=QEtoolkit

The plotKCOHP-bubble.sh and plotKCOHP-color.sh are scripts used to draw k-dependence COHP files processed by getKspaceCOHP.x .

For details on the use of getKspaceCOHP.X, please refer to:https://github.com/rnels12/getKspaceCOHP

The sqs2poscar is used to convert the bestsqs.in file generated by ATAT into a POSCAR file for VASP calculation.

gen_mapsrep is a modified version of mapsrep module in ATAT
