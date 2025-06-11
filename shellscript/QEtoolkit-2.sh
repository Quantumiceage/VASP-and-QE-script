#!/bin/bash

#=================== User Defined parameters ==================
#define pseudopotentials directory path
gbrvpath='/home/dy/qe_pbe_GBRV'
pbepawpath='/data/home/leiguozhu/pseudopotential/pslibrary.1.0.0/pbe/PSEUDOPOTENTIALS'
pbesolpawpath='/home/dy/qe_pbesol_psl'
oncvpath='/data/home/leiguozhu/pseudopotential/oncv'
QEversion='7.4'
#==============================================================

echo '>===============================================================================<'
echo '>-                                                                             -<'
echo '>-                                 QEtoolkit                                   -<'
echo '>-                                                                             -<'
echo '>-                              Author: Yue Ding                               -<'
echo '>-                                                                             -<'
echo '>-                              Version 2.0 (dev)                              -<'
echo '>-                                                                             -<'
echo '>-           Contact me if you have any suggestions: QQ 3305507756             -<'
echo '>===============================================================================<'
function main_menu (){
echo
echo 'Note: Below functions are designed for ibrav=0 combined with angstrom unit'
echo 
echo '============================== Input Files Generation ==========================' 
echo '  0) pw.x input files	1) neb.x input files	2) ph.x input files'  
echo '  3) hp.x input files	4) Dos.x input files	5) Projwfc.x input files'  
echo '  6) pp.x input files	7) Bands.x input files'
echo '============================= Post processing section =========================='
echo '  8) Output (vc)relax structure to .gjf format'
echo '  9) Output (vc)relax structure to .cif format'
echo '  10) Output (vc)relax structure to .xyz format'
echo '  11) Convert (vc)relax output file for nscf calculation'
echo '  12) Convert pw.x input file to .xyz format'
echo '  13) Convert pw.x input file to .cif format'
echo '  14) Convert pw.x input file to .gjf format'
echo '=============================== Other functions ================================'
echo '  15) Fix atoms for slab model'
echo '  16) Monitor energy convergence in SCF, relax, and vc-relax'
echo '  17) Convergence test for ecutwfc and ecutrho'
echo '  18) Convergence test for k-points'
echo '  19) Generate gnuplot plotting scripts'
echo '================================================================================'
echo 
}
main_menu

fname1=`echo $1`
fname2=`echo $2`
fname3=`echo $3`
prefix=`echo "${fname1%%.*}"`
	
#Check whether Multwifn is installed or not.
Multiwfnpath=$(which Multiwfn 2>/dev/null)
if [[ -z $Multiwfnpath ]];then
        echo " <Multiwfn> is not found, please recheck whether its environment variable is correctly set or not!"
        exit 1
fi

#define atomic index with corresponding element
atm["1"]="H";atm["2"]="He";atm["3"]="Li";atm["4"]="Be";atm["5"]="B";atm["6"]="C";atm["7"]="N";\
atm["8"]="O";atm["9"]="F";atm["10"]="Ne";atm["11"]="Na";atm["12"]="Mg";atm["13"]="Al";atm["14"]="Si";\
atm["15"]="P";atm["16"]="S";atm["17"]="Cl";atm["18"]="Ar";atm["19"]="K";atm["20"]="Ca";atm["21"]="Sc";\
atm["22"]="Ti";atm["23"]="V";atm["24"]="Cr";atm["25"]="Mn";atm["26"]="Fe";atm["27"]="Co";atm["28"]="Ni";\
atm["29"]="Cu";atm["30"]="Zn";atm["31"]="Ga";atm["32"]="Ge";atm["33"]="As";atm["34"]="Se";atm["35"]="Br";\
atm["36"]="Kr";atm["37"]="Rb";atm["38"]="Sr";atm["39"]="Y";atm["40"]="Zr";atm["41"]="Nb";atm["42"]="Mo";\
atm["43"]="Tc";atm["44"]="Ru";atm["45"]="Rh";atm["46"]="Pd";atm["47"]="Ag";atm["48"]="Cd";atm["49"]="In";\
atm["50"]="Sn";atm["51"]="Sb";atm["52"]="Te";atm["53"]="I";atm["54"]="Xe";atm["55"]="Cs";atm["56"]="Ba";\
atm["57"]="La";atm["58"]="Ce";atm["59"]="Pr";atm["60"]="Nd";atm["61"]="Pm";atm["62"]="Sm";atm["63"]="Eu";\
atm["64"]="Gd";atm["65"]="Tb";atm["66"]="Dy";atm["67"]="Ho";atm["68"]="Er";atm["69"]="Tm";atm["70"]="Yb";\
atm["71"]="Lu";atm["72"]="Hf";atm["73"]="Ta";atm["74"]="W";atm["75"]="Re";atm["76"]="Os";atm["77"]="Ir";\
atm["78"]="Pt";atm["79"]="Au";atm["80"]="Hg";atm["81"]="Tl";atm["82"]="Pb";atm["83"]="Bi";atm["84"]="Po";\
atm["85"]="At";atm["86"]="Rn"

#define atomic mass (amu), obtained from https://ptable.com/#%E6%80%A7%E8%B4%A8
atmmass["1"]="1.008";atmmass["2"]="4.0026";atmmass["3"]="6.94";atmmass["4"]="9.0122";atmmass["5"]="10.81";atmmass["6"]="12.011";atmmass["7"]="14.007";\
atmmass["8"]="15.999";atmmass["9"]="18.998";atmmass["10"]="20.180";atmmass["11"]="22.990";atmmass["12"]="24.305";atmmass["13"]="26.982";atmmass["14"]="28.085";\
atmmass["15"]="30.974";atmmass["16"]="32.06";atmmass["17"]="35.45";atmmass["18"]="39.948";atmmass["19"]="39.098";atmmass["20"]="40.078";atmmass["21"]="44.956";\
atmmass["22"]="47.867";atmmass["23"]="50.942";atmmass["24"]="51.996";atmmass["25"]="54.938";atmmass["26"]="55.845";atmmass["27"]="58.933";atmmass["28"]="58.693";\
atmmass["29"]="63.546";atmmass["30"]="65.38";atmmass["31"]="69.723";atmmass["32"]="72.630";atmmass["33"]="74.922";atmmass["34"]="78.971";atmmass["35"]="79.904";\
atmmass["36"]="83.798";atmmass["37"]="85.468";atmmass["38"]="87.62";atmmass["39"]="88.906";atmmass["40"]="91.244";atmmass["41"]="92.906";atmmass["42"]="95.95";\
atmmass["43"]="98";atmmass["44"]="101.07";atmmass["45"]="102.91";atmmass["46"]="106.42";atmmass["47"]="107.87";atmmass["48"]="112.41";atmmass["49"]="114.82";\
atmmass["50"]="118.71";atmmass["51"]="121.76";atmmass["52"]="127.60";atmmass["53"]="126.90";atmmass["54"]="131.29";atmmass["55"]="132.91";atmmass["56"]="137.33";\
atmmass["57"]="138.91";atmmass["58"]="140.12";atmmass["59"]="140.91";atmmass["60"]="144.24";atmmass["61"]="145";atmmass["62"]="150.36";atmmass["63"]="151.96";\
atmmass["64"]="157.25";atmmass["65"]="158.93";atmmass["66"]="162.50";atmmass["67"]="164.93";atmmass["68"]="167.26";atmmass["69"]="168.93";atmmass["70"]="173.05";\
atmmass["71"]="174.97";atmmass["72"]="178.49";atmmass["73"]="180.95";atmmass["74"]="183.84";atmmass["75"]="186.21";atmmass["76"]="190.23";atmmass["77"]="192.22";\
atmmass["78"]="195.08";atmmass["79"]="196.97";atmmass["80"]="200.59";atmmass["81"]="204.38";atmmass["82"]="207.2";atmmass["83"]="208.98";atmmass["84"]="209";\
atmmass["85"]="210";atmmass["86"]="222"	

#define GBRV pseudopotentials library
gbrvlib["1"]="h_pbe_v1.4.uspp.F.UPF";gbrvlib["3"]="li_pbe_v1.4.uspp.F.UPF";gbrvlib["4"]="be_pbe_v1.4.uspp.F.UPF";gbrvlib["5"]="b_pbe_v1.4.uspp.F.UPF";gbrvlib["6"]="c_pbe_v1.2.uspp.F.UPF";gbrvlib["7"]="n_pbe_v1.2.uspp.F.UPF";\
gbrvlib["8"]="o_pbe_v1.2.uspp.F.UPF";gbrvlib["9"]="f_pbe_v1.4.uspp.F.UPF";gbrvlib["11"]="na_pbe_v1.5.uspp.F.UPF";gbrvlib["12"]="mg_pbe_v1.4.uspp.F.UPF";gbrvlib["13"]="al_pbe_v1.uspp.F.UPF";gbrvlib["14"]="si_pbe_v1.uspp.F.UPF";\
gbrvlib["15"]="p_pbe_v1.5.uspp.F.UPF";gbrvlib["16"]="s_pbe_v1.4.uspp.F.UPF";gbrvlib["17"]="cl_pbe_v1.4.uspp.F.UPF";gbrvlib["19"]="k_pbe_v1.4.uspp.F.UPF";gbrvlib["20"]="ca_pbe_v1.uspp.F.UPF";gbrvlib["21"]="sc_pbe_v1.uspp.F.UPF";\
gbrvlib["22"]="ti_pbe_v1.4.uspp.F.UPF";gbrvlib["23"]="v_pbe_v1.4.uspp.F.UPF";gbrvlib["24"]="cr_pbe_v1.5.uspp.F.UPF";gbrvlib["25"]="mn_pbe_v1.5.uspp.F.UPF";gbrvlib["26"]="fe_pbe_v1.5.uspp.F.UPF";gbrvlib["27"]="co_pbe_v1.2.uspp.F.UPF";gbrvlib["28"]="ni_pbe_v1.4.uspp.F.UPF";\
gbrvlib["29"]="cu_pbe_v1.2.uspp.F.UPF";gbrvlib["30"]="zn_pbe_v1.uspp.F.UPF";gbrvlib["31"]="ga_pbe_v1.4.uspp.F.UPF";gbrvlib["32"]="ge_pbe_v1.4.uspp.F.UPF";gbrvlib["33"]="as_pbe_v1.uspp.F.UPF";gbrvlib["34"]="se_pbe_v1.uspp.F.UPF";gbrvlib["35"]="br_pbe_v1.4.uspp.F.UPF";\
gbrvlib["37"]="rb_pbe_v1.uspp.F.UPF";gbrvlib["38"]="sr_pbe_v1.uspp.F.UPF";gbrvlib["39"]="y_pbe_v1.4.uspp.F.UPF";gbrvlib["40"]="zr_pbe_v1.uspp.F.UPF";gbrvlib["41"]="nb_pbe_v1.uspp.F.UPF";gbrvlib["42"]="mo_pbe_v1.uspp.F.UPF";\
gbrvlib["43"]="tc_pbe_v1.uspp.F.UPF";gbrvlib["44"]="ru_pbe_v1.2.uspp.F.UPF";gbrvlib["45"]="rh_pbe_v1.4.uspp.F.UPF";gbrvlib["46"]="pd_pbe_v1.4.uspp.F.UPF";gbrvlib["47"]="ag_pbe_v1.4.uspp.F.UPF";gbrvlib["48"]="cd_pbe_v1.uspp.F.UPF";gbrvlib["49"]="in_pbe_v1.4.uspp.F.UPF";\
gbrvlib["50"]="sn_pbe_v1.4.uspp.F.UPF";gbrvlib["51"]="sb_pbe_v1.4.uspp.F.UPF";gbrvlib["52"]="te_pbe_v1.uspp.F.UPF";gbrvlib["53"]="i_pbe_v1.uspp.F.UPF";gbrvlib["55"]="cs_pbe_v1.uspp.F.UPF";gbrvlib["56"]="ba_pbe_v1.uspp.F.UPF";\
gbrvlib["57"]="la_pbe_v1.uspp.F.UPF";gbrvlib["72"]="hf_pbe_plus4_v1.uspp.F.UPF";gbrvlib["73"]="ta_pbe_v1.uspp.F.UPF";gbrvlib["74"]="w_pbe_v1.2.uspp.F.UPF";gbrvlib["75"]="re_pbe_v1.2.uspp.F.UPF";gbrvlib["76"]="os_pbe_v1.2.uspp.F.UPF";gbrvlib["77"]="ir_pbe_v1.2.uspp.F.UPF";\
gbrvlib["78"]="pt_pbe_v1.4.uspp.F.UPF";gbrvlib["79"]="au_pbe_v1.uspp.F.UPF";gbrvlib["80"]="hg_pbe_v1.uspp.F.UPF";gbrvlib["81"]="tl_pbe_v1.2.uspp.F.UPF";gbrvlib["82"]="pb_pbe_v1.uspp.F.UPF";gbrvlib["83"]="bi_pbe_v1.uspp.F.UPF"

#define PAW pseudopotentials library
pawlib["1"]="H.pbe-kjpaw_psl.1.0.0.UPF";pawlib["2"]="He.pbe-kjpaw_psl.1.0.0.UPF";pawlib["3"]="Li.pbe-s-kjpaw_psl.1.0.0.UPF";pawlib["4"]="Be.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["5"]="B.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["6"]="C.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["7"]="N.pbe-n-kjpaw_psl.1.0.0.UPF";\
pawlib["8"]="O.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["9"]="F.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["10"]="Ne.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["11"]="Na.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["12"]="Mg.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["13"]="Al.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["14"]="Si.pbe-n-kjpaw_psl.1.0.0.UPF";\
pawlib["15"]="P.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["16"]="S.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["17"]="Cl.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["18"]="Ar.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["19"]="K.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["20"]="Ca.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["21"]="Sc.pbe-spn-kjpaw_psl.1.0.0.UPF";\
pawlib["22"]="Ti.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["23"]="V.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["24"]="Cr.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["25"]="Mn.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["26"]="Fe.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["27"]="Co.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["28"]="Ni.pbe-n-kjpaw_psl.1.0.0.UPF";\
pawlib["29"]="Cu.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["30"]="Zn.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["31"]="Ga.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["32"]="Ge.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["33"]="As.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["34"]="Se.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["35"]="Br.pbe-n-kjpaw_psl.1.0.0.UPF";\
pawlib["36"]="Kr.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["37"]="Rb.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["38"]="Sr.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["39"]="Y.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["40"]="Zr.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["41"]="Nb.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["42"]="Mo.pbe-spn-kjpaw_psl.1.0.0.UPF";\
pawlib["43"]="Tc.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["44"]="Rb.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["45"]="Rh.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["46"]="Pd.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["47"]="Ag.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["48"]="Cd.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["49"]="In.pbe-dn-kjpaw_psl.1.0.0.UPF";\
pawlib["50"]="Sn.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["51"]="Sb.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["52"]="Te.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["53"]="I.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["54"]="Xe.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["55"]="Cs.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["56"]="Ba.pbe-spn-kjpaw_psl.1.0.0.UPF";\
pawlib["57"]="La.pbe-spfn-kjpaw_psl.1.0.0.UPF";pawlib["58"]="Ce.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["59"]="Pr.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["60"]="Nd.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["61"]="Pm.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["62"]="Sm.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["63"]="Eu.pbe-spn-kjpaw_psl.1.0.0.UPF";\
pawlib["64"]="Gd.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["65"]="Tb.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["66"]="Dy.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["67"]="Ho.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["68"]="Er.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["69"]="Tm.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["70"]="Yb.pbe-spn-kjpaw_psl.1.0.0.UPF";\
pawlib["71"]="Lu.pbe-spdn-kjpaw_psl.1.0.0.UPF";pawlib["72"]="Hf.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["73"]="Ta.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["74"]="W.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["75"]="Re.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["76"]="Os.pbe-spn-kjpaw_psl.1.0.0.UPF";pawlib["77"]="I.pbe-n-kjpaw_psl.1.0.0.UPF";\
pawlib["78"]="Pt.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["79"]="Au.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["80"]="Hg.pbe-n-kjpaw_psl.1.0.0.UPF";pawlib["81"]="Tl.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["82"]="Pb.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["83"]="Bi.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["84"]="Po.pbe-dn-kjpaw_psl.1.0.0.UPF";\
pawlib["85"]="At.pbe-dn-kjpaw_psl.1.0.0.UPF";pawlib["86"]="Rn.pbe-dn-kjpaw_psl.1.0.0.UPF"

#define ONCV pseudopotentials library
oncvlib["1"]="H_ONCV_PBE-1.2.upf";oncvlib["2"]="He_ONCV_PBE-1.2.upf";oncvlib["3"]="Li_ONCV_PBE-1.2.upf";oncvlib["4"]="Be_ONCV_PBE-1.2.upf";oncvlib["5"]="B_ONCV_PBE-1.2.upf";oncvlib["6"]="C_ONCV_PBE-1.2.upf";oncvlib["7"]="N_ONCV_PBE-1.2.upf";\
oncvlib["8"]="O_ONCV_PBE-1.2.upf";oncvlib["9"]="F_ONCV_PBE-1.2.upf";oncvlib["10"]="Ne_ONCV_PBE-1.2.upf";oncvlib["11"]="Na_ONCV_PBE-1.2.upf";oncvlib["12"]="Na_ONCV_PBE-1.2.upf";oncvlib["13"]="Al_ONCV_PBE-1.2.upf";oncvlib["14"]="Si_ONCV_PBE-1.2.upf";\
oncvlib["15"]="P_ONCV_PBE-1.2.upf";oncvlib["16"]="S_ONCV_PBE-1.2.upf";oncvlib["17"]="Cl_ONCV_PBE-1.2.upf";oncvlib["18"]="Ar_ONCV_PBE-1.2.upf";oncvlib["19"]="K_ONCV_PBE-1.2.upf";oncvlib["20"]="Ca_ONCV_PBE-1.2.upf";oncvlib["21"]="Sc_ONCV_PBE-1.2.upf";\
oncvlib["22"]="Ti_ONCV_PBE-1.2.upf";oncvlib["23"]="V_ONCV_PBE-1.2.upf";oncvlib["24"]="Cr_ONCV_PBE-1.2.upf";oncvlib["25"]="Mn_ONCV_PBE-1.2.upf";oncvlib["26"]="Fe_ONCV_PBE-1.2.upf";oncvlib["27"]="Co_ONCV_PBE-1.2.upf";oncvlib["28"]="Ni_ONCV_PBE-1.2.upf";\
oncvlib["29"]="Cu_ONCV_PBE-1.2.upf";oncvlib["30"]="Zn_ONCV_PBE-1.2.upf";oncvlib["31"]="Ga_ONCV_PBE-1.2.upf";oncvlib["32"]="Ge_ONCV_PBE-1.2.upf";oncvlib["33"]="As_ONCV_PBE-1.2.upf";oncvlib["34"]="Se_ONCV_PBE-1.2.upf";oncvlib["35"]="Br_ONCV_PBE-1.2.upf";\
oncvlib["36"]="Kr_ONCV_PBE-1.2.upf";oncvlib["37"]="Rb_ONCV_PBE-1.2.upf";oncvlib["38"]="Sr_ONCV_PBE-1.2.upf";oncvlib["39"]="Y_ONCV_PBE-1.2.upf";oncvlib["40"]="Zr_ONCV_PBE-1.2.upf";oncvlib["41"]="Nb_ONCV_PBE-1.2.upf";oncvlib["42"]="Mo_ONCV_PBE-1.2.upf";\
oncvlib["43"]="Tc_ONCV_PBE-1.2.upf";oncvlib["44"]="Ru_ONCV_PBE-1.2.upf";oncvlib["45"]="Rh_ONCV_PBE-1.2.upf";oncvlib["46"]="Pd_ONCV_PBE-1.2.upf";oncvlib["47"]="Ag_ONCV_PBE-1.2.upf";oncvlib["48"]="Cd_ONCV_PBE-1.2.upf";oncvlib["49"]="In_ONCV_PBE-1.2.upf";\
oncvlib["50"]="Sn_ONCV_PBE-1.2.upf";oncvlib["51"]="Sb_ONCV_PBE-1.2.upf";oncvlib["52"]="Te_ONCV_PBE-1.2.upf";oncvlib["53"]="I_ONCV_PBE-1.2.upf";oncvlib["54"]="Xe_ONCV_PBE-1.2.upf";oncvlib["55"]="Cs_ONCV_PBE-1.2.upf";oncvlib["56"]="Ba_ONCV_PBE-1.2.upf";\
oncvlib["57"]="La_ONCV_PBE-1.2.upf";oncvlib["72"]="Hf_ONCV_PBE-1.2.upf";oncvlib["73"]="Ta_ONCV_PBE-1.2.upf";oncvlib["74"]="W_ONCV_PBE-1.2.upf";oncvlib["75"]="Re_ONCV_PBE-1.2.upf";oncvlib["76"]="Os_ONCV_PBE-1.2.upf";oncvlib["77"]="Ir_ONCV_PBE-1.2.upf";\
oncvlib["78"]="Pt_ONCV_PBE-1.2.upf";oncvlib["79"]="Au_ONCV_PBE-1.2.upf";oncvlib["80"]="Hg_ONCV_PBE-1.2.upf";oncvlib["81"]="Tl_ONCV_PBE-1.2.upf";oncvlib["82"]="Pb_ONCV_PBE-1.2.upf";oncvlib["83"]="Bi_ONCV_PBE-1.2.upf"

