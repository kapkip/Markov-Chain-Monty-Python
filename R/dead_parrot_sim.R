
### THE MONTY PYTHON MARKOV CHAIN SIMULATOR ###
#_____________________________________________#


# --- Simulation Loop ---

run_markov_simulation <- function(states, transition_matrix, start_state, max_ticks) {
  
  # 1. Validation: Ensure rows sum to 1
  if (!all(abs(rowSums(transition_matrix) - 1) < 1e-9)) {
    stop("Error: Row probabilities in the transition matrix must sum to 1.0!")
  }
  
  # 2. Setup tracking vector
  history <- character(max_ticks + 1)
  history[1] <- start_state
  current_state <- start_state
  
  # 3. Monte Carlo Loop
  for (tick in 1:max_ticks) {
    # Get the row index for the current state
    state_idx <- which(states == current_state)
    
    # Sample the next state based on the row's probabilities
    next_state <- sample(
      x       = states, 
      size    = 1, 
      prob    = transition_matrix[state_idx, ]
    )
    
    history[tick + 1] <- next_state
    
    # Check for an absorbing state (e.g., Ex-Parrot maps 100% to itself)
    if (next_state == current_state && transition_matrix[state_idx, state_idx] == 1.0) {
      # Truncate history to the current length and exit early
      history <- history[1:(tick + 1)]
      break
    }
    
    current_state <- next_state
  }
  
  return(history)
}

# --- Configuration and Running ---

# Define the state space
parrot_states <- c("Resting", "Pining", "Stunned", "Ex-Parrot")

# Define the Transition Matrix (Rows = From, Columns = To)
# Note: R fills matrices by column by default, so we specify byrow=TRUE
parrot_matrix <- matrix(
  c(
    0.5,  0.3,  0.2,  0.0,   # From Resting
    0.4,  0.4,  0.2,  0.0,   # From Pining
    0.2,  0.0,  0.0,  0.8,   # From Stunned
    0.0,  0.0,  0.0,  1.0    # From Ex-Parrot (Absorbing State)
  ), 
  nrow  = 4, 
  ncol  = 4, 
  byrow = TRUE,
  dimnames = list(parrot_states, parrot_states)
)

# Run it
cat("--- Simulating the Fate of the Parrot in R ---\n")
results <- run_markov_simulation(
  states            = parrot_states, 
  transition_matrix = parrot_matrix, 
  start_state       = "Resting", 
  max_ticks         = 20
)

# Print the timeline cleanly
for (i in seq_along(results)) {
  cat(sprintf("[Tick %02d]: %s\n", i - 1, results[i]))
  if (results[i] == "Ex-Parrot") {
    cat("\n'E's kicked the bucket, shuffled off 'is mortal coil! (Simulation Ended)\n")
    break
  }
}

library(ggplot2)
library(patchwork) # For combining the plots side-by-side

# 1. Setup a "living" parrot matrix so the chain doesn't immediately stop
states <- c("Resting", "Pining", "Stunned", "Vooming")
matrix_data <- matrix(
  c(
    0.5,  0.3,  0.2,  0.0,
    0.4,  0.4,  0.2,  0.0,
    0.1,  0.1,  0.1,  0.7,
    0.6,  0.0,  0.0,  0.4   # Vooming can loop or go back to resting!
  ), 
  nrow = 4, byrow = TRUE, dimnames = list(states, states)
)

# 2. Run a long simulation (1,000 steps)
set.seed(42)
current <- "Resting"
history <- character(1000)

for(t in 1:1000) {
  idx <- which(states == current)
  current <- sample(states, size = 1, prob = matrix_data[idx, ])
  history[t] <- current
}

# Create a clean dataframe for ggplot
df <- data.frame(
  Tick = 1:1000,
  State = factor(history, levels = states)
)

# --- Diagnostics and Visualization ----

# Problem 1: The distribution of the starting sample is too different from target distribution (Burn-In Failure)
  # Started in a too-improbable state that will skew your final averages and distributions
# Fix: -discard some initial observations
#     -increace iterations

# # Problem 2: Effective sample size is too small (ESS)
  # The chain has a high rate of autocorrelation and while you have many steps, too many adjacent are too similar
  # This will tank the independence of samples and you will have massive error margins and might miss the distribution shape entirely
# Fix: -thinning (keeping only every xth observation)
#     -increace iterations


# PLOT 1: The Trace Plot (The Horrible Mess of Noise)

p1 <- ggplot(df, aes(x = Tick, y = State, group = 1)) +
  geom_line(color = "#2c3e50", alpha = 0.6) +
  geom_point(color = "#e74c3c", size = 0.5, alpha = 0.4) +
  theme_minimal() +
  labs(title = "MCMC Trace Plot", subtitle = "Sampling Timeline")

# Type 1: will look like a bolt that gets noisy
# Type 2: will not be noisy at all, jagged line 


# PLOT 2: Posterior Density Plot

p2 <- ggplot(df, aes(x = State, fill = State)) +
  geom_bar(aes(y = after_stat(prop), group = 1), color = "black", alpha = 0.7) +
  scale_fill_brewer(palette = "Spectral") +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "State Frequency", subtitle = "The 'Bins' of Long-Term Probability", y = "Proportion")

# Display them side by side
p1 + p2
