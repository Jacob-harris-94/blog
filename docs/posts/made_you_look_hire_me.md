---
date: 2026-01-01
draft: true
categories:
  - project
  - programming
---

How funny would this be?
...
# Goals
### Primary
Do the thing
### Secondary 
Exercise the [[2026-05-22_Residues]] method of architecture. I'm going to take a first pass at doing so without reviewing the book or talk to stretch my brain a little. The book encouraged "just doing it" after all.

# Architecture 
### Residuality
Residuality is about understanding software as part of an operational context which is in constant flux - the part that still works when context changes is the residue.
To crudely summarize, the method goes like this:

1. **Define a naive architecture that would work under ideal circumstances.** This could be for example a single service that does everything in memory, or whatever the equivalent of a fragile MVP is.
2. **Stress it - itemize potential _stressors_**, that is anything which can change in the operating context and affect the software. Probability doesn't matter, just volume and diversity.
3. **Evaluate the impact of the stressors on the architecture.** The part that's still working is the residue.
4. **Note changes to the architecture that would allow it to survive**. This is a change to the residue???
5. **Collect some set of residues** (not necessarily all) together into the architecture.
6. **Measure and iterate** - compare response to stressors. Use novel stressors to compare the naive to the new architecture like using a held-out test set in machine learning. If desired, iterate further.

### Applicability
Applying this enterprise architecture alternative for something like this might seem silly. And it might actually *be* silly -- but I think breaking down even a simple application into components and managing their scope and relationship is very closely analogous to doing the same at a higher level.

### Avoiding functional decomposition
I'm so freaking tempted to do functional decomposition I can't even explain it. I recall [[Righting Software]] warned of the same. 
> The problems with functional decomposition are many and acute.
>     - *Righting Software*

How can I avoid it? I think by earnestly starting from the naive architecture and justifying every component with stressors.

### Naive Architecture
What is this? It's a bash or python script that loops over an array of 365 hard coded values, calls git as a subprocess every 24 hours, sleeps in between. The 365 values can be generated any which way. 

```python
PIXELS = [] #365?
for p in PIXELS:
    time.sleep(60*60*24)
    popen("cat )
    popen(")

```

### Stressors (draft), attractors?
-  leap year
- start on one machine, finish on another
- GitHub down (my uptime was 450 days lol)
- my machine down temp
- my machine down perm
- network issue
- 
 
