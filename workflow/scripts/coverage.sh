normalize="$1"
sample="$2"
input="$3"
output="$4"

if [ "$normalize" = "True" ]; then
    normVal=$(awk -v sam=$sample '$1 == sam {print $2}' ./results/normalize/scale)
else
    normVal='1'
fi

bedtools genomecov "$5" -scale $normVal -ibam "$input" > "$output"