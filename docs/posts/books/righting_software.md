---
date: 2026-05-18
categories:
  - book review
  - programming
---

# Righting Software

### Author 
Juval Löwy
### Read
Early 2025

### Thoughts
I am extremely conflicted about this book. I like a lot of the discussions about design process and what can go wrong - even more after a recent re-reading - but it seems too good to be true...

<!-- more -->

### Design
I am writing this nearly two years after reading, and what stuck with me most: 
> Design iteratively, build incrementally.

The analogy (used nearly to a fault) to building a house and knocking it down vs building up one floor at a time was convincing. 


The railing against functional decomposition also stuck with me although I can't say I fully absorbed it. Only after reading [Residuality](residuality.md) did I come back to this with fresh eyes and absorb more of the "what not to do". 

### Volatility-based decomposition 
The author suggests deriving the components of the architecture based on what changes together across use cases and/or customers, *Volatility-based decomposition*. Re-reading the first few chapters after [Residuality](residuality.md), there are some extremely strong similarities. In Volatility-based decomposition, one tries to demarcate components based on what changes together - in Residuality, the "unit of architecture" is the residue, which is what is left over when the business context changes forcing the software to change. 

I like the process of user stories -> use case diagrams (uml activity diagrams) -> architecture diagrams -> sequence diagrams to validate the architecture. I've done this with my team and we ended up with applications we continued to build on for a year and a half with significant scope increase and the fundamental architecture didn't have to change. 

I came out of this interested in using the design process presented, called somewhat snootily *The Method*, but highly skeptical that it would work as universally as claimed. 
### Project design
I'm even more skeptical about the heavy waterfall-style implementation prescribed. Budgeting hours tightly and phasing different kinds of workers in and out throughout the development feels like a management pipe dream. Perhaps this can be made as much a science as presented here but I've never seen development go predicably enough for this. 

The one redeeming concept here in my extremely biased view is the creation of a tasking [DAG](https://en.wikipedia.org/wiki/Directed_acyclic_graph) and performing critical path analysis. My understanding is that critical path analysis is used for *real* disciplines like construction too. 
