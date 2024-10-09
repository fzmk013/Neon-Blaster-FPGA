setMode -bs
setMode -bs
setMode -bs
setMode -bs
setCable -port svf -file "E:/ISE/CAD971VGA_Xilinx/CAD971VGA/aaa.svf"
addDevice -p 1 -file "E:/ISE/CAD971VGA_Xilinx/CAD971VGA/cad971test.bit"
Program -p 1 
setMode -bs
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
saveProjectFile -file "E:\ISE\CAD971VGA_Xilinx\CAD971VGA\\auto_project.ipf"
setMode -bs
setMode -bs
deleteDevice -position 1
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
