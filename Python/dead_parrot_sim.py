## Monty Python Markov Chain Simulation ##

import random
from typing import Dict, List


class MarkovChainSimulator:
    """A reusable Monte Carlo simulator for discrete-time Markov Chains."""

    def __init__(self, transition_matrix: Dict[str, Dict[str, float]]):
        self.matrix = transition_matrix
        self._validate_matrix()

    def _validate_matrix(self):
        """Ensures probabilities for each state sum up to approximately 1.0."""
        for state, transitions in self.matrix.items():
            total = sum(transitions.values())
            if not (0.99 <= total <= 1.01):
                raise ValueError(
                    f"State '{state}' probabilities sum to {total}, must be 1.0!"
                )

    def next_state(self, current_state: str) -> str:
        """Samples the next state based on current state's probabilities."""
        if current_state not in self.matrix:
            raise KeyError(f"State '{current_state}' not found in matrix.")

        choices = list(self.matrix[current_state].keys())
        weights = list(self.matrix[current_state].values())

        # random.choices returns a list; grab the first element
        return random.choices(choices, weights=weights)[0]

    def run_simulation(self, start_state: str, max_ticks: int) -> List[str]:
        """Runs the Monte Carlo simulation loop."""
        history = [start_state]
        current_state = start_state

        for _ in range(max_ticks):
            next_st = self.next_state(current_state)
            history.append(next_st)

            # Check for an absorbing state (loops to itself with 100% probability)
            if next_st == current_state and self.matrix[current_state][next_st] == 1.0:
                break

            current_state = next_st

        return history



# CONFIGURATION: Parrot Matrix

norwegian_blue_matrix = {
    "Resting": {"Resting": 0.5, "Pining": 0.3, "Stunned": 0.2},
    "Pining": {"Resting": 0.4, "Pining": 0.4, "Stunned": 0.2},
    "Stunned": {"Resting": 0.2, "Ex-Parrot": 0.8},
    "Ex-Parrot": {"Ex-Parrot": 1.0},  # The Absorbing State / Choir Invisible
}


# %% EXECUTION

if __name__ == "__main__":
    # Initialize the simulator with our script
    simulator = MarkovChainSimulator(norwegian_blue_matrix)

    print("--- Simulating the Fate of the Norwegian Blue ---")
    state_history = simulator.run_simulation(start_state="Resting", max_ticks=20)

    # Print flavor-text results based on the state sequence
    for tick, state in enumerate(state_history):
        print(f"[Tick {tick:02d}]: {state}")
        if state == "Ex-Parrot":
            print(
                "\n'E's bleedin' demised! This is an EX-PARROT! (Simulation Terminated)"
            )
            break
    else:
        print("\n Amazingly, it's still pining for the fjords.")
      
## Diagnostic Visualization
  # %% Load Libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# Simulation dummy data for execution safety:
np.random.seed(42)
states = ["Resting", "Pining", "Stunned", "Vooming"]
df = pd.DataFrame({
    "Tick": range(1, 1001),
    "State": np.random.choice(states, size=1000)
})

# Set a clean, minimalist style globally
sns.set_theme(style="whitegrid")

# %% Initialize Subplots (Side-by-Side)
# This mimics R's `patchwork` layout engine
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# PLOT 1: Trace Plot
# Python requires converting categories to numbers or strings to plot lines smoothly
sns.lineplot(data=df, x="Tick", y="State", ax=ax1, color="#2c3e50", alpha=0.6, linewidth=1)
sns.scatterplot(data=df, x="Tick", y="State", ax=ax1, color="#e74c3c", s=10, alpha=0.4)

ax1.set_title("MCMC Trace Plot", fontsize=14, pad=10)
ax1.set_xlabel("Sampling Timeline")
ax1.set_ylabel("State")

# PLOT 2: Posterior Density Plot
# stat="probability" gives you proportions instead of raw counts
sns.histplot(data=df, x="State", ax=ax2, stat="probability", hue="State", 
             palette="Spectral", shrink=0.7, edgecolor="black", alpha=0.7, legend=False)

ax2.set_title("State Frequency", fontsize=14, pad=10)
ax2.set_xlabel("The 'Bins' of Long-Term Probability")
ax2.set_ylabel("Proportion")

# %% Display and Clean Up
plt.tight_layout()
plt.show()
