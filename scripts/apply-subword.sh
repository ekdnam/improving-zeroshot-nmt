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


# apply sub-word segmentation
if [ ! -d $BPE_DATA ]; then
 mkdir $BPE_DATA

 for SET in train dev test; do
  subword-nmt apply-bpe -c $BPE_MODEL/code.${BPESIZE}.bpe < $PRE_DATA/${SET}.src > $BPE_DATA/${SET}.src 
  subword-nmt apply-bpe -c $BPE_MODEL/code.${BPESIZE}.bpe < $PRE_DATA/${SET}.tgt > $BPE_DATA/${SET}.tgt
 done
fi