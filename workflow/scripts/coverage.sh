normalize=$1
sample=$2
input=$3
output=$4
params=$5

if [ "$normalize" = "True" ]; then
    normVal=$(awk -v sam=$sample '$1 == sam {print $2}' ./results/normalize/scale)
else
    normVal='1'
fi

genomeCoverageBed "$params" -scale $normVal "$input" > "$output"