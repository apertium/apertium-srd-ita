#!/bin/bash

set -e -u

if [[ $# -eq 1 ]]; then
    mode=$1
    dix=guess
elif  [[ $# -eq 2 ]]; then
    mode=$1
    dix=$2
else
    cat >&2 <<EOF
Usage: $0 lang1-lang2
or:    $0 lang1-lang2 foo.dix

Replaces the first step of the pipeline with the expanded analyser and
shows the resulting generation errors.

For example, do \`$0 nno-nob' in trunk/apertium-nno-nob/'
to find generation errors in the nno-nob direction (assumes that
modes/nno-nob.mode exists). If the source .dix file has a non-standard
name, you can specify it in the second argument, for example
\`$0 eng-sco ../apertium-eng_feil/apertium-eng.eng.dix'
EOF
    exit 1
fi

analysis_expansion () {
    lt-print "$1".automorf.bin \
        | sed 's/ /@_SPACE_@/g' \
        | hfst-txt2fst -e ε \
        | hfst-project -p lower \
        | hfst-fst2strings  -c0  \
        | awk -v clb="$2" '
          /[][$^{}\\]/{next} # skip escaping hell
          {
            gsub("]","\\]")
            esc=$0
            gsub("/","\\/",esc)
            gsub("^","\\^",esc)
            gsub("$","\\$",esc)
            print "["esc"] ^"$0"$ ^.<sent>"clb"$"
          }'
          # give the "disambiguated" output, no forms
}

split_ambig () {
    if command -V pypy3 &>/dev/null; then
        python=pypy3
    else
        python=python3
    fi
    PYTHONPATH="$(dirname "$0"):${PYTHONPATH:-}" "${python}" -c '
from streamparser import parse_file, readingToString
import sys
for blank, lu in parse_file(sys.stdin, withText=True):
    print(blank+" ".join("^{}/{}$".format(lu.wordform, readingToString(r))
                         for r in lu.readings),
          end="")'

}

mode_after_analysis ()
{
    eval $(grep '|' "$1" |\
                  sed 's/[^|]*|//' |\
                  sed 's/.*apertium-pretransfer/apertium-pretransfer/' |\
                  sed 's/lt-proc -p[^|]*/cat/' |\
                  sed 's/autobil.bin *|/& split_ambig |/' |\
                  sed 's/\$1/-d/g;s/\$2//g')
    # lt-proc -p fails
}

only_errs () {
    grep '][^<]*[#/]'
}


lang1=${mode%%-*}

if [[ ${dix} = guess ]]; then
    lang1dir=$(grep -m1 "^AP_SRC.*apertium-${lang1}" config.log | sed "s/^[^=]*='//;s/'$//")
    dix=${lang1dir}/apertium-${lang1}.${lang1}.dix
fi

clb=""
case ${lang1} in
    nno|nob) clb="<clb>" ;;
esac

# Make it possible to edit the .dix while testvoc is running:
dixtmp=$(mktemp -t gentestvoc.XXXXXXXXXXX)
trap 'rm -f "${dixtmp}"' EXIT
cat "${dix}" > "${dixtmp}"

analysis_expansion "${mode}" "${clb}" \
    | mode_after_analysis modes/"${mode}".mode \
    | only_errs
