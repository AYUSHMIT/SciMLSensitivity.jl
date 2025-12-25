# ═══════════════════════════════════════════════════════════════════════════════
# Beautiful Exploratory Demo of SciMLSensitivity.jl
# ═══════════════════════════════════════════════════════════════════════════════
#
# This demo showcases the power and elegance of SciMLSensitivity.jl for:
# - Sensitivity analysis of differential equations
# - Parameter estimation and model calibration
# - Neural differential equations
# - Various advanced techniques in scientific machine learning
#
# Author: SciML Community
# License: MIT
# ═══════════════════════════════════════════════════════════════════════════════

println("╔═══════════════════════════════════════════════════════════════╗")
println("║   🎨 SciMLSensitivity.jl - Beautiful Exploratory Demo 🎨    ║")
println("╚═══════════════════════════════════════════════════════════════╝")
println()

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 Package Loading
# ═══════════════════════════════════════════════════════════════════════════════

using OrdinaryDiffEq
using SciMLSensitivity
using ForwardDiff
using Zygote
using Plots
using LinearAlgebra
using Statistics
using Random
using Optimization
using OptimizationOptimisers

# Set random seed for reproducibility
Random.seed!(1234)

# Enhanced plotting defaults for beautiful visualizations
default(
    fontfamily="Computer Modern",
    linewidth=2,
    framestyle=:box,
    label=nothing,
    grid=true,
    gridstyle=:dot,
    gridalpha=0.3,
    dpi=300
)

println("✓ All packages loaded successfully!\n")

# ═══════════════════════════════════════════════════════════════════════════════
# 🦋 SECTION 1: The Lotka-Volterra Predator-Prey Model
# ═══════════════════════════════════════════════════════════════════════════════
println("═" ^ 70)
println("SECTION 1: Basic Sensitivity Analysis - Lotka-Volterra System")
println("═" ^ 70)
println()
println("The Lotka-Volterra equations model predator-prey dynamics:")
println("  dx/dt = αx - βxy   (prey growth and predation)")
println("  dy/dt = -γy + δxy  (predator death and growth from predation)")
println()

# Define the Lotka-Volterra system
function lotka_volterra!(du, u, p, t)
    α, β, γ, δ = p
    x, y = u
    
    du[1] = α * x - β * x * y  # Prey
    du[2] = -γ * y + δ * x * y # Predator
end

# True parameters
p_true = [1.5, 1.0, 3.0, 1.0]  # [α, β, γ, δ]
u0 = [1.0, 1.0]                 # Initial populations
tspan = (0.0, 10.0)
prob = ODEProblem(lotka_volterra!, u0, tspan, p_true)

# Solve the system
println("🔄 Solving the Lotka-Volterra system...")
sol = solve(prob, Tsit5(), saveat=0.1)

# Create beautiful visualization
p1 = plot(sol, 
    xlabel="Time", 
    ylabel="Population",
    title="Lotka-Volterra Predator-Prey Dynamics",
    label=["Prey (Rabbits)" "Predators (Foxes)"],
    color=[:green :red],
    linewidth=2.5,
    legend=:topright
)

p2 = plot(sol, 
    vars=(1, 2),
    xlabel="Prey Population", 
    ylabel="Predator Population",
    title="Phase Portrait",
    color=:blue,
    linewidth=2,
    marker=:circle,
    markersize=2,
    alpha=0.8
)

demo_plot1 = plot(p1, p2, layout=(1, 2), size=(1000, 400))
display(demo_plot1)
println("✓ Basic dynamics plotted!\n")

# ═══════════════════════════════════════════════════════════════════════════════
# 📊 SECTION 2: Forward Sensitivity Analysis
# ═══════════════════════════════════════════════════════════════════════════════
println("═" ^ 70)
println("SECTION 2: Forward Sensitivity Analysis")
println("═" ^ 70)
println()
println("Forward sensitivity computes: ∂u/∂p")
println("This tells us how the solution changes with respect to parameters.")
println()

# Compute sensitivities using forward sensitivity analysis
println("🔄 Computing forward sensitivities...")

function compute_sensitivities(prob, p)
    # Use ForwardDiff to compute sensitivities
    function loss(p)
        tmp_prob = remake(prob, p=p)
        sol = solve(tmp_prob, Tsit5(), saveat=0.1, sensealg=ForwardSensitivity())
        return sol[1, end]  # Prey population at final time
    end
    
    return ForwardDiff.gradient(loss, p)
