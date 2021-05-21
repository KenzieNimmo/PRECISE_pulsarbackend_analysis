cd /data2/nimmo/PRECISE/SRT/20201107/analysis/

if [[ -d ../rawfiles/R17_D ]]
then
    for f in ../rawfiles/R17*/*sf; do
        base1=${f##*/}
        base=${base1%.sf}
        cd ./$base
        python ~/pulses_extract/src/pulses_extract_indep.py -file_name 2020*.fil -DM_low 200 -mask -DM_high 240 -DM_step 0.5 -SN_peak 7.0 -begin_mask 0,670,1000,100,830 -end_mask 350,730,1024,130,860 -save_fig > pulses_extract.log
        mkdir pulse_cands
        mv *.png pulse_cands
        cd ..
    done

fi
