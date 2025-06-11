from pymatgen.io.lobster.inputs import Lobsterin

Lobsterin.write_POSCAR_with_standard_primitive(
    POSCAR_input="POSCAR",
    POSCAR_output="POSCAR.lobster"
)

Lobsterin.write_KPOINTS(
    POSCAR_input="POSCAR",
    KPOINTS_output="KPOINTS.lobster",
    reciprocal_density=100,
    isym=0,
    line_mode=True,
    kpoints_line_density=20
)
