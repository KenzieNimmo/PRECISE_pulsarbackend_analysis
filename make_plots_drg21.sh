DATE='20210222'
EFF='False'
SRT='True'

ADD_MASK='None'
#ADD_MASK='350:420,230:240' #basically your -zapchan input for rfifind                                                                                                
BEGIN_MASK='None' #BEGIN_MASK='350,230'                                                                                                                               
END_MASK='None' #these are the inputs for pulses_extract #END_MASK='420,240'

if [  $EFF = 'True' ]
then
    cd /data2/nimmo/PRECISE/$DATE/analysis/

    if [[ -d ../rawfiles/R4_D ]]
    then
	for f in ../rawfiles/R4*/*out.fil; do
            base1=${f##*/}
            base=${base1%.out.fil}
            cd ./$base
	    if [ $ADD_MASK != 'None' ]
	    then
		python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 80 -mask -DM_high 120 -DM_step 0.3 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
	    fi
	    if [ $ADD_MASK = 'None' ]
	    then
		python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 80 -mask -DM_high 120 -DM_step 0.3 -SN_peak 7.0  -save_fig > pulses_extract.log
            fi
	    mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done
    fi

    if [[ -d ../rawfiles/R200120_D ]]
    then
	for f in ../rawfiles/R200120*/*out.fil; do
            base1=${f##*/}
            base=${base1%.out.fil}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 70 -mask -DM_high 110 -DM_step 0.3 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 70 -mask -DM_high 110 -DM_step 0.3 -SN_peak 7.0  -save_fig > pulses_extract.log
            fi
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done
    fi


    if [[ -d ../rawfiles/R2_D ]]
    then
        for f in ../rawfiles/R2*/*out.fil; do
            base1=${f##*/}
            base=${base1%.out.fil}
            cd ./$base
	    if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 170 -mask -DM_high 210 -DM_step 0.3 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
	    fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 170 -mask -DM_high 210 -DM_step 0.3 -SN_peak 7.0  -save_fig > pulses_extract.log
	    fi
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done
    fi

    if [[ -d ../rawfiles/R6_D ]]
    then
	for f in ../rawfiles/R6*/*out.fil; do
            base1=${f##*/}
            base=${base1%.out.fil}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 345 -mask -DM_high 385 -DM_step 0.5 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 345 -mask -DM_high 385 -DM_step 0.5 -SN_peak 7.0  -save_fig > pulses_extract.log
            fi
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done
    fi

fi

if [ $SRT = 'True' ]
then
    cd /data2/nimmo/PRECISE/SRT/$DATE/analysis/

    if [[ -d ../rawfiles/R12_D ]]
    then
	for f in ../rawfiles/R12*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 440 -mask -DM_high 480 -DM_step 0.5 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 440 -mask -DM_high 480 -DM_step 0.5 -SN_peak 7.0 -save_fig > pulses_extract.log
            fi
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done

    fi


    if [[ -d ../rawfiles/R17_D ]]
    then
	for f in ../rawfiles/R17*/*sf; do
	    base1=${f##*/}
	    base=${base1%.sf}
	    cd ./$base
	    if [ $ADD_MASK != 'None' ]
            then
		python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 205 -mask -DM_high 235 -DM_step 0.1 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
	    fi
	    if [ $ADD_MASK = 'None' ]
            then
		python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 205 -mask -DM_high 235 -DM_step 0.1 -SN_peak 7.0 -save_fig > pulses_extract.log
       	    fi
	    mkdir pulse_cands
	    mv *.png pulse_cands
	    cd ..
	done
    fi

    if [[ -d ../rawfiles/R4_D ]]
    then
	for f in ../rawfiles/R4*/*sf; do
	    base1=${f##*/}
	    base=${base1%.sf}
	    cd ./$base
	    if [ $ADD_MASK != 'None' ]
	    then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 80 -mask -DM_high 120 -DM_step 0.2 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig -dmtrue 103.5 > pulses_extract.log
	    fi
	    if [ $ADD_MASK = 'None' ]
	    then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 80 -mask -DM_high 120 -DM_step 0.2 -SN_peak 7.0 -save_fig -dmtrue 103.5 > pulses_extract.log
	    fi
	    mkdir pulse_cands
	    mv *.png pulse_cands
	    cd ..
        done
    fi


    if [[ -d ../rawfiles/R16_D ]]
    then 
	for f in ../rawfiles/R16*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 370 -mask -DM_high 410 -DM_step 0.5 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 370 -mask -DM_high 410 -DM_step 0.5 -SN_peak 7.0 -save_fig > pulses_extract.log
            fi
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done

    fi

    if [[ -d ../rawfiles/R2_D ]]
    then
        for f in ../rawfiles/R2*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 170 -mask -DM_high 210 -DM_step 0.2 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig -dmtrue 189.0 > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 170 -mask -DM_high 210 -DM_step 0.2 -SN_peak 7.0 -save_fig -dmtrue 189.0 > pulses_extract.log
            fi
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done
    fi


fi
    


