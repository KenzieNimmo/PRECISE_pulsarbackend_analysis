DATE='20210410'
EFF='True'
SRT='False'

ADD_MASK='400:450'
#ADD_MASK='350:420,230:240' #basically your -zapchan input for rfifind                                                                                                
BEGIN_MASK='400' #BEGIN_MASK='350,230'                                                                                                                              
END_MASK='450' #these are the inputs for pulses_extract #END_MASK='420,240'     

if [ $EFF = 'True' ]
then
    cd /data2/nimmo/PRECISE/$DATE/analysis/
    if [[ -d ../rawfiles/R180301_D ]]
    then
        for f in ../rawfiles/R180301*/*out.fil; do
            base1=${f##*/}
            base=${base1%.out.fil}
            mkdir ./$base
            cd ./$base
            ln -s ../$f ./
            rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
            if [ $ADD_MASK != 'None' ]
            then
                rfifind -nocompute -zapchan $ADD_MASK -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
            fi
            bash ~/FRB_PRECISE_analysis/command_files/command_Eff_R180301.txt $base > pipeline_$base.sh
            bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 8
            cp DM_*/*.singlepulse ./
            cd ..
        done

        for f in ../rawfiles/R180301*/*out.fil; do
            base1=${f##*/}
            base=${base1%.out.fil}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 500 -mask -DM_high 540 -DM_step 1 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 500 -mask -DM_high 540 -DM_step 1 -SN_peak 7.0  -save_fig > pulses_extract.log
            fi
            mkdir pulse_cands
	    mv *.png pulse_cands
            cd ..
        done
    fi

    if [[ -d ../rawfiles/R67_D ]]
    then
        for f in ../rawfiles/R67*/*out.fil; do
            base1=${f##*/}
            base=${base1%.out.fil}
            mkdir ./$base
            cd ./$base
            ln -s ../$f ./
            rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
            if [ $ADD_MASK != 'None' ]
            then
                rfifind -nocompute -zapchan $ADD_MASK -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
            fi
            bash ~/FRB_PRECISE_analysis/command_files/command_Eff_R67.txt $base > pipeline_$base.sh
            bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 7
            cp DM_*/*.singlepulse ./
            cd ..
        done

        for f in ../rawfiles/R67*/*out.fil; do
            base1=${f##*/}
            base=${base1%.out.fil}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 390 -mask -DM_high 430 -DM_step 3 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig -dmtrue 413 > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 390 -mask -DM_high 430 -DM_step 3 -SN_peak 7.0  -save_fig > pulses_extract.log
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
            mkdir ./$base
            cd ./$base
            ln -s ../$f ./
            rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
            if [ $ADD_MASK != 'None' ]
            then
                rfifind -nocompute -zapchan $ADD_MASK -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
            fi
            bash ~/FRB_PRECISE_analysis/command_files/command_Eff_R200120.txt $base > pipeline_$base.sh
            bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 10
            cp DM_*/*.singlepulse ./
            cd ..
        done

        for f in ../rawfiles/R200120*/*out.fil; do
            base1=${f##*/}
            base=${base1%.out.fil}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 70 -mask -DM_high 100 -DM_step 1 -SN_peak 7.0 -dmtrue 88 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 70 -mask -DM_high 100 -DM_step 1 -SN_peak 7.0 -dmtrue 88 -save_fig > pulses_extract.log
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
	    mkdir ./$base
	    cd ./$base
	    ln -s ../$f ./$base1
	    digifil -o $base.fil -b 8 ./$base1
	    rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
	    rfifind -nocompute -zapchan 674:1023,294:364,0:3,894:924,164:194 -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
	    bash ~/FRB_PRECISE_analysis/command_lowDM.txt $base > pipeline_$base.sh
	    bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 16
	    cp DM_*/*.singlepulse ./
	    cd ..
	done

	for f in ../rawfiles/R17*/*sf; do
	    base1=${f##*/}
	    base=${base1%.sf}
	    cd ./$base
	    python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 205 -mask -DM_high 235 -DM_step 0.1 -SN_peak 7.0 -begin_mask 674,294,0,894,164 -end_mask 1023,364,3,924,194 -save_fig > pulses_extract.log
	    mkdir pulse_cands
	    mv *.png pulse_cands
	    cd ..
	done
	
    fi

    if [[ -d ../rawfiles/R25_D ]]
    then
        for f in ../rawfiles/R25_D/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            mkdir ./$base
            cd ./$base
            ln -s ../$f ./$base1
            digifil -o $base.fil -b 8 ./$base1
            rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
	    rfifind -nocompute -zapchan 674:1023 -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
            bash ~/FRB_PRECISE_analysis/command_lowDM.txt $base > pipeline_$base.sh
            bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 16
            cp DM_*/*.singlepulse ./
            cd ..
        done

        for f in ../rawfiles/R25*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 205 -mask -DM_high 235 -DM_step 0.1 -SN_peak 7.0 -begin_mask 674 -end_mask 1023 -save_fig > pulses_extract.log
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
	    if [ $ADD_MASK != 'None' ]
            then
                rfifind -nocompute -zapchan $ADD_MASK -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
            fi

            bash ~/FRB_PRECISE_analysis/command_lowDM.txt $base > pipeline_$base.sh
            bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 16
            cp DM_*/*.singlepulse ./
            cd ..
        done

        for f in ../rawfiles/R14*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 280 -mask -DM_high 320 -DM_step 0.3 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 280 -mask -DM_high 320 -DM_step 0.3 -SN_peak 7.0  -save_fig > pulses_extract.log
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
            mkdir ./$base
            cd ./$base
            ln -s ../$f ./$base1
            digifil -o $base.fil -b 8 ./$base1
            python ~/FRB_PRECISE_analysis/crop_freq_fil.py ./$base.fil
            rm ./$base.fil
            rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
            if [ $ADD_MASK != 'None' ]
            then
                rfifind -nocompute -zapchan $ADD_MASK -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
            fi
            bash ~/FRB_PRECISE_analysis/command_files/command_SRT_R4.txt $base > pipeline_$base.sh
            bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 9
            cp DM_*/*.singlepulse ./
            cd ..
        done

	for f in ../rawfiles/R4*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 80 -mask -DM_high 120 -DM_step 0.2 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig -dmtrue 103.5  > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 80 -mask -DM_high 120 -DM_step 0.2 -SN_peak 7.0 -save_fig -dmtrue 103.5 > pulses_extract.log
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
            mkdir ./$base
            cd ./$base
            ln -s ../$f ./$base1
            digifil -o $base.fil -b 8 ./$base1
            python ~/FRB_PRECISE_analysis/crop_freq_fil.py ./$base.fil
            rm ./$base.fil
            rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
            if [ $ADD_MASK != 'None' ]
            then
                rfifind -nocompute -zapchan $ADD_MASK -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
            fi
            bash ~/FRB_PRECISE_analysis/command_files/command_SRT_R2.txt $base > pipeline_$base.sh
            bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 11
            cp DM_*/*.singlepulse ./
            cd ..
        done

	for f in ../rawfiles/R2*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                !python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 170 -mask -DM_high 210 -DM_step 0.2 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                !python ~/pulses_extract/src/pulses_extract_indep.py -file_name *.fil -DM_low 170 -mask -DM_high 210 -DM_step 0.2 -SN_peak 7.0 -save_fig > pulses_extract.log
            fi
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done

    fi

    if [[ -d ../rawfiles/R5_D ]]
    then
        for f in ../rawfiles/R5*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            mkdir ./$base
            cd ./$base
            ln -s ../$f ./$base1
            digifil -o $base.fil -b 8 ./$base1
            rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
            if [ $ADD_MASK != 'None' ]
            then
                rfifind -nocompute -zapchan $ADD_MASK -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
            fi

            bash ~/FRB_PRECISE_analysis/command_files/command_SRT_R5.txt $base > pipeline_$base.sh
            bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 9
            cp DM_*/*.singlepulse ./
            cd ..
        done

        for f in ../rawfiles/R5*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            if [ $ADD_MASK != 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 430 -mask -DM_high 470 -DM_step 0.5 -SN_peak 7.0 -begin_mask $BEGIN_MASK -end_mask $END_MASK -save_fig > pulses_extract.log
            fi
            if [ $ADD_MASK = 'None' ]
            then
                python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 430 -mask -DM_high 470 -DM_step 0.5 -SN_peak 7.0  -save_fig > pulses_extract.log
            fi
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done

    fi

fi
    


