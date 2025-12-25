# 🚀 Quick Start Guide - SciMLSensitivity.jl Demo

Welcome! This guide will get you up and running with the SciMLSensitivity.jl demo in just a few minutes.

## Step 1: Install Julia

If you haven't already, download and install Julia 1.10 or higher from [julialang.org](https://julialang.org/downloads/).

### Verify Installation

Open a terminal and run:
```bash
julia --version
```

You should see something like: `julia version 1.10.0`

## Step 2: Navigate to the Demo Directory

```bash
cd /path/to/SciMLSensitivity.jl/demo
```

## Step 3: Set Up the Environment

Start Julia from the demo directory:
```bash
julia
```

In the Julia REPL, activate and instantiate the demo environment:
```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

This will download and install all required packages. It may take a few minutes the first time.

## Step 4: Run the Demo

There are several ways to run the demo:

### Option A: Run the Complete Demo (Recommended)

```julia
include("exploratory_demo.jl")
```

This will run through all sections sequentially, showing beautiful visualizations and explanations.

### Option B: Interactive Mode

For a more exploratory experience, run sections one at a time:

1. Open `exploratory_demo.jl` in your favorite editor (VS Code with Julia extension recommended)
2. Execute sections individually by selecting code and pressing `Shift+Enter` (VS Code) or your IDE's execute shortcut

### Option C: Jupyter Notebook

If you prefer notebooks:

```julia
using IJulia
notebook(dir=pwd())
```

Then create a new notebook and copy-paste sections from `exploratory_demo.jl`.

## What to Expect

The demo includes 6 main sections:

1. **Basic Dynamics** - Lotka-Volterra predator-prey model (~2 minutes)
2. **Forward Sensitivity** - Understanding parameter sensitivity (~1 minute)
3. **Adjoint Methods** - Efficient gradient computation (~1 minute)
4. **Neural ODEs** - Training neural networks to learn dynamics (~2-3 minutes)
5. **Parameter Estimation** - Recovering parameters from noisy data (~2-3 minutes)
6. **Algorithm Comparison** - Performance benchmarks (~1 minute)

**Total runtime: 10-15 minutes**

## Troubleshooting

### Issue: "Package not found"
**Solution:** Make sure you ran `Pkg.instantiate()` in the demo directory.

### Issue: Plots don't display
**Solution:** 
- For command line Julia: Plots should open in a separate window
- For Jupyter: Plots display inline
- For VS Code: Make sure the Julia extension is installed

### Issue: Out of memory errors
**Solution:** The Neural ODE section can be memory intensive. Try:
```julia
# Reduce iterations in the optimization
maxiters=50  # instead of 100
```

### Issue: Slow performance
**Solution:** First run is always slower due to compilation. Subsequent runs will be much faster!

## Tips for Best Experience

1. **Use a good editor**: VS Code with the Julia extension provides syntax highlighting, inline plotting, and easy code execution

2. **Start simple**: Run the complete demo first to see everything work, then explore individual sections

3. **Experiment**: Try changing parameters! For example:
   - Different initial conditions: `u0 = [2.0, 0.5]`
   - Different time spans: `tspan = (0.0, 20.0)`
   - Different parameters: `p_true = [2.0, 1.5, 2.0, 1.5]`

4. **Read the comments**: The code is heavily documented to explain what's happening

5. **Check the plots**: Each visualization is designed to teach you something about sensitivity analysis

## Next Steps

After completing the quick start:

1. ✅ Read through `EXAMPLES.md` for more detailed examples
2. ✅ Explore the [official documentation](https://docs.sciml.ai/SciMLSensitivity/stable/)
3. ✅ Try modifying the demo to solve your own problems
4. ✅ Join the [Julia Discourse](https://discourse.julialang.org) or [Zulip chat](https://julialang.zulipchat.com) to ask questions

## Need Help?

- **Documentation**: https://docs.sciml.ai/SciMLSensitivity/stable/
- **Forum**: https://discourse.julialang.org (tag: `sciml`)
- **Chat**: https://julialang.zulipchat.com (channel: `#sciml-bridged`)
- **Issues**: https://github.com/SciML/SciMLSensitivity.jl/issues

---

**Ready to explore?** Run `include("exploratory_demo.jl")` and enjoy! 🎉
