---
title: Smith-Waterman algorithm in Python
layout: post
---

Because I am currently working with [Local Sequence Alignment (LSA)](https://en.wikipedia.org/wiki/Sequence_alignment) in a project I decided to use the [Smith-Waterman algorithm](https://en.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm) to find a partially matching substring $$b$$ in a longer substring $$a$$. Since I am coding in Python, I was sure there were dozens of implementations already, ready to be used. I found a few indeed, namely [here](https://gist.github.com/nornagon/6326a643fc30339ece3021013ed9b48c) and [here](https://gist.github.com/radaniba/11019717). However, the first implementation is incomplete, because it only includes calculating the scoring matrix and not the backtracing. I did not test the second implementation because it seemed overly complicated and apparently contained bugs (judging from the comments).

I therefore went for my own implementation. What I wanted was some easy to use function with a slim signature, something like

`start, end = smith_waterman(string_a, string_b)`

to find out where some version of `string_b` (including gaps and deletions) starts and ends within `string_a`.

## Step 1: Scoring matrix

To find the local alignment of $$b$$ with $$a$$ the Smith-Waterman calculates a scoring matrix first. The following code calculates this matrix for two strings `a` and `b` with linear gap costs. For performance reasons I went for an implementation with [NumPy](http://www.numpy.org/) arrays. Values for match scores and gap costs can be changed. The default values correspond to the [example](https://en.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm#Example) from Wikipedia:

```python
import itertools
import numpy as np

def matrix(a, b, match_score=3, gap_cost=2):
    H = np.zeros((len(a) + 1, len(b) + 1), np.int)

    for i, j in itertools.product(range(1, H.shape[0]), range(1, H.shape[1])):
        match = H[i - 1, j - 1] + (match_score if a[i - 1] == b[j - 1] else - match_score)
        delete = H[i - 1, j] - gap_cost
        insert = H[i, j - 1] - gap_cost
        H[i, j] = max(match, delete, insert, 0)
    return H
```

## Step 2: Backtracing

The second step is backtracing from the calculated scoring matrix to calculate the optimal alignment of `b` with `a`. Since `b` will not simply be a substring of `a` in most cases, some version of `b` that includes gaps and deletions needs to be calculated.
I had to juggle with the NumPy arrays a bit because [`numpy.argmax()`](https://docs.scipy.org/doc/numpy/reference/generated/numpy.argmax.html) will only find the **first** indexes of a maximum value inside an array and backtracing involves starting with the **last** occurrence of the maximum value.

```python
def traceback(H, b, b_='', old_i=0):
    # flip H to get index of **last** occurrence of H.max() with np.argmax()
    H_flip = np.flip(np.flip(H, 0), 1)
    i_, j_ = np.unravel_index(H_flip.argmax(), H_flip.shape)
    i, j = np.subtract(H.shape, (i_ + 1, j_ + 1))  # (i, j) are **last** indexes of H.max()
    if H[i, j] == 0:
        return b_, j
    b_ = b[j - 1] + '-' + b_ if old_i - i > 1 else b[j - 1] + b_
    return traceback(H[0:i, 0:j], b, b_, i)

```

## Step 3: Calculating start- and end-index

Finally, the implementation for the top-level function simply performs these two steps by calling above functions. Since the LSA should not be case sensitive in my project, I normalized the strings beforehand by converting them to uppercase. Start and end index of string `b` in `a` are calculated from the result of the backtracing step.

```python
def smith_waterman(a, b, match_score=3, gap_cost=2):
    a, b = a.upper(), b.upper()
    H = matrix(a, b, match_score, gap_cost)
    b_, pos = traceback(H, b)
    return pos, pos + len(b_)
```

## Usage and tests

To see if everything worked I wrote a few test with printouts:

```python
    # prints correct scoring matrix from Wikipedia example
    print(matrix('GGTTGACTA', 'TGTTACGG'))

    a, b = 'ggttgacta', 'tgttacgg'
    H = matrix(a, b)
    print(traceback(H, b)) # ('gtt-ac', 1)

    a, b = 'GGTTGACTA', 'TGTTACGG'
    start, end = smith_waterman(a, b)
    print(a[start:end])     # GTTGAC
```

## Resources

For the implementation I found the [Wikipedia article](https://en.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm) and an [Online-Tool to interactively perform the calculations](http://rna.informatik.uni-freiburg.de/Teaching/index.jsp?toolName=Smith-Waterman) very useful.