# Improving Zero-shot Translation


This repo implements the paper -- [__Improving Zero-shot Translation of Low-resource Languages__](https://arxiv.org/pdf/1811.01389.pdf). 


---

<!--
## Abstract

*...propose an __iterative
training__ procedure that leverages a duality of translations directly generated by the system for the zero-shot directions.
The translations produced by the system (sub-optimal since
they contain mixed language from the shared vocabulary),
are then used together with the original parallel data to feed
and iteratively re-train the multilingual network. Over time,
this allows the system to learn from its own generated and
increasingly better output. Approach shows to be effective in improving the two zero-shot directions of our multilingual model.*
-->

## Current procedure to run the code on Colab
```
git clone https://github.com/ekdnam/improving-zeroshot-nmt.git
bash setup-env.sh
bash scripts/get-ted-talks-data.sh
python scripts/ted_reader.py
python scripts/ted_reader_it.py
bash scripts/preprocess.sh 'it ro'
bash pretrain-baseline.sh
```

## Scenario

Before the experimental setup, if you are wondering what type of MT problem we are approaching, take into consideration the following scenario:


- For languages `X, Y, P`, parallel training data is available only for `X-P` and `Y-P` pairs
- This allows to train a [multiligual model](https://arxiv.org/abs/1611.04558) with four translation directions.
- At time of inference, however, you can attempt to translate between the `X-Y` pair -- also known as *Zero-Shot Translation* (ZST).


Given the large majority of language pairs lack parallel data, ZST becomes a super exciting approach, especially if the translations are usable. 
However, it is mostly the case to get poor ZST outputs. 
For instance, mixed language on top of wrong translations. 
<!--This translation issues occur primarily for the simple reason that the model not explicityly observing parallel data for zero-shot pair. -->


What you are going to replicate below answers the question -- *how to further improve over the naive zero-shot inference leveraging a baseline multiligual model.*  For further details on the approach see the [paper](https://arxiv.org/pdf/1811.01389.pdf).



# Experimental Setup
---

#### Requirements

- [Fairseq](https://github.com/pytorch/fairseq)
- [Moses](https://github.com/moses-smt/mosesdecoder)
- [Subword NMT](https://github.com/rsennrich/subword-nmt)

`./setup-env.sh` or see dependecies for each repo.



## Data Preparation 

For this experiment, we use the [TED Talks data](http://phontron.com/data/ted_talks.tar.g) from [Qi et al.](https://www.aclweb.org/anthology/N18-2084).


`./scripts/get-ted-talks-data.sh`




## Pre-Training Baseline (Multilingual) Model

Following the scenario, (`X, Y, P`) languages, lets take Italian/X (it), Romanian/Y (ro), and English/P (en). 



#### Preprocess

`./scripts/preprocess.sh 'it ro'`  


We assume `en` as the target for the `it, ro` source. In total we process a 4 direction multilingual training data.



#### Pre-Training

`./pretrain-baseline.sh`



## Train Zero-Shot Model

Before the ZST training, lets extract `n-way` parallel evaluation data (e.g. `X-P-Y`) from the `X-P` and `Y-P` pairs. This is important for evaluating the `X<>Y` ZST pair or the alternative pivoting translation `X<>P<>Y`. 

`./scripts/get-n-way-parallel-data.sh [zst-src-lang-id] [zst-tgt-lang-id] [pivot-lang-id]`



#### Train ZST Model

`./train-zst-model.sh [zst-src-lang-id] [zst-tgt-lang-id] [pre-trained-model-dir] [zst-training-rounds] [gpu-id]` 


<!--
*Regardless of the underlying NMT training framework (here we use fairseq), this script implements the proposed approach. Basically an inference and training stages alternate for `N` rounds for both of the ZST directions.* 
-->


#### Evaluation
Takes a preprocessed source file, translate and evaluates. For src-pivot-tgt pivot based evaluation, specify the pivot language id.  


`./translate_evaluate.sh [data-bin-dir] [src-input] [model] [gpu-id] [src-lang-id] [tgt-lang-id] [pivot-lang-id]`


<!-- 
`./inference.sh [data-bin-dir] [input-file] [model] [gpu-id]`

Compute BLEU
`./compute-bleu.sh [hypothesis-file] [reference-file]`

-->

---

#### Reference
```bibtex
@article{lakew2018improving,
  title={Improving zero-shot translation of low-resource languages},
  author={Lakew, Surafel M and Lotito, Quintino F and Negri, Matteo and Turchi, Marco and Federico, Marcello},
  journal={arXiv preprint arXiv:1811.01389},
  year={2018}
}

@article{lakew2019multilingual,
  title={Multilingual Neural Machine Translation for Zero-Resource Languages},
  author={Lakew, Surafel M and Federico, Marcello and Negri, Matteo and Turchi, Marco},
  journal={arXiv preprint arXiv:1909.07342},
  year={2019}
}
```