end

sens = compute_sensitivities(prob, p_true)

println("Parameter Sensitivities at t=10.0:")
println("  ∂(prey)/∂α = ", round(sens[1], digits=4))
println("  ∂(prey)/∂β = ", round(sens[2], digits=4))
println("  ∂(prey)/∂γ = ", round(sens[3], digits=4))
println("  ∂(prey)/∂δ = ", round(sens[4], digits=4))
println()

# Visualize sensitivity
sens_plot = bar(
    ["α (prey growth)", "β (predation)", "γ (predator death)", "δ (pred. growth)"],
    sens,
    title="Parameter Sensitivity of Final Prey Population",
    xlabel="Parameter",
    ylabel="Sensitivity",
    color=[:green :red :blue :orange],
    legend=false,
    size=(800, 400)
)
display(sens_plot)
println("✓ Forward sensitivities computed and visualized!\n")

# ═══════════════════════════════════════════════════════════════════════════════
# 🎯 SECTION 3: Adjoint Sensitivity for Efficient Gradients
# ═══════════════════════════════════════════════════════════════════════════════
println("═" ^ 70)
println("SECTION 3: Adjoint Sensitivity Analysis")
println("═" ^ 70)
println()
println("Adjoint methods compute gradients efficiently for high-dimensional")
println("parameter spaces - crucial for parameter estimation and optimization!")
println()

# Define a loss function
function loss_function(p)
    tmp_prob = remake(prob, p=p)
    sol = solve(tmp_prob, Tsit5(), saveat=0.1, sensealg=InterpolatingAdjoint(autojacvec=ReverseDiffVJP(true)))
    
    # Loss: sum of squared prey population (we want to maximize prey)
    return sum(abs2, 1.0 .- sol[1, :])
end

println("🔄 Computing adjoint sensitivities with Zygote...")
adjoint_grad = Zygote.gradient(loss_function, p_true)[1]

println("Adjoint Gradients:")
println("  ∂L/∂α = ", round(adjoint_grad[1], digits=4))
println("  ∂L/∂β = ", round(adjoint_grad[2], digits=4))
println("  ∂L/∂γ = ", round(adjoint_grad[3], digits=4))
println("  ∂L/∂δ = ", round(adjoint_grad[4], digits=4))
println()

# Compare methods
comp_plot = groupedbar(
    ["α" "β" "γ" "δ"],
    [sens' adjoint_grad'],
    label=["Forward Sens." "Adjoint Grad."],
    title="Comparison: Forward vs Adjoint Methods",
    xlabel="Parameter",
    ylabel="Gradient Value",
    color=[:skyblue :coral],
    size=(800, 400),
    legend=:topright
)
display(comp_plot)
println("✓ Adjoint sensitivities computed!\n")

# ═══════════════════════════════════════════════════════════════════════════════
# 🧠 SECTION 4: Neural Ordinary Differential Equations
# ═══════════════════════════════════════════════════════════════════════════════
println("═" ^ 70)
println("SECTION 4: Neural Ordinary Differential Equations")
println("═" ^ 70)
println()
println("Neural ODEs: Learn the dynamics from data!")
println("We'll train a neural network to discover the Lotka-Volterra dynamics.")
println()

# Generate training data with noise
println("🔄 Generating noisy training data...")
datasize = 30
t_data = range(tspan[1], tspan[2], length=datasize)
sol_data = solve(prob, Tsit5(), saveat=t_data)
ode_data = Array(sol_data) .+ 0.1 .* randn(size(Array(sol_data)))

# Simple neural network to represent the ODE
function neural_ode_func!(du, u, p, t)
    # A simple 2-layer neural network
    # Layer 1: 2 -> 8 neurons with tanh activation
    W1 = reshape(p[1:16], 8, 2)
    b1 = p[17:24]
    
    # Layer 2: 8 -> 2 neurons (output layer)
    W2 = reshape(p[25:40], 2, 8)
    b2 = p[41:42]
    
    # Forward pass
    h = tanh.(W1 * u .+ b1)
    du .= W2 * h .+ b2
end

# Initialize parameters
p_neural = randn(42) .* 0.1

