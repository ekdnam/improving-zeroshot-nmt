#!/bin/bash

set -e

# === UPDATE ACCORDINGLY ===
SRCS=$1 #"it ro"  	# different sources, initial paper includes 'de nl it ro'
TGTS="en"		# fixed since ./data/ted-data/ANY-en dir structure 
#BIDIRECTION=true	# if true, aggregate data both in src<>tgt directions
ADD_LANGID=true 	# if true, adds tgt lang_id on src side examples, set false for single pair settings
BPESIZE=32000


MOSES=$PWD/mosesdecoder/scripts
NORM=$MOSES/tokenizer/normalize-punctuation.perl
TOK=$MOSES/tokenizer/tokenizer.perl
DEES=$MOSES/tokenizer/deescape-special-chars.perl


DATA=$PWD/data/ted-data 		
EXPDIR=$PWD/pretrain-model

PRE_DATA=$EXPDIR/data/pre-data
BPE_MODEL=$EXPDIR/data/bpe-model
BPE_DATA=$EXPDIR/data/bpe-data
BIN_DATA=$EXPDIR/data/bin-data
# ===	===


if [ ! -d $PRE_DATA ]; then 
mkdir -p $PRE_DATA 
pushd $PRE_DATA

for SRC in $SRCS; do
  for TGT in $TGTS; do
 
    if [ $SRC != $TGT ]; then # && [ ! -d $PRE_DATA ]; then 
      echo "PREPROCESSING $SRC <> $TGT DATA: $PWD"

      for SET in train dev test; do
      RAW_DATA=$DATA/$TGT_$SRC/${SET}
# 	RAW_DATA=$DATA/$SRC-$TGT/${SET}

	# if adding lang_id, data should aggregate in bidirectional SRC<>TGT
	if $ADD_LANGID; then 
          $NORM < ${RAW_DATA}.$SRC | $TOK -l $SRC -q | $DEES | awk -vtgt_tag="<2${TGT}>" '{ print tgt_tag" "$0 }' > ${SET}.src	#$SRC 
          $NORM < ${RAW_DATA}.$TGT | $TOK -l $TGT -q | $DEES | awk -vtgt_tag="<2${SRC}>" '{ print tgt_tag" "$0 }' > ${SET}.src	#$SRC 

          $NORM < ${RAW_DATA}.$TGT | $TOK -l $TGT -q | $DEES > ${SET}.tgt
          $NORM < ${RAW_DATA}.$SRC | $TOK -l $SRC -q | $DEES > ${SET}.tgt	
	else
          $NORM < ${RAW_DATA}.$SRC | $TOK -l $SRC -q | $DEES > ${SET}.src
          $NORM < ${RAW_DATA}.$TGT | $TOK -l $TGT -q | $DEES > ${SET}.tgt
	fi

      done

    fi

  done
done

popd
fi
