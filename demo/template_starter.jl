# 🚀 Your Custom Demo Template

# Copy this file and modify it for your own sensitivity analysis project!
# This template includes the essential structure for parameter estimation.

using OrdinaryDiffEq
using SciMLSensitivity
using Zygote
using Optimization
using OptimizationOptimisers
using Plots

println("╔═══════════════════════════════════════════════════════╗")
println("║          Custom Sensitivity Analysis Demo           ║")
println("╚═══════════════════════════════════════════════════════╝")
println()

# ═══════════════════════════════════════════════════════════
# STEP 1: Define Your Differential Equation
# ═══════════════════════════════════════════════════════════

# TODO: Replace this with your own ODE system
function my_ode_system!(du, u, p, t)
    # Example: Simple exponential growth/decay
    # du/dt = p[1] * u
    
    # Your parameters
    k = p[1]  # Growth/decay rate
    
    # Your equations
    du[1] = k * u[1]
    
    # Add more equations as needed:
    # du[2] = ...
    # du[3] = ...
end

# ═══════════════════════════════════════════════════════════
# STEP 2: Set Up Initial Conditions and Parameters
# ═══════════════════════════════════════════════════════════

# TODO: Set your initial conditions
u0 = [1.0]  # Initial state

# TODO: Set your time span
tspan = (0.0, 10.0)  # Start and end time

# TODO: Define true parameters (if generating synthetic data)
p_true = [0.5]  # Your parameters

# ═══════════════════════════════════════════════════════════
# STEP 3: Generate or Load Data
# ═══════════════════════════════════════════════════════════

# Option A: Generate synthetic data
println("Generating synthetic data...")
prob = ODEProblem(my_ode_system!, u0, tspan, p_true)
t_data = range(tspan[1], tspan[2], length=20)
sol_true = solve(prob, Tsit5(), saveat=t_data)
data = Array(sol_true) .+ 0.1 .* randn(size(Array(sol_true)))  # Add noise

# Option B: Load your own data
# data = your_data_here
# t_data = your_time_points_here

println("✓ Data ready: $(size(data, 2)) time points")

# ═══════════════════════════════════════════════════════════
# STEP 4: Visualize Your Data
# ═══════════════════════════════════════════════════════════

println("\nVisualizing data...")
p_data = scatter(t_data, data[1, :],
    xlabel="Time",
    ylabel="State",
    title="Observed Data",
    label="Observations",
    marker=:circle,
    markersize=4,
    legend=:best
)
display(p_data)

# ═══════════════════════════════════════════════════════════
# STEP 5: Define Loss Function for Parameter Estimation
# ═══════════════════════════════════════════════════════════

function loss_function(p)
    # Solve ODE with current parameter guess
    tmp_prob = remake(prob, p=p)
    pred = solve(tmp_prob, Tsit5(), saveat=t_data,
                 sensealg=InterpolatingAdjoint(autojacvec=ReverseDiffVJP(true)))
    
    # Check if solve was successful
    if pred.retcode != :Success
        return Inf
    end
    
    # Compute loss (sum of squared errors)
    return sum(abs2, data .- Array(pred))
end

# ═══════════════════════════════════════════════════════════
# STEP 6: Set Up and Run Optimization
# ═══════════════════════════════════════════════════════════

# TODO: Set initial parameter guess
p_guess = [0.3]  # Your initial guess

println("\n" * "═"^60)
println("Parameter Estimation")
println("═"^60)
println("True parameters:    ", p_true)
println("Initial guess:      ", p_guess)
println("Initial loss:       ", round(loss_function(p_guess), digits=4))
println()

# Set up optimization
optf = Optimization.OptimizationFunction(
    (x, p) -> loss_function(x),
    Optimization.AutoZygote()
)
optprob = Optimization.OptimizationProblem(optf, p_guess)

# Callback to monitor progress
iter_count = [0]
function callback(p, l)
    iter_count[1] += 1
    if iter_count[1] % 10 == 0
        println("  Iteration $(iter_count[1]): Loss = $(round(l, digits=4))")
    end
    return false
end

# Run optimization
println("Running optimization...")
result = Optimization.solve(optprob, OptimizationOptimisers.Adam(0.05),
                           callback=callback, maxiters=100)

p_estimated = result.u

