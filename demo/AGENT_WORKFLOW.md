# 🤖 GitHub Agent Workflow Guide

This guide explains how to use the SciMLSensitivity.jl demo in an automated GitHub Agent workflow.

## Overview

The demo package is designed to be:
- ✅ **Self-contained**: All dependencies specified in `Project.toml`
- ✅ **Automated**: Can run without user interaction
- ✅ **Educational**: Generates comprehensive output and visualizations
- ✅ **Reproducible**: Fixed random seeds for consistent results

## Setup for Automated Execution

### 1. Prerequisites Check

```julia
# Check Julia version
using InteractiveUtils
versioninfo()

# Verify it's 1.10 or higher
if VERSION < v"1.10"
    error("Julia 1.10 or higher required")
end
```

### 2. Environment Activation

```julia
using Pkg

# Activate the demo environment
Pkg.activate("demo")

# Install all dependencies
Pkg.instantiate()

# Verify installation
Pkg.status()
```

### 3. Running the Demo

```julia
# Include and run the demo
include("demo/exploratory_demo.jl")
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Run SciMLSensitivity Demo

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  demo:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: julia-actions/setup-julia@v1
      with:
        version: '1.10'
    
    - name: Install dependencies
      run: |
        julia --project=demo -e 'using Pkg; Pkg.instantiate()'
    
    - name: Run demo
      run: |
        julia --project=demo demo/exploratory_demo.jl
    
    - name: Upload plots
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: demo-plots
        path: '*.png'
```

### Docker Container

```dockerfile
FROM julia:1.10

# Set working directory
WORKDIR /workspace

# Copy demo files
COPY demo/ /workspace/demo/

# Install dependencies
RUN julia --project=demo -e 'using Pkg; Pkg.instantiate()'

# Set entry point
CMD ["julia", "--project=demo", "demo/exploratory_demo.jl"]
```

## Programmatic Usage

### Running Specific Sections

```julia
# Load packages first
include("demo/exploratory_demo.jl")

# Then you can run specific sections by copying code blocks
# For example, just run the Lotka-Volterra section:

function run_lotka_volterra_section()
    using OrdinaryDiffEq, Plots
    
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
    
    return sol
end

sol = run_lotka_volterra_section()
```

### Saving Outputs Programmatically

```julia
using Plots

# Modify plot commands to save instead of display
savefig(demo_plot1, "output_lotka_volterra.png")
savefig(sens_plot, "output_sensitivity.png")
savefig(neural_plot, "output_neural_ode.png")
```

## Customization for Different Workflows

### 1. Headless Mode (No Display)

```julia
# Set GR backend to save without display
ENV["GKSwstype"] = "100"
using Plots
gr()

# Now plots save but don't display
include("demo/exploratory_demo.jl")
```

### 2. Reduced Computation (Fast Mode)

```julia
# Edit the demo file or override parameters
const FAST_MODE = true

# Reduce iterations
max_iterations = FAST_MODE ? 20 : 100

# Use in optimization calls
result = Optimization.solve(optprob, OptimizationOptimisers.Adam(0.01), 
                           callback=callback, maxiters=max_iterations)
```

### 3. Extended Logging

```julia
using Logging

# Set up file logging
log_file = open("demo_output.log", "w")
logger = SimpleLogger(log_file)

with_logger(logger) do
    include("demo/exploratory_demo.jl")
end

close(log_file)
```

## Agent Integration Patterns

### Pattern 1: Batch Processing

```julia
# Run demo multiple times with different parameters
parameter_sets = [
    [1.5, 1.0, 3.0, 1.0],
    [2.0, 1.5, 2.5, 1.2],
    [1.0, 0.8, 3.5, 0.9]
]

results = []
for (i, params) in enumerate(parameter_sets)
    println("Running simulation $i with params: $params")
    
    # Modify and run
    prob = ODEProblem(lotka_volterra!, u0, tspan, params)
    sol = solve(prob, Tsit5())
    
    push!(results, sol)
    
    # Save result
    savefig(plot(sol), "result_$i.png")
end
```

### Pattern 2: Interactive Agent Mode

```julia
function agent_query(question::String)
    if contains(lowercase(question), "sensitivity")
        println("Running sensitivity analysis...")
        # Run section 2
        return compute_sensitivities(prob, p_true)
        
    elseif contains(lowercase(question), "neural")
        println("Running Neural ODE training...")
        # Run section 4
        return train_neural_ode()
        
    else
        println("Running complete demo...")
        include("demo/exploratory_demo.jl")
    end
end

# Agent can call
agent_query("Show me sensitivity analysis")
```

### Pattern 3: Report Generation

