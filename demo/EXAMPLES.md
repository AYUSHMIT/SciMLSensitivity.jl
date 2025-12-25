# 📚 Examples Gallery - SciMLSensitivity.jl

This guide provides additional examples and use cases beyond the main demo. Each example is self-contained and demonstrates a specific feature or application.

## Table of Contents

1. [SIR Epidemic Model](#sir-epidemic-model)
2. [Chemical Reaction Networks](#chemical-reaction-networks)
3. [Sensitivity Heatmaps](#sensitivity-heatmaps)
4. [Optimal Control](#optimal-control)
5. [Stochastic Differential Equations](#stochastic-differential-equations)

---

## Example 1: SIR Epidemic Model

### Understanding Disease Spread with Sensitivity Analysis

The SIR (Susceptible-Infected-Recovered) model is fundamental in epidemiology:

```julia
using OrdinaryDiffEq, SciMLSensitivity, Plots, ForwardDiff

# SIR Model: Susceptible, Infected, Recovered
function sir_model!(du, u, p, t)
    S, I, R = u
    β, γ = p  # β: transmission rate, γ: recovery rate
    N = S + I + R  # Total population
    
    du[1] = -β * S * I / N      # Susceptible
    du[2] = β * S * I / N - γ * I  # Infected
    du[3] = γ * I               # Recovered
end

# Initial conditions: 99% susceptible, 1% infected
u0 = [990.0, 10.0, 0.0]
tspan = (0.0, 160.0)
p = [0.5, 0.25]  # β=0.5 (transmission), γ=0.25 (recovery)

prob = ODEProblem(sir_model!, u0, tspan, p)
sol = solve(prob, Tsit5())

# Visualize
plot(sol, 
    xlabel="Days", 
    ylabel="Population",
    title="SIR Epidemic Model",
    label=["Susceptible" "Infected" "Recovered"],
    linewidth=2,
    color=[:blue :red :green]
)

# Compute sensitivity: How does peak infection depend on transmission rate?
function peak_infected(p)
    sol = solve(remake(prob, p=p), Tsit5())
    return maximum(sol[2, :])  # Max infected
end

# Sensitivity with respect to β (transmission rate)
∂peak_∂β = ForwardDiff.derivative(β -> peak_infected([β, p[2]]), p[1])
println("If β increases by 0.01, peak infections increase by: ", round(∂peak_∂β * 0.01, digits=2))

# What if we implement social distancing (reduce β)?
β_values = 0.2:0.05:0.8
peaks = [peak_infected([β, p[2]]) for β in β_values]

plot(β_values, peaks,
    xlabel="Transmission Rate (β)",
    ylabel="Peak Infected",
    title="Effect of Intervention on Peak Infections",
    linewidth=2,
    marker=:circle,
    legend=false
)
```

**Key Insight**: This shows how sensitivity analysis helps understand the impact of public health interventions!

---

## Example 2: Chemical Reaction Networks

### Robertson Chemical Kinetics Problem

A classic stiff ODE system modeling chemical reactions:

```julia
using OrdinaryDiffEq, SciMLSensitivity, Zygote

# Robertson problem: A -> B -> C
function robertson!(du, u, p, t)
    k1, k2, k3 = p
    
    du[1] = -k1 * u[1] + k3 * u[2] * u[3]
    du[2] = k1 * u[1] - k2 * u[2]^2 - k3 * u[2] * u[3]
    du[3] = k2 * u[2]^2
end

u0 = [1.0, 0.0, 0.0]
tspan = (0.0, 1e5)
p = [0.04, 3e7, 1e4]

prob = ODEProblem(robertson!, u0, tspan, p)

# Solve with appropriate solver for stiff problems
sol = solve(prob, Rodas5(), saveat=10 .^ range(0, 5, length=100))

# Visualize on log scale
plot(sol, 
    xscale=:log10,
    yscale=:log10,
    xlabel="Time (log scale)",
    ylabel="Concentration (log scale)",
    title="Robertson Chemical Kinetics",
    label=["A" "B" "C"],
    linewidth=2
)

# Use adjoint sensitivity for gradient computation
function final_concentration(p)
    sol = solve(remake(prob, p=p), Rodas5(), 
                sensealg=InterpolatingAdjoint(autojacvec=ReverseDiffVJP(true)))
    return sol[3, end]  # Final concentration of C
end

grad = Zygote.gradient(final_concentration, p)[1]
println("Gradient of final C concentration: ", grad)
```

**Key Insight**: Adjoint methods handle stiff problems efficiently, crucial for chemical kinetics!

---

## Example 3: Sensitivity Heatmaps

### Visualizing Parameter Space

Create beautiful heatmaps to understand parameter sensitivity:

```julia
using OrdinaryDiffEq, Plots

# Simple exponential decay with two parameters
function decay!(du, u, p, t)
    k1, k2 = p
    du[1] = -k1 * u[1]
    du[2] = -k2 * u[2]
end

u0 = [1.0, 1.0]
tspan = (0.0, 5.0)

# Create parameter grid
k1_range = range(0.1, 2.0, length=50)
k2_range = range(0.1, 2.0, length=50)

# Compute final values for each parameter combination
results = zeros(length(k1_range), length(k2_range))

for (i, k1) in enumerate(k1_range)
    for (j, k2) in enumerate(k2_range)
        prob = ODEProblem(decay!, u0, tspan, [k1, k2])
        sol = solve(prob, Tsit5())
        results[i, j] = sum(sol[:, end])  # Total final amount
    end
end

# Create beautiful heatmap
heatmap(k1_range, k2_range, results',
    xlabel="k₁ (decay rate 1)",
    ylabel="k₂ (decay rate 2)",
    title="Parameter Space Exploration",
    color=:viridis,
    colorbar_title="Final Total",
    size=(600, 500)
)
```

**Key Insight**: Heatmaps reveal parameter interactions and optimal regions!

---

## Example 4: Optimal Control

### Finding Optimal Control Policy

Use sensitivity analysis for optimal control:

```julia
using OrdinaryDiffEq, SciMLSensitivity, Optimization, OptimizationOptimisers

# Controlled system: minimize deviation from target
function controlled_system!(du, u, p, t)
    x, v = u
    control = p[1] * sin(p[2] * t + p[3])  # Parameterized control
    
    du[1] = v
    du[2] = control - 0.1 * v  # Control with damping
end

u0 = [0.0, 0.0]
tspan = (0.0, 10.0)
target = [1.0, 0.0]  # Target position

# Initial control parameters
p_control = [1.0, 1.0, 0.0]  # [amplitude, frequency, phase]

prob = ODEProblem(controlled_system!, u0, tspan, p_control)

# Cost function: minimize distance to target
function control_cost(p)
    sol = solve(remake(prob, p=p), Tsit5(), sensealg=InterpolatingAdjoint(autojacvec=ReverseDiffVJP(true)))
    final_state = sol[:, end]
    return sum(abs2, final_state .- target)
end

# Optimize control parameters
optf = Optimization.OptimizationFunction((x, p) -> control_cost(x), Optimization.AutoZygote())
optprob = Optimization.OptimizationProblem(optf, p_control)
result = Optimization.solve(optprob, OptimizationOptimisers.Adam(0.1), maxiters=200)

# Compare initial vs optimal control
sol_initial = solve(ODEProblem(controlled_system!, u0, tspan, p_control), Tsit5())
sol_optimal = solve(ODEProblem(controlled_system!, u0, tspan, result.u), Tsit5())

plot(sol_initial, 
    xlabel="Time", 
    ylabel="State",
    title="Optimal Control",
    label=["Initial Position" "Initial Velocity"],
    linestyle=:dash,
    linewidth=2
)

plot!(sol_optimal,
    label=["Optimal Position" "Optimal Velocity"],
    linewidth=2
)
```

**Key Insight**: Sensitivity-based optimization finds control strategies that achieve desired outcomes!

---

## Example 5: Stochastic Differential Equations

### Adding Noise to Dynamics

Extend to stochastic systems:

```julia
using StochasticDiffEq, SciMLSensitivity, Plots

# Stochastic predator-prey
function lotka_volterra_drift!(du, u, p, t)
    α, β, γ, δ = p
    x, y = u
    
    du[1] = α * x - β * x * y
    du[2] = -γ * y + δ * x * y
end

# Noise term (diffusion)
function lotka_volterra_diffusion!(du, u, p, t)
    σ = 0.1  # Noise intensity
    du[1] = σ * u[1]
    du[2] = σ * u[2]
end

u0 = [1.0, 1.0]
tspan = (0.0, 10.0)
p = [1.5, 1.0, 3.0, 1.0]

prob = SDEProblem(lotka_volterra_drift!, lotka_volterra_diffusion!, u0, tspan, p)

# Solve multiple trajectories
ensemble_prob = EnsembleProblem(prob)
sol = solve(ensemble_prob, EM(), dt=0.01, trajectories=20)

# Visualize ensemble
plot(sol, 
    xlabel="Time",
    ylabel="Population",
    title="Stochastic Lotka-Volterra (20 trajectories)",
    alpha=0.3,
    linewidth=1,
    color=[:green :red],
    legend=false
)

# Compute mean trajectory
mean_sol = EnsembleSummary(sol)
plot!(mean_sol,
    label=["Mean Prey" "Mean Predators"],
    linewidth=3,
    color=[:darkgreen :darkred]
)
```

**Key Insight**: SciMLSensitivity.jl handles stochastic systems with specialized algorithms!

---

## Advanced Topics

### Memory-Efficient Backsolve Adjoint

For very long time series:

```julia
# Use BacksolveAdjoint for O(1) memory
sol = solve(prob, Tsit5(), sensealg=BacksolveAdjoint(autojacvec=ReverseDiffVJP(true)))
```

### Continuous Callbacks

For events during simulation:

```julia
# Define callback for when prey population drops below threshold
condition(u, t, integrator) = u[1] - 0.5
affect!(integrator) = integrator.p[1] *= 1.1  # Increase growth rate

cb = ContinuousCallback(condition, affect!)
sol = solve(prob, Tsit5(), callback=cb)
```

### GPU Acceleration

For large-scale problems:

```julia
using CUDA

# Convert to GPU arrays
u0_gpu = cu(u0)
prob_gpu = remake(prob, u0=u0_gpu)
sol_gpu = solve(prob_gpu, Tsit5())
```

---

## Tips and Tricks

1. **Choose the right algorithm**: 
   - Few parameters → ForwardSensitivity
   - Many parameters → Adjoint methods

2. **Handle stiffness**: Use appropriate solvers (Rodas5, TRBDF2) for stiff problems

3. **Checkpointing**: For long simulations, use checkpointing to balance memory and computation

4. **Sparse Jacobians**: Exploit sparsity for large systems with `jac_prototype`

5. **Automatic differentiation**: Let SciMLSensitivity choose with `sensealg=nothing`

---

## More Resources

- **Documentation**: https://docs.sciml.ai/SciMLSensitivity/stable/
- **Examples**: https://docs.sciml.ai/SciMLSensitivity/stable/examples/
- **Tutorials**: https://docs.sciml.ai/SciMLSensitivity/stable/tutorials/
- **Paper**: [Universal Differential Equations](https://arxiv.org/abs/2001.04385)

---

**Happy Exploring!** Try these examples and adapt them to your own problems! 🚀