# Define Neural ODE problem
neural_prob = ODEProblem(neural_ode_func!, u0, tspan, p_neural)

# Prediction function
function predict_neuralode(p)
    Array(solve(neural_prob, Tsit5(), p=p, saveat=t_data))
end

# Loss function
function loss_neuralode(p)
    pred = predict_neuralode(p)
    return sum(abs2, ode_data .- pred)
end

println("🔄 Training Neural ODE (this may take a minute)...")
println("Initial loss: ", round(loss_neuralode(p_neural), digits=2))

# Training with optimization
callback_count = [0]
function callback(p, l)
    callback_count[1] += 1
    if callback_count[1] % 10 == 0
        println("  Iteration $(callback_count[1]): Loss = $(round(l, digits=4))")
    end
    return false
end

# Simple gradient descent optimization
optf = Optimization.OptimizationFunction((x, p) -> loss_neuralode(x), Optimization.AutoZygote())
optprob = Optimization.OptimizationProblem(optf, p_neural)

# Train for a limited number of iterations for demo purposes
result = Optimization.solve(optprob, OptimizationOptimisers.Adam(0.01), 
                           callback=callback, maxiters=100)

println("\nFinal loss: ", round(loss_neuralode(result.u), digits=2))
println()

# Visualize Neural ODE results
pred_trained = predict_neuralode(result.u)

neural_plot = plot(t_data, ode_data', 
    xlabel="Time",
    ylabel="Population",
    title="Neural ODE: Learning Dynamics from Data",
    label=["True Prey" "True Predators"],
    marker=:circle,
    markersize=4,
    linestyle=:dash,
    color=[:green :red],
    linewidth=2
)

plot!(neural_plot, t_data, pred_trained',
    label=["Predicted Prey" "Predicted Predators"],
    color=[:lightgreen :pink],
    linewidth=3,
    alpha=0.7
)

display(neural_plot)
println("✓ Neural ODE trained and visualized!\n")

# ═══════════════════════════════════════════════════════════════════════════════
# 🎲 SECTION 5: Parameter Estimation with Noisy Data
# ═══════════════════════════════════════════════════════════════════════════════
println("═" ^ 70)
println("SECTION 5: Parameter Estimation from Noisy Data")
println("═" ^ 70)
println()
println("Can we recover the true parameters from noisy observations?")
println("Let's find out using optimization with adjoint sensitivities!")
println()

# Start with wrong initial guess
p_guess = [1.0, 1.5, 2.5, 0.8]  # Initial guess (wrong parameters)

println("True parameters:    ", p_true)
println("Initial guess:      ", p_guess)
println()

# Define optimization problem for parameter estimation
function param_loss(p)
    tmp_prob = remake(prob, p=p, u0=u0)
    pred = solve(tmp_prob, Tsit5(), saveat=t_data, sensealg=InterpolatingAdjoint(autojacvec=ReverseDiffVJP(true)))
    
    if pred.retcode != :Success
        return Inf
    end
    
    return sum(abs2, ode_data .- Array(pred))
end

println("🔄 Estimating parameters from data...")
println("Initial loss: ", round(param_loss(p_guess), digits=2))

# Optimize
param_callback_count = [0]
function param_callback(p, l)
    param_callback_count[1] += 1
    if param_callback_count[1] % 10 == 0
        println("  Iteration $(param_callback_count[1]): Loss = $(round(l, digits=4))")
    end
    return false
end

optf_param = Optimization.OptimizationFunction((x, p) -> param_loss(x), Optimization.AutoZygote())
optprob_param = Optimization.OptimizationProblem(optf_param, p_guess, lb=[0.1, 0.1, 0.1, 0.1], ub=[5.0, 5.0, 5.0, 5.0])

result_param = Optimization.solve(optprob_param, OptimizationOptimisers.Adam(0.05), 
                                 callback=param_callback, maxiters=100)

p_estimated = result_param.u
println("\nTrue parameters:      ", [round(p, digits=3) for p in p_true])
println("Estimated parameters: ", [round(p, digits=3) for p in p_estimated])
println("Estimation error:     ", round(norm(p_true .- p_estimated), digits=4))
println()

# Compare true vs estimated
sol_estimated = solve(remake(prob, p=p_estimated), Tsit5(), saveat=t_data)

