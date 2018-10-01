---
title: Creating a n-gram Language Model using Wikipedia
layout: post
---

<div class="alert alert-primary" role="alert">
  <strong>TLDR</strong>: This article describes how to train a n-gram Language Model of any order using Wikipedia articles. The code used is available from <a href="https://github.com/tiefenauer/wiki-lm" target="_blank">my GitHub repo</a>.
</div>

For my master thesis at [FHNW] I am building a pipeline for [Forced Alignment] (FA). This pipeline requires an [Automatic Speech Recognition] (ASR) system in one stage to produce partial transcripts for voiced audio segments that were detected using [Voice Activity Detection] (VAD) from [WebRTC]. Luckily, there is a Python module called [webrtcvad] containing the C-bindings for the VAD-part of WebRTC and is therefore very fast and accurate. Those partial transcripts are then locally aligned with the (known) full transcript using the [Smith Waterman] (SM) algorithm (see [my blog post]({{ site.baseurl }}{% post_url 2018-07-13-smith-waterman %}) for an implementation in Python).

## On the road to ASR

A Speech-to-Text (STT) engine is used to implement the ASR stage. Because of time constraints, I just plugged in an API call to [Google Cloud Speech-to-Text] engine and used whatever transcript was returned. This worked reasonably well, although even the STT engine from Google was not error free. Using this API I was able to prove the pipeline approch to be generally working. The downside were the costs that were billed by the minutes of audio transcribed and that I was not able to tune the engine to my needs. Concretely I suspected that a STT engine would suffice, that is not able to recognize speech with the same quality like the Google STT, but still well enough to be useful for the pipeline. So I had to try and train my own STT engine, for which I used a [Keras] implementation of a simplified version of the model presented in the [Deep Speech paper]. Note that there is already an [Mozilla implementation] of this model for TensorFlow, but that model aims for high accuracy in speech recognition, which is not what I wanted - my model did not need to be best in class, but merely _good enough_.

Although the pipeline has four stages (Preprocessing, VAD, ASR, LSA), the overall quality of the produced alignments will highly depend on the quality of the partial transcriptions and therefore on the LSA stage - meaning it would all come down on my simplified STT engine. The LSA stage is able to handle some errors, but only to a certain degree. This means the STT engine is at the heart of the pipeline and should be able to infer transcripts that are _good enough_ for the downstream local alignment stage. The quality of ASR systems is usually measured with the [Word Error Rate] (WER). The WER value of an ASR system can often be improved by using a [Language Model] (LM). A LM models the probability of a given sentence. The most widely used types of LM are [$$n$$-gram] models, where $$n$$ denotes the order of the model.

## Creating a LM from German Wikipedia articles

Since the ASR stage should also work for German recordings, I needed a LM for German. The only pre-trained $$n$$-gram model I found was one from [CMUSphinx], which is a 3-gram model. The file `cmusphinx-voxforge-de.lm.gz` at the [SourceForge] download center contains an [ARPA] file which contains the probabilities and backoff weights for the 1-, 2- and 3-grams. However, what I wanted was a 4-gram model. Luckily I found [KenLM] could be used to train n-gram LMs of any order. I only needed a corpus which contained one German sentence per line, words delimited by whitespace (as described in the [Corpus Formatting Notes]). I decided to train on articles and pages from German Wikipedia, which can be downloaded as a dump from [Wikipedia dumps]. The dump is a `*.bz2`-compressed XML file containing the articles in Wiki markup, which means some heavy preprocessing was needed in order to arrive at a raw text corpus in the expected input format.

### Preprocessing the Wikipedia dump

Creating a corpus is no trivial task, especially if the raw data is contained in XML and the actual raw text contains Wiki markup and other special characters, most (!) of which are not wanted in the corpus. Some Google Research revealed a few options for how to extract the raw text from a Wiki dump:

1. **[Wiki Parser](https://dizzylogic.com/wiki-parser)**: This is a tool written in C++ that seemed to work pretty well. The text extraction is comparably fast (1-2 hours for the whole dump), but the result still needs to be postprocessed by removing special characters and splitting the text into one sentence per line. Unfortunately, this tool only runs on Windows (I'm using Ubuntu) and does not offer functionality over a CLI, which means I cannot include it in a script.
2. **[WikiCorpus](https://radimrehurek.com/gensim/corpora/wikicorpus.html)**: This is the way to go proposed by a [post on KDnuggets]. _WikiCorpus_ is a class in the [Gensim] module, which can be used to extract the text from a Wikipedia dump as a stream of word tokens. According to the comments in the code, processing takes up to 8 hours, which is quite slow. Additionally, the tokenization into sentences is lost because each article is converted into a flat list of words. The module offers hooks to plug in a custom tokenization algorithm. However, since this is the core part of extracting the raw text, this probably requires a lot of coding to remove Wiki markup and transform all text into the expected output.
3. **[WikiExtractor](https://github.com/attardi/wikiextractor)**: This is a standalone Python class that can be used to _"clean"_ a Wikipedia corpus, i.e. extract the text from a database dump. I found that processing the dump with this implementation required approximately 2.5 hours on my personal laptop, which was much shorter than the Gensim implementation.

After some experimentation, I found that WikiExtractor last option offered the most bang for the buck for my purpose. Unfortunately, WikiExtractor does not write to a text file directly, but rather split the dump file into a bunch of compressed files with similar size. Each of these files contains a number of articles in the [Document Format]. This means, the results of WikiExtractor are just an intermediate product that needs further processing. Luckily, I found the amount required for this justifiable, using a combination of Bash and Python scripts to build a raw text corpus. I was able to script the whole process to build the corpus and train the LM on it and will describe the core steps here. You can find the whole implementation in [my GitHub repository](https://github.com/tiefenauer/wiki-lm).

### Building the corpus

The following bash script will define a few variables that will be used in the following scripts. Note that [Pipeline Viewer] is required to show a nice progress bar.

```bash
corpus_name="wiki_${language}"
lm_basename="${corpus_name}_${order}_gram"
tmp_dir="./tmp"  # directory for intermediate artifacts
lm_dir="./" # directory for trained model

cleaned_dir="${tmp_dir}/${corpus_name}_clean" # directory for WikiExtractor
corpus_file="${tmp_dir}/${corpus_name}.txt" # uncompressed corpus
lm_counts="${tmp_dir}/${corpus_name}.counts" # corpus vocabulary with counts (all words)
lm_vocab="${tmp_dir}/${corpus_name}.vocab" # corpus vocabulary used for training (most frequent words)
lm_arpa="${tmp_dir}/${lm_basename}.arpa" # ARPA file

lm_binary="${lm_dir}/${lm_basename}.klm" # KenLM binary file (this is the result of the script)
```

The following bash script will download the German Wikipedia dump (~6GB). This will take some time (at least in my case Wiki servers were quite slow when I downloaded the dump).

```bash
wget -O ${target_file} ${download_url}
```

The following bash script will use WikiExtractor split the dump into the directory defined by `$cleaned_dir` (about 1.6 GB). This took about 3 hours on my machine.

```bash
python3 ./WikiExtractor.py -c -b 25M -o ${cleaned_dir} ${target_file}
```

The following bash script will read the content of each compresed file and pipe ie to some [`sed`] commands to remove the `<doc>`-tag and all kinds of quotation marks. The number of processed articles is counted by `grep`ping the number of occurrences of the `<doc>`-tag. The result is the normalized and split into lines of sentences by piping it through a Python script called `create_lm.py`. This scripts prints its output to stdout and can be written to `$dewiki_txt`. This file can then be compressed to save space.

```bash
result=$(find $cleaned_dir -name '*bz2' -exec bzcat {} \+ \
        | pv \
        | tee >(    sed 's/<[^>]*>//g' \
                  | sed 's|["'\''„“‚‘]||g' \
                  | python3 ./create_corpus.py ${language} > ${corpus_file} \
               ) \
        | grep -e "<doc" \
        | wc -l)
echo "Processed ${result} articles and saved raw text in $corpus_file"
bzip2 ${corpus_file}
```

The [`create_lm.py`](https://github.com/tiefenauer/wiki-lm/blob/master/create_corpus.py) script processes each line by splitting it into sentences using [NLTK]. Each sentence is split into a list of word-tokens. Each token is then procesed by removing unwanted characters, replacing numbers by the `<num>`-token, trimming whitespaces and replacing each character with an ASCII character (if that is possible), a process called unidecoding. Note that umlauts are very common in German and should therefore not be replaced. I had to write a slightly modified version of the [`unidecode`] function from the Python module of the same name. The modified version will not replace umlauts, but the rest of the logic is identical.

The processed word-tokens are then concatenated again using a single whitespace and made lowercase. The result is the representation of a sentence that can be used for training a KenLM model and is written to stdout. Since the python script is called in a bash script and its output is written directly to the `$dewiki_txt`, `$dewiki_txt` will contain the raw text data with one sentence per line.

```python
import sys
import nltk
import re
import string

from sys import version_info
from unidecode import unidecode, _warn_if_not_unicode, Cache

if __name__ == '__main__':
    LANGUAGES = {'de': 'german', 'en': 'english'}
    lang = LANGUAGES[sys.argv[1]]
    for line in sys.stdin:
        for sentence in process_line(line, language=lang):
            print(sentence)

def process_line(line, min_words=4, language='german'):
    sentences = []
    sents = nltk.sent_tokenize(line.strip(), language=language)
    for sentence in sents:
        sentence_processed = process_sentence(sentence, min_words)
        if sentence_processed:
            sentences.append(sentence_processed)

    return sentences


def process_sentence(sent, min_words=4):
    words = [normalize_word(word) for word in nltk.word_tokenize(sent, language='german')]
    if len(words) >= min_words:
        return ' '.join(w for w in words if w).strip()  # prevent multiple spaces
    return ''


def normalize_word(token):
    _token = unidecode_keep_umlauts(token)
    _token = remove_punctuation(_token)  # remove any special chars
    _token = replace_numeric(_token, by_single_digit=True)
    _token = '<num>' if _token == '#' else _token  # if token was a number, replace it with <num> token
    return _token.strip().lower()


def remove_punctuation(text, punctiation_extended=string.punctuation + """"„“‚‘"""):
    return ''.join(c for c in text if c not in punctiation_extended)


def replace_numeric(text, numeric_pattern=re.compile('[0-9]+'), digit_pattern=re.compile('[0-9]'), repl='#',
                    by_single_digit=False):
    return re.sub(numeric_pattern, repl, text) if by_single_digit else re.sub(digit_pattern, repl, text)


def contains_numeric(text):
    return any(char.isdigit() for char in text)


def unidecode_keep_umlauts(text):
    # modified version from unidecode.unidecode_expect_ascii that does not replace umlauts
    _warn_if_not_unicode(text)
    try:
        bytestring = text.encode('ASCII')
    except UnicodeEncodeError:
        return _unidecode_keep_umlauts(text)
    if version_info[0] >= 3:
        return text
    else:
        return bytestring


def _unidecode_keep_umlauts(text):
    # modified version from unidecode._unidecode that keeps umlauts
    retval = []

    for char in text:
        codepoint = ord(char)

        # Basic ASCII, ä/Ä, ö/Ö, ü/Ü
        if codepoint < 0x80 or codepoint in [0xe4, 0xc4, 0xf6, 0xd6, 0xfc, 0xdc]:
            retval.append(str(char))
            continue

        if codepoint > 0xeffff:
            continue  # Characters in Private Use Area and above are ignored

        if 0xd800 <= codepoint <= 0xdfff:
            warnings.warn("Surrogate character %r will be ignored. "
                          "You might be using a narrow Python build." % (char,),
                          RuntimeWarning, 2)

        section = codepoint >> 8  # Chop off the last two hex digits
        position = codepoint % 256  # Last two hex digits

        try:
            table = Cache[section]
        except KeyError:
            try:
                mod = __import__('unidecode.x%03x' % (section), globals(), locals(), ['data'])
            except ImportError:
                Cache[section] = None
                continue  # No match: ignore this character and carry on.

            Cache[section] = table = mod.data

        if table and len(table) > position:
            retval.append(table[position])

    return ''.join(retval)


def check_lm(lm_path, vocab_path, sentence):
    import kenlm
    model = kenlm.LanguageModel(lm_path)
    print(f'loaded {model.order}-gram model from {lm_path}')
    print(f'sentence: {sentence}')
    print(f'score: {model.score(sentence)}')

    words = ['<s>'] + sentence.split() + ['</s>']
    for i, (prob, length, oov) in enumerate(model.full_scores(sentence)):
        two_gram = ' '.join(words[i + 2 - length:i + 2])
        print(f'{prob} {length}: {two_gram}')
        if oov:
            print(f'\t\"{words[i+1]}" is an OOV!')

    vocab = set(word for line in open(vocab_path) for word in line.strip().split())
    print(f'loaded vocab with {len(vocab)} unique words')
    print()
    word = input('Your turn now! Start a sentence by writing a word: (enter nothing to abort)\n')
    sentence = ''
    state_in, state_out = kenlm.State(), kenlm.State()
    total_score = 0.0
    model.BeginSentenceWrite(state_in)

    while word:
        sentence += ' ' + word
        sentence = sentence.strip()
        print(f'sentence: {sentence}')
        total_score += model.BaseScore(state_in, word, state_out)

        candidates = list((model.score(sentence + ' ' + next_word), next_word) for next_word in vocab)
        bad_words = sorted(candidates, key=itemgetter(0), reverse=False)
        top_words = sorted(candidates, key=itemgetter(0), reverse=True)
        worst_5 = bad_words[:5]
        print()
        print(f'least probable 5 next words:')
        for w, s in worst_5:
            print(f'\t{w}\t\t{s}')

        best_5 = top_words[:5]
        print()
        print(f'most probable 5 next words:')
        for w, s in best_5:
            print(f'\t{w}\t\t{s}')

        if '.' in word:
            print(f'score for sentence \"{sentence}\":\t {total_score}"')  # same as model.score(sentence)!
            sentence = ''
            state_in, state_out = kenlm.State(), kenlm.State()
            model.BeginSentenceWrite(state_in)
            total_score = 0.0
            print(f'Start a new sentence!')
        else:
            state_in, state_out = state_out, state_in

        word = input('Enter next word: ')

    print(f'That\'s all folks. Thanks for watching.')
```

Following the steps above I arrived at a corpus, which stored the entire German encyclopedia from Wikipedia in a single corpus text file at `$dewiki_txt`. The corpus file is approximately 5GB in size (xxxGB compressed) and contains 42,229,452 sentences (712,167,726 words) from ~2.2 million articles. Here's an excerpt from the [German Wikipedia article about Language Models]:

```
ebenfalls im jahr <num> erschienen zwei bestofalben mit den grössten hits der band best of the braving days und best of the awakening days
am <num> april <num> stellten galneryus ihr erstes studioprojekt mit sho vor die aus drei tracks bestehende ep beginning of the resurrection
bei einem der tracks handelt es sich um das abspannlied a faroff distance der animeserie
am <num> juni wurde das sechste album resurrection veröffentlicht
die unterschiede zwischen yamab und sho sind hier deutlich wahrnehmbar
dennoch ist es der band seitdem gelungen eine stilistischklangliche kontinuität zu bewahren und musikalische elemente einzubauen die an die frühen galneryusalben erinnern
mit phoenix rising veröffentlichte die band am <num> oktober <num> ihr siebtes studio album
im januar <num> veröffentlichte die band ein minialbum unter dem namen kizuna der gleichnamige song wurde in dem pachinko game pachinko cr first of the blue sky verwendet
im juli des gleichen jahres folgte eine neue single hunting for your dream welches als abspannlied der anime serie hunter x hunter veröffentlicht wurde
das lang erwartete achte studio album angel of salvation erschien am <num> oktober <num>
der namensgebende titel angel of salvation war bis zu diesem zeitpunkt der längste song in der bandgeschichte

```

### Training the LM

Training the KenLM model requires building the project using cmake and other tools (see the [KenLM documentation] for more details), which only works on Unix based systems. Make sure, you have the resulting `bin` folder on the path to use `lmplz` and `build_binary`. Also, make sure the temporary directory set with `-T` provides enough free storage, otherwise training will fail with a message like `Last element should be poison`.

```bash
echo "Training $N-gram KenLM model with data from $dewiki_txt and saving ARPA file to $lm_arpa"
lmplz -o ${order} -T ${tmp_dir} -S 40% --limit_vocab_file ${lm_vocab} <${corpus_file}.bz2
``` 

After building the ARPA file, this file can be converte to a binary file, which loads faster. Note that KenLM works with any ARPA files, so you could even convert the ARPA file from CMUSphinx mentioned above.

```bash
echo "Building binary file from $lm_arpa and saving to $lm_binary"
build_binary trie ${lm_arpa} ${lm_binary}
```

Running all the steps through here will produce an ARPA file at `$lm_arpa` and a binary KenLM model in `lm_binary`. If a sorted vocabulary of all the unique words is require, this can be obtained by running the following command. Note that the vocabulary is extracted from the corpus the LM was trained on, this works only for unpruned models.

```bash
echo "(re-)creating vocabulary of $dewiki_txt and saving it in $lm_vocab"
grep -oE '\w+' $dewiki_txt | pv -s $(stat --printf="%s" $dewiki_txt) | sort -u -f > $lm_vocab
```

## Evaluating the LM
The raw text corpus contains more than 700 million words from 42 million sentences in 2.2 million articles. The vocabulary size (i.e. the number of unique words) is about 8.3 million. I used it to train a 2-gram and a 4-gram KenLM model using my personal Laptop using an i7 processor with 4 cores, 8GB RAM and an SSD hard disk. Creating the raw text corpus from the Wikipedia dump took the most time. After that, it was more or less smooth sailing, apart from some fiddling with the `lmplz` parameters `-T` (to make sure to use a temporary directory with enough space) and and `-S` (to make sure not to use too much memory). The final model uses about 2.3G (2-gram) resp. 18G (4-gram) of disk space.

According to Dan Jurafsky bible _[Speech and Language Processing]_The best way to evaluate a n-gram LM is to embed it in an application and measure how much the application improves (called _extrinsic evaluation_). _Intrinsic evaluation_ describes measuring the performance of a LM independent from any application and would require scoring sentences on a training set, which were never seen before. The results can then be compared to a reference LM: Whatever model produces higher probabilities (or lower perplexity) to the $$n$$-grams in the test set is deemed to perform better.

Because of time constraints and because KenLM has already been extensively evaluated on English I refrained from evaluating my German LM intrinsically, although the corpus used for training is not as big as the one used by Ken Heafield. To still get an intuition about how well the model performs, the model's score on some test sentences were calculated. To make sure the sentences could not have been seen during training, the following set of 5 sentences of the current newspaper (a date after creation of the Wikipedia dump) was used:


## Using a LM to build a simple spell checker

With my newly built LM I was now able to improve the quality of the transcripts produced by my simplified STT engine by using it as a rudimentary spell checker. The LM will post-process the transcripts by going through it word by word and create a list of possible spellings for each word. To do this, we check if the word is in the vocabulary of the LM. If it is, we can assume the word was correctly inferred i.e. it does not only sound right but is also correctly spelled. If it is not in the vocabulary of the LM, we create a list of words with [edit distance] ($$ed$$) 1. If none of these words are in the vocabulary of the LM, create a list of words with $$ed(w)=2$$ (can be recursively done from the list of words with $$ed(w)=1$$). If none of the words from this list are in the vocabulary of the LM, keep the original word and accept that it might have been incorrectly transcribed (i.e. with an $$ed(w)>1$$), the word is completely wrong (i.e. e.g. _their_ instead of _they're_) or the word has simply never been seen while training the LM.

Concatenating the lists of possible spellings gives us a matrix of words. A LM can now assess the probability of each path by calculating the probability of the sentence that is created by concatenating all the words from a path. The sentence can then be corrected by taking the most probable sentence. Note, that the number of paths can become exponentially huge when proceeding as described, requiring dynamic programming and merging paths to calculate the most probable path. I implemented a greedy variant which only keeps the 1.024 most probable sequences after each step (i.e. after adding the list of possible spellings for a word).

## Results & Conclusion



[FHNW]: https://www.fhnw.ch/
[Forced Alignment]: http://www.voxforge.org/home/docs/faq/faq/what-is-forced-alignment
[Automatic Speech Recognition]: https://en.wikipedia.org/wiki/Speech_recognition
[Voice Activity Detection]: https://en.wikipedia.org/wiki/Voice_activity_detection
[webrtcvad]: https://github.com/wiseman/py-webrtcvad
[Smith Waterman]: https://en.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm
[Word Error Rate]: https://en.wikipedia.org/wiki/Word_error_rate
[Language Model]: https://en.wikipedia.org/wiki/Language_model
[$$n$$-gram]: https://en.wikipedia.org/wiki/N-gram
[edit distance]: https://en.wikipedia.org/wiki/Edit_distance
[WebRTC]: https://webrtc.org
[KenLM]: https://github.com/kpu/kenlm
[KenLM documentation]: https://kheafield.com/code/kenlm/
[Corpus Formatting Notes]: https://kheafield.com/code/kenlm/estimation/
[Wiki Parser]: https://dizzylogic.com/wiki-parser
[post on KDnuggets]: https://www.kdnuggets.com/2017/11/building-wikipedia-text-corpus-nlp.html
[KerasDeepSpeech]: https://github.com/robmsmt/KerasDeepSpeech
[WikiExtractor]: https://github.com/attardi/wikiextractor
[Document Format]: http://medialab.di.unipi.it/wiki/Document_Format
[WikiCorpus]: https://radimrehurek.com/gensim/corpora/wikicorpus.html
[Gensim]: https://radimrehurek.com/gensim/index.html
[Wikipedia dumps]: https://dumps.wikimedia.org/
[CMUSphinx]: https://cmusphinx.github.io/wiki/download/
[ARPA]: https://cmusphinx.github.io/wiki/arpaformat/
[SourceForge]: https://sourceforge.net/projects/cmusphinx/files/Acoustic%20and%20Language%20Models/German/
[NLTK]: https://www.nltk.org/
[Pipeline Viewer]: http://www.ivarch.com/programs/pv.shtml
[German Wikipedia article about Language Models]: https://de.wikipedia.org/wiki/Spracherkennung#Sprachmodell
[`sed`]: http://www.grymoire.com/Unix/Sed.html
[`unidecode`]: https://pypi.org/project/Unidecode/
[Google Cloud Speech-to-Text]: https://cloud.google.com/speech-to-text/
[Keras]: https://keras.io
[Deep Speech paper]: https://arxiv.org/abs/1412.5567
[Mozilla implementation]: https://github.com/mozilla/DeepSpeech
[Speech and Language Processing]: https://web.stanford.edu/~jurafsky/slp3/