#define pbesol PAW pseudopotentials library
pbesollib["1"]="H.pbesol-kjpaw_psl.1.0.0.UPF";pbesollib["2"]="He.pbesol-kjpaw_psl.1.0.0.UPF";pbesollib["3"]="Li.pbesol-s-kjpaw_psl.1.0.0.UPF";pbesollib["4"]="Be.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["5"]="B.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["6"]="C.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["7"]="N.pbesol-n-kjpaw_psl.1.0.0.UPF";\
pbesollib["8"]="O.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["9"]="F.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["10"]="Ne.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["11"]="Na.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["12"]="Mg.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["13"]="Al.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["14"]="Si.pbesol-n-kjpaw_psl.1.0.0.UPF";\
pbesollib["15"]="P.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["16"]="S.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["17"]="Cl.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["18"]="Ar.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["19"]="K.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["20"]="Ca.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["21"]="Sc.pbesol-spn-kjpaw_psl.1.0.0.UPF";\
pbesollib["22"]="Ti.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["23"]="V.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["24"]="Cr.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["25"]="Mn.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["26"]="Fe.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["27"]="Co.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["28"]="Ni.pbesol-n-kjpaw_psl.1.0.0.UPF";\
pbesollib["29"]="Cu.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["30"]="Zn.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["31"]="Ga.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["32"]="Ge.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["33"]="As.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["34"]="Se.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["35"]="Br.pbesol-n-kjpaw_psl.1.0.0.UPF";\
pbesollib["36"]="Kr.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["37"]="Rb.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["38"]="Sr.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["39"]="Y.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["40"]="Zr.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["41"]="Nb.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["42"]="Mo.pbesol-spn-kjpaw_psl.1.0.0.UPF";\
pbesollib["43"]="Tc.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["44"]="Ru.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["45"]="Rh.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["46"]="Pd.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["47"]="Ag.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["48"]="Cd.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["49"]="In.pbesol-dn-kjpaw_psl.1.0.0.UPF";\
pbesollib["50"]="Sn.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["51"]="Sb.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["52"]="Te.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["53"]="I.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["54"]="Xe.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["55"]="Cs.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["56"]="Ba.pbesol-spn-kjpaw_psl.1.0.0.UPF";\
pbesollib["57"]="La.pbesol-spfn-kjpaw_psl.1.0.0.UPF";pbesollib["58"]="Ce.pbesol-spdfn-kjpaw_psl.1.0.0.UPF";pbesollib["59"]="Pr.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["60"]="Nd.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["61"]="Pm.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["62"]="Sm.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["63"]="Eu.pbesol-spn-kjpaw_psl.1.0.0.UPF";\
pbesollib["64"]="Gd.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["65"]="Tb.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["66"]="Dy.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["67"]="Ho.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["68"]="Er.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["69"]="Tm.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["70"]="Yb.pbesol-spn-kjpaw_psl.1.0.0.UPF";\
pbesollib["71"]="Lu.pbesol-spdn-kjpaw_psl.1.0.0.UPF";pbesollib["72"]="Hf.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["73"]="Ta.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["74"]="W.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["75"]="Re.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["76"]="Os.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["77"]="Ir.pbesol-n-kjpaw_psl.1.0.0.UPF";\
pbesollib["78"]="Pt.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["79"]="Au.pbesol-spn-kjpaw_psl.1.0.0.UPF";pbesollib["80"]="Hg.pbesol-n-kjpaw_psl.1.0.0.UPF";pbesollib["81"]="Tl.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["82"]="Pb.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["83"]="Bi.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["84"]="Po.pbesol-dn-kjpaw_psl.1.0.0.UPF";\
pbesollib["85"]="At.pbesol-dn-kjpaw_psl.1.0.0.UPF";pbesollib["86"]="Rn.pbesol-dn-kjpaw_psl.1.0.0.UPF"

