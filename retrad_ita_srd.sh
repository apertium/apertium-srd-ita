make && cat ../Scrivania/apertium-ita/corpus/corpus_it_wp10000.txt | apertium -d . ita-srd > nova_trad_ita_srd.txt
diff act_trad_ita_srd.txt nova_trad_ita_srd.txt | more