```julia
using Dates

function generate_report()
    report = []
    
    push!(report, "# SciMLSensitivity.jl Demo Report")
    push!(report, "Generated: $(now())")
    push!(report, "")
    
    # Run demo and capture results
    println("Running demo...")
    include("demo/exploratory_demo.jl")
    
    push!(report, "## Results")
    push!(report, "- Demo completed successfully")
    push!(report, "- All visualizations generated")
    push!(report, "")
    
    # Save report
    open("DEMO_REPORT.md", "w") do f
        write(f, join(report, "\n"))
    end
    
    println("Report saved to DEMO_REPORT.md")
end

generate_report()
```

## Testing the Demo

### Automated Tests

```julia
using Test

@testset "Demo Execution" begin
    @testset "Environment Setup" begin
        @test isfile("demo/Project.toml")
        @test isfile("demo/exploratory_demo.jl")
    end
    
    @testset "Dependencies" begin
        using Pkg
        Pkg.activate("demo")
        @test Pkg.instantiate() === nothing
    end
    
    @testset "Demo Runs" begin
        # This will error if demo fails
        @test include("demo/exploratory_demo.jl") === nothing
    end
end
```

### Validation Checks

```julia
function validate_demo_output()
    checks = Dict()
    
    # Check if key variables exist
    checks["lotka_volterra_defined"] = isdefined(Main, :lotka_volterra!)
    checks["solution_computed"] = isdefined(Main, :sol)
    
    # Check if plots were created
    checks["plots_created"] = isdefined(Main, :demo_plot1)
    
    # Print validation results
    println("Validation Results:")
    for (check, passed) in checks
        println("  $check: $(passed ? "✓" : "✗")")
    end
    
    return all(values(checks))
end

validate_demo_output()
```

## Troubleshooting for Automated Runs

### Issue 1: Display Errors
```julia
# Solution: Use non-interactive backend
ENV["GKSwstype"] = "100"
```

### Issue 2: Memory Constraints
```julia
# Solution: Reduce problem size
datasize = 20  # instead of 30
maxiters = 50  # instead of 100
```

### Issue 3: Timeout
```julia
# Solution: Add progress monitoring
using ProgressMeter

@showprogress for i in 1:max_iterations
    # optimization step
end
```

## Performance Benchmarking

```julia
using BenchmarkTools

function benchmark_demo()
    println("Benchmarking demo components...")
    
    # Section 1: Basic solving
    t1 = @elapsed begin
        sol = solve(prob, Tsit5(), saveat=0.1)
    end
    println("Basic ODE solve: $(round(t1, digits=3))s")
    
    # Section 2: Sensitivity
    t2 = @elapsed begin
        sens = compute_sensitivities(prob, p_true)
    end
    println("Sensitivity analysis: $(round(t2, digits=3))s")
    
    # Section 3: Adjoint
    t3 = @elapsed begin
        grad = Zygote.gradient(loss_function, p_true)
    end
    println("Adjoint gradient: $(round(t3, digits=3))s")
    
    total = t1 + t2 + t3
    println("\nTotal core computation time: $(round(total, digits=3))s")
end

benchmark_demo()
```

## Best Practices for Agent Workflows

1. ✅ **Always activate the demo environment first**
2. ✅ **Handle plotting backend appropriately for headless systems**
3. ✅ **Add timeouts for long-running optimizations**
4. ✅ **Log all output for debugging**
5. ✅ **Save artifacts (plots, data) with timestamps**
6. ✅ **Include error handling for robustness**
7. ✅ **Use fixed random seeds for reproducibility**
8. ✅ **Test on a small example first**

## Example: Complete Agent Script

```julia
#!/usr/bin/env julia

# Complete automated demo execution script
using Pkg, Dates

function main()
    println("="^70)
    println("SciMLSensitivity.jl Automated Demo")
    println("Started: $(now())")
    println("="^70)
    
    try
        # Setup environment
        println("\n1. Setting up environment...")
        ENV["GKSwstype"] = "100"  # Headless mode
        Pkg.activate("demo")
        Pkg.instantiate()
        
        # Run demo
        println("\n2. Running demo...")
        include("demo/exploratory_demo.jl")
        
        # Validate
        println("\n3. Validating results...")
        success = validate_demo_output()
        
        # Report
        println("\n4. Generating report...")
        generate_report()
        
        println("\n" * "="^70)
        println("Demo completed successfully!")
        println("Finished: $(now())")
        println("="^70)
        
        return 0
        
    catch e
        println("\n❌ Error occurred: $e")
        println(stacktrace(catch_backtrace()))
        return 1
    end
end

# Execute
exit(main())
```

---

## 📚 Additional Resources

- [Julia Documentation](https://docs.julialang.org/)
- [SciMLSensitivity Docs](https://docs.sciml.ai/SciMLSensitivity/stable/)
- [GitHub Actions with Julia](https://github.com/julia-actions)
- [Julia in Docker](https://hub.docker.com/_/julia)

---

**Ready to automate?** This guide gives you everything needed for seamless GitHub Agent integration! 🚀