#--------------------------------- pw.x module----------------------------------------
function pwin (){

#check the input file
if [ -z "$fname1" ]; then  
    echo
    echo ' Load a file that can be parsed by Multiwfn, e.g. .cif and .gjf format.'
    read fname1
    while [ -z "$fname1" ]; do
        echo
        echo ' Load a file that can be parsed by Multiwfn, e.g.  .cif and .gjf format.'
        read fname1
    done
    prefix=`echo "${fname1%%.*}"`
fi

echo ' Now cell Informations is parsed by Multiwfn (http://sobereva.com/multiwfn)....'
echo
#Invoking Multiwfn to generate temporal QE input file to get cell informations and atomic coordinations
Multiwfn ${fname1} << EOF &> /dev/null
100
2
26
${prefix}_QE.tmp
0
q
EOF

natm=`grep 'nat' ${prefix}_QE.tmp | awk '{print $2}'`
ntyp=`grep 'ntyp' ${prefix}_QE.tmp | awk '{print $2}'`
begcellpos=`grep -n 'CELL_PARAMETERS' ${prefix}_QE.tmp | awk -F : '{print $1 + 1}'`
endcellpos=$((${begcellpos} + 2))
begatmpos=`grep -n 'ATOMIC_POSITIONS' ${prefix}_QE.tmp | awk -F : '{print $1 + 1}'`
endatmpos=$((${begatmpos} + ${natm} -1))

#Get the number of atoms of each types and the corresponding elements.
for ((i=1;i<=$ntyp;i++))
do
	Natmtype[$i]=`sed -n "${begatmpos},${endatmpos}p" ${prefix}_QE.tmp | awk '{print $1}'|sort|uniq -c| awk -v var="$i" 'NR==var{print $1}'`
	atmtype[$i]=`sed -n "${begatmpos},${endatmpos}p" ${prefix}_QE.tmp | awk '{print $1}'|sort|uniq |awk -v var="$i" 'NR==var{print $1}'`
done

#Define pwin menu
systype='Insulator'
rtask='energy'
func='PBE'
dispcorr='None'
dipcorr='None'
dftu='No'
kpmesh='2*2*1'
nbnd='Default'
pseudolib='PBE-GBRV'

function pwin_menu (){
	echo " 0) Generate input file now"
	echo " 1) Set system type, current: $systype"
	echo " 2) Choose the run task, current: $rtask"
	echo " 3) Choose the theoretical method, current: $func"
	echo " 4) Set dispersion correction, current: $dispcorr"
	echo " 5) Set surface dipole correction, current: $dipcorr"
	echo " 6) Define atomic magnetization"
	echo " 7) Toggle using DFT+U, current: $dftu"
	echo " 8) Set kpoint mesh, current: $kpmesh"
	echo " 9) Set the number of bands, current: $nbnd"
	echo " 10) Choose the pseudopotential library, current: $pseudolib"
	echo " 11) Return"
} 

pwin_menu
pwin_choice=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11") 
read pwin_arg
while ! echo "${pwin_choice[@]}" | grep -wq "$pwin_arg" 
do
	echo "Please reinput function number..."
	read pwin_arg
done

#generate the input file
function genpwinfile (){
#&control section
if [ "$rtask" == "energy" ]; then
	echo ' &CONTROL' >> ${prefix}.scf.in
	echo "   calculation     = 'scf'" >> ${prefix}.scf.in
	echo "   restart_mode    = 'from_scratch'" >> ${prefix}.scf.in
	echo "   outdir          = './tmp'" >> ${prefix}.scf.in
	if [ "$pseudolib" == "PBE-GBRV" ]; then
		echo "   pseudo_dir      = '"$gbrvpath"'" >> ${prefix}.scf.in
	elif [ "$pseudolib" == "PBE-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbepawpath"'" >> ${prefix}.scf.in
	elif [ "$pseudolib" == "PBEsol-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbesolpawpath"'" >> ${prefix}.scf.in
	elif [ "$pseudolib" == "PBE-ONCV" ]; then
		echo "   pseudo_dir      = '"$oncvpath"'" >> ${prefix}.scf.in
	fi
	echo "   prefix          = '"${prefix}"'" >> ${prefix}.scf.in
    echo "   verbosity       = 'low'" >> ${prefix}.scf.in
	if [ "$dipcorr" == "saw-like potential" ]; then
		echo "   tefield         = .true." >> ${prefix}.scf.in
		echo "   dipfield        = .true." >> ${prefix}.scf.in	
	fi	
    echo ' /' >> ${prefix}.scf.in
elif [ "$rtask" == "energy+force+stress" ];then
	echo ' &CONTROL' >> ${prefix}.scf.in
	echo "   calculation     = 'scf'" >> ${prefix}.scf.in
	echo "   restart_mode    = 'from_scratch'" >> ${prefix}.scf.in
	echo "   outdir          = './tmp'" >> ${prefix}.scf.in
	if [ "$pseudolib" == "PBE-GBRV" ]; then
		echo "   pseudo_dir      = '"$gbrvpath"'" >> ${prefix}.scf.in
	elif [ "$pseudolib" == "PBE-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbepawpath"'" >> ${prefix}.scf.in
	elif [ "$pseudolib" == "PBEsol-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbesolpawpath"'" >> ${prefix}.scf.in
	elif [ "$pseudolib" == "PBE-ONCV" ]; then
		echo "   pseudo_dir      = '"$oncvpath"'" >> ${prefix}.scf.in
	fi
	echo "   prefix          = '"${prefix}"'" >> ${prefix}.scf.in
	echo '   tstress         = .true.'  >> ${prefix}.scf.in
    echo '   tprnfor         = .true.' >> ${prefix}.scf.in
    echo "   verbosity       = 'low'" >> ${prefix}.scf.in
	if [ "$dipcorr" == "saw-like potential" ]; then
		echo "   tefield         = .true." >> ${prefix}.scf.in
		echo "   dipfield        = .true." >> ${prefix}.scf.in	
	fi	
    echo ' /' >> ${prefix}.scf.in
	
elif [ "$rtask" == "structural optimization(relax)" ];then
	echo ' &CONTROL' >> ${prefix}.relax.in
	echo "   calculation     = 'relax'" >> ${prefix}.relax.in
	echo "   restart_mode    = 'from_scratch'" >> ${prefix}.relax.in
	echo "   outdir          = './tmp'" >> ${prefix}.relax.in
	if [ "$pseudolib" == "PBE-GBRV" ]; then
		echo "   pseudo_dir      = '"$gbrvpath"'" >> ${prefix}.relax.in
	elif [ "$pseudolib" == "PBE-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbepawpath"'" >> ${prefix}.relax.in
	elif [ "$pseudolib" == "PBEsol-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbesolpawpath"'" >> ${prefix}.relax.in
	elif [ "$pseudolib" == "PBE-ONCV" ]; then
		echo "   pseudo_dir      = '"$oncvpath"'" >> ${prefix}.relax.in
	fi
	echo "   prefix          = '"${prefix}"'" >> ${prefix}.relax.in
    echo "   verbosity       = 'low'" >> ${prefix}.relax.in
	echo "   etot_conv_thr   = 1.D-4" >> ${prefix}.relax.in
	echo "   forc_conv_thr   = 1.D-3" >> ${prefix}.relax.in
	echo "   nstep           = 200" >> ${prefix}.relax.in
	if [ "$dipcorr" == "saw-like potential" ]; then
		echo "   tefield         = .true." >> ${prefix}.relax.in
		echo "   dipfield        = .true." >> ${prefix}.relax.in	
	fi
    echo ' /' >> ${prefix}.relax.in

elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
	echo ' &CONTROL' >> ${prefix}.vcrelax.in
	echo "   calculation     = 'vc-relax'" >> ${prefix}.vcrelax.in
	echo "   restart_mode    = 'from_scratch'" >> ${prefix}.vcrelax.in
	echo "   outdir          = './tmp'" >> ${prefix}.vcrelax.in
	if [ "$pseudolib" = "PBE-GBRV" ]; then
		echo "   pseudo_dir      = '"$gbrvpath"'" >> ${prefix}.vcrelax.in
	elif [ "$pseudolib" = "PBE-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbepawpath"'" >> ${prefix}.vcrelax.in
	elif [ "$pseudolib" = "PBEsol-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbesolpawpath"'" >> ${prefix}.vcrelax.in
	elif [ "$pseudolib" = "PBE-ONCV" ]; then
		echo "   pseudo_dir      = '"$oncvpath"'" >> ${prefix}.vcrelax.in
	fi
	echo "   prefix          = '"${prefix}"'" >> ${prefix}.vcrelax.in
    echo "   verbosity       = 'low'" >> ${prefix}.vcrelax.in
	echo "   etot_conv_thr   = 1.D-4" >> ${prefix}.vcrelax.in
	echo "   forc_conv_thr   = 1.D-3" >> ${prefix}.vcrelax.in
	echo "   nstep           = 200" >> ${prefix}.vcrelax.in
	if [ "$dipcorr" == "saw-like potential" ]; then
		echo "   tefield         = .true." >> ${prefix}.vcrelax.in
		echo "   dipfield        = .true." >> ${prefix}.vcrelax.in	
	fi	
    echo ' /' >> ${prefix}.vcrelax.in
elif [ "$rtask" == "bands" ];then
	echo ' &CONTROL' >> ${prefix}.bands.in
	echo "   calculation     = 'bands'" >> ${prefix}.bands.in
	echo "   restart_mode    = 'from_scratch'" >> ${prefix}.bands.in
	echo "   outdir          = './tmp'" >> ${prefix}.bands.in
	if [ "pseudolib" == "PBE-GBRV" ]; then
		echo "   pseudo_dir      = '"$gbrvpath"'" >> ${prefix}.bands.in
	elif [ "pseudolib" == "PBE-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbepawpath"'" >> ${prefix}.bands.in
	elif [ "pseudolib" == "PBEsol-PAW in pslibrary" ];then
		echo "   pseudo_dir      = '"$pbesolpawpath"'" >> ${prefix}.bands.in
	elif [ "pseudolib" == "PBE-ONCV" ]; then
		echo "   pseudo_dir      = '"$oncvpath"'" >> ${prefix}.bands.in
	fi
	echo "   prefix          = '"${prefix}"'" >> ${prefix}.bands.in
    echo "   verbosity       = 'low'" >> ${prefix}.bands.in
	if [ "$dipcorr" == "saw-like potential" ]; then
		echo "   tefield         = .true." >> ${prefix}.bands.in
		echo "   dipfield        = .true." >> ${prefix}.bands.in	
	fi	
    echo ' /' >> ${prefix}.bands.in
fi 
#&system section
if [ "$rtask" == "energy" ] || [ "$rtask" == "energy+force+stress" ]; then
	echo ' &SYSTEM' >> ${prefix}.scf.in
	echo "   ibrav           = 0" >> ${prefix}.scf.in
	echo "   nat             = $natm" >> ${prefix}.scf.in
	echo "   ntyp            = $ntyp" >> ${prefix}.scf.in
	echo "   ecutwfc         = 44.0" >> ${prefix}.scf.in
	echo "   ecutrho         = 300.0" >> ${prefix}.scf.in
	
	if [ "$nbnd" != "Default" ]; then
		echo "   nbnd            = $nbnd" >> ${prefix}.scf.in
	fi
	
	if [ "$systype" == "Insulator" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.scf.in
		echo "   degauss         = 0.001" >> ${prefix}.scf.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.scf.in
	elif [ "$systype" == "Semi-conductor" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.scf.in
		echo "   degauss         = 0.005" >> ${prefix}.scf.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.scf.in
	elif [ "$systype" == "Conductor" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.scf.in
		echo "   degauss         = 0.02" >> ${prefix}.scf.in
		echo "   smearing        = 'methfessel-paxton'" >> ${prefix}.scf.in
	elif [ "$systype" == "Molecule" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.scf.in
		echo "   degauss         = 0.001" >> ${prefix}.scf.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.scf.in
		echo "   assume_isolated = 'martyna-tuckerman'" >> ${prefix}.scf.in
	fi
	
	#check whether turn on LSDA
	for ((i=1;i<="${#atmtype[@]}";i++))
	do
		if [[ "${magarr[$i]}" > "0" ]]; then
		lsda=on
		fi
	done
	if [ "$lsda" == "on" ]; then 
		echo "   nspin           = 2" >> ${prefix}.scf.in
		for ((i=1;i<="${#atmtype[@]}";i++))
		do
			echo "   starting_magnetization($i) = "${magarr[$i]}"" >> ${prefix}.scf.in
		done
	fi
	
	#lda and hybird functionals setting
	if [ "$func" == "pz" ]; then 
		echo "   input_dft       = 'pz'" >> ${prefix}.scf.in 
	elif [ "$func" == "HSE06" ]; then
		echo "   input_dft       = 'hse'" >> ${prefix}.scf.in
		echo "   exxdiv_treatment = 'gygi-baldereschi'" >> ${prefix}.scf.in
		echo "   x_gamma_extrapolation = .true." >> ${prefix}.scf.in
		echo "   nqx1            = 1" >> ${prefix}.scf.in
		echo "   nqx2            = 1" >> ${prefix}.scf.in
		echo "   nqx3            = 1" >> ${prefix}.scf.in
	elif [ "$func" == "PBE0" ]; then
		echo "   input_dft       = 'pbe0'" >> ${prefix}.scf.in
		echo "   exxdiv_treatment = 'gygi-baldereschi'" >> ${prefix}.scf.in
		echo "   x_gamma_extrapolation = .true." >> ${prefix}.scf.in
		echo "   nqx1            = 1" >> ${prefix}.scf.in
		echo "   nqx2            = 1" >> ${prefix}.scf.in
		echo "   nqx3            = 1" >> ${prefix}.scf.in
	fi
	
	#hubbard U setting
	if [ "$(echo "$QEversion <= 7.0" |bc)" -eq "1" ]; then
		if [ "$dftu" == "DFT+U" ]; then
			echo "   lda_plus_u      = .true." >> ${prefix}.scf.in
			echo "   lda_plus_u_kind = 0" >> ${prefix}.scf.in
			for ((i=1;i<="${#atmtype[@]}";i++))
			do
				echo "   Hubbard_U($i)    = 0" >> ${prefix}.scf.in
			done
			echo "   U_projection_type = 'ortho-atomic'" >> ${prefix}.scf.in
		elif [ "$dftu" == "DFT+U+V" ]; then
			echo "   lda_plus_u      = .true." >> ${prefix}.scf.in
			echo "   lda_plus_u_kind = 2" >> ${prefix}.scf.in
			echo "   U_projection_type = 'ortho-atomic'" >> ${prefix}.scf.in
			echo "   Hubbard_parameters = 'file'" >> ${prefix}.scf.in
		fi
	fi
	
	#surface dipole correction
	if [ "$dipcorr" == "saw-like potential" ]; then
		echo "   edir            = 3" >> ${prefix}.scf.in
		echo "   emaxpos         = 0.55" >> ${prefix}.scf.in
		echo "   eopreg          = 0.06" >> ${prefix}.scf.in
		echo "   eamp            = 0.0005" >> ${prefix}.scf.in
	elif [ "$dipcorr" == "ESM-bc1 (recommend)" ]; then
		echo "   assume_isolated = 'esm'" >> ${prefix}.scf.in
		echo "   esm_bc          = 'bc1'" >> ${prefix}.scf.in
	fi	
	
	#dispersion correction
	if [ "$dispcorr" == "DFT-D2" ]; then
		echo "   vdw_corr        = 'grimme-d2'" >> ${prefix}.scf.in
	elif [ "$dispcorr" == "DFT-D3" ]; then
		echo "   vdw_corr        = 'grimme-d3'" >> ${prefix}.scf.in
		echo "   dftd3_version   = 3" >> ${prefix}.scf.in
	elif [ "$dispcorr" == "DFT-D3(BJ)" ]; then
		echo "   vdw_corr        = 'grimme-d3'" >> ${prefix}.scf.in
		echo "   dftd3_version   = 4" >> ${prefix}.scf.in
	fi
    echo ' /' >> ${prefix}.scf.in
		 
elif [ "$rtask" == "structural optimization(relax)" ];then
	echo ' &SYSTEM' >> ${prefix}.relax.in
	echo "   ibrav           = 0" >> ${prefix}.relax.in
	echo "   nat             = $natm" >> ${prefix}.relax.in
	echo "   ntyp            = $ntyp" >> ${prefix}.relax.in
	echo "   ecutwfc         = 44.0" >> ${prefix}.relax.in
	echo "   ecutrho         = 300.0" >> ${prefix}.relax.in
	
	if [ "$nbnd" != "Default" ]; then
		echo "   nbnd            = $nbnd" >> ${prefix}.relax.in
	fi
	
	if [ "$systype" == "Insulator" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.relax.in
		echo "   degauss         = 0.001" >> ${prefix}.relax.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.relax.in
	elif [ "$systype" == "Semi-conductor" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.relax.in
		echo "   degauss         = 0.005" >> ${prefix}.relax.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.relax.in
	elif [ "$systype" == "Conductor" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.relax.in
		echo "   degauss         = 0.02" >> ${prefix}.relax.in
		echo "   smearing        = 'methfessel-paxton'" >> ${prefix}.relax.in
	elif [ "$systype" == "Molecule" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.relax.in
		echo "   degauss         = 0.001" >> ${prefix}.relax.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.relax.in
		echo "   assume_isolated = 'martyna-tuckerman'" >> ${prefix}.relax.in
	fi
	
	#check whether turn on LSDA
	for ((i=1;i<="${#atmtype[@]}";i++))
	do
		if [[ "${magarr[$i]}" > "0" ]]; then
		lsda=on
		fi
	done
	if [ "$lsda" == "on" ]; then 
		echo "   nspin           = 2" >> ${prefix}.relax.in
		for ((i=1;i<="${#atmtype[@]}";i++))
		do
			echo "   starting_magnetization($i) = "${magarr[$i]}"" >> ${prefix}.relax.in
		done
	fi
	
	#lda and hybird functionals setting
	if [ "$func" == "pz" ]; then 
		echo "   input_dft       = 'pz'" >> ${prefix}.relax.in 
	elif [ "$func" == "HSE06" ]; then
		echo "   input_dft       = 'hse'" >> ${prefix}.relax.in
		echo "   exxdiv_treatment = 'gygi-baldereschi'" >> ${prefix}.relax.in
		echo "   x_gamma_extrapolation = .true." >> ${prefix}.relax.in
		echo "   nqx1            = 1" >> ${prefix}.relax.in
		echo "   nqx2            = 1" >> ${prefix}.relax.in
		echo "   nqx3            = 1" >> ${prefix}.relax.in
	elif [ "$func" == "PBE0" ]; then
		echo "   input_dft       = 'pbe0'" >> ${prefix}.relax.in
		echo "   exxdiv_treatment = 'gygi-baldereschi'" >> ${prefix}.relax.in
		echo "   x_gamma_extrapolation = .true." >> ${prefix}.relax.in
		echo "   nqx1            = 1" >> ${prefix}.relax.in
		echo "   nqx2            = 1" >> ${prefix}.relax.in
		echo "   nqx3            = 1" >> ${prefix}.relax.in
	fi
	
	#hubbard U setting
	if [ "$(echo "$QEversion <= 7.0" |bc)" -eq "1" ]; then
		if [ "$dftu" == "DFT+U" ]; then
			echo "   lda_plus_u      = .true." >> ${prefix}.relax.in
			echo "   lda_plus_u_kind = 0 " >> ${prefix}.relax.in
			for ((i=1;i<="${#atmtype[@]}";i++))
			do
				echo "   Hubbard_U($i)    = 0" >> ${prefix}.relax.in
			done
			echo "   U_projection_type = 'ortho-atomic'" >> ${prefix}.relax.in
		elif [ "$dftu" == "DFT+U+V" ]; then
			echo "   lda_plus_u      = .true." >> ${prefix}.relax.in
			echo "   lda_plus_u_kind = 2" >> ${prefix}.relax.in
			echo "   U_projection_type = 'ortho-atomic'" >> ${prefix}.relax.in
			echo "   Hubbard_parameters = 'file'" >> ${prefix}.relax.in
		fi
	fi
	
	#surface dipole correction
	if [ "$dipcorr" == "saw-like potential" ]; then
		echo "   edir            = 3" >> ${prefix}.relax.in
		echo "   emaxpos         = 0.55" >> ${prefix}.relax.in
		echo "   eopreg          = 0.06" >> ${prefix}.relax.in
		echo "   eamp            = 0.0005" >> ${prefix}.relax.in
	elif [ "$dipcorr" == "ESM-bc1 (recommend)" ]; then
		echo "   assume_isolated = 'esm'" >> ${prefix}.relax.in
		echo "   esm_bc          = 'bc1'" >> ${prefix}.relax.in
	fi	
	
	#dispersion correction
	if [ "$dispcorr" == "DFT-D2" ]; then
		echo "   vdw_corr        = 'grimme-d2'" >> ${prefix}.relax.in
	elif [ "$dispcorr" == "DFT-D3" ]; then
		echo "   vdw_corr        = 'grimme-d3'" >> ${prefix}.relax.in
		echo "   dftd3_version   = 3" >> ${prefix}.relax.in
	elif [ "$dispcorr" == "DFT-D3(BJ)" ]; then
		echo "   vdw_corr        = 'grimme-d3'" >> ${prefix}.relax.in
		echo "   dftd3_version   = 4" >> ${prefix}.relax.in
	fi
    echo ' /' >> ${prefix}.relax.in
	
elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
	echo ' &SYSTEM' >> ${prefix}.vcrelax.in
	echo "   ibrav           = 0" >> ${prefix}.vcrelax.in
	echo "   nat             = $natm" >> ${prefix}.vcrelax.in
	echo "   ntyp            = $ntyp" >> ${prefix}.vcrelax.in
	echo "   ecutwfc         = 44.0" >> ${prefix}.vcrelax.in
	echo "   ecutrho         = 300.0" >> ${prefix}.vcrelax.in
	
	if [ "$nbnd" != "Default" ]; then
		echo "   nbnd            = $nbnd" >> ${prefix}.vcrelax.in
	fi
	
	if [ "$systype" == "Insulator" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.vcrelax.in
		echo "   degauss         = 0.001" >> ${prefix}.vcrelax.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.vcrelax.in
	elif [ "$systype" == "Semi-conductor" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.vcrelax.in
		echo "   degauss         = 0.005" >> ${prefix}.vcrelax.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.vcrelax.in
	elif [ "$systype" == "Conductor" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.vcrelax.in
		echo "   degauss         = 0.02" >> ${prefix}.vcrelax.in
		echo "   smearing        = 'methfessel-paxton'" >> ${prefix}.vcrelax.in	
	fi
	
	#check whether turn on LSDA
	for ((i=1;i<="${#atmtype[@]}";i++))
	do
		if [[ "${magarr[$i]}" > "0" ]]; then
		lsda=on
		fi
	done
	if [ "$lsda" == "on" ]; then 
		echo "   nspin           = 2" >> ${prefix}.vcrelax.in
		for ((i=1;i<="${#atmtype[@]}";i++))
		do
			echo "   starting_magnetization($i) = "${magarr[$i]}"" >> ${prefix}.vcrelax.in
		done
	fi
	
	#lda and hybird functionals setting
	if [ "$func" == "pz" ]; then 
		echo "   input_dft       = 'pz'" >> ${prefix}.vcrelax.in 
	elif [ "$func" == "HSE06" ]; then
		echo "   input_dft       = 'hse'" >> ${prefix}.vcrelax.in
		echo "   exxdiv_treatment = 'gygi-baldereschi'" >> ${prefix}.vcrelax.in
		echo "   x_gamma_extrapolation = .true." >> ${prefix}.vcrelax.in
		echo "   nqx1            = 1" >> ${prefix}.vcrelax.in
		echo "   nqx2            = 1" >> ${prefix}.vcrelax.in
		echo "   nqx3            = 1" >> ${prefix}.vcrelax.in
	elif [ "$func" == "PBE0" ]; then
		echo "   input_dft       = 'pbe0'" >> ${prefix}.vcrelax.in
		echo "   exxdiv_treatment = 'gygi-baldereschi'" >> ${prefix}.vcrelax.in
		echo "   x_gamma_extrapolation = .true." >> ${prefix}.vcrelax.in
		echo "   nqx1            = 1" >> ${prefix}.vcrelax.in
		echo "   nqx2            = 1" >> ${prefix}.vcrelax.in
		echo "   nqx3            = 1" >> ${prefix}.vcrelax.in
	fi
	
	#hubbard U setting
	if [ "$(echo "$QEversion <= 7.0" |bc)" -eq "1" ]; then
		if [ "$dftu" == "DFT+U" ]; then
			echo "   lda_plus_u      = .true." >> ${prefix}.vcrelax.in
			echo "   lda_plus_u_kind = 0 " >> ${prefix}.vcrelax.in
			for ((i=1;i<="${#atmtype[@]}";i++))
			do
				echo "   Hubbard_U($i)    = 0" >> ${prefix}.vcrelax.in
			done
			echo "   U_projection_type = 'ortho-atomic'" >> ${prefix}.vcrelax.in
		elif [ "$dftu" == "DFT+U+V" ]; then
			echo "   lda_plus_u      = .true." >> ${prefix}.vcrelax.in
			echo "   lda_plus_u_kind = 2 " >> ${prefix}.vcrelax.in
			echo "   U_projection_type = 'ortho-atomic'" >> ${prefix}.vcrelax.in
			echo "   Hubbard_parameters = 'file'" >> ${prefix}.vcrelax.in
		fi
	fi
	
	#surface dipole correction
	if [ "$dipcorr" == "saw-like potential" ]; then
		echo "   edir            = 3" >> ${prefix}.vcrelax.in
		echo "   emaxpos         = 0.55" >> ${prefix}.vcrelax.in
		echo "   eopreg          = 0.06" >> ${prefix}.vcrelax.in
		echo "   eamp            = 0.0005" >> ${prefix}.vcrelax.in
	elif [ "$dipcorr" == "ESM-bc1 (recommend)" ]; then
		echo "   assume_isolated = 'esm'" >> ${prefix}.vcrelax.in
		echo "   esm_bc          = 'bc1'" >> ${prefix}.vcrelax.in
	fi	
	
	#dispersion correction
	if [ "$dispcorr" == "DFT-D2" ]; then
		echo "   vdw_corr        = 'grimme-d2'" >> ${prefix}.vcrelax.in
	elif [ "$dispcorr" == "DFT-D3" ]; then
		echo "   vdw_corr        = 'grimme-d3'" >> ${prefix}.vcrelax.in
		echo "   dftd3_version   = 3" >> ${prefix}.vcrelax.in
	elif [ "$dispcorr" == "DFT-D3(BJ)" ]; then
		echo "   vdw_corr        = 'grimme-d3'" >> ${prefix}.vcrelax.in
		echo "   dftd3_version   = 4" >> ${prefix}.vcrelax.in
	fi
    echo ' /' >> ${prefix}.vcrelax.in
	
elif [ "$rtask" == "bands" ];then
	echo ' &SYSTEM' >> ${prefix}.bands.in
	echo "   ibrav           = 0" >> ${prefix}.bands.in
	echo "   nat             = $natm" >> ${prefix}.bands.in
	echo "   ntyp            = $ntyp" >> ${prefix}.bands.in
	echo "   ecutwfc         = 44.0" >> ${prefix}.bands.in
	echo "   ecutrho         = 300.0" >> ${prefix}.bands.in
	
	if [ "$nbnd" != "Default" ]; then
		echo "   nbnd            = $nbnd" >> ${prefix}.bands.in
	fi
	
	if [ "$systype" == "Insulator" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.bands.in
		echo "   degauss         = 0.001" >> ${prefix}.bands.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.bands.in
	elif [ "$systype" == "Semi-conductor" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.bands.in
		echo "   degauss         = 0.005" >> ${prefix}.bands.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.bands.in
	elif [ "$systype" == "Conductor" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.bands.in
		echo "   degauss         = 0.02" >> ${prefix}.bands.in
		echo "   smearing        = 'methfessel-paxton'" >> ${prefix}.bands.in
	elif [ "$systype" == "Molecule" ]; then
		echo "   occupations     = 'smearing'" >> ${prefix}.bands.in
		echo "   degauss         = 0.001" >> ${prefix}.bands.in
		echo "   smearing        = 'gaussian'" >> ${prefix}.bands.in
	fi
	
	#check whether turn on LSDA
	for ((i=1;i<="${#atmtype[@]}";i++))
	do
		if [[ "${magarr[$i]}" > "0" ]]; then
		lsda=on
		fi
	done
	if [ "$lsda" == "on" ]; then 
		echo "   nspin           = 2" >> ${prefix}.bands.in
		for ((i=1;i<="${#atmtype[@]}";i++))
		do
			echo "   starting_magnetization($i) = "${magarr[$i]}"" >> ${prefix}.bands.in
		done
	fi
	
	#lda and hybird functionals setting
	if [ "$func" == "pz" ]; then 
		echo "   input_dft       = 'pz'" >> ${prefix}.bands.in 
	elif [ "$func" == "HSE06" ]; then
		echo "   input_dft       = 'hse'" >> ${prefix}.bands.in
		echo "   exxdiv_treatment = 'gygi-baldereschi'" >> ${prefix}.bands.in
		echo "   x_gamma_extrapolation = .true." >> ${prefix}.bands.in
		echo "   nqx1            = 1" >> ${prefix}.bands.in
		echo "   nqx2            = 1" >> ${prefix}.bands.in
		echo "   nqx3            = 1" >> ${prefix}.bands.in
	elif [ "$func" == "PBE0" ]; then
		echo "   input_dft       = 'pbe0'" >> ${prefix}.bands.in
		echo "   exxdiv_treatment = 'gygi-baldereschi'" >> ${prefix}.bands.in
		echo "   x_gamma_extrapolation = .true." >> ${prefix}.bands.in
		echo "   nqx1            = 1" >> ${prefix}.bands.in
		echo "   nqx2            = 1" >> ${prefix}.bands.in
		echo "   nqx3            = 1" >> ${prefix}.bands.in
	fi
	
	#hubbard U setting
	if [ "$(echo "$QEversion <= 7.0" |bc)" -eq "1" ]; then
		if [ "$dftu" == "DFT+U" ]; then
			echo "   lda_plus_u      = .true." >> ${prefix}.bands.in
			echo "   lda_plus_u_kind = 0 " >> ${prefix}.bands.in
			for ((i=1;i<="${#atmtype[@]}";i++))
			do
				echo "   Hubbard_U($i)    = 0" >> ${prefix}.bands.in
			done
			echo "   U_projection_type = 'ortho-atomic'" >> ${prefix}.bands.in
		elif [ "$dftu" == "DFT+U+V" ]; then
			echo "   lda_plus_u      = .true." >> ${prefix}.bands.in
			echo "   lda_plus_u_kind = 2 " >> ${prefix}.bands.in
			echo "   U_projection_type = 'ortho-atomic'" >> ${prefix}.bands.in
			echo "   Hubbard_parameters = 'file'" >> ${prefix}.bands.in
		fi
	fi
	
	#surface dipole correction
	if [ "$dipcorr" == "saw-like potential" ]; then
		echo "   edir            = 3" >> ${prefix}.bands.in
		echo "   emaxpos         = 0.55" >> ${prefix}.bands.in
		echo "   eopreg          = 0.06" >> ${prefix}.bands.in
		echo "   eamp            = 0.0005" >> ${prefix}.bands.in
	elif [ "$dipcorr" == "ESM-bc1 (recommend)" ]; then
		echo "   assume_isolated = 'esm'" >> ${prefix}.bands.in
		echo "   esm_bc          = 'bc1'" >> ${prefix}.bands.in
	fi	
	
	#dispersion correction
	if [ "$dispcorr" == "DFT-D2" ]; then
		echo "   vdw_corr        = 'grimme-d2'" >> ${prefix}.bands.in
	elif [ "$dispcorr" == "DFT-D3" ]; then
		echo "   vdw_corr        = 'grimme-d3'" >> ${prefix}.bands.in
		echo "   dftd3_version   = 3" >> ${prefix}.bands.in
	elif [ "$dispcorr" == "DFT-D3(BJ)" ]; then
		echo "   vdw_corr        = 'grimme-d3'" >> ${prefix}.bands.in
		echo "   dftd3_version   = 4" >> ${prefix}.bands.in
	fi
    echo ' /' >> ${prefix}.bands.in
fi 

#electrons section
if [ "$rtask" == "energy" ] || [ "$rtask" == "energy+force+stress" ]; then
	echo ' &ELECTRONS' >> ${prefix}.scf.in
	echo "   electron_maxstep = 128" >> ${prefix}.scf.in
	echo "   conv_thr        = 1.D-6" >> ${prefix}.scf.in
	echo "   mixing_mode     = 'plain'" >> ${prefix}.scf.in
	echo "   mixing_beta     = 0.7" >> ${prefix}.scf.in
	echo "   mixing_ndim     = 8" >> ${prefix}.scf.in
	echo "   diagonalization = 'david'" >> ${prefix}.scf.in
	echo ' /' >> ${prefix}.scf.in
elif [ "$rtask" == "structural optimization(relax)" ];then
	echo ' &ELECTRONS' >> ${prefix}.relax.in
	echo "   electron_maxstep = 128" >> ${prefix}.relax.in
	echo "   conv_thr        = 1.D-6" >> ${prefix}.relax.in
	echo "   mixing_mode     = 'plain'" >> ${prefix}.relax.in
	echo "   mixing_beta     = 0.7" >> ${prefix}.relax.in
	echo "   mixing_ndim     = 8" >> ${prefix}.relax.in
	echo "   diagonalization = 'david'" >> ${prefix}.relax.in
	echo ' /' >> ${prefix}.relax.in
elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
	echo ' &ELECTRONS' >> ${prefix}.vcrelax.in
	echo "   electron_maxstep = 128" >> ${prefix}.vcrelax.in
	echo "   conv_thr        = 1.D-6" >> ${prefix}.vcrelax.in
	echo "   mixing_mode     = 'plain'" >> ${prefix}.vcrelax.in
	echo "   mixing_beta     = 0.7" >> ${prefix}.vcrelax.in
	echo "   mixing_ndim     = 8" >> ${prefix}.vcrelax.in
	echo "   diagonalization = 'david'" >> ${prefix}.vcrelax.in
	echo ' /' >> ${prefix}.vcrelax.in
elif [ "$rtask" == "bands" ];then
	echo ' &ELECTRONS' >> ${prefix}.bands.in
	echo "   electron_maxstep = 128" >> ${prefix}.bands.in
	echo "   conv_thr        = 1.D-6" >> ${prefix}.bands.in
	echo "   mixing_mode     = 'plain'" >> ${prefix}.bands.in
	echo "   mixing_beta     = 0.7" >> ${prefix}.bands.in
	echo "   mixing_ndim     = 8" >> ${prefix}.bands.in
	echo "   diagonalization = 'david'" >> ${prefix}.bands.in
	echo ' /' >> ${prefix}.bands.in
fi

#ions section
if [ "$rtask" == "structural optimization(relax)" ]; then
	echo ' &IONS' >> ${prefix}.relax.in
	echo "   ion_dynamics    = 'bfgs'"  >> ${prefix}.relax.in
	echo ' /'  >> ${prefix}.relax.in
elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
	echo ' &IONS' >> ${prefix}.vcrelax.in
	echo "   ion_dynamics    = 'bfgs'"  >> ${prefix}.vcrelax.in
	echo ' /'  >> ${prefix}.vcrelax.in
fi

#cell section
if [ "$rtask" == "cell optimization(vc-relax)" ]; then
	echo ' &CELL' >> ${prefix}.vcrelax.in
	echo "   cell_dynamics   = 'bfgs'" >> ${prefix}.vcrelax.in
	echo "   press           = 0" >> ${prefix}.vcrelax.in
	echo "   press_conv_thr  = 0.5" >> ${prefix}.vcrelax.in
	echo ' /' >> ${prefix}.vcrelax.in
elif [ "$rtask" == "cell optimization for 2D materials" ]; then
	echo ' &CELL' >> ${prefix}.vcrelax.in
	echo "   cell_dynamics   = 'bfgs'" >> ${prefix}.vcrelax.in
	echo "   press           = 0" >> ${prefix}.vcrelax.in
	echo "   press_conv_thr  = 0.5" >> ${prefix}.vcrelax.in
	echo "   cell_dofree     = '2Dxy'" >> ${prefix}.vcrelax.in
	echo ' /' >> ${prefix}.vcrelax.in
fi
 
#cell informations
if [ "$rtask" == "energy" ] || [ "$rtask" == "energy+force+stress" ]; then
	echo " CELL_PARAMETERS angstrom" >> ${prefix}.scf.in
	for i in $(seq ${begcellpos} ${endcellpos}) 
	do
		sed -n "${i}p" ${prefix}_QE.tmp |awk '{printf "     %.9f    %.9f    %.9f\n",$1,$2,$3}' >> ${prefix}.scf.in
	done
elif [ "$rtask" == "structural optimization(relax)" ];then
	echo " CELL_PARAMETERS angstrom" >> ${prefix}.relax.in
	for i in $(seq ${begcellpos} ${endcellpos}) 
	do
		sed -n "${i}p" ${prefix}_QE.tmp |awk '{printf "     %.9f    %.9f    %.9f\n",$1,$2,$3}' >> ${prefix}.relax.in
	done
elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
	echo " CELL_PARAMETERS angstrom" >> ${prefix}.vcrelax.in
	for i in $(seq ${begcellpos} ${endcellpos}) 
	do
		sed -n "${i}p" ${prefix}_QE.tmp |awk '{printf "     %.9f    %.9f    %.9f\n",$1,$2,$3}' >> ${prefix}.vcrelax.in
	done
elif [ "$rtask" == "bands" ];then
	echo " CELL_PARAMETERS angstrom" >> ${prefix}.bands.in
	for i in $(seq ${begcellpos} ${endcellpos}) 
	do
		sed -n "${i}p" ${prefix}_QE.tmp |awk '{printf "     %.9f    %.9f    %.9f\n",$1,$2,$3}' >> ${prefix}.bands.in
	done
fi

#atomic species
if [ "$rtask" == "energy" ] || [ "$rtask" == "energy+force+stress" ]; then
	echo " ATOMIC_SPECIES" >> ${prefix}.scf.in
	for ((i=1;i<=$ntyp;i++))
	do
		for ((j=1;j<=86;j++))
		do
			if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
				atmindex=$j
			fi
		done
		if [ "$pseudolib" == "PBE-GBRV" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${gbrvlib[$atmindex]}"" >> ${prefix}.scf.in
		elif [ "$pseudolib" == "PBE-PAW in pslibrary" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${pawlib[$atmindex]}"" >> ${prefix}.scf.in
		elif [ "$pseudolib" == "PBEsol-PAW in pslibrary" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${pbesollib[$atmindex]}"" >> ${prefix}.scf.in
		elif [ "$pseudolib" == "PBE-ONCV" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${oncvlib[$atmindex]}"" >> ${prefix}.scf.in
		fi
	done
	
elif [ "$rtask" == "structural optimization(relax)" ];then
	echo " ATOMIC_SPECIES" >> ${prefix}.relax.in
	for ((i=1;i<=$ntyp;i++))
	do
		for ((j=1;j<=86;j++))
		do
			if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
				atmindex=$j
			fi
		done
		if [ "$pseudolib" == "PBE-GBRV" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${gbrvlib[$atmindex]}"" >> ${prefix}.relax.in
		elif [ "$pseudolib" == "PBE-PAW in pslibrary" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${pawlib[$atmindex]}"" >> ${prefix}.relax.in
		elif [ "$pseudolib" == "PBEsol-PAW in pslibrary" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${pbesollib[$atmindex]}"" >> ${prefix}.relax.in
		elif [ "$pseudolib" == "PBE-ONCV" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${oncvlib[$atmindex]}"" >> ${prefix}.relax.in
		fi
	done
	
elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
	echo " ATOMIC_SPECIES" >> ${prefix}.vcrelax.in
	for ((i=1;i<=$ntyp;i++))
	do
		for ((j=1;j<=86;j++))
		do
			if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
				atmindex=$j
			fi
		done
		if [ "$pseudolib" == "PBE-GBRV" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${gbrvlib[$atmindex]}"" >> ${prefix}.vcrelax.in
		elif [ "$pseudolib" == "PBE-PAW in pslibrary" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${pawlib[$atmindex]}"" >> ${prefix}.vcrelax.in
		elif [ "$pseudolib" == "PBEsol-PAW in pslibrary" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${pbesollib[$atmindex]}"" >> ${prefix}.vcrelax.in
		elif [ "$pseudolib" == "PBE-ONCV" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${oncvlib[$atmindex]}"" >> ${prefix}.vcrelax.in
		fi
	done
	
elif [ "$rtask" == "bands" ];then
	echo " ATOMIC_SPECIES" >> ${prefix}.bands.in
	for ((i=1;i<=$ntyp;i++))
	do
		for ((j=1;j<=86;j++))
		do
			if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
				atmindex=$j
			fi
		done
		if [ "$pseudolib" == "PBE-GBRV" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${gbrvlib[$atmindex]}"" >> ${prefix}.bands.in
		elif [ "$pseudolib" == "PBE-PAW in pslibrary" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${pawlib[$atmindex]}"" >> ${prefix}.bands.in
		elif [ "$pseudolib" == "PBEsol-PAW in pslibrary" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${pbesollib[$atmindex]}"" >> ${prefix}.bands.in
		elif [ "$pseudolib" == "PBE-ONCV" ]; then
			echo -e "   "${atmtype[$i]}" \t"${atmmass[$atmindex]}" \t"${oncvlib[$atmindex]}"" >> ${prefix}.bands.in
		fi
	done
fi

#atoms coordination
if [ "$rtask" == "energy" ] || [ "$rtask" == "energy+force+stress" ]; then
	echo " ATOMIC_POSITIONS angstrom" >> ${prefix}.scf.in
	for i in $(seq ${begatmpos} ${endatmpos})
	do
		sed -n "${i}p" ${prefix}_QE.tmp |awk '{printf "   %2s      %.9f    %.9f    %.9f\n",$1,$2,$3,$4}' >> ${prefix}.scf.in
	done
elif [ "$rtask" == "structural optimization(relax)" ];then
	echo " ATOMIC_POSITIONS angstrom" >> ${prefix}.relax.in
	for i in $(seq ${begatmpos} ${endatmpos})
	do
		sed -n "${i}p" ${prefix}_QE.tmp |awk '{printf "   %2s      %.9f    %.9f    %.9f\n",$1,$2,$3,$4}' >> ${prefix}.relax.in
	done
elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
	echo " ATOMIC_POSITIONS angstrom" >> ${prefix}.vcrelax.in
	for i in $(seq ${begatmpos} ${endatmpos})
	do
		sed -n "${i}p" ${prefix}_QE.tmp |awk '{printf "   %2s      %.9f    %.9f    %.9f\n",$1,$2,$3,$4}' >> ${prefix}.vcrelax.in
	done
elif [ "$rtask" == "bands" ];then
	echo " ATOMIC_POSITIONS angstrom" >> ${prefix}.bands.in
	for i in $(seq ${begatmpos} ${endatmpos})
	do
		sed -n "${i}p" ${prefix}_QE.tmp |awk '{printf "   %2s      %.9f    %.9f    %.9f\n",$1,$2,$3,$4}' >> ${prefix}.bands.in
	done
fi

#k-points
if [ "$rtask" == "energy" ] || [ "$rtask" == "energy+force+stress" ]; then
	if [ "$kpmesh" != "gamma" ]; then
		echo " K_POINTS automatic" >> ${prefix}.scf.in
		kptmp=`echo $kpmesh |sed 's/\*/\ /g'`
		echo " $kptmp 0 0 0" >> ${prefix}.scf.in
	else
		echo " K_POINTS gamma" >> ${prefix}.scf.in
	fi
	
elif [ "$rtask" == "structural optimization(relax)" ];then
	if [ "$kpmesh" != "gamma" ]; then
		echo " K_POINTS automatic" >> ${prefix}.relax.in
		kptmp=`echo $kpmesh |sed 's/\*/\ /g'`
		echo " $kptmp 0 0 0" >> ${prefix}.relax.in
	else
		echo " K_POINTS gamma" >> ${prefix}.relax.in
	fi
	
elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
	if [ "$kpmesh" != "gamma" ]; then
		echo " K_POINTS automatic" >> ${prefix}.vcrelax.in
		kptmp=`echo $kpmesh |sed 's/\*/\ /g'`
		echo " $kptmp 0 0 0" >> ${prefix}.vcrelax.in
	else
		echo " K_POINTS gamma" >> ${prefix}.vcrelax.in
	fi
	
elif [ "$rtask" == "bands" ];then
	echo " K_POINTS crystal" >> ${prefix}.bands.in
	echo " Input high symmetry points path, which can be generated by 'SeeK-path' or 'xcrysden'!" >> ${prefix}.bands.in
fi

#hubbard U setting 
if [ "$(echo "$QEversion > 7.0" |bc)" -eq "1" ] && [ "$dftu" == "DFT+U" ]; then
	if [ "$rtask" == "energy" ] || [ "$rtask" == "energy+force+stress" ]; then
		echo ' HUBBARD {ortho-atomic}' >> ${prefix}.scf.in
		echo " element element-3d u_value" >> ${prefix}.scf.in
	elif [ "$rtask" == "structural optimization(relax)" ];then
		echo ' HUBBARD {ortho-atomic}' >> ${prefix}.relax.in
		echo " element element-3d u_value" >> ${prefix}.relax.in
	elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
		echo ' HUBBARD {ortho-atomic}' >> ${prefix}.vcrelax.in
		echo " element element-3d u_value" >> ${prefix}.vcrelax.in
	elif [ "$rtask" == "bands" ];then
		echo ' HUBBARD {ortho-atomic}' >> ${prefix}.bands.in
		echo " element element-3d u_value" >> ${prefix}.bands.in
	fi
elif [ "$(echo "$QEversion > 7.0" |bc)" -eq "1" ] && [ "$dftu" == "DFT+U+V" ]; then
	if [ "$rtask" == "energy" ] || [ "$rtask" == "energy+force+stress" ]; then
		echo ' HUBBARD {ortho-atomic}' >> ${prefix}.scf.in
		echo " V element1-3d element1-3d 1 1 v_value #This is actualy U value, a equivalent syntax" >> ${prefix}.scf.in
		echo " V element1-3d element2-2p 1 2 v_value" >> ${prefix}.scf.in
	elif [ "$rtask" == "structural optimization(relax)" ];then
		echo ' HUBBARD {ortho-atomic}' >> ${prefix}.relax.in
		echo " V element1-3d element1-3d 1 1 v_value #This is actualy U value, a equivalent syntax" >> ${prefix}.relax.in
		echo " V element1-3d element2-2p 1 2 v_value" >> ${prefix}.relax.in
	elif [ "$rtask" == "cell optimization(vc-relax)" ] || [ "$rtask" == "cell optimization for 2D materials" ]; then
		echo ' HUBBARD {ortho-atomic}' >> ${prefix}.vcrelax.in
		echo " V element1-3d element1-3d 1 1 v_value #This is actualy U value, a equivalent syntax" >> ${prefix}.vcrelax.in
		echo " V element1-3d element2-2p 1 2 v_value" >> ${prefix}.vcrelax.in
	elif [ "$rtask" == "bands" ];then
		echo ' HUBBARD {ortho-atomic}' >> ${prefix}.bands.in
		echo " V element1-3d element1-3d 1 1 v_value #This is actualy U value, a equivalent syntax" >> ${prefix}.bands.in
		echo " V element1-3d element2-2p 1 2 v_value" >> ${prefix}.bands.in
	fi	
fi
}

#Creat item sections for pwin menu.
while [[ "$pwin_arg" != "11" ]]; do
	case $pwin_arg in 
		"0") 
			echo 'The input file has been generated in current folder!'
			genpwinfile
			rm -f ${prefix}_QE.tmp
			break
			;;
		"1")
			PS3=''
			systype_array=("Insulator" "Semi-conductor" "Conductor" "Molecule")
			select isystype in "${systype_array[@]}"; do
				case $isystype in
					"Insulator") 
						systype="Insulator"
						pwin_menu
						break
						;;
					"Semi-conductor")
						systype="Semi-conductor"
						pwin_menu
						break
						;;
					"Conductor")
						systype="Conductor"
						pwin_menu
						break
						;;
					"Molecule")
						systype="Molecule"
						pwin_menu
						break
						;;
					"*")
						;;
				esac
			done
			;;
		"2")
			PS3=''
			rtask_array=("energy" "energy+force+stress" "structural optimization(relax)" "cell optimization(vc-relax)" "cell optimization for 2D materials" "bands")
			select irtask in "${rtask_array[@]}"; do
				case $irtask in
					"energy")
						rtask='energy'
						pwin_menu
						break
						;;
					"energy+force+stress")
						rtask='energy+force+stress'
						pwin_menu
						break
						;;
					"structural optimization(relax)")
						rtask='structural optimization(relax)'
						pwin_menu
						break
						;;
					"cell optimization(vc-relax)")
						rtask='cell optimization(vc-relax)'
						pwin_menu
						break
						;;
					"cell optimization for 2D materials")
						rtask='cell optimization for 2D materials'
						pwin_menu
						break
						;;
					"bands")
						rtask='bands'
						pwin_menu
						break
						;;
					"*")
						;;
				esac
			done
			;;
		"3")
			PS3=''
			func_array=("PBE" "PBE0" "PBEsol" "HSE06" "pz")
			select ifunc in "${func_array[@]}"; do
			case $ifunc in
				"PBE")
					func='PBE'
					pwin_menu
					break
					;;
				"PBE0")
					func='PBE0'
					pwin_menu
					break
					;;
				"PBEsol")
					func='PBEsol'
					pwin_menu
					break
					;;
				"HSE06")
					func='HSE06'
					pwin_menu
					break
					;;
				"pz")
					func='pz'
					pwin_menu
					break
					;;
				"*")
					;;
				esac
			done
			;;
		"4")
			PS3=""
			dispcorr_array=("None" "DFT-D2" "DFT-D3" "DFT-D3(BJ)")
			echo "Note: DFT-D3 and DFT-D3(BJ) are not compatible with phonon, while DFT-D2 is supported!"
			select idispcorr in "${dispcorr_array[@]}"; do
				case $idispcorr in
				"None")
					dispcorr='None'
					pwin_menu
					break
					;;
				"DFT-D2")
					dispcorr='DFT-D2'
					pwin_menu
					break
					;;
				"DFT-D3")
					dispcorr='DFT-D3'
					pwin_menu
					break
					;;
				"DFT-D3(BJ)")
					dispcorr='DFT-D3(BJ)'
					pwin_menu
					break
					;;
				"*")
					;;
				esac
			done
			;;
		"5")
			PS3=''
			dipcorr_array=("None" "saw-like potential" "ESM-bc1 (recommend)")
			select idipcorr in "${dipcorr_array[@]}"; do
				case $idipcorr in 
					"None")
						dipcorr='None'
						pwin_menu
						break
						;;
					"saw-like potential")
						dipcorr='saw-like potential'
						pwin_menu
						break
						;;
					"ESM-bc1 (recommend)")
						dipcorr='ESM-bc1 (recommend)'
						pwin_menu
						break
						;;
					"*")
					;;
				esac
			done
			;;
		"6")
			echo ' Define Magnetization:'
			for ((i=1;i<="${#atmtype[@]}";i++))
			do
				magarr[$i]=0
				echo -e " type$i: "${atmtype[$i]}" \tmagnetization:"${magarr[$i]}" \tNatms:"${Natmtype[$i]}""
			done
			echo
			echo ' * Magnetization is defined as (nalpha-nbeta)/(nalpha+nbeta), ranges from -1 to 1.'
			echo ' * If you want to define antiferromagnetism state, two groups of same type atoms should be setted with opposite magnetization of -n and n, respectively.' 
			echo ' * Input "q" to exit.'
			echo ' Which type of atoms do you want to define magnetization:'
			read iatmtype
			while [ "$iatmtype" != "q" ]; do
				if [[ "$iatmtype" > "${#atmtype[@]}" || "$iatmtype" =~ ^[a-z]+$ ]]; then
					read iatmtype
				fi
				echo ' Input magnetization, e.g. 0.5'
				read magval
				magarr[$iatmtype]=$magval
				echo
				for ((i=1;i<="${#atmtype[@]}";i++))
				do
					echo -e " type$i: "${atmtype[$i]}" \tmagnetization:"${magarr[$i]}" \tNatms:"${Natmtype[$i]}""
				done
				echo ' Which type of atoms do you want to define magnetization:'
				read iatmtype
			done
			if [ "$iatmtype" = "q" ]; then
				pwin_menu
			fi
			;;
		"7")
			PS3=''
			dftu_array=("No" "DFT+U" "DFT+U+V")
			echo 'Note: DFT+U is not implemented for gamma point'
			select idftu in "${dftu_array[@]}"; do
				case $idftu in
					"No")
						dftu='No'
						pwin_menu
						break
						;;
					"DFT+U")
						dftu='DFT+U'
						echo ' Current effective U parameters are arbitary, please revise it manually!'
						echo
						pwin_menu
						break
						;;
					"DFT+U+V")
						dftu='DFT+U+V'
						echo ' Current U and V values are arbitary, please revise it manually!'
						echo 
						pwin_menu
						break
						;;
					"*")
					;;
				esac
			done
			;;
		"8")
			echo ' Input k-points mesh in three directions, e.g. 2,2,1'
			echo " You can also directly input 'gamma', then Brillouin zone sampling will be at gamma point, typically is used for pre-optimization."
			read kpmesh
			while [ -z "$kpmesh" ]; do
					echo
					echo '  Reinput k-points mesh in three directions, e.g. 2,2,1'
					read kpmesh
			done
			
			if [ "$kpmesh" = "gamma" ]; 
			then
				kpmesh='gamma'
			else 
				kpmesh=`echo $kpmesh|awk -F , '{printf "%d*%d*%d\n",$1,$2,$3}'`
			fi
			echo 'Done!'
			pwin_menu
			;;
		"9")
			echo ' Input the number of electronic states to be solved, e.g. 50'
			echo ' If you input nothing, default numbers in pw.x code are used, i.e. 50% valence electrons for insulator'
			read nbnd
			if [ -z "$nbnd" ]; then nbnd='Default'; fi
			echo 'Done!'
			pwin_menu
			;;
		"10")
			PS3=''
			pseudolib_array=("PBE-GBRV" "PBE-PAW in pslibrary" "PBEsol-PAW in pslibrary" "PBE-ONCV")
			select ipseudolib in "${pseudolib_array[@]}"; do
				case $ipseudolib in
					"PBE-GBRV")
						pseudolib='PBE-GBRV'
						pwin_menu
						break
						;;
					"PBE-PAW in pslibrary")
						pseudolib='PBE-PAW in pslibrary'
						pwin_menu
						break
						;;
					"PBEsol-PAW in pslibrary")
						pseudolib='PBEsol-PAW in pslibrary'
						pwin_menu
						break
						;;
					"PBE-ONCV")
						pseudolib='PBE-ONCV'
						pwin_menu
						break
						;;
					"*")
						;;
				esac
			done
			;;
	esac
	unset pwin_arg
	read pwin_arg
	while ! echo "${pwin_choice[@]}" | grep -wq "$pwin_arg" 
	do
	  echo "Please reinput function number..."
	  read pwin_arg
	done
