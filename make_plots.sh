DATE='20201115'
EFF='True'
SRT='False'

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

fi

if [ $SRT = 'True' ]
then
    cd /data2/nimmo/PRECISE/SRT/$DATE/analysis/

    if [[ -d ../rawfiles/R17_D ]]
    then
	for f in ../rawfiles/R17*/*sf; do
	    base1=${f##*/}
	    base=${base1%.sf}
	    cd ./$base
	    python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 205 -mask -DM_high 235 -DM_step 0.1 -SN_peak 7.0 --begin_mask 0,670,1000,100,830 --end_mask 350,730,1024,130,860 -save_fig > pulses_extract.log
	    mkdir pulse_cands
	    mv *.png pulse_cands
	    cd ..
	done
	
    fi

    if [[ -d ../rawfiles/R25_D ]]
    then
        for f in ../rawfiles/R25*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 205 -mask -DM_high 235 -DM_step 0.1 -SN_peak 7.0 --begin_mask 0,670,1000,100,830 --end_mask 350,730,1024,130,860 -save_fig > pulses_extract.log
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done
	
    fi

    
    if [[ -d ../rawfiles/R14_D ]]
    then
        for f in ../rawfiles/R14*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            mkdir ./$base
            cd ./$base
            ln -s ../$f ./$base1
            digifil -o $base.fil -b 8 ./$base1
            rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
            rfifind -nocompute -zapchan 0:350,660:730,1000:1024,100:130,830:860 -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
            bash ~/FRB_PRECISE_analysis/command_lowDM.txt $base > pipeline_$base.sh
            bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 16
            cp DM_*/*.singlepulse ./
            cd ..
        done

        for f in ../rawfiles/R14*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 280 -mask -DM_high 320 -DM_step 0.1 -SN_peak 7.0 --begin_mask 0,670,1000,100,830 --end_mask 350,730,1024,130,860 -save_fig > pulses_extract.log
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done

    fi
fi
    


