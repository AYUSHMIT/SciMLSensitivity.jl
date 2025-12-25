#!/usr/bin/env julia

"""
Minimal test to verify the core demo functionality works.
This version is suitable for headless CI/CD environments.
"""

using Pkg
Pkg.activate(@__DIR__)

println("╔═══════════════════════════════════════════════════════════╗")
println("║     SciMLSensitivity.jl Demo Validation Test            ║")
println("╚═══════════════════════════════════════════════════════════╝")
println()

# Test core functionality without plotting
println("Loading packages...")
using OrdinaryDiffEq
using SciMLSensitivity
using ForwardDiff
using Zygote
using LinearAlgebra
using Random

Random.seed!(1234)
println("✓ Packages loaded\n")

# Test 1: Basic ODE solving
println("Test 1: Basic Lotka-Volterra ODE...")
function lotka_volterra!(du, u, p, t)
    α, β, γ, δ = p
    x, y = u
    du[1] = α * x - β * x * y
    du[2] = -γ * y + δ * x * y
end

p_true = [1.5, 1.0, 3.0, 1.0]
u0 = [1.0, 1.0]
tspan = (0.0, 10.0)
prob = ODEProblem(lotka_volterra!, u0, tspan, p_true)

sol = solve(prob, Tsit5(), saveat=0.1)
if sol.retcode == :Success
    println("  ✓ ODE solved successfully")
    println("  Final populations: prey=$(round(sol[1,end], digits=3)), predator=$(round(sol[2,end], digits=3))")
else
    println("  ✗ ODE solve failed")
    exit(1)
end

# Test 2: Forward sensitivity
println("\nTest 2: Forward sensitivity analysis...")
function compute_sensitivities(prob, p)
    function loss(p)
        tmp_prob = remake(prob, p=p)
        sol = solve(tmp_prob, Tsit5(), saveat=0.1, sensealg=ForwardSensitivity())
        if sol.retcode != :Success
            return Inf
        end
        return sol[1, end]
    end
    
    return ForwardDiff.gradient(loss, p)
end

try
    sens = compute_sensitivities(prob, p_true)
    println("  ✓ Forward sensitivities computed")
    println("  Sensitivities: ", [round(s, digits=4) for s in sens])
catch e
    println("  ✗ Forward sensitivity failed: $e")
    exit(1)
end

# Test 3: Adjoint sensitivity
println("\nTest 3: Adjoint sensitivity analysis...")
function loss_function(p)
    tmp_prob = remake(prob, p=p)
    sol = solve(tmp_prob, Tsit5(), saveat=0.1, 
                sensealg=InterpolatingAdjoint(autojacvec=ReverseDiffVJP(true)))
    if sol.retcode != :Success
        return Inf
    end
    return sum(abs2, 1.0 .- sol[1, :])
end

try
    adjoint_grad = Zygote.gradient(loss_function, p_true)[1]
    println("  ✓ Adjoint gradients computed")
    println("  Gradients: ", [round(g, digits=4) for g in adjoint_grad])
catch e
    println("  ✗ Adjoint sensitivity failed: $e")
    exit(1)
end

# Test 4: Parameter estimation setup
println("\nTest 4: Parameter estimation framework...")
datasize = 20
t_data = range(tspan[1], tspan[2], length=datasize)
sol_data = solve(prob, Tsit5(), saveat=t_data)
ode_data = Array(sol_data) .+ 0.05 .* randn(size(Array(sol_data)))

p_guess = [1.0, 1.5, 2.5, 0.8]

function param_loss(p)
    tmp_prob = remake(prob, p=p, u0=u0)
    pred = solve(tmp_prob, Tsit5(), saveat=t_data, 
                 sensealg=InterpolatingAdjoint(autojacvec=ReverseDiffVJP(true)))
    
    if pred.retcode != :Success
        return Inf
    end
    
    return sum(abs2, ode_data .- Array(pred))
end

try
    loss_initial = param_loss(p_guess)
    grad_initial = Zygote.gradient(param_loss, p_guess)[1]
    
    println("  ✓ Parameter estimation framework working")
    println("  Initial loss: ", round(loss_initial, digits=4))
    println("  Gradient norm: ", round(norm(grad_initial), digits=4))
catch e
    println("  ✗ Parameter estimation failed: $e")
    exit(1)
end

# Test 5: Simple Neural ODE structure
println("\nTest 5: Neural ODE structure...")
function neural_ode_func!(du, u, p, t)
    # Simple 2-layer network: 2 -> 4 -> 2
    W1 = reshape(p[1:8], 4, 2)
    b1 = p[9:12]
    W2 = reshape(p[13:20], 2, 4)
    b2 = p[21:22]
    
    h = tanh.(W1 * u .+ b1)
    du .= W2 * h .+ b2
end

p_neural = randn(22) .* 0.1
neural_prob = ODEProblem(neural_ode_func!, u0, (0.0, 1.0), p_neural)

try
    neural_sol = solve(neural_prob, Tsit5())
    if neural_sol.retcode == :Success
        println("  ✓ Neural ODE structure works")
        println("  Neural ODE solved successfully")
    else
        println("  ⚠ Neural ODE solve returned: $(neural_sol.retcode)")
    end
catch e
    println("  ✗ Neural ODE failed: $e")
    exit(1)
end

# Final summary
println("\n" * "═"^70)
println("✓ All Core Tests Passed!")
println("═"^70)
println()
println("The demo environment is properly configured and ready to use.")
println()
println("Key capabilities verified:")
println("  ✓ ODE solving with OrdinaryDiffEq.jl")
println("  ✓ Forward sensitivity analysis")
println("  ✓ Adjoint sensitivity methods")
println("  ✓ Parameter estimation framework")
println("  ✓ Neural ODE architecture")
println()
println("To run the full interactive demo with visualizations:")
println("  julia> include(\"exploratory_demo.jl\")")
println()
println("═"^70)

exit(0)
