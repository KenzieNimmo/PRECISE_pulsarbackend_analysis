DATE='20201107'
EFF='False'
SRT='True'

if [ $EFF = 'True' ]
then
    cd /data2/nimmo/PRECISE/$DATE/analysis/
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
        for f in ../rawfiles/R25*/*sf; do
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

        for f in ../rawfiles/R25*/*sf; do
            base1=${f##*/}
            base=${base1%.sf}
            cd ./$base
            python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 205 -mask -DM_high 235 -DM_step 0.1 -SN_peak 7.0 -begin_mask 674,294,0,894,164 -end_mask 1023,364,3,924,194 -save_fig > pulses_extract.log
            mkdir pulse_cands
            mv *.png pulse_cands
            cd ..
        done
	
    fi

    
    #if [[ -d ../rawfiles/R14_D ]]
    #then
    #    for f in ../rawfiles/R14*/*sf; do
    #        base1=${f##*/}
    #        base=${base1%.sf}
    #        mkdir ./$base
    ##       cd ./$base
    #        ln -s ../$f ./$base1
    #        digifil -o $base.fil -b 8 ./$base1
    #        rfifind  -noclip -time 0 -o rfimask ./*.fil > rfi_$base.log
    #        rfifind -nocompute -zapchan 674:1023,294:364,0:3,894:924,164:194 -mask rfimask_rfifind.mask -o rfimask ./*.fil > rfi_$base.log
    #        bash ~/FRB_PRECISE_analysis/command_lowDM.txt $base > pipeline_$base.sh
    #        bash ~/FRB_PRECISE_analysis/parallel.sh pipeline_$base.sh 16
    #        cp DM_*/*.singlepulse ./
    #        cd ..
    #    done

    #    for f in ../rawfiles/R14*/*sf; do
    #        base1=${f##*/}
    #        base=${base1%.sf}
    #        cd ./$base
    #        python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 280 -mask -DM_high 320 -DM_step 0.1 -SN_peak 7.0 -begin_mask 674,294,0,894,164 -end_mask 1023,364,3,924,194 -save_fig > pulses_extract.log
    #        mkdir pulse_cands
    #        mv *.png pulse_cands
    #        cd ..
    #    done

#    fi
fi
    