done
if [[ "$pwin_arg" == "11" ]]; then 
	rm -f ${prefix}_QE.tmp
	main_menu
	rmainfunc
fi
}

#--------------------------------- neb.x module----------------------------------------
function nebin (){

#run tips
echo ' Tips：run ./QEtoolkit.sh [CuO.relax_ini.in] [CuO.relax_ini.out] [CuO.relax_fin.out] will be more convinent!'
#read the input files.
if [ -z "$fname1" ]; then 
	echo 
	echo ' load the xxx.relax1.in file, which wiil be used as templete to generate the neb.x input file.'
	read fname1
	while [ -z "$fname1" ]; do
        echo
        echo '  load the xxx.relax1.in file, which wiil be used as templete to generate the neb.x input file.'
        read fname1
    done
	prefix=`echo "${fname1%%.*}"`
fi
if [ -z "$fname2" ]; then
	echo 
	echo ' load the xxx.relax1.out file, which contains the initial optimized structure.'
	read fname2
	while [ -z "$fname2" ]; do
        echo
        echo '  load the xxx.relax1.out file, which contains the initial optimized structure.'
        read fname2
    done
fi
if [ -z "$fname3" ]; then
	echo 
	echo ' load the xxx.relax2.out file, which contains the finial optimized structure.'
	read fname3
	while [ -z "$fname3" ]; do
        echo
        echo '  load the xxx.relax2.out file, which contains the finial optimized structure.'
        read fname3
    done
fi

#delete atomic_positions section
natm=`grep 'nat' ${fname1} | awk '{print $3}'`
begdel=`grep -n 'ATOMIC_POSITIONS' ${fname1} | awk -F : '{print $1}'`
enddel=$((${begdel}+${natm}))
cp $fname1 ${prefix}.neb.tmp
sed -i "${begdel},${enddel}d" ${prefix}.neb.tmp

#get initial and finial atomic positions 
begatmpos1=`grep -n 'ATOMIC_POSITIONS' ${fname2} |tail -1|awk -F : '{print $1 + 1}'`
endatmpos1=`grep -n 'End final coordinates' ${fname2} |tail -1|awk -F : '{print $1 - 1}'`
begatmpos2=`grep -n 'ATOMIC_POSITIONS' ${fname3} |tail -1|awk -F : '{print $1 + 1}'`
endatmpos2=`grep -n 'End final coordinates' ${fname3} |tail -1|awk -F : '{print $1 - 1}'`

#generate neb input file
echo 'BEGIN' >> ${prefix}.neb.in
echo 'BEGIN_PATH_INPUT' >> ${prefix}.neb.in
echo '&PATH' >> ${prefix}.neb.in
echo "   string_method   = 'neb'" >> ${prefix}.neb.in
echo "   restart_mode    = 'from_scratch'" >> ${prefix}.neb.in
echo "   num_of_images   = 5" >> ${prefix}.neb.in
echo "   nstep_path     = 100" >> ${prefix}.neb.in
echo "   opt_scheme      = 'broyden'" >> ${prefix}.neb.in
echo "   CI_scheme       = 'auto'" >> ${prefix}.neb.in
echo "   path_thr        = 0.05" >> ${prefix}.neb.in
echo "   k_max           = 0.3" >> ${prefix}.neb.in
echo "   k_min           = 0.2" >> ${prefix}.neb.in
echo ' /' >> ${prefix}.neb.in
echo "END_PATH_INPUT" >> ${prefix}.neb.in
echo "BEGIN_ENGINE_INPUT" >> ${prefix}.neb.in
cat ${prefix}.neb.tmp >> ${prefix}.neb.in
echo 'BEGIN_POSITIONS' >> ${prefix}.neb.in
echo 'FIRST_IMAGE' >> ${prefix}.neb.in
echo 'ATOMIC_POSITIONS angstrom' >> ${prefix}.neb.in
for i in $(seq ${begatmpos1} ${endatmpos1})
do
	sed -n "${i}p" ${fname2} |awk '{printf "%2s \t %.9f \t %.9f \t %.9f\n",$1,$2,$3,$4}' >> ${prefix}.neb.in
done
echo 'LAST_IMAGE' >> ${prefix}.neb.in
echo 'ATOMIC_POSITIONS angstrom' >> ${prefix}.neb.in
for j in $(seq ${begatmpos2} ${endatmpos2})
do
	sed -n "${j}p" ${fname3} |awk '{printf "%2s \t %.9f \t %.9f \t %.9f\n",$1,$2,$3,$4}' >> ${prefix}.neb.in
done
echo 'END_POSITIONS' >> ${prefix}.neb.in
echo 'END_ENGINE_INPUT' >> ${prefix}.neb.in
echo 'END' >> ${prefix}.neb.in
rm -f ${prefix}.neb.tmp
}

#--------------------------------- ph.x module----------------------------------------
function phin (){

echo " * This module is designed for the phonon and thermodynamic properties of adsorbed/gaseous molecules and solid phase."
echo ' * Phonon calculations are not compatible with DFT-D3, while DFT-D2 is supported!'
echo ' * For Raman spectrum calculation, functional and pseudopotentials must be lda and NC, respectively!'
echo

#functions need to read pw.x input file 
if [ -z "$fname1" ]; then
	echo ' This function need to read pw.x input file.'
	read fname1
	while [ -z "$fname1" ]; do
        echo
        echo '  This function need to read pw.x input file.'
        read fname1
    done
    prefix=`echo "${fname1%%.*}"`
fi

natm=`grep 'nat' ${fname1} | awk '{print $3}'`
ntyp=`grep 'ntyp' ${fname1} | awk '{print $3}'`
begatmpos=`grep -n 'ATOMIC_POSITIONS' ${fname1} | awk -F : '{print $1 + 1}'`
endatmpos=$((${begatmpos} + ${natm} -1))

#Get the number of atoms of each types and the corresponding elements.
for ((i=1;i<=$ntyp;i++))
do
	atmtype[$i]=`sed -n "${begatmpos},${endatmpos}p" ${fname1} | awk '{print $1}'|sort|uniq |awk -v var="$i" 'NR==var{print $1}'`
done

#define ph.x menu
function phin_menu (){
echo " 1) Slab model"
echo " 2) Gaseous molecule"
echo " 3) Non-polar materials"
echo " 4) Polar materials"
echo " 5) Return"
}

phin_menu
phin_choice=("1" "2" "3" "4" "5")
read phin_arg
while ! echo "${phin_choice[@]}" | grep -wq "$phin_arg" 
do
	echo "Please reinput function number..."
	read phin_arg
done


#-----------Phonon frequency of adsorbed molecule at gamma-----------
function adsmolfreq (){

echo ' How to calculate phonon frequency of adsorbed molecule at gamma:'
echo ' * step 1: Perform a Self-Consistent Field ground-state calculation at the equilibrium structure using the pw.x program.'
echo '   Running cmd: mpirun -np 16 pw.x -i xxx.scf.in > xxx.scf.out'
echo ' * step 2: calculate phonon frequency by ph.x code:'
echo '   Running cmd: mpirun -np 16 ph.x -i xxx.ph.in > xxx.ph.out'
echo 
echo ' Input the atom index to be used in the linear response calculation, e.g. 3,5,10-15'
read atmphon

echo $atmphon | awk -F , '{for(i=1;i<=NF;i++) print $i}' > atmphontmp.dat
acc=0
for i in $(cat atmphontmp.dat);do
	if [[ "$i" =~ ^[0-9]+$ ]];then
		atmphon_arry["$acc"]="$i"
		acc=$(($acc+1))
	else 
		Min=$(echo $i |awk -F \- '{print $1}')
		Max=$(echo $i |awk -F \- '{print $2}')
		for j in $(seq $Min $Max)
		do
			atmphon_arry["$acc"]="$j"
			acc=$(($acc+1))
		done	       
	fi
done
rm -f atmphontmp.dat

#generate ph.x input file
echo '&inputph' >> ${prefix}.ph.in
echo "   prefix='"${prefix}"'," >> ${prefix}.ph.in
echo "   tr2_ph=1.0d-12," >> ${prefix}.ph.in
echo "   nmix_ph=16," >> ${prefix}.ph.in
for ((i=1;i<=$ntyp;i++))
do
	for ((j=1;j<=86;j++))
	do
		if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo "   amass($i)="${atmmass[$atmindex]}"," >> ${prefix}.ph.in
done
echo "   outdir='./tmp'," >> ${prefix}.ph.in
echo "   fildyn='${prefix}.dynG'," >> ${prefix}.ph.in
echo "   nat_todo="${#atmphon_arry[@]}"," >> ${prefix}.ph.in
echo ' /' >> ${prefix}.ph.in
echo "0.0 0.0 0.0" >> ${prefix}.ph.in
echo "${atmphon_arry[@]}" >> ${prefix}.ph.in
}

#-----------Thermodynamic properties of adsorbed molecule-----------
function adsmolthermo (){

echo " How to calculate the thermodynamic properties of adsorbed molecule:"
echo " * Step 1: calculate phonon frequency gaseous molecule at gamma."
echo " * Step 2: using Shermo to calculate thermodynamic properties."
echo "   Running cmd: Shermo xxx.shm -T 298.15 -P 1 -E 300 -imode 1"
echo
if [ -z "$fname2" ]; then
	echo " This function need to read ph.x output file, e.g. xxx.ph.out"
	read fname2
	while [ -z "$fname2" ]
	do
		echo "This function need to read ph.x output file, e.g. xxx.ph.out"
		read fname2
	done
fi

#read which atom will be used in the linear response calculation
ncol=`grep 'Compute atoms' $fname2 |awk '{print NF}'`
acc=0
for ((i=3;i<=$ncol;i++))
do
        dophonatm[$acc]=`grep 'Compute atoms' $fname2 |awk -v var="$i" '{printf "%d\n",$var}'`
        acc=$(($acc+1))
done

#read which irreducible representations will be calculate
acc=0
for ((i=1;i<=$(("${#dophonatm[@]}"*3));i++))
do
        domodes[$acc]=`grep 'To be done' $fname2 | awk -v var="$i" 'NR==var{print $2}'`
        acc=$(($acc+1))
done

#record the frequency of irreducible representations to be calculated
if [ "$(echo "$QEversion > 7.0" |bc)" -eq "1" ]; then 
	for ((i=0;i<"${#domodes[@]}";i++))
	do
		adsfreq[$i]=`grep "freq (  "${domodes[$i]}")" $fname2 |awk '{print $8}'`
	done
else
	for ((i=0;i<"${#domodes[@]}";i++))
	do
		adsfreq[$i]=`grep "freq (   "${domodes[$i]}")" $fname2 |awk '{print $8}'`
	done
fi

#write Shermo input file
echo '*E' >> ${prefix}.shm
echo "  Input electronic energy in Hartree unit rather than Ry unit." >> ${prefix}.shm
echo '*wavenum' >> ${prefix}.shm
for ((i=0;i<"${#domodes[@]}";i++))
do
	echo "${adsfreq[$i]}" >> ${prefix}.shm
done
echo "*atoms" >> ${prefix}.shm
for ((i=0;i<"${#dophonatm[@]}";i++))
do
	dophonatmpos=$(($begatmpos+"${dophonatm[$i]}"-1))
	dophonatmtype=`sed -n "${dophonatmpos}p" $fname1 |awk '{print $1}'`
	dophonatmcoord=`sed -n "${dophonatmpos}p" $fname1 |awk '{printf "%.9f    %.9f    %.9f\n",$2,$3,$4}'`
	for ((j=1;j<=86;j++))
	do
		if [ "$dophonatmtype" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo -e "$dophonatmtype \t"${atmmass[$atmindex]}" \t $dophonatmcoord" >> ${prefix}.shm	
done
echo '*elevel' >> ${prefix}.shm
echo '0.00    1' >> ${prefix}.shm
}

#-----------Phonon frequency of gaseous molecule at gamma-----------
function gasmolfreq (){

echo ' How to calculate phonon frequency of gaseous molecule at gamma:'
echo ' * step 1: Perform a Self-Consistent Field ground-state calculation at the equilibrium structure using the pw.x program.'
echo '   Running cmd: mpirun -np 16 pw.x -i xxx.scf.in > xxx.scf.out'
echo ' * step 2: calculate phonon frequency by ph.x code:'
echo '   Running cmd: mpirun -np 16 ph.x -i xxx.ph.in > xxx.ph.out'
echo ' * step 3: Impose the Acoustic Sum Rule (ASR) by dynmat.x code:'
echo '   Running cmd: dynmat.x -i dynmat.in > dynmat.out'
echo

echo '&inputph' >> ${prefix}.ph.in
echo "   prefix='"${prefix}"'," >> ${prefix}.ph.in
echo "   tr2_ph=1.0d-12," >> ${prefix}.ph.in
echo "   nmix_ph=16," >> ${prefix}.ph.in
for ((i=1;i<=$ntyp;i++))
do
	for ((j=1;j<=86;j++))
	do
		if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo "   amass($i)="${atmmass[$atmindex]}"," >> ${prefix}.ph.in
done
echo "   outdir='./tmp'," >> ${prefix}.ph.in
echo "   fildyn='${prefix}.dynG'," >> ${prefix}.ph.in
echo "   asr= .true.," >> ${prefix}.ph.in
echo ' /' >> ${prefix}.ph.in
echo "0.0 0.0 0.0" >> ${prefix}.ph.in


#generate dynmat.x input file
echo '&input' >> ${prefix}.dynmat.in
echo "fildyn='${prefix}.dynG'," >> ${prefix}.dynmat.in
echo "asr='zero-dim'" >> ${prefix}.dynmat.in
echo '/' >> ${prefix}.dynmat.in
}

#-----------Thermodynamic properties of gaseous molecule-----------
function gasmolthermo (){
echo " How to calculate the thermodynamic properties of gaseous molecule:"
echo " * Step 1: calculate phonon frequency gaseous molecule at gamma."
echo " * Step 2: using Shermo to calculate thermodynamic properties."
echo "   Running cmd: Shermo xxx.shm -T 298.15 -P 1 -E 300 -imode 0"
echo 

if [ -z "$(ls dynmat.mold 2>/dev/null)" ]; then 
	echo " The 'dynmat.mold' file does not exist!"
	exit 1
fi

#read frequency from dynmat.mold
acc=0
for ((i=3;i<"$(grep -n 'FR-COORD' dynmat.mold |awk -F \: '{print $1}')";i++))
do
	val=`sed -n "${i}p" dynmat.mold`
	if [ "$(echo "$val > 0.0" |bc)" -eq "1" ]; then
		gasfreq[$acc]="$val"
		acc=$(($acc+1))
	fi
done

#write Shermo input file
echo '*E' >> ${prefix}.shm
echo "  Input electronic energy in Hartree unit rather than Ry unit." >> ${prefix}.shm
echo '*wavenum' >> ${prefix}.shm
for ((i=0;i<"${#gasfreq[@]}";i++))
do
	echo "${gasfreq[$i]}" >> ${prefix}.shm
done
echo "*atoms" >> ${prefix}.shm
for ((i=0;i<"$natm";i++))
do
	gasmolpos=$((${begatmpos}+$i))
	gasatmtype=`sed -n "${gasmolpos}p" $fname1 |awk '{print $1}'`
	gasatmcoord=`sed -n "${gasmolpos}p" $fname1 |awk '{printf "%.9f    %.9f    %.9f\n",$2,$3,$4}'`
	for ((j=1;j<=86;j++))
	do
		if [ "$gasatmtype" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo -e "$gasatmtype \t"${atmmass[$atmindex]}" \t $gasatmcoord" >> ${prefix}.shm	
done
echo '*elevel' >> ${prefix}.shm
echo '0.00    1' >> ${prefix}.shm
}

#---------Non-polar materials Phonon frequency at gamma-------
function nonpolarfreq (){

echo ' How to calculate phonon frequency of Non-polar materials at gamma:'
echo ' * step 1: Perform a Self-Consistent Field ground-state calculation at the equilibrium structure using the pw.x program.'
echo '   Running cmd: mpirun -np 16 pw.x -i xxx.scf.in > xxx.scf.out'
echo ' * step 2: calculate phonon frequency by ph.x code:'
echo '   Running cmd: mpirun -np 16 ph.x -i xxx.ph.in > xxx.ph.out'
echo ' * step 3: Impose the Acoustic Sum Rule (ASR) by dynmat.x code:'
echo '   Running cmd: dynmat.x -i dynmat.in > dynmat.out'
echo

echo '&inputph' >> ${prefix}.ph.in
echo "   prefix='"${prefix}"'," >> ${prefix}.ph.in
echo "   tr2_ph=1.0d-12," >> ${prefix}.ph.in
echo "   nmix_ph=16," >> ${prefix}.ph.in
for ((i=1;i<=$ntyp;i++))
do
	for ((j=1;j<=86;j++))
	do
		if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo "   amass($i)="${atmmass[$atmindex]}"," >> ${prefix}.ph.in
done
echo "   outdir='./tmp'," >> ${prefix}.ph.in
echo "   fildyn='${prefix}.dynG'," >> ${prefix}.ph.in
echo ' /' >> ${prefix}.ph.in
echo "0.0 0.0 0.0" >> ${prefix}.ph.in


#generate dynmat.x input file
echo '&input' >> ${prefix}.dynmat.in
echo "fildyn='${prefix}.dynG'," >> ${prefix}.dynmat.in
echo "asr='simple'" >> ${prefix}.dynmat.in
echo '/' >> ${prefix}.dynmat.in
}

#---------Non-polar materials Phonon dispersion-------
function nonpolardisp (){

echo " How to calculate phonon dispersion of Non-polar materials:"
echo " * Step 1: Perform a Self-Consistent Field ground-state calculation at the equilibrium structure using the pw.x program."
echo '   Running cmd: mpirun -np 16 pw.x -i xxx.scf.in > xxx.scf.out'
echo ' * Step 2: Perform a phonon calculation on a uniform grid of q points using the ph.x code.'
echo "   Running cmd: mpirun -np 16 ph.x -i xxx.ph.in > xxx.ph.out"
echo ' * Step 3: Calculation of the Interatomic Force Constants (IFC) using the q2r.x code.'
echo '   Running cmd: q2r.x -i xxx.q2r.in > xxx.q2r.out'
echo ' * Step 4: Calculate phonons at generic q points using IFC by means of the code matdyn.x.'
echo '   Running cmd: matdyn.x -i xxx.matdyn.in > xxx.matdyn.out'
echo ' * Step 5: Plot the phonon dispersion using the plotband.x program and gnuplot.'
echo '   Running cmd: plotband.x < xxx.plotband.in > xxx.plotband.out'
echo 

#generate the input file for step 2.
echo '&inputph' >> ${prefix}.ph.in
echo "   prefix='"${prefix}"'," >> ${prefix}.ph.in
echo "   tr2_ph=1.0d-12," >> ${prefix}.ph.in
echo "   nmix_ph=16," >> ${prefix}.ph.in
for ((i=1;i<=$ntyp;i++))
do
	for ((j=1;j<=86;j++))
	do
		if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo "   amass($i)="${atmmass[$atmindex]}"," >> ${prefix}.ph.in
done
echo "   ldisp=.true." >> ${prefix}.ph.in
echo "   nq1=4," >> ${prefix}.ph.in
echo "   nq2=4," >> ${prefix}.ph.in
echo "   nq3=4," >> ${prefix}.ph.in
echo "   outdir='./tmp'," >> ${prefix}.ph.in
echo "   fildyn='${prefix}.dyn'," >> ${prefix}.ph.in
echo ' /' >> ${prefix}.ph.in

#generate input file for step 3
echo '&input' >> ${prefix}.q2r.in
echo "   fildyn='${prefix}.dyn'," >> ${prefix}.q2r.in
echo "   zasr='simple'," >> ${prefix}.q2r.in
echo "   flfrc='${prefix}.fc'," >> ${prefix}.q2r.in
echo ' /' >> ${prefix}.q2r.in

#generate input file for step 4
echo '&input' >> ${prefix}.matdyn.in
echo "   asr='simple'," >> ${prefix}.matdyn.in
echo "   flfrc='${prefix}.fc'," >> ${prefix}.matdyn.in
echo "   flfreq='${prefix}.freq'," >> ${prefix}.matdyn.in
echo "   q_in_cryst_coord=.true." >> ${prefix}.matdyn.in
echo ' /'  >> ${prefix}.matdyn.in 
echo " Input q-points path, same in bands." >> ${prefix}.matdyn.in

#generate input file for step 4
echo "${prefix}.freq" >> ${prefix}.plotband.in
echo "0 700" >> ${prefix}.plotband.in
echo "freq.plot" >> ${prefix}.plotband.in
echo "freq.ps" >> ${prefix}.plotband.in
echo '0.0' >> ${prefix}.plotband.in
echo "100.0 0.0" >> ${prefix}.plotband.in
}

#---------Non-polar materials raman-------
function nonpolarraman (){

echo ' How to calculate Raman spectrum of Non-polar materials:'
echo ' * step 1: Perform a Self-Consistent Field ground-state calculation at the equilibrium structure using the lda and NC pseudopotentials.'
echo '   Running cmd: mpirun -np 16 pw.x -i xxx.scf.in > xxx.scf.out'
echo ' * step 2: calculate Raman spectrum by ph.x code:'
echo '   Running cmd: mpirun -np 16 ph.x -i xxx.ph.in > xxx.ph.out'
echo ' * step 3: Impose the Acoustic Sum Rule (ASR) by dynmat.x code:'
echo '   Running cmd: dynmat.x -i dynmat.in > dynmat.out'
echo

echo '&inputph' >> ${prefix}.ph.in
echo "   prefix='"${prefix}"'," >> ${prefix}.ph.in
echo "   tr2_ph=1.0d-12," >> ${prefix}.ph.in
echo "   nmix_ph=16," >> ${prefix}.ph.in
for ((i=1;i<=$ntyp;i++))
do
	for ((j=1;j<=86;j++))
	do
		if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo "   amass($i)="${atmmass[$atmindex]}"," >> ${prefix}.ph.in
done 
echo "   lraman=.true." >> ${prefix}.ph.in
echo "   outdir='./tmp'," >> ${prefix}.ph.in
echo "   fildyn='${prefix}.dynG'," >> ${prefix}.ph.in
echo ' /' >> ${prefix}.ph.in
echo "0.0 0.0 0.0" >> ${prefix}.ph.in


#generate dynmat.x input file
echo '&input' >> ${prefix}.dynmat.in
echo "fildyn='${prefix}.dynG'," >> ${prefix}.dynmat.in
echo "asr='simple'," >> ${prefix}.dynmat.in
echo '/' >> ${prefix}.dynmat.in
}

#---------polar materials Phonon frequency at gamma-------
function polarfreq (){

echo ' How to calculate phonon frequency of polar materials at gamma:'
echo ' * step 1: Perform a Self-Consistent Field ground-state calculation at the equilibrium structure using the pw.x program.'
echo '   Running cmd: mpirun -np 16 pw.x -i xxx.scf.in > xxx.scf.out'
echo ' * step 2: calculate phonon frequency by ph.x code:'
echo '   Running cmd: mpirun -np 16 ph.x -i xxx.ph.in > xxx.ph.out'
echo ' * step 3: Impose the Acoustic Sum Rule (ASR) by dynmat.x code:'
echo '   Running cmd: dynmat.x -i dynmat.in > dynmat.out'
echo

echo '&inputph' >> ${prefix}.ph.in
echo "   prefix='"${prefix}"'," >> ${prefix}.ph.in
echo "   tr2_ph=1.0d-12," >> ${prefix}.ph.in
echo "   nmix_ph=16," >> ${prefix}.ph.in
for ((i=1;i<=$ntyp;i++))
do
	for ((j=1;j<=86;j++))
	do
		if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo "   amass($i)="${atmmass[$atmindex]}"," >> ${prefix}.ph.in
done
echo "   outdir='./tmp'," >> ${prefix}.ph.in
echo "   fildyn='${prefix}.dynG'," >> ${prefix}.ph.in
echo ' /' >> ${prefix}.ph.in
echo "0.0 0.0 0.0" >> ${prefix}.ph.in


#generate dynmat.x input file
echo '&input' >> ${prefix}.dynmat.in
echo "fildyn='${prefix}.dynG'," >> ${prefix}.dynmat.in
echo "asr='simple'," >> ${prefix}.dynmat.in
echo "q(1)=1.0," >> ${prefix}.dynmat.in
echo "q(2)=0.0," >> ${prefix}.dynmat.in
echo "q(3)=0.0," >> ${prefix}.dynmat.in
echo '/' >> ${prefix}.dynmat.in
}

#---------polar materials Phonon dispersion-------
function polardisp (){

echo " How to calculate phonon dispersion of Non-polar materials:"
echo " * Step 1: Perform a Self-Consistent Field ground-state calculation at the equilibrium structure using the pw.x program."
echo '   Running cmd: mpirun -np 16 pw.x -i xxx.scf.in > xxx.scf.out'
echo ' * Step 2: Perform a phonon calculation on a uniform grid of q points using the ph.x code.'
echo "   Running cmd: mpirun -np 16 ph.x -i xxx.ph.in > xxx.ph.out"
echo ' * Step 3: Calculation of the Interatomic Force Constants (IFC) using the q2r.x code.'
echo '   Running cmd: q2r.x -i xxx.q2r.in > xxx.q2r.out'
echo ' * Step 4: Calculate phonons at generic q points using IFC by means of the code matdyn.x.'
echo '   Running cmd: matdyn.x -i xxx.matdyn.in > xxx.matdyn.out'
echo ' * Step 5: Plot the phonon dispersion using the plotband.x program and gnuplot.'
echo '   Running cmd: plotband.x < xxx.plotband.in > xxx.plotband.out'
echo 

#generate the input file for step 2.
echo '&inputph' >> ${prefix}.ph.in
echo "   prefix='"${prefix}"'," >> ${prefix}.ph.in
echo "   tr2_ph=1.0d-12," >> ${prefix}.ph.in
echo "   nmix_ph=16," >> ${prefix}.ph.in
for ((i=1;i<=$ntyp;i++))
do
	for ((j=1;j<=86;j++))
	do
		if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo "   amass($i)="${atmmass[$atmindex]}"," >> ${prefix}.ph.in
done
echo "   ldisp=.true." >> ${prefix}.ph.in
echo "   nq1=4," >> ${prefix}.ph.in
echo "   nq2=4," >> ${prefix}.ph.in
echo "   nq3=4," >> ${prefix}.ph.in
echo "   outdir='./tmp'," >> ${prefix}.ph.in
echo "   fildyn='${prefix}.dyn'," >> ${prefix}.ph.in
echo ' /' >> ${prefix}.ph.in

#generate input file for step 3
echo '&input' >> ${prefix}.q2r.in
echo "   fildyn='${prefix}.dyn'," >> ${prefix}.q2r.in
echo "   zasr='simple'," >> ${prefix}.q2r.in
echo "   flfrc='${prefix}.fc'," >> ${prefix}.q2r.in
echo ' /' >> ${prefix}.q2r.in

#generate input file for step 4
echo '&input' >> ${prefix}.matdyn.in
echo "   asr='simple'," >> ${prefix}.matdyn.in
echo "   flfrc='${prefix}.fc'," >> ${prefix}.matdyn.in
echo "   flfreq='${prefix}.freq'," >> ${prefix}.matdyn.in
echo "   q_in_cryst_coord=.true." >> ${prefix}.matdyn.in
echo ' /'  >> ${prefix}.matdyn.in 
echo " Input q-points path, same in bands." >> ${prefix}.matdyn.in

#generate input file for step 4
echo "${prefix}.freq" >> ${prefix}.plotband.in
echo "0 700" >> ${prefix}.plotband.in
echo "freq.plot" >> ${prefix}.plotband.in
echo "freq.ps" >> ${prefix}.plotband.in
echo '0.0' >> ${prefix}.plotband.in
echo "100.0 0.0" >> ${prefix}.plotband.in
}

#---------polar materials raman-------
function polarraman (){

echo ' How to calculate Raman spectrum of polar materials:'
echo ' * step 1: Perform a Self-Consistent Field ground-state calculation at the equilibrium structure using the lda and NC pseudopotentials.'
echo '   Running cmd: mpirun -np 16 pw.x -i xxx.scf.in > xxx.scf.out'
echo ' * step 2: calculate Raman spectrum by ph.x code:'
echo '   Running cmd: mpirun -np 16 ph.x -i xxx.ph.in > xxx.ph.out'
echo ' * step 3: Impose the Acoustic Sum Rule (ASR) by dynmat.x code:'
echo '   Running cmd: dynmat.x -i dynmat.in > dynmat.out'
echo

echo '&inputph' >> ${prefix}.ph.in
echo "   prefix='"${prefix}"'," >> ${prefix}.ph.in
echo "   tr2_ph=1.0d-12," >> ${prefix}.ph.in
echo "   nmix_ph=16," >> ${prefix}.ph.in
for ((i=1;i<=$ntyp;i++))
do
	for ((j=1;j<=86;j++))
	do
		if [ "${atmtype[$i]}" == "${atm[$j]}" ]; then 
			atmindex=$j
		fi
	done
	echo "   amass($i)="${atmmass[$atmindex]}"," >> ${prefix}.ph.in
done 
echo "   lraman=.true." >> ${prefix}.ph.in
echo "   outdir='./tmp'," >> ${prefix}.ph.in
echo "   fildyn='${prefix}.dynG'," >> ${prefix}.ph.in
echo ' /' >> ${prefix}.ph.in
echo "0.0 0.0 0.0" >> ${prefix}.ph.in


#generate dynmat.x input file
echo '&input' >> ${prefix}.dynmat.in
echo "fildyn='${prefix}.dynG'," >> ${prefix}.dynmat.in
echo "asr='simple'" >> ${prefix}.dynmat.in
echo "q(1)=1.0," >> ${prefix}.dynmat.in
echo "q(2)=0.0," >> ${prefix}.dynmat.in
echo "q(3)=0.0," >> ${prefix}.dynmat.in
echo '/' >> ${prefix}.dynmat.in
}


while [[ "$phin_arg" != "5" ]]; do
	case $phin_arg in
		"1")
			PS3=''
			slab_array=("Phonon frequency of adsorbed molecule at gamma" "Thermodynamic properties of adsorbed molecule" "Return")
			select islab in "${slab_array[@]}"; do
				case "$islab" in 
					"Phonon frequency of adsorbed molecule at gamma")
						adsmolfreq
						echo ' The input file has been generate at current folder!'
						exit 1
						;;
					"Thermodynamic properties of adsorbed molecule")
						adsmolthermo
						echo ' The Shermo input file has been generate at current folder!'
						exit 1
						;;
					"Return")
						phin_menu
						break
						;;
					"*")
						;;
				esac
			done		
			;;
		"2")
			PS3=''
			gasmol_array=("Phonon frequency of gaseous molecule at gamma" "Thermodynamic properties of gaseous molecule" "Return")
			select igasmol in "${gasmol_array[@]}"; do
				case $igasmol in 
					"Phonon frequency of gaseous molecule at gamma")
						gasmolfreq
						echo ' The input file has been generate at current folder!'
						exit 1
						;;
					"Thermodynamic properties of gaseous molecule")
						gasmolthermo
						echo ' The input file has been generate at current folder!'
						exit 1
						;;
					"Return")
						phin_menu
						break
						;;
					"*")
						;;
				esac
			done	
			;;
		"3")
			PS3=''
			nonpolar_array=("Phonon frequency at gamma" "Phonon dispersion" "IR spectrum" "Raman spectrum" "Return")
			select inonpolar in "${nonpolar_array[@]}"; do
				case "$inonpolar" in 
					"Phonon frequency at gamma")
						nonpolarfreq
						echo ' The input file has been generate at current folder!'
						exit 1
						;;
					"Phonon dispersion")
						nonpolardisp
						echo ' The input file has been generate at current folder!'
						exit 1
						;;
					"Raman spectrum")
						nonpolarraman
						echo ' The input file has been generate at current folder!'
						exit 1
						;;
					"Return")
						phin_menu
						break
						;;
					"*")
						;;
				esac
			done
			;;
		"4")
			PS3=''
			polar_array=("Phonon frequency at gamma" "Phonon dispersion" "IR spectrum" "Raman spectrum" "Return")
			select ipolar in "${polar_array[@]}"; do
				case "$ipolar" in 
					"Phonon frequency at gamma")
						polarfreq
						echo ' The input file has been generate at current folder!'
						exit 1
						;;
					"Phonon dispersion")
						polardisp
						echo ' The input file has been generate at current folder!'
						exit 1
						;;
					"Raman spectrum")
						polarraman
						echo ' The input file has been generate at current folder!'
						exit 1
						;;
					"Return")
						phin_menu
						break
						;;
					"*")
						;;
				esac
			done
			;;
		"*")
			;;
	esac
	unset phin_arg
	read phin_arg
	while ! echo "${phin_choice[@]}" | grep -wq "$phin_arg" 
	do
	  echo "Please reinput function number..."
	  read phin_arg
	done
