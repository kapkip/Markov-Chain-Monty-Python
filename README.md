# ☠️🦜 Markov Chain Monty Python Simulation 🦜☠️
# 

This repository contains simplified, reusable, model templates for running discrete-time **Markov Chain Monte Carlo (MCMC)** simulations in both **Python** and **R**. 

To make the code readable and self-contained, the simulation models the behavioral states of the dear, departed **Mister Polly Parrot** of Monty Python fame. It serves as a basic framework for tracking how an individual organism or population transitions through probabilistic life-history stages until hitting an absorbing state (`Ex-Parrot`).

## 🦜 The Transition Matrix Mathematics 🦜

The simulation tracks an organism moving through a finite state space $S$:

$$S = \{\text{Resting}, \text{Pining}, \text{Stunned}, \text{Ex-Parrot}\}$$

The transition probability matrix $P$, where entry $P_{ij}$ represents the probability of transitioning from state $i$ to state $j$, is defined as:

$$
P = \begin{pmatrix} 
0.5 & 0.3 & 0.2 & 0.0 \\
0.4 & 0.4 & 0.2 & 0.0 \\
0.2 & 0.0 & 0.0 & 0.8 \\
0.0 & 0.0 & 0.0 & 1.0 
\end{pmatrix}
$$

### Key Concept: Absorbing States

State 4 (`Ex-Parrot`) is an **absorbing state** because $P_{4,4} = 1.0$. Once the system transitions into this state, it can never leave. In epidemiology and survival analysis, this directly mirrors irreversible multi-state disease progression or a terminal event (such as mortality, permanent recovery with full immunity, or tracking a vector moving from $S$ -> $I$ -> $R$). It represents the definitive endpoint of a biological cohort.

---

## 🦜 Model Validation & Diagnostics 🦜

Because raw mathematical simulations can hide sampling bugs or structural biases, both the Python and R implementations include interactive diagnostics to validate the model's health before you interpret the biological results.


###  Convergence Diagnostics

Both scripts are explicitly segmented into **Execution Cells** (`# %%`). Running the simulation and plotting the diagnostic cells side-by-side reveals two metrics:

1. **The Trace Plot (Sampling Timeline):** Tracks the path of the simulation step-by-step. 
   * *Expected Behavior:* A healthy run will show rapid, chaotic "fuzzy caterpillar" noise jumping dynamically between the transient biological states (`Resting`, `Pining`, `Stunned`) before flatlining permanently at the bottom once the parrot joins the choir invisible.
   * *Failure Modes:* A sharp, clean diagonal cliff or bolt at the very start indicates a **Burn-in Failure** (the simulation started in an unnaturally rare state and took too long to find the true baseline). A slow, lazy wave indicates Low Effective Sample Size (ESS), meaning the model is too "sticky" and isn't moving freely between states.
2. **The Marginal Posterior Distribution (State Frequency):** A categorical histogram showing the final, long-term proportion of time spent in each state. This verifies the empirical probability of an organism occupying a specific health bracket (e.g., the exact percentage of the timeline spent "Pining for the Fjords" versus "Resting").

###  Directory Requirements
To run the diagnostics locally, ensure your folders contain the standard environment configurations:
* **/r/**: Requires `ggplot2` and `patchwork` installed in your R library.
* **/python/**: Requires running `pip install -r requirements.txt` to load `numpy`, `pandas`, `matplotlib`, and `seaborn`.

---