param_est_plot = plot(t_data, ode_data',
    xlabel="Time",
    ylabel="Population",
    title="Parameter Estimation: Data vs Model",
    label=["Observed Prey" "Observed Predators"],
    marker=:circle,
    markersize=4,
    color=[:green :red],
    linestyle=:dash,
    linewidth=1
)

plot!(param_est_plot, sol,
    label=["True Model Prey" "True Model Predators"],
    color=[:darkgreen :darkred],
    linewidth=2,
    alpha=0.8
)

plot!(param_est_plot, sol_estimated,
    label=["Estimated Model Prey" "Estimated Model Predators"],
    color=[:lightgreen :pink],
    linewidth=2.5,
    linestyle=:dot
)

display(param_est_plot)
println("✓ Parameter estimation complete!\n")

# ═══════════════════════════════════════════════════════════════════════════════
# 🌊 SECTION 6: Exploring Different Sensitivity Algorithms
# ═══════════════════════════════════════════════════════════════════════════════
println("═" ^ 70)
println("SECTION 6: Comparing Different Sensitivity Algorithms")
println("═" ^ 70)
println()
println("SciMLSensitivity.jl offers many algorithms, each with trade-offs:")
println("- ForwardSensitivity: Best for few parameters, many outputs")
println("- InterpolatingAdjoint: Efficient for many parameters")
println("- QuadratureAdjoint: More accurate for certain problems")
println("- BacksolveAdjoint: Memory efficient with O(1) memory")
println()

# Compare computation times for different algorithms
algorithms = [
    ("Forward", ForwardSensitivity()),
    ("Interpolating Adjoint", InterpolatingAdjoint(autojacvec=ReverseDiffVJP(true))),
    ("Quadrature Adjoint", QuadratureAdjoint(autojacvec=ReverseDiffVJP(true))),
    ("Backsolve Adjoint", BacksolveAdjoint(autojacvec=ReverseDiffVJP(true)))
]

times = Float64[]
println("🔄 Benchmarking different sensitivity algorithms...")

for (name, alg) in algorithms
    function test_loss(p)
        tmp_prob = remake(prob, p=p)
        sol = solve(tmp_prob, Tsit5(), saveat=0.1, sensealg=alg)
        return sum(abs2, sol[1, :])
    end
    
    # Warm-up
    try
        Zygote.gradient(test_loss, p_true)
    catch
        push!(times, NaN)
        println("  ⚠ $name: Not compatible with current setup")
        continue
    end
    
    # Time it
    t = @elapsed begin
        for i in 1:5
            Zygote.gradient(test_loss, p_true)
        end
    end
    push!(times, t / 5)
    println("  ✓ $name: $(round(t/5 * 1000, digits=2)) ms")
end

println()

# Visualize comparison
valid_idx = .!isnan.(times)
if sum(valid_idx) > 0
    alg_names = [name for (name, _) in algorithms][valid_idx]
    valid_times = times[valid_idx]
    
    alg_plot = bar(alg_names,
        valid_times .* 1000,
        xlabel="Algorithm",
        ylabel="Time (ms)",
        title="Sensitivity Algorithm Performance Comparison",
        color=:viridis,
        legend=false,
        size=(800, 400),
        xrotation=15
    )
    display(alg_plot)
    println("✓ Algorithm comparison complete!\n")
end

# ═══════════════════════════════════════════════════════════════════════════════
# 🎬 Final Summary
# ═══════════════════════════════════════════════════════════════════════════════
println("═" ^ 70)
println("🎉 Demo Complete!")
println("═" ^ 70)
println()
println("You've explored:")
println("  ✓ Basic ODE solving and visualization")
println("  ✓ Forward sensitivity analysis")
println("  ✓ Adjoint methods for efficient gradients")
println("  ✓ Neural ordinary differential equations")
println("  ✓ Parameter estimation from noisy data")
println("  ✓ Performance comparison of different algorithms")
println()
println("Next Steps:")
println("  → Explore the official documentation: https://docs.sciml.ai/SciMLSensitivity/stable/")
println("  → Try your own differential equations")
println("  → Experiment with SDEs, DDEs, and hybrid systems")
println("  → Build physics-informed neural networks")
println()
println("═" ^ 70)
println("Happy Scientific Machine Learning! 🚀")
println("═" ^ 70)
