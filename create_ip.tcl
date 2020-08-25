set PROJECT_NAME aq_axis_djpeg
set PART_NAME xc7a100tcsg324-1

create_project $PROJECT_NAME ./$PROJECT_NAME -part $PART_NAME -force

set FILES [list \
           ./src/aq_axis_djpeg.v \
           ./src/aq_axis_djpeg_ctrl.v \
           ./src/aq_djpeg.v \
           ./src/aq_djpeg_dht.v \
           ./src/aq_djpeg_dqt.v \
           ./src/aq_djpeg_fsm.v \
           ./src/aq_djpeg_hm_decode.v \
           ./src/aq_djpeg_huffman.v \
           ./src/aq_djpeg_idct.v \
           ./src/aq_djpeg_idct_calc.v \
           ./src/aq_djpeg_idctb.v \
           ./src/aq_djpeg_regdata.v \
           ./src/aq_djpeg_ycbcr.v \
           ./src/aq_djpeg_ycbcr2rgb.v \
           ./src/aq_djpeg_ycbcr_mem.v \
           ./src/aq_djpeg_ziguzagu.v \
          ]
		  
add_files -norecurse $FILES

set imgfg [ipx::get_file_groups xilinx_utilityxitfiles]
set imgfile [list \
			 ./xgui/jpegc.png
			 ]

set nimfile [ipx::add_file $imgfile $imgfg]

set_property type [list image LOGO] $nimfile

ipx::package_project -root_dir ./ -vendor aquaxis.com -library aquaxis -taxonomy /UserIP

set_property core_revision 1 [ipx::current_core]

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

               
    
    
                  
         
       