println("\nOptimization complete!")
println("True parameters:      ", p_true)
println("Estimated parameters: ", p_estimated)
println("Final loss:           ", round(loss_function(p_estimated), digits=4))
println("Relative error:       ", round(abs(p_estimated[1] - p_true[1]) / p_true[1] * 100, digits=2), "%")

# ═══════════════════════════════════════════════════════════
# STEP 7: Visualize Results
# ═══════════════════════════════════════════════════════════

println("\nGenerating comparison plot...")

# Solve with estimated parameters
sol_estimated = solve(remake(prob, p=p_estimated), Tsit5(), saveat=t_data)

# Create comparison plot
p_comparison = scatter(t_data, data[1, :],
    xlabel="Time",
    ylabel="State",
    title="Parameter Estimation Results",
    label="Observed Data",
    marker=:circle,
    markersize=4,
    color=:black
)

plot!(p_comparison, sol_true,
    label="True Model",
    linewidth=2,
    color=:blue,
    linestyle=:dash
)

plot!(p_comparison, sol_estimated,
    label="Estimated Model",
    linewidth=2.5,
    color=:red
)

display(p_comparison)

# ═══════════════════════════════════════════════════════════
# STEP 8: Sensitivity Analysis (Optional)
# ═══════════════════════════════════════════════════════════

println("\nComputing parameter sensitivities...")

using ForwardDiff

function final_state(p)
    tmp_prob = remake(prob, p=p)
    sol = solve(tmp_prob, Tsit5(), sensealg=ForwardSensitivity())
    return sol[1, end]
end

sensitivity = ForwardDiff.gradient(final_state, p_estimated)
println("Sensitivity at estimated parameters: ", sensitivity)
println("Interpretation: 1% change in parameter causes $(round(sensitivity[1]/final_state(p_estimated)*100, digits=2))% change in final state")

# ═══════════════════════════════════════════════════════════
# STEP 9: Save Results (Optional)
# ═══════════════════════════════════════════════════════════

# TODO: Uncomment to save results
# using DelimitedFiles
# writedlm("estimated_parameters.txt", p_estimated)
# savefig(p_comparison, "parameter_estimation_results.png")
# println("\n✓ Results saved")

# ═══════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════

println("\n" * "═"^60)
println("✓ Analysis Complete!")
println("═"^60)
println()
println("Next steps:")
println("  1. Modify my_ode_system!() with your equations")
println("  2. Adjust initial conditions and parameters")
println("  3. Load your own data or adjust noise levels")
println("  4. Experiment with different optimizers")
println("  5. Add uncertainty quantification")
println("  6. Try different sensitivity algorithms")
println()
println("═"^60)

# ═══════════════════════════════════════════════════════════
# Tips and Tricks
# ═══════════════════════════════════════════════════════════

"""
TIPS FOR CUSTOMIZATION:

1. Multiple Parameters:
   p = [k1, k2, k3, ...]
   Just add more elements to your parameter vector

2. Multiple State Variables:
   u0 = [x0, y0, z0, ...]
   data = Matrix with multiple rows

3. Different Sensitivity Algorithms:
   - ForwardSensitivity() - good for few parameters
   - InterpolatingAdjoint() - good for many parameters
   - BacksolveAdjoint() - memory efficient
   - QuadratureAdjoint() - more accurate

4. Better Optimization:
   - Try different optimizers: Adam, BFGS, NewtonRaphson
   - Adjust learning rate
   - Add bounds: lb=[...], ub=[...]
   - Use multiple initial guesses

5. Handling Stiff Problems:
   - Use Rodas5() or TRBDF2() instead of Tsit5()
   - Add tolerances: reltol=1e-6, abstol=1e-8

6. Debugging:
   - Start with synthetic data (known parameters)
   - Check if your ODE solves without optimization
   - Visualize loss landscape
   - Use smaller time ranges first

7. Performance:
   - Use in-place operations (!)
   - Pre-allocate arrays
   - Consider GPU acceleration for large systems

COMMON ISSUES:

Q: "Solve failed" or retcode != :Success
A: Try different solver, adjust tolerances, check initial conditions

Q: Optimization doesn't converge
A: Try different initial guess, adjust learning rate, use bounds

Q: Loss is NaN or Inf
A: Check for division by zero, use better initial guess

Q: Too slow
A: Reduce time span, use coarser time steps, try BacksolveAdjoint

For more help, see:
- QUICKSTART.md
- EXAMPLES.md
- https://docs.sciml.ai/SciMLSensitivity/stable/
"""
