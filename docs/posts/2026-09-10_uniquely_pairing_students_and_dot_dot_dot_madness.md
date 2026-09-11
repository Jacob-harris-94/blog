---
draft: false 
date: 2026-09-10 
---

# Uniquely pairing students and a self-imposed descent into madness

# A deceptively simple problem
My wife [nerd-sniped](https://xkcd.com/356) me with the following: given her class of 17 students, could I generate unique pairings such that every week students could be paired with a new partner (or two, for one group of three). 

Easy, right? Something compelled me to do this the hard way...

tests:
$ a $

$a$

$$ a $$

$$a$$

<!-- more -->

### Summary
This was an exercise in stretching the wrinkles out of my brain, as my parents would say. I'm sure LLMs or even Google could have spit out the solution to this quickly. What I did instead was force myself to contemplate and experiment and talk to people until I made progress. I undoubtedly wired together a neuron or two in the process which still means something - to me, at least. 

# Initial approach 
I'm going to assume an even number of students for now, and put off dealing with odd numbers [until later](###elegant-triples-handling-thanks-to-the-above).  How many unique pairs actually exist? I remembered the classic phrasing of the "unique number of handshakes that could occur at a party" problem - shockingly apt unlike the typical thinly-veiled excuses to learn combinatorics. I had a feeling after thinking about it for a while that the answer was $n(n-1)/2$, but a quick graphical "proof" confirmed.

![[2026-09-09_pairing_scans-1-cropped.png]]

I also re-derived the binomial coefficient $n\choose{k}$ formula and confirmed the special case $\binom{n}{2} = n(n-1)/2$ agreed. I can generate all unique pairs with `[(i, j) for i in range(N) for j in range(i+1, N)]` so that seems mostly solved. The only _minor_ problem with this is that it's not a usable order for pairing students in class. For example, in the first round: $(1,2), (1,3), \dots$ is a non-starter. Student $1$[^1] can't be in two groups. 

Ok, well maybe I can generate the pairs like that and then think of some ways to mix 'em up. Whatever the solution is, it will obey these invariants: 
- each student number $1, 2, \dots, n$ used once per "round" of $n/2$ pairs
- $n-1$ rounds
which follows directly from reorganizing the expression above
$$\binom{n}{2} = n(n-1)/2 = \underbrace{\left(\frac{n}{2}\right)}_\text{pairs} \underbrace{(n - 1)}_\text{rounds} $$
I didn't actually know at this point whether it was always possible to construct all $n-1$ rounds worth of combinations without re-using anything, especially because of...
### A *de*motivational example
With $n=6$, I tried hand-selecting pairs for a few rounds.
1. $(1,2), (3,4), (5, 6)$
2. $(1,3), (2,4), \dots$  and I'm in trouble, can't re-use $(5,6)$ and that's all I have left. 
Even worse, I got $2/3$ of the way through the round. It seems like I need some sort of backtracking.
### Dead ends
##### Latin squares 
I tried some graphical approaches based on filling an upper-triangular grid of $(i, j) \space | \space j > i$ points, but didn't have any luck beyond $n=4$ which seems to "luckily" have a symmetrical solution. This is reminiscent of Latin squares which have each element occur exactly once in each row and column - using each row and column once in a round (and never using those same coordinates again) is equivalent to pairing each number uniquely. However, Latin squares typically fill the full matrix so I had some doubt about whether an algorithm for finding them would work in this case, and I certainly didn't figure it out yet if so.

![[2026-09-09_pairing_scans-3-latin-squares.png]]
##### Bipartite graphs 
I don't know if I even got far enough to call this a dead end, but it's something. A round can be consider as a graph with nodes $1, 2, \dots, n$ arranged in two groups with edges pairing nodes between the two groups (and not within). This is the definition of a bipartite graph. What I needed to find was a collection of $n-1$ such graphs that had no edges in common among all of them, or in other words, no reused pairs. I got nowhere with this angle.
# An extraordinarily bad, but technically correct, initial solution 
I had gotten nowhere with (would be) clever iterative solutions, but I had a clue from my [manual attempt at n=6](#demotivation-example) that I could try adding rounds, see if they had a conflict, and if they do try a different one and proceed. I implemented the first thing I thought could work - naively selecting possible rounds and backtracking when conflicts are found. I was going to write out the pseudocode here, but it's python so it's approximately pseudocode already:
```python
def solve(N):
    assert N%2 == 0
    num_round_pairs = N//2
    all_pairs = list(combinations(range(N),2)) # TODO performance

    def is_valid(this_round, so_far):
        if not len(set(this_round)) == len(this_round):
            return False
        if any(curr in so_far for curr in this_round):
            return False
        all_elements = []
        for pair in this_round:
            all_elements.extend(pair)
        return len(set(all_elements)) == N

    def find_rounds(N, pairs_used):
        unused_pairs = list(set(all_pairs) - set(pairs_used))
        if len(pairs_used) == len(all_pairs):
            return True
        for pair_selection in combinations(range(len(unused_pairs)), num_round_pairs): # TODO performance
            round_pairs = [unused_pairs[ii] for ii in pair_selection]
            if is_valid(round_pairs, pairs_used):
                pairs_used += round_pairs
                found = find_rounds(N, pairs_used)
                if found:
                    return True
                del pairs_used[-num_round_pairs:]
        return False

    result_list = []
    success = find_rounds(N, result_list)
    if success:
        return result_list
    else:
        return []


```
I'm no computer scientist, but I can sometimes smell a frightening big-$\mathcal{O}$ complexity without doing the math. This was one of those times. I knew all those `combinations` and recursive backtracking weren't going to be good. Oh, it finished in the blink of an eye for my test case of $n=6$ and the solution is valid! Wow I love python, I can write a bunch of tricky (for me) recursion and it just works on the first try! Let me try running it with slightly larger $n$. Ok, it still returns right away for $n=12$. My wife's class is only $n\approx18$ so this should work! I ran with $n=18$ and... went to bed with it still running. Next day, still running. Day after that, still running. I guess this is what exponential growth feels like.
For your amusement, selected timing measurements: 

| $n$  | time (seconds) |
| ---- | -------------- |
| $12$ | $\approx 0$    |
| $14$ | $45$           |
| $16$ | $7956$         |
| $18$ | $\dots ?$      |
Based on a rough two orders of magnitude gain per pair added, we're in the realm of weeks.
# A merely horrible second attempt
This above is, of course, gobsmackingly inefficient. How else could I approach this? (Besides the obvious holy grail of a clever iterative solution.) I'll do just a _little_ math and... for $n=18$, that step of `for round_pairs in combinations(pairs_available, round_size):` gives $\binom{153}{9} \approx \text{buttloads}$ of iterations in the worst case. That's for just a single round, and there's $17$ rounds! Admittedly the number to choose from decreases, but these are nested loops so the complexity multiples. 
At this point recursive backtracking was still the only approach I knew would work, but it had to be possible to be less wasteful. I realized the aforementioned `combinations` is generating mostly garbage possibilities (like reusing numbers within the round) and there was no reason I had to iterate one round at a time. I modified the program to pick just a single pair at a time, so the "inner loop" is linear in the number of elements even though recursion depth increases. I found the other members of the current round with a modulus operation to prevent reusing numbers within a round.
```python
def solve(N):
    assert N%2 == 0
    num_round_pairs = N//2
    all_pairs = list(combinations(range(N),2))
    used = [False for _ in range(len(all_pairs))]
    def is_valid(pair, all_elements):
        ans = not any(el in all_elements for el in pair)
        return ans
    def find(N, sequence):
        if len(sequence) == len(all_pairs):
            return True
        round_pairs = sequence[-(len(sequence) % num_round_pairs):] if len(sequence) % num_round_pairs else []
        all_elements = set()
        for rp in round_pairs:
            all_elements.update(rp)
        for ii, pair in enumerate(all_pairs): 
            if not used[ii] and is_valid(pair, all_elements):
                sequence.append(pair)
                used[ii] = True
                found = find(N, sequence)
                if found:
                    return True
                del sequence[-1]
                used[ii] = False
        return False
    result_list = []
    success = find(N, result_list)
    if success:
        return result_list
    else:
        return []
```
The above fix and couple minor optimizations got the solve time for $n=18$ from probably weeks to $\approx 1$ second. Not too shabby. How about slightly larger? What if my wife has more students next year? Oops, $n=24$ hangs for as long as I was willing to let it go, just like $n=18$ did for the previous solution. I guess I shifted the exponential right a bit, but didn't change the shape all that much. 

| $n$  | time (seconds) |
| ---- | -------------- |
| $12$ | $0.007$        |
| $14$ | $0.784$ [^2]   |
| $16$ | $0.003$        |
| $18$ | $1.106$        |
| $20$ | $129.241$      |
| $22$ | $9928.534$     |
| $24$ | $\dots ?$      |
### Delivering anyway (quick and dirty odd number handling)
I told my wife I'd actually deliver her a table for $n=17$ she could use, so it was time to temporarily suck up my dissatisfaction with a solution on the razor's edge of feasibility and work on the [odd number logic](https://github.com/Jacob-harris-94/pairing/blob/feature-csv-output/src/main.py) (revisited later). She had been extremely patient while I sketched, talked with friends, and programmed what was almost undoubtedly a solved problem. I thought I owed her a solution to her actual problem, not just the tidy abstraction I had obsessed over. 
Thankfully, the use case is _very_ forgiving, and less than perfect distribution of triple membership was allowed. I simply took an even number $n=18$ as usual, then whichever paired with the $18$ was made a triple with one of the existing pairs. This preserves the properties of evenly spreading out who's tripled unless the pairs selected aren't perfect - and they _weren't_. Late one night after the household chores were done, in a rush for the deadline, I accepted the dreadful consequence of students being tripled anywhere from 2 to 4 times over the whole schedule. It remains to be seen whether the students notice.
With that practical stuff out of the way, it was time to see this through to the end.
# A family of almost-solutions
I discussed all the above with some colleagues in hopes of discovering an iterative solution. We shared a lot of almost-solutions. One promising candidate family involved shifting around arrays, with various attempts to mix them in just the right way. A handful of attempts with different types of mixing and shifting: 

![[2026-09-09_pairing_scans-6-arrays-3.png]]

![[2026-09-09_pairing_scans-3-arrays-1.png]]

![[2026-09-09_pairing_scans-4-arrays-2.png]]

![[2026-09-09_pairing_scans-7-arrays-4.png]]
None of those worked out. I implemented many of these ([linked here, but I wouldn't recommend looking, it's gross](https://github.com/Jacob-harris-94/pairing/blob/investigate-new-approach/src/main.py)) and some seemed  to generate $\approx 2/3$ of the potential unique pairs, but of course many of the rounds would be infeasible due to any repeats and so useless. Anything less then perfect is trash, in this case at least.
### A clue?
My younger and smarter colleague thought about it overnight and got a real solution after I had been thinking about for a week. No, I didn't want to know what it was. Well, I did, but I was going to figure this out or die trying. Sanity and patience diminished, I grudgingly accepted a small hint.
> It's very close to something we already tried together. We were one idea away from it.
This was perhaps more frustrating that knowing nothing - after all, if I hadn't that hint, I would simply imagine the solution to be so complicated I couldn't possibly expect myself to find it. Knowing it was similar to things I'd been thinking about for days was irksome. It was tantalizingly close but out of reach.
I had committed to figuring it out myself, so I had to reach for things "one idea away" from our iterative attempts. I experimented with patterns of pairs on the "circular" graphs of all $1, 2, \dots, n$ nodes. For $n=6,8$ I found some elegant looking patterns that produced every pair with no overlap in rounds. I thought this was going to be the solution and I just needed to find a way to generate these seemingly symmetrical and well-behaved patterns. Then I tried for $n=10$ and utterly failed to find any simple patterns that would produce all pairs with no repetition. Devastated might be an exaggeration but I wasn't thrilled.
![[2026-09-09_pairing_scans-6-graphs-2.png]]
# Finally _the_ solution
Keeping in mind the above clue, I went back to [array manipulation attempts](#A family of almost-solutions) and continued working from there. I experimented with many variations of the following, where the numbers are split into two lists.
```python
def solve(N):
	a = list(range(N//2))
	b = list(range(N//2, N))
	for _ in range(N-1):
		# mix up lists `a` and `b` somehow
		# rotate lists `a` and `b` somehow
		# save all pairs a[j], b[j]
```

All variations above did some sort of swapping between lists and some sort of rotation within each list like $[1, 2, 3] \rightarrow [2,3,1]$ . I realized I hadn't tried rotating both lists together, circularly. That didn't work by itself, but I figured I could combine it with swapping elements. I started with swapping $a_1 \leftrightarrow b_1$. **It worked!** Below is my [first working iterative solution](https://github.com/Jacob-harris-94/pairing/blob/first-iterative-solution/src/main.py): 
```python
def solve(N):
    l1 = list(range(N//2))
    l2 = list(range(N//2, N))
    pairs = []
    for ii in range(N-1):
        # swap
        l1[0], l2[0] = l2[0], l1[0]
        # rotate
        l2.insert(0, l1.pop(0))
        l1.append(l2.pop(-1))
        # save each pair
        for jj in range(N//2):
            pairs.append(tuple(sorted((l1[jj], l2[jj]))))
    return pairs
```
Timing is _slightly_ improved compared to the recursive solutions.

| $n$      | time (seconds) |
| -------- | -------------- |
| $18$     | $< 0.001$      |
| $1,000$  |                |
| $2,000$  |                |
| $10,000$ | $12.683$ [^3]  |
| $20,000$ | $60.443$       |
The above solution is accidentally equivalent to what my colleague realized: keep the two arrays with circular rotation of the elements, but fix a single element in place, skipping it in the rotation order. 
### Proof by construction
I realized the graphical approaches above were _so close_ to working! Holding a single element static in the two arrays is equivalent to forming the odd-numbered graph $1, 2, \dots, n-1$, pairing together every equidistant pair from a rotating held-out node, and pairing that held-out node with $n$. Each rotation of the held-out node corresponds to the $n-1$ rounds. Node $n$ is paired with each of the other nodes exactly once. And for any other given pair $(i, j) \space | \space i \neq j, i, j < n$ there is exactly one equidistant point ($\mod n-1$) corresponding to the round it which $(i, j)$ will be paired.
![[2026-09-09_pairing_scans-8-final.png]]
### Another perspective
This lead to a [more elegant solution](https://github.com/Jacob-harris-94/pairing/blob/iterative-elegant-slower-solution/src/main.py) which directly constructs the pairs with simple modulus operations:
```python
def solve(N):
    left_out = N-1
    pairs = []
    for ii in range(N-1):
        removed = ii
        pairs.append((removed, left_out))
        for jj in range(1, (N-1)//2 + 1):
            pairs.append(tuple(sorted(((ii-jj)%(N-1), (ii+jj)%(N-1)))))
    return pairs
```
Shockingly, to me, this was slower than the [original solution above](#Finally-the-solution) - not by a huge factor, only about $30\%$ slower. I haven't and I'm not going to dig into why, but I have a good theory: I thought the array manipulations would be the slowest part, but they are spread over an entire round. Only two `pop` and two `insert/append` are needed per round after which all $n/2$ pairs can be read out with direct array indexing. I instead replaced a linear number of those array operations with a quadratic number of modulus operations. While not an especially slow operation, anything that slows the inner loop is penalizing the quadratic complexity term.

| $n$      | time (seconds) |
| -------- | -------------- |
| $18$     | $< 0.001$      |
| $1,000$  | $0.168$        |
| $2,000$  | $0.669$        |
| $10,000$ | $17.618$       |
| $20,000$ | $81.136$ [^3]  |
### One last performance tweak
Now that I know this approach is correct, I can discard the `sorted` call. Pairs will no longer be ordered, but uniqueness is maintained - only one of $(1, 2)$ and $(2, 1)$ can possibly be generated. This cuts almost $2/3$ off the previous best (array-manipulation-based) solution. Not bad!

| $n$      | time (seconds) |
| -------- | -------------- |
| $10,000$ | $4.749$        |
### Elegant triples handling thanks to the graph perspective
Thanks to the graph rotation perspective it was easy to generate triples by taking the "left out" element and adding it to one of the other pairs. By construction, each number will be in a triple exactly $3$ times - once when it's left out, and two other times when it's at the selected index from the left out element.
```python
def solve_odd(N):
    pairs = []
    for ii in range(N):
        for jj in range(1, N//2 + 1):
            if jj == N//2 - 1:
				# only for once specific index, add the "left out" element ii
                pairs.append(tuple(sorted(((ii-jj)%N, (ii+jj)%N, ii))))
                continue
            pairs.append(tuple(sorted(((ii-jj)%N, (ii+jj)%N))))
    return pairs
```
# Reflections
Forcing myself to think things through was more rewarding than I expected! I feel that I genuinely improved some discrete math skills and refreshed some combinatorics I haven't used in a long time. In our world of instant (if questionably correct) answers, just sitting with a problem for a while is a rarity and something I want to do more often. Without getting too-heavily [Cal Newport](https://en.wikipedia.org/wiki/Cal_Newport) on you, it's good to be bored now and then. Being bored and coming back to the problem over time allowed me to think about Latin squares, bipartite graphs, and make the connection to the _elegant_ way of selecting students to put in a triple alongside the (handwaved) proof that each student must be in a triple exactly $3$ times total across all possible rounds. I'll be doing this again.

[^1]: I will freely use zero and one-based indexing throughout, with no attempt at consistency. Sue me. 
[^2]: no, that's not a typo. yes I ran this multiple times. I assume this particular solution does dramatically more backtracking.
[^3]: nice $O(n^2)$ behavior like I'd expect!