done

if [[ "$phin_arg" == "5" ]]; then
	main_menu
	rmainfunc
fi
}

#--------------------------------- hp.x module----------------------------------------
function hpin (){
#print how to calculate hubbard U parameters
echo ' Tips:'
echo ' * For non-magnetic cases:'
echo '  step 1: Toggle using hubbard U in pw.x input, and set a non-zero U value for corresponding element, e.g. 1.D-8.'
echo '  step 2: hp.x code calculates U value.'
echo 
echo ' * For antiferromagnetic/magnetic insulator cases:'
echo '   step 1: Toggle using hubbard U in pw.x input, and set a non-zero U value for corresponding, e.g. 1.D-8, and remember to set magnetization.'
echo '   step 2: copy the previous input file, make following changes and run again:'
echo '   * change occupations=fixed'
echo '   * set tot_magnetization and nbnd, which can be obtained from last pw.x output file'
echo "   * in &ELECTRON section, add startingpot='file', startingwfc='file'"
echo '   step 3: hp.x code calculates U value.'
echo 
echo " * For U calculating of two elements, run hp.element1.in first, and then hp.element2.in, hp.tot.in at last."
echo 
echo ' * For calculating DFT+U+V, the hp.x inut file is the same as in DFT+U'
echo '   Running cmd: mpirun -np 16 hp.x -i hp.in > hp.out'
echo 

PS3=''
hpin_array=("calculate U for only one element" "calculate U for two elements" "Return")
select ihpin in "${hpin_array[@]}"; do
	case $ihpin in 
		"calculate U for only one element")
			echo '&INPUTHP' >> hp.in
			echo "   prefix          = 'xxx'" >> hp.in
			echo "   outdir          = './tmp'" >> hp.in
			echo "   iverbosity      = 2" >> hp.in
			echo "   nq1             = 2" >> hp.in
			echo "   nq2             = 2" >> hp.in
			echo "   nq3             = 2" >> hp.in
			echo "   conv_thr_chi    = 1.0d-5" >> hp.in
			echo '/' >> hp.in
			break
			;;
		"calculate U for two elements")
			echo '&INPUTHP' >> hp.element1.in
			echo "   prefix          = 'xxx'" >> hp.element1.in
			echo "   outdir          = './tmp'" >> hp.element1.in
			echo "   iverbosity      = 2" >> hp.element1.in
			echo "   nq1             = 2" >> hp.element1.in
			echo "   nq2             = 2" >> hp.element1.in
			echo "   nq3             = 2" >> hp.element1.in
			echo "   conv_thr_chi    = 1.0d-5" >> hp.element1.in
			echo "   perturb_only_atom(1) = .true." >> hp.element1.in
			echo '/' >> hp.element1.in
			
			echo '&INPUTHP' >> hp.element2.in
			echo "   prefix          = 'xxx'" >> hp.element2.in
			echo "   outdir          = './tmp'" >> hp.element2.in
			echo "   iverbosity      = 2" >> hp.element2.in
			echo "   nq1             = 2" >> hp.element2.in
			echo "   nq2             = 2" >> hp.element2.in
			echo "   nq3             = 2" >> hp.element2.in
			echo "   conv_thr_chi    = 1.0d-5" >> hp.element2.in
			echo "   perturb_only_atom(2) = .true." >> hp.element2.in
			echo '/' >> hp.element2.in
			
			echo '&INPUTHP' >> hp.tot.in
			echo "   prefix          = 'xxx'" >> hp.tot.in
			echo "   outdir          = './tmp'" >> hp.tot.in
			echo "   iverbosity      = 2" >> hp.tot.in
			echo "   nq1             = 2" >> hp.tot.in
			echo "   nq2             = 2" >> hp.tot.in
			echo "   nq3             = 2" >> hp.tot.in
			echo "   conv_thr_chi    = 1.0d-5" >> hp.tot.in
			echo "   compute_hp      = .true." >> hp.tot.in
			echo '/' >> hp.tot.in
			break
			;;
		"Return")
			main_menu
			rmainfunc
			break
			;;
		"*")
			;;
	esac
done
}

#--------------------------------- Dos.x module----------------------------------------
function dosin (){

echo ' Tips:'
echo " * For Non-metallic systems, It is recommended to use the tetrahedra method to get a smoother Dos, and the data file must be produced by pw.x using the option occupations='tetrahedra'."
echo " * A denser k-points is needed for tetrahedra method. Be ware in QE, Monkhorst-Pack grids of 'k1 k2 k3 0 0 0' is always through gamma point, no matter what k_i takes."
echo " * For metallic systems, gaussian broadening method will be used."
echo ' * Running cmd: mpirun -np 6 dos.x -i dos.in > dos.out'
echo
PS3=''
dosin_array=("Non-metallic systems" "Metallic systems" "Return")
select idosin in "${dosin_array[@]}"; do 
	case $idosin in 
		"Non-metallic systems")
			echo ' &DOS' >> dos.in
			echo "   prefix          = 'xxx'" >> dos.in
			echo "   outdir          = './tmp'" >> dos.in
			echo "   bz_sum          = 'tetrahedra'" >> dos.in
			echo "   DeltaE          = 0.01" >> dos.in
			echo "   Emin            = -20" >> dos.in
			echo "   Emax            = 20" >> dos.in
			echo ' /' >> dos.in
			break
			;;
		"Metallic systems")
			echo ' &DOS' >> dos.in
			echo "   prefix          = 'xxx'" >> dos.in
			echo "   outdir          = './tmp'" >> dos.in
			echo "   bz_sum          = 'smearing'" >> dos.in
			echo "   ngauss	         = 0" >> dos.in
			echo "   degauss         = 0.01" >> dos.in
			echo "   DeltaE          = 0.01" >> dos.in
			echo "   Emin            = -20" >> dos.in
			echo "   Emax            = 20" >> dos.in
			echo ' /' >> dos.in
			break
			;;
		"Return")
			main_menu
			rmainfunc
			break
			;;
		"*")
			;;
	esac
done
}

#--------------------------------- Projwfc.x module----------------------------------------
function projwfcin (){

echo ' Tips:'
echo " * For Non-metallic systems, It is recommended to use the tetrahedra method to get a smoother Dos, and the data file must be produced by pw.x using the option occupations='tetrahedra'."
echo " * A denser k-points is needed for tetrahedra method. Be ware in QE, Monkhorst-Pack grids of 'k1 k2 k3 0 0 0' is always through gamma point, no matter what k_i takes."
echo " * For metallic systems, gaussian broadening method will be used."
echo ' * Running cmd: mpirun -np 6 projwfc.x -i projwfc.in > projwfc.out'
echo
PS3=''
dosin_array=("Non-metallic systems" "Metallic systems" "Return")
select idosin in "${dosin_array[@]}"; do 
	case $idosin in 
		"Non-metallic systems")
			echo '&PROJWFC' >> projwfc.in
			echo "   prefix          = 'xxx'" >> projwfc.in
			echo "   outdir          = './tmp'" >> projwfc.in
			echo "   ngauss          = 0" >> projwfc.in
			echo "   DeltaE          = 0.01" >> projwfc.in
			echo "   Emin            = -20" >> projwfc.in
			echo "   Emax            = 20" >> projwfc.in
			echo ' /' >> projwfc.in
			break
			;;
		"Metallic systems")
			echo '&PROJWFC' >> projwfc.in
			echo "   prefix          = 'xxx'" >> projwfc.in
			echo "   outdir          = './tmp'" >> projwfc.in
			echo "   ngauss          = 0" >> projwfc.in
			echo "   degauss         = 0.01" >> projwfc.in
			echo "   DeltaE          = 0.01" >> projwfc.in
			echo "   Emin            = -20" >> projwfc.in
			echo "   Emax            = 20" >> projwfc.in
			echo ' /' >> projwfc.in
			break
			;;
		"Return")
			main_menu
			rmainfunc
			break
			;;
		"*")
			;;
	esac
done
}

#--------------------------------- PP.x module----------------------------------------
function ppin (){
echo "  * 1~9 fuctions will creat Gaussian-type cube file, then it can be further processed by Multiwfn, Vesta, VMD, etc."
echo "  * Deformation density means charge density minus superposition of atomic charge density."
echo '  * Running cmd: mpirun -np 6 pp.x -i xxx.pp.in > xxx.pp.out'
echo
PS3=''
ppin_array=("Charge density" "spin density" "ELF" "Deformation density" "ESP" "RDG" "Sign(lambda2)rho" "DORI" "Plotting orbitals" "STM" "Return")
select ippin in "${ppin_array[@]}"; do
	case $ippin in 
		"Charge density")
			echo '&INPUTPP' >> chgden.pp.in
			echo "   prefix          = 'xxx'" >> chgden.pp.in
			echo "   outdir          = './tmp'" >> chgden.pp.in
			echo "   filplot         = 'chgden.dat'" >> chgden.pp.in
			echo "   plot_num        = 0" >> chgden.pp.in
			echo ' /' >> chgden.pp.in
			echo '&PLOT' >> chgden.pp.in
			echo "   nfile           = 1" >> chgden.pp.in 
			echo "   filepp(1)       = 'chgden.dat'" >> chgden.pp.in
			echo "   weight(1)       = 1.0" >> chgden.pp.in
			echo "   fileout         = 'chgden.cube'" >> chgden.pp.in
			echo "   iflag           = 3" >> chgden.pp.in
			echo "   output_format   = 6" >> chgden.pp.in
			echo ' /' >> chgden.pp.in
			break
			;;
		"spin density")
			echo '&INPUTPP' >> spinden.pp.in
			echo "   prefix          = 'xxx'" >> spinden.pp.in
			echo "   outdir          = './tmp'" >> spinden.pp.in
			echo "   filplot         = 'spinden.dat'" >> spinden.pp.in
			echo "   plot_num        = 6" >> spinden.pp.in
			echo ' /' >> spinden.pp.in
			echo '&PLOT' >> spinden.pp.in
			echo "   nfile           = 1" >> spinden.pp.in 
			echo "   filepp(1)       = 'spinden.dat'" >> spinden.pp.in
			echo "   weight(1)       = 1.0" >> spinden.pp.in
			echo "   fileout         = 'spinden.cube'" >> spinden.pp.in
			echo "   iflag           = 3" >> spinden.pp.in
			echo "   output_format   = 6" >> spinden.pp.in
			echo ' /' >> spinden.pp.in
			break
			;;
		"ELF")
			echo '&INPUTPP' >> elf.pp.in
			echo "   prefix          = 'xxx'" >> elf.pp.in
			echo "   outdir          = './tmp'" >> elf.pp.in
			echo "   filplot         = 'elf.dat'" >> elf.pp.in
			echo "   plot_num        = 8" >> elf.pp.in
			echo ' /' >> elf.pp.in
			echo '&PLOT' >> elf.pp.in
			echo "   nfile           = 1" >> elf.pp.in 
			echo "   filepp(1)       = 'elf.dat'" >> elf.pp.in
			echo "   weight(1)       = 1.0" >> elf.pp.in
			echo "   fileout         = 'elf.cube'" >> elf.pp.in
			echo "   iflag           = 3" >> elf.pp.in
			echo "   output_format   = 6" >> elf.pp.in
			echo ' /' >> elf.pp.in
			break
			;;
		"Deformation density")
			echo '&INPUTPP' >> defden.pp.in
			echo "   prefix          = 'xxx'" >> defden.pp.in
			echo "   outdir          = './tmp'" >> defden.pp.in
			echo "   filplot         = 'defden.dat'" >> defden.pp.in
			echo "   plot_num        = 9" >> defden.pp.in
			echo ' /' >> defden.pp.in
			echo '&PLOT' >> defden.pp.in
			echo "   nfile           = 1" >> defden.pp.in 
			echo "   filepp(1)       = 'defden.dat'" >> defden.pp.in
			echo "   weight(1)       = 1.0" >> defden.pp.in
			echo "   fileout         = 'defden.cube'" >> defden.pp.in
			echo "   iflag           = 3" >> defden.pp.in
			echo "   output_format   = 6" >> defden.pp.in
			echo ' /' >> defden.pp.in
			break
			;;
		"ESP")
			echo '&INPUTPP' >> esp.pp.in
			echo "   prefix          = 'xxx'" >> esp.pp.in
			echo "   outdir          = './tmp'" >> esp.pp.in
			echo "   filplot         = 'esp.dat'" >> esp.pp.in
			echo "   plot_num        = 11" >> esp.pp.in
			echo ' /' >> esp.pp.in
			echo '&PLOT' >> esp.pp.in
			echo "   nfile           = 1" >> esp.pp.in 
			echo "   filepp(1)       = 'esp.dat'" >> esp.pp.in
			echo "   weight(1)       = 1.0" >> esp.pp.in
			echo "   fileout         = 'esp.cube'" >> esp.pp.in
			echo "   iflag           = 3" >> esp.pp.in
			echo "   output_format   = 6" >> esp.pp.in
			echo ' /' >> esp.pp.in
			break
			;;
		"RDG")
			echo '&INPUTPP' >> rdg.pp.in
			echo "   prefix          = 'xxx'" >> rdg.pp.in
			echo "   outdir          = './tmp'" >> rdg.pp.in
			echo "   filplot         = 'rdg.dat'" >> rdg.pp.in
			echo "   plot_num        = 19" >> rdg.pp.in
			echo ' /' >> rdg.pp.in
			echo '&PLOT' >> rdg.pp.in
			echo "   nfile           = 1" >> rdg.pp.in 
			echo "   filepp(1)       = 'rdg.dat'" >> rdg.pp.in
			echo "   weight(1)       = 1.0" >> rdg.pp.in
			echo "   fileout         = 'rdg.cube'" >> rdg.pp.in
			echo "   iflag           = 3" >> rdg.pp.in
			echo "   output_format   = 6" >> rdg.pp.in
			echo ' /' >> rdg.pp.in
			break
			;;
		"Sign(lambda2)rho")
			echo '&INPUTPP' >> sign_lambda2_rho.pp.in
			echo "   prefix          = 'xxx'" >> sign_lambda2_rho.pp.in
			echo "   outdir          = './tmp'" >> sign_lambda2_rho.pp.in
			echo "   filplot         = 'sign_lambda2_rho.dat'" >> sign_lambda2_rho.pp.in
			echo "   plot_num        = 20" >> sign_lambda2_rho.pp.in
			echo ' /' >> sign_lambda2_rho.pp.in
			echo '&PLOT' >> sign_lambda2_rho.pp.in
			echo "   nfile           = 1" >> sign_lambda2_rho.pp.in 
			echo "   filepp(1)       = 'sign_lambda2_rho.dat'" >> sign_lambda2_rho.pp.in
			echo "   weight(1)       = 1.0" >> sign_lambda2_rho.pp.in
			echo "   fileout         = 'sign_lambda2_rho.cube'" >> sign_lambda2_rho.pp.in
			echo "   iflag           = 3" >> sign_lambda2_rho.pp.in
			echo "   output_format   = 6" >> sign_lambda2_rho.pp.in
			echo ' /' >> sign_lambda2_rho.pp.in
			break
			;;
		"DORI")
			echo '&INPUTPP' >> dori.pp.in
			echo "   prefix          = 'xxx'" >> dori.pp.in
			echo "   outdir          = './tmp'" >> dori.pp.in
			echo "   filplot         = 'dori.dat'" >> dori.pp.in
			echo "   plot_num        = 123" >> dori.pp.in
			echo ' /' >> dori.pp.in
			echo '&PLOT' >> dori.pp.in
			echo "   nfile           = 1" >> dori.pp.in 
			echo "   filepp(1)       = 'dori.dat'" >> dori.pp.in
			echo "   weight(1)       = 1.0" >> dori.pp.in
			echo "   fileout         = 'dori.cube'" >> dori.pp.in
			echo "   iflag           = 3" >> dori.pp.in
			echo "   output_format   = 6" >> dori.pp.in
			echo ' /' >> dori.pp.in
			break
			;;
		"Plotting orbitals")
			echo '&INPUTPP' >> orb.pp.in
			echo "   prefix          = 'xxx'" >> orb.pp.in
			echo "   outdir          = './tmp'" >> orb.pp.in
			echo "   filplot         = 'orb.dat'" >> orb.pp.in
			echo "   plot_num        = 7" >> orb.pp.in
			echo "   kpoint(1)       = 1" >> orb.pp.in
			echo "   kpoint(2)       = 1" >> orb.pp.in
			echo "   kband(1)        = 1" >> orb.pp.in
			echo "   kband(2)        = 16" >> orb.pp.in
			echo "   lsign           = .true." >> orb.pp.in
			echo ' /' >> orb.pp.in
			echo '&PLOT' >> orb.pp.in
			echo "   nfile           = 1" >> orb.pp.in 
			echo "   filepp(1)       = 'orb.dat'" >> orb.pp.in
			echo "   weight(1)       = 1.0" >> orb.pp.in
			echo "   fileout         = 'orb.cube'" >> orb.pp.in
			echo "   iflag           = 3" >> orb.pp.in
			echo "   output_format   = 6" >> orb.pp.in
			echo ' /' >> orb.pp.in
			break
			;;
		"STM")
			echo '&INPUTPP' >> stm.pp.in
			echo "   prefix          = 'xxx'" >> stm.pp.in
			echo "   outdir          = './tmp'" >> stm.pp.in
			echo "   filplot         = 'stm.dat'" >> stm.pp.in
			echo "   plot_num        = 5" >> stm.pp.in
			echo "   sample_bias     = -0.0735" >> stm.pp.in
			echo ' /' >> stm.pp.in
			echo '&PLOT' >> stm.pp.in
			echo "   nfile           = 1" >> stm.pp.in 
			echo "   filepp(1)       = 'stm.dat'" >> stm.pp.in
			echo "   weight(1)       = 1.0" >> stm.pp.in
			echo "   fileout         = 'stm.cube'" >> stm.pp.in
			echo "   iflag           = 2" >> stm.pp.in
			echo "   output_format   = 7" >> stm.pp.in
			echo "   e1(1)           = 7" >> stm.pp.in
			echo "   e1(2)           = 0" >> stm.pp.in
			echo "   e1(3)           = 0" >> stm.pp.in
			echo "   e2(1)           = 0" >> stm.pp.in
			echo "   e2(2)           = 9.9" >> stm.pp.in
			echo "   e2(3)           = 0" >> stm.pp.in
			echo "   x0(1)           = 0" >> stm.pp.in
			echo "   x0(2)           = 1.37" >> stm.pp.in
			echo "   x0(3)           = 3.55" >> stm.pp.in
			echo "   nx              = 400" >> stm.pp.in
			echo "   ny              = 300" >> stm.pp.in
			echo ' /' >> stm.pp.in
			break
			;;
		"Return")
			main_menu
			rmainfunc
			break
			;;
		"*")
			;;
	esac
done	
}	

#--------------------------------- Bands.x module----------------------------------------
function bandin (){
echo " * For spin-unpolarized case, delete the 'spin_component  = 1' in the input file."
echo " * Running cmd: mpirun -np 6 bands.x -i bands.in > bands.out"
echo
echo "&BANDS" >> bands.in
echo "   prefix          = 'xxx'" >> bands.in
echo "   outdir          = './tmp'" >> bands.in
echo "   filband         = 'bands.dat'" >> bands.in
echo "   spin_component  = 1" >> bands.in
echo "   plot_2d         = .true." >> bands.in
echo ' /' >> bands.in
}

#--------------------------------- post processing ----------------------------------------
function relaxcheck (){
	if [ -z "$fname1" ]; then
		echo " Load a (vc)relax output file."
		read fname1
		while [ -z "$fname1" ]
		do
			echo " Load a (vc)relax output file."
			read fname1
		done
	fi
	
	ibrav=`grep 'bravais-lattice' ${fname1} |awk '{print $4}'|head -1`
	norm=`grep 'JOB' ${fname1} |awk '{print $1}' 2> /dev/null`
	cellinfo=`grep 'CELL_PARAMETERS' ${fname1} |tail -1|awk '{print $1}' 2> /dev/null`
	natm=`grep 'number of atoms/cell' ${fname1} |head -1 |awk '{print $5}'`
	begatmpos=`grep -n 'ATOMIC_POSITIONS' ${fname1} |tail -1|awk -F : '{print $1 + 1}'`
	endatmpos=`grep -n 'End final coordinates' ${fname1} |tail -1|awk -F : '{print $1 - 1}'`
	
	if [ -z "${norm}" ] || [ "$ibrav" != "0" ]; then
		echo ' Please recheck whether the input file terminates normally or not, or is supported by script! '
		exit 1
	elif [ -n "${cellinfo}" ]; then
		begcellpos=`grep -n 'CELL_PARAMETERS' ${fname1} |tail -1|awk -F : '{print $1 + 1}'`
		endcellpos=$((${begcellpos}+2))
	else 
		alat=`grep 'lattice parameter (alat)' ${fname1} |awk '{print $5}'`
		begcellpos=`grep -n 'crystal axes' ${fname1} |awk '{print $1}'|awk -F : '{print $1 + 1}'`
		endcellpos=$((${begcellpos}+2))
	fi
}

function infcheck (){
	if [ -z "$fname1" ]; then
		echo " Load a pw.x input file."
		read fname1
		while [ -z "fname1" ]
		do 
			echo " Load a pw.x input file."
			read fname1
		done
	fi
		
	infcheck1=`grep '&CONTROL' ${fname1}`
	infcheck2=`grep 'CELL_PARAMETERS' ${fname1}`
	infcheck3=`grep 'angstrom' ${fname1} | head -1`
	
	if [ -z "${infcheck1}" ] || [ -z "${infcheck2}" ] || [ -z "${infcheck3}" ]; then 
		echo ' Input file is not supported!'
		exit 1
	fi
	
	cellinfo=`grep 'CELL_PARAMETERS' ${fname1} |tail -1|awk '{print $1}' 2> /dev/null`
	natm=`grep 'nat' ${fname1} | awk '{print $3}'`
    begatmpos=`grep -n 'ATOMIC_POSITIONS' ${fname1} | awk -F : '{print $1 + 1}'`
	endatmpos=$((${begatmpos} + ${natm} -1))
    begcellpos=`grep -n 'CELL_PARAMETERS' ${fname1} | awk -F : '{print $1 + 1}'`
    endcellpos=$((${begcellpos} + 2))
}

function relax2gjf (){
	rm -f ${prefix}.gjf
	echo '%mem=10gb' >> ${prefix}.gjf
	echo '%nproc=10' >> ${prefix}.gjf
	echo "%chk=${prefix}.chk" >> ${prefix}.gjf
	echo '#P B3LYP/6-31G*' >> ${prefix}.gjf
	echo "" >> ${prefix}.gjf
	echo 'Generated by QEtoolkit.sh' >> ${prefix}.gjf
	echo "" >> ${prefix}.gjf
	echo '0 1' >> ${prefix}.gjf

	for i in $(seq ${begatmpos} ${endatmpos})
	do
		sed -n "${i}p" ${fname1} |awk '{printf "%-s \t %.9f \t %.9f \t %.9f\n",$1,$2,$3,$4}' >> ${prefix}.gjf
	done

	if [ -n "${cellinfo}" ]; then
		for i in $(seq ${begcellpos} ${endcellpos}) 
		do
			sed -n "${i}p" ${fname1} |awk '{printf "%-s \t %.9f \t %.9f \t %.9f\n","TV",$1,$2,$3}' >> ${prefix}.gjf
		done
	else
		for i in $(seq ${begcellpos} ${endcellpos}) 
		do 
			sed -n "${i}p" ${fname1} |awk -v var="${alat}" '{printf "%-s \t %.9f \t %.9f \t %.9f\n","TV",$4*var*0.5291772,$5*var*0.5291772,$6*var*0.5291772}' >> ${prefix}.gjf
		done
	fi
	
	echo "" >> ${prefix}.gjf
	echo "" >> ${prefix}.gjf
}

function relax2cif (){
	rm -f ${prefix}.cif
	echo ' Now is invoking Multiwfn to generate the cif file...'
Multiwfn ${prefix}.gjf << EOF &> /dev/null
100
2
33
${prefix}.cif
0
q
EOF
rm -f ${prefix}.gjf
}

function relax2xyz (){
	rm -f ${prefix}.xyz
	echo "${natm}" >> ${prefix}.xyz
	echo "" >> ${prefix}.xyz

    for i in $(seq ${begatmpos} ${endatmpos})
    do
        sed -n "${i}p" ${fname1} |awk '{printf "%-s \t %.9f \t %.9f \t %.9f\n",$1,$2,$3,$4}' >> ${prefix}.xyz
    done
}

function relax2nscf (){
	echo ' * Tips: ./QEtoolkit.sh [(vc)relax input file] [(vc)relax output file],run in this way directly will be more convinent for this function!'
	echo ' * Please feel safe for the &IONS (or &CELL) section contained in the nscf file, which will be ignored by code during nscf calculation.'
	echo 
	if [ -z "$fname1" ]; then
		echo ' Input the (vc)relax input file.'
		read fname1
		while [ -z "$fname1" ]
		do
			echo ' Input the (vc)relax input file.'
			read fname1
		done
	fi
	
	if [ -z "${fname2}" ]; then
		echo ' Input the corresponding (vc)relax output file.' 
		read fname2
        while [ -z "${fname2}" ]; do
                echo ' Input the corresponding (vc)relax output file.'
                read fname2
        done
	fi
	
	cellinfo=`grep 'CELL_PARAMETERS' ${fname2} |tail -1|awk '{print $1}' 2> /dev/null`
	natm=`grep 'number of atoms/cell' ${fname2} |head -1 |awk '{print $5}'`
	begatmpos1=`grep -n 'ATOMIC_POSITIONS' ${fname1} |tail -1|awk -F : '{print $1 + 1}'`
	endatmpos1=$((${begatmpos1}+${natm}-1))
	begcellpos1=`grep -n 'CELL_PARAMETERS' ${fname1} |tail -1|awk -F : '{print $1 + 1}'`
	endcellpos1=$((${begcellpos1}+2))
	begatmpos2=`grep -n 'ATOMIC_POSITIONS' ${fname2} |tail -1|awk -F : '{print $1 + 1}'`
	endatmpos2=`grep -n 'End final coordinates' ${fname2} |tail -1|awk -F : '{print $1 - 1}'`
	begcellpos2=`grep -n 'CELL_PARAMETERS' ${fname2} |tail -1|awk -F : '{print $1 + 1}' 2> /dev/null`
	endcellpos2=$((${begcellpos2}+2))
	
	
	cp ${fname1} ${prefix}.nscf.in
	sed -i "${begatmpos1},${endatmpos1}d" ${prefix}.nscf.in
	
	for i in $(seq ${begatmpos2} ${endatmpos2})
    do
        sed -n "${i}p" ${fname2} |awk '{printf "%s %.9f %.9f %.9f\n",$1,$2,$3,$4}' >> ${prefix}_tmpcoord.xyz
    done
	
	if [ -n "${cellinfo}" ]; then
		sed -i "${begcellpos1},${endcellpos1}d" ${prefix}.nscf.in
		for i in $(seq ${begcellpos2} ${endcellpos2}) 
		do
			sed -n "${i}p" ${fname2} |awk '{printf "%.9f %.9f %.9f\n",$1,$2,$3}' >> ${prefix}_tmpcell.xyz
		done
		insetcellpos=$((${begcellpos1}-1))
		for ((j=1;j<=3;j++))
		do
			cellval=`cat ${prefix}_tmpcell.xyz | awk -v var=$j 'NR==var{printf "   %.9f    %.9f    %.9f\n",$1,$2,$3}'`
			sed -i "${insetcellpos}a ${cellval}" ${prefix}.nscf.in
			insetcellpos=$((${insetcellpos}+1))
		done
	fi
	
	insetatmpos=$((${begatmpos1}-1))
	for ((k=1;k<=${natm};k++))
	do
		atmval=`cat ${prefix}_tmpcoord.xyz | awk -v var=$k 'NR==var{printf "   %s      %.9f    %.9f    %.9f\n",$1,$2,$3,$4}'`
		sed -i "${insetatmpos}a ${atmval}" ${prefix}.nscf.in
		insetatmpos=$((${insetatmpos}+1))
	done
	
	calcpos=`grep -n 'calculation' ${prefix}.nscf.in |awk '{print $1}'|awk -F : '{print $1}'`
	nsteppos=`grep -n 'nstep' ${prefix}.nscf.in |awk '{print $1}'|awk -F : '{print $1}'`
	sed -i "${calcpos}c\   calculation     = 'nscf'" ${prefix}.nscf.in
	
	if [ -n "${nsteppos}" ]; then 
		sed -i "${nsteppos}d" ${prefix}.nscf.in
	fi
	
	rm -f ${prefix}_tmpcoord.xyz ${prefix}_tmpcell.xyz
}

#--------------------------------- other functions ----------------------------------------
function fixatm (){
	echo ' Input indices of the atoms to be constraint (fixed), e.g. 1,5,9-12,14-18' 
	read num
	echo ' Input if_pos(i), e.g. 0 0 0, which means atomic coordinates at x, y, and z direction will be fixed simutaneously.' 
	read if_pos
	echo

	pos=`grep -n ATOMIC_POSITIONS ${fname1} |cut -d ":" -f 1 |head -1`
	echo $num|awk -F , '{for(i=1;i<=NF;i++) print $i}' > ${prefix}_tmp1.dat

	#Generating the atoms Index into tmp2.dat 
	for i in $(cat ${prefix}_tmp1.dat);do
		if [[ "$i" =~ ^[0-9]+$ ]];then 
			echo $i >> ${prefix}_tmp2.dat
		else 
			Min=$(echo $i |awk -F \- '{print $1}')
			Max=$(echo $i |awk -F \- '{print $2}')
			for j in $(seq $Min $Max)
			do
		       	echo $j >> ${prefix}_tmp2.dat
	      	done	       
		fi
	done

	#fixing atoms in the QE input file
	for i in $(cat ${prefix}_tmp2.dat)
	do 
		line=$(($i + $pos))
		echo $line >> ${prefix}_tmp3.dat
	done

	for i in $(cat ${prefix}_tmp3.dat)
	do 
		sed -i "${i}s/$/    ${if_pos}/g" ${fname1}
	done

	rm -f ${prefix}_tmp*
}

function conver (){
	condition=`grep "\!" ${fname1} |wc -l`
	
	if [ "${condition}" -le "1" ]; then 
	       	grep "\ \{5\}total\ energy" ${fname1} |awk '{print NR "\t" $4}' > ${prefix}_ener1.dat
		begener=`cat ${prefix}_ener1.dat | head -1 |awk '{print $2}'` 
		cat ${prefix}_ener1.dat | awk -v var="${begener}" '{print $1 "\t" ($2-var)*13.6057}' > ${prefix}_ener2.dat
	elif [ "${condition}" -gt "1" ]; then 
		grep '!' ${fname1} | awk '{print NR "\t" $5}' > ${prefix}_ener1.dat
		begener=`cat ${prefix}_ener1.dat | head -1 |awk '{print $2}'`
		cat ${prefix}_ener1.dat | awk -v var="${begener}" '{print $1 "\t" ($2-var)*13.6057}' > ${prefix}_ener2.dat
	fi
	if [ "$(wc -l ${prefix}_ener2.dat|awk '{print $1}')" > "5" ]; then
		tail -5 ${prefix}_ener2.dat > ${prefix}_ener3.dat
	fi
	
gnuplot -p << EOF
set multiplot layout 2,1
set grid
set xlabel "steps"
set ylabel "Energy Variation (eV)"
set xtic nomirror out scale 0.8 
set ytic nomirror out scale 0.8 
plot "${prefix}_ener2.dat" u 1:2 w lp lw 2 lc rgb "dark-blue" ps 1.5 pt 7 t 'Total variation'
plot "${prefix}_ener3.dat" u 1:2 w lp lw 2 lc rgb "dark-blue" ps 1.5 pt 7 t 'Last 5 steps'
EOF
rm -f ${prefix}_ener*.dat
}

function ecuttest (){
	rm -rf scan_ecut
	lecutwfc=`grep -n 'ecutwfc' ${fname1} |awk '{print $1}'|awk -F : '{print $1}'`
	lecutrho=`grep -n 'ecutrho' ${fname1} |awk '{print $1}'|awk -F : '{print $1}'`
	
	if [ -z "${lecutwfc}" ] || [ -z "${lecutrho}" ]; then
		echo ' ecutwfc and ecutrho keywords must be specified!'
		exit 1
	fi

	echo ' Input the starting value, stride, and end value of ecutwfc, e.g. 30 5 60' 
	read ecutwfc
	while [ -z `echo ${ecutwfc}|awk '{print $1}'` ]
	do 
		echo ' Input the starting value, stride, and end value of ecutwfc, e.g. 30 5 60' 
		read ecutwfc
	done

	echo ' Input dual, e.g. 4' 
	echo ' dual means ecutrho = ecutwfc*dual. So if there are serval duals, e.g. 4 8 12, then each ecutwfc will be scaned under different duals.'
	echo ' Rule of thumb: dual is ~4 for PAW and 8~12 for USPP.'
	read ecutrho
	while [ -z `echo ${ecutrho}|awk '{print $1}'` ]
	do
		echo ' Input dual, e.g. 4' 
		read ecutrho
	done

	ecutwfc_beg=`echo ${ecutwfc} | awk '{print $1}'`
	ecutwfc_step=`echo ${ecutwfc} | awk '{print $2}'`
	ecutwfc_end=`echo ${ecutwfc} | awk '{print $3}'`
	
	for i in $(seq ${ecutwfc_beg} ${ecutwfc_step} ${ecutwfc_end}); do
		echo "${ecutrho}" |awk -v var="${i}" '{for (j=1;j<=NF;j++) print var "\t" $j*var}' >> ${prefix}_ecut.tmp
	done
	
	mkdir ./scan_ecut
	nlecut=`wc -l "${prefix}_ecut.tmp"|awk '{print $1}'`
	for ((i=1;i<=${nlecut};i++))
	do
		ewfc=`cat "${prefix}_ecut.tmp"|awk -v var="$i" 'NR==var{print $1}'`
		erho=`cat "${prefix}_ecut.tmp"|awk -v var="$i" 'NR==var{print $2}'`
		sed -i "${lecutrho}c\   ecutrho         = ${erho}" ${fname1}
		sed -i "${lecutwfc}c\   ecutwfc         = ${ewfc}" ${fname1}	
		cp ${fname1} ./scan_ecut/${prefix}_${ewfc}_${erho}.scf.in
	done

	rm -f ${prefix}_ecut.tmp
}

function script_ecut (){
#Generate a pbs script for reference
cat > ./scan_ecut/sub_qe.sh << EOF
#!/bin/bash
#PBS -S /bin/bash
#PBS -N scan_ecut
#PBS -j oe
#PBS -q intel
#PBS -l walltime=1440:00:00
#PBS -l nodes=1:ppn=9
#PBS -V

cd \${PBS_O_WORKDIR}

n=0
for inf in *.in
do
	n=\$((\$n+1))
	mpirun -np 9 pw.x -i \${inf} &> \${inf//in/out}
	grep ! \${inf//in/out} |awk -v var="\$n" '{print var "\t" \$5}' >> energy.dat
done
	
EOF

#Generate gnuplot script
cat > ./scan_ecut/scan_ecut.gp << EOF
set grid
set xlabel "Number"
set ylabel "Total Energy (Ry)"
unset key
plot 'energy.dat' u 1:2 w lp lw 2 lc rgb "dark-blue" ps 1.5 pt 7,
pause -1
EOF
}

function kptest (){
	rm -rf scan_kp
	ltmp=`grep -n 'K_POINTS' ${fname1} | awk '{print $1}'| awk -F : '{print $1}'`
	lkpoint=$((${ltmp} + 1))
	
	echo ' Input serval kpoints to be scaned, e.g. 1 1 1,2 2 2,4 5 5' 
	read kp
	
	mkdir ./scan_kp
	echo "${kp}" | awk -F , '{for (i=1;i<=NF;i++) print $i}' > ${prefix}_kp.tmp
	
	nlkp=`wc -l ${prefix}_kp.tmp|awk '{print $1}'`
	for ((i=1;i<=${nlkp};i++))
	do
		ikp=`cat "${prefix}_kp.tmp"|awk -v var="$i" 'NR==var{print $1 " " $2 " " $3}'`
		ikpname=`echo "${ikp}"|awk '{print $1 $2 $3}'`
		sed -i "${lkpoint}c\  ${ikp} 0 0 0" ${fname1} 
		cp ${fname1} ./scan_kp/${prefix}_${ikpname}.scf.in
	done

	rm -f ${prefix}_kp.tmp
}

function script_kp (){
#Generate a pbs script for reference
cat > ./scan_kp/sub_qe.sh << EOF
#!/bin/bash
#PBS -S /bin/bash
#PBS -N scan_ecut
#PBS -j oe
#PBS -q intel
#PBS -l walltime=1440:00:00
#PBS -l nodes=1:ppn=9
#PBS -V

cd \${PBS_O_WORKDIR}

n=0
for inf in *.in
do
        n=\$((\$n+1))
        mpirun -np 9 pw.x -i \${inf} &> \${inf//in/out}
        grep ! \${inf//in/out} |awk -v var="\$n" '{print var "\t" \$5}' >> energy.dat
done

EOF

#Generate gnuplot script
cat > ./scan_kp/scan_kp.gp << EOF
set grid
set xlabel "Number"
set ylabel "Total Energy (Ry)"
unset key
plot 'energy.dat' u 1:2 w lp lw 2 lc rgb "dark-blue" ps 1.5 pt 7,
pause -1
EOF
}

function gengnuplot (){
PS3=''
gnuplot_array=("plotting lines" "plotting histogram" "plotting pdos" "plotting bands" "plotting relief-map" "Return")
select ignuplot in "${gnuplot_array[@]}"; do
	case $ignuplot in 
		"plotting lines")
			echo "set term pngcairo enhanced font 'Helvetica,14'" >> lines.gp
			echo "set output 'FES.png'" >> lines.gp
			echo "set ylabel 'Free Energy (Kcal/mol)' offset 0.2,0 font \"Helvetica,16\"" >> lines.gp
			echo "set xlabel 'Psi (rad)' font \"Helvetica,16\"" >> lines.gp
			echo "set format y \"%.2f\"" >> lines.gp
			echo "set format x \"%.2f\"" >> lines.gp
			echo "set border lw 2" >> lines.gp
			echo "set xtic nomirror out scale 0.8 font \"Helvetica,14\"" >> lines.gp
			echo "set ytic nomirror out scale 0.8 font \"Helvetica,14\"" >> lines.gp
			echo "#set xrange [-0.05:0.05]" >> lines.gp
			echo "#set yrange [0.0:0.08]" >> lines.gp
			echo "set style line 1 lw 2 lc rgb '#E64B35'" >> lines.gp
			echo "set style line 2 lw 2 lc rgb '#4DBBD5'" >> lines.gp
			echo "set style line 3 lw 2 lc rgb '#00A087'" >> lines.gp
			echo "set style line 4 lw 2 lc rgb '#3C5488'" >> lines.gp
			echo "set style line 5 lw 2 lc rgb '#F39B7F'" >> lines.gp
			echo "set style line 6 lw 2 lc rgb '#8491B4'" >> lines.gp
			echo "set style line 7 lw 2 lc rgb '#91D1C2'" >> lines.gp
			echo "set style line 8 lw 2 lc rgb '#DC0000'" >> lines.gp
			echo "set style line 9 lw 2 lc rgb '#7E6148'" >> lines.gp
			echo "set style line 10 lw 2 lc rgb '#B09C85'" >> lines.gp
			echo "set style increment userstyles" >> lines.gp
			echo "plot 'fes.dat' u 1:2 w l lw 2 lc rgb 'dark-blue' not" >> lines.gp
			break
			;;
		"plotting histogram")
			echo "set term pngcairo enhanced font 'Helvetica,16'" >> hist.gp
			echo "set output 'hist.png'" >> hist.gp
			echo "set ylabel 'Probability' offset 2.1,0 font \"Helvetica,16\"" >> hist.gp
			echo "set xlabel 'Psi (deg)' offset 0,-0.3 font  \"Helvetica,16\"" >> hist.gp
			echo "set format y \"%.2f\"" >> hist.gp
			echo "set border lw 2" >> hist.gp
			echo "set xtic nomirror out scale 0 rotate by 45 offset -0.5,-1.3 font \"Helvetica,14\"" >> hist.gp
			echo "set ytic nomirror out scale 0.8 offset 0.5,0 font \"Helvetica,14\"" >> hist.gp
			echo "set xrange [-0.3:10.3]" >> hist.gp
			echo "set style data histograms" >> hist.gp
			echo "set style histogram cluster gap 0.8" >> hist.gp
			echo "set boxwidth 0.8 relative" >> hist.gp
			echo "set style fill solid 0.4 border lt -1" >> hist.gp
			echo "plot 'cv2hist.dat' u 2:xticlabels(1) lc rgb 'dark-blue' not" >> hist.gp
			break 
			;;
		"plotting pdos")
			echo "set term pngcairo enhanced font \"Helvetica,16\"" >> pdos.gp
			echo "set output 'PDOS.png'" >> pdos.gp
			echo "set ylabel 'PDOS (states/eV/atom)' offset 0.5,0 font \"Helvetica,16\"" >> pdos.gp
			echo "set xlabel 'E-E_f (eV)' offset 0,0.5 font \"Helvetica,16\"" >> pdos.gp
			echo "set format y \"%.f\"" >> pdos.gp
			echo "set format x \"%.f\"" >> pdos.gp
			echo "set border lw 2" >> pdos.gp
			echo "set key font \"Helvetica,12\"" >> pdos.gp
			echo "set xtic nomirror out scale 0.8 offset 0,0.15 font \"Helvetica,14\"" >> pdos.gp
			echo "set ytic nomirror out scale 0.8 offset 0.15,0 font \"Helvetica,14\"" >> pdos.gp
			echo "set yzeroaxis lt -1 dt 2 lw 1.5" >> pdos.gp
			echo "set xzeroaxis lt -1 lw 1.5" >> pdos.gp
			echo "set xrange [-10:10]" >> pdos.gp
			echo "#set yrange [0.0:0.08]" >> pdos.gp
			echo "set style line 1 lw 2 lc rgb '#E64B35'" >> pdos.gp
			echo "set style line 2 lw 2 lc rgb '#4DBBD5'" >> pdos.gp
			echo "set style line 3 lw 2 lc rgb '#00A087'" >> pdos.gp
			echo "set style line 4 lw 2 lc rgb '#3C5488'" >> pdos.gp
			echo "set style line 5 lw 2 lc rgb '#F39B7F'" >> pdos.gp
			echo "set style line 6 lw 2 lc rgb '#8491B4'" >> pdos.gp
			echo "set style line 7 lw 2 lc rgb '#91D1C2'" >> pdos.gp
			echo "set style line 8 lw 2 lc rgb '#DC0000'" >> pdos.gp
			echo "set style line 9 lw 2 lc rgb '#7E6148'" >> pdos.gp
			echo "set style line 10 lw 2 lc rgb '#B09C85'" >> pdos.gp
			echo "Ef=10.3552" >> pdos.gp
			echo 'plot \' >> pdos.gp
			echo "	 'FeO.pdos_atm#1(Fe1)_wfc#3(d)' u ($1-Ef):2 w l ls 1 t 'Fe-3d',\\" >> pdos.gp
			echo " 	 'FeO.pdos_atm#1(Fe1)_wfc#2(p)' u ($1-Ef):2 w l ls 2 t 'O-2P',\\" >> pdos.gp
			echo "	 'FeO.pdos_atm#1(Fe1)_wfc#3(d)' u ($1-Ef):(-$3) w l ls 1 not,\\" >> pdos.gp
			echo "	'FeO.pdos_atm#1(Fe1)_wfc#3(d)' u ($1-Ef):(-$3) w l ls 1 not,\\" >> pdos.gp
			echo "	'FeO.pdos_atm#1(Fe1)_wfc#2(p)' u ($1-Ef):(-$3) w l ls 2 not" >> pdos.gp
			break
			;;
		"plotting bands")
			echo "set term pngcairo enhanced font \"Helvetica,16\"" >> bands.gp
			echo "set output 'bands.png'" >> bands.gp
			echo "set ylabel 'Energy (Ry)' offset 0.5,0 font \"Helvetica,16\"" >> bands.gp
			echo "unset xlabel" >> bands.gp
			echo "set format y \"%.f\"" >> bands.gp
			echo "set border lw 2" >> bands.gp
			echo "set xzeroaxis lt -1 dt 2 lw 1.5 lc rgb 'dark-blue'" >> bands.gp
			echo "set ytic nomirror out scale 0.8 offset 0.15,0 font \"Helvetica,14\"" >> bands.gp
			echo "set xtics (\"{/Symbol G}\" 0.0, \"X\" 0.7071, \"U|K\" 1.0133,\"{/Symbol G}\" 1.9319,\"L\" 2.7979, \"W\" 3.15, \"X\" 3.5050)" >> bands.gp
			echo "set arrow from 0.7071,-15 to 0.7017,15 nohead lt -1 lw 1.5 lc rgb 'dark-blue'" >> bands.gp
			echo "set arrow from 1.0133,-15 to 1.0133,15 nohead lt -1 lw 1.5 lc rgb 'dark-blue'" >> bands.gp
			echo "set arrow from 1.9319,-15 to 1.9319,15 nohead lt -1 lw 1.5 lc rgb 'dark-blue'" >> bands.gp
			echo "set arrow from 2.7979,-15 to 2.7979,15 nohead lt -1 lw 1.5 lc rgb 'dark-blue'" >> bands.gp
			echo "set arrow from 3.15,-15 to 3.15,15 nohead lt -1 lw 1.5 lc rgb 'dark-blue'" >> bands.gp
			echo "set arrow from 3.505,-15 to 3.505,15 nohead lt -1 lw 1.5 lc rgb 'dark-blue'" >> bands.gp
			echo "set xrange [0:3.505]" >> bands.gp
			echo "set yrange [-15:15]" >> bands.gp
			echo "Ef=6.3611" >> bands.gp
			echo "set style line 1 lw 2 lc rgb 'dark-blue'" >> bands.gp
			echo "plot 'bands.dat.gnu' u 1:(\$2-Ef) w l ls 1 not" >> bands.gp
			break 
			;;
		"plotting relief-map")
			echo "set term pngcairo enhanced font 'Helvetica,14'" >> reliefmap.gp
			echo "set output 'fes.png'" >> reliefmap.gp
			echo "set pm3d at bs" >> reliefmap.gp
			echo "unset surface" >> reliefmap.gp
			echo "set border 31 lw 1.5" >> reliefmap.gp
			echo "set view 63,50" >> reliefmap.gp
			echo "set xyplane 0.8" >> reliefmap.gp
			echo "set palette rgbformulae 22,13,-31" >> reliefmap.gp
			echo "set cbrange [0:10]" >> reliefmap.gp
			echo "set cbtics mirror font \"Helvetica,13\"" >> reliefmap.gp
			echo "set xrange [-3.5:3.5]" >> reliefmap.gp
			echo "set yrange [-3.5:3.5]" >> reliefmap.gp
			echo "set xtics -3,1,3 out scale 0.8 nomirror offset -1.3,0 font \"Helvetica,13\"" >> reliefmap.gp
			echo "set ytics -3,1,3 out scale 0.8 nomirror offset 0.8,0 font \"Helvetica,13\"" >> reliefmap.gp
			echo "set ztics out scale 0.8 nomirror offset 0.5,0 font \"Helvetica,13\"" >> reliefmap.gp
			echo "set xlabel 'Phi (rad)' rotate parallel offset 1.3,0 font \"Helvetica,14\"" >> reliefmap.gp
			echo "set ylabel 'Psi (rad)' rotate parallel offset -1.5,0 font \"Helvetica,14\"" >> reliefmap.gp
			echo "set zlabel 'Free energy (Kcal/mol)' rotate parallel offset 1,0 font \"Helvetica,14\"" >> reliefmap.gp
			echo "splot 'fes.dat' u 1:2:3  w l lw 1 not" >> reliefmap.gp
			break
			;;
		"Return")
			main_menu
			rmainfunc
			break
			;;
		"*")
			;;
	esac
done
}

#read main functions
function rmainfunc (){
echo ' Input the function number.'
array_mainchoice=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19") 
read mainchoice
while ! echo "${array_mainchoice[@]}" | grep -wq "$mainchoice" 
do
  echo "Please reinput function number..."
  read mainchoice
done

case $mainchoice in
	"0")
		pwin
		;;
	"1")
		nebin
		;;
	"2")
		phin
		;;
	"3")
		hpin
		;;
	"4")
		dosin
		;;
	"5")
		projwfcin
		;;
	"6")
		ppin
		;;
	"7")
		bandin
		;;
	"8")
        relaxcheck
        relax2gjf
		;;
	"9")
		relaxcheck
        relax2gjf
        relax2cif
		;;
	"10")
		relaxcheck
        relax2xyz
		;;
	"11")
		relax2nscf
		;;
	"12")
		infcheck
        relax2xyz
		;;
	"13")
		infcheck
        relax2gjf
        relax2cif
		;;
	"14")
		infcheck
        relax2gjf
		;;
	"15")
		infcheck
		fixatm
		;;
	"16")
		conver
		;;
	"17")
		infcheck
        ecuttest
		script_ecut
		;;
	"18")
		infcheck
        kptest
		script_kp
		;;
	"19")
		gengnuplot
		;;
esac
}		

rmainfunc		

  
  
