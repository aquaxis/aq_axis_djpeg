set PROJECT_NAME aq_axis_djpeg
# ZYBO-Z7-20
#set PART_NAME xc7z020clg400-1
# FZ3
set PART_NAME xazu3eg-sfvc784-1-i

create_project $PROJECT_NAME ./$PROJECT_NAME -part $PART_NAME -force

set FILES [list \
           ./sources/aq_axis_djpeg.v \
           ./sources/aq_axis_djpeg_ctrl.v \
           ./sources/aq_djpeg.v \
           ./sources/aq_djpeg_dht.v \
           ./sources/aq_djpeg_dqt.v \
           ./sources/aq_djpeg_fsm.v \
           ./sources/aq_djpeg_hm_decode.v \
           ./sources/aq_djpeg_huffman.v \
           ./sources/aq_djpeg_idct.v \
           ./sources/aq_djpeg_idct_calc.v \
           ./sources/aq_djpeg_idctb.v \
           ./sources/aq_djpeg_regdata.v \
           ./sources/aq_djpeg_ycbcr.v \
           ./sources/aq_djpeg_ycbcr2rgb.v \
           ./sources/aq_djpeg_ycbcr_mem.v \
           ./sources/aq_djpeg_ziguzagu.v \
          ]

add_files -norecurse $FILES

set SIM_FILES [list \
           ./testbench/task_axilm.v \
           ./testbench/tb_aq_axis_djpeg.v \
]

add_files -fileset sim_1 -norecurse $SIM_FILES

ipx::package_project -root_dir ./ -vendor aquaxis.com -library aquaxis -taxonomy /UserIP

set_property core_revision 1 [ipx::current_core]

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
