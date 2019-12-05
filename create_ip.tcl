set PROJECT_NAME aq_axis_djpeg
set PART_NAME xc7z020clg400-1

create_project $PROJECT_NAME ./$PROJECT_NAME -part $PART_NAME -force

set FILES [list \
           ../$PROJECT_NAME/src/aq_axi_djpeg.v \
           ../$PROJECT_NAME/src/aq_axi_djpeg_ctrl.v \
           ../$PROJECT_NAME/src/aq_djpeg.v \
           ../$PROJECT_NAME/src/aq_djpeg_dht.v \
           ../$PROJECT_NAME/src/aq_djpeg_dqt.v \
           ../$PROJECT_NAME/src/aq_djpeg_fsm.v \
           ../$PROJECT_NAME/src/aq_djpeg_hm_decode.v \
           ../$PROJECT_NAME/src/aq_djpeg_huffman.v \
           ../$PROJECT_NAME/src/aq_djpeg_idct.v \
           ../$PROJECT_NAME/src/aq_djpeg_idct_calc.v \
           ../$PROJECT_NAME/src/aq_djpeg_idctb.v \
           ../$PROJECT_NAME/src/aq_djpeg_regdata.v \
           ../$PROJECT_NAME/src/aq_djpeg_ycbcr.v \
           ../$PROJECT_NAME/src/aq_djpeg_ycbcr2rgb.v \
           ../$PROJECT_NAME/src/aq_djpeg_ycbcr_mem.v \
           ../$PROJECT_NAME/src/aq_djpeg_ziguzagu.v \
          ]

add_files -norecurse $FILES

ipx::package_project -root_dir ../$PROJECT_NAME -vendor aquaxis.com -library aquaxis -taxonomy /UserIP

set_property core_revision 1 [ipx::current_core]

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

               
    
    
                  
         
       
