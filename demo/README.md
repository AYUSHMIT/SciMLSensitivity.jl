# Beautiful Exploratory Demo of SciMLSensitivity.jl

This directory contains a comprehensive, creative demo showcasing the power and versatility of **SciMLSensitivity.jl** - Julia's premier package for automatic differentiation and sensitivity analysis of differential equations.

> 📑 **New to the demo?** Check out [INDEX.md](INDEX.md) for a complete guide to all resources and suggested learning paths!

## 🎯 What's Inside

This demo explores:

1. **Basic Sensitivity Analysis** - Understanding how parameters affect system behavior
2. **Adjoint Methods** - Efficient gradient computation for optimization
3. **Neural Differential Equations** - Combining machine learning with physics
4. **Parameter Estimation** - Calibrating models to real data
5. **Advanced Applications** - SDEs, DDEs, and hybrid systems

## 🚀 Quick Start

### Prerequisites

Make sure you have Julia 1.10 or higher installed. You can download it from [julialang.org](https://julialang.org/downloads/).

### Installation

1. Clone this repository (or navigate to the demo directory)
2. Start Julia and activate the demo environment:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

### Running the Demo

The demo is organized as a Julia script that can be run interactively:

```julia
include("exploratory_demo.jl")
```

Or run it section by section in your favorite Julia IDE (VS Code with Julia extension, Jupyter, or Pluto.jl).

## 📚 What You'll Learn

### 1. Sensitivity Analysis Fundamentals
- How small changes in parameters affect solutions
- Forward vs. adjoint sensitivity methods
- When to use each approach

### 2. Neural ODEs in Action
- Training neural networks inside differential equations
- Universal differential equations
- Physics-informed machine learning

### 3. Real-World Applications
- Epidemiological modeling
- Chemical reaction systems
- Control theory applications

### 4. Performance Optimization
- Choosing the right sensitivity algorithm
- Computational efficiency comparisons
- Memory usage optimization

## 🎨 Visualization Features

The demo includes:
- **Interactive plots** showing system dynamics
- **Heatmaps** of parameter sensitivity
- **Animation sequences** of learning processes
- **3D visualizations** of phase spaces
- **Comparison charts** of different methods

## 📖 Documentation

Each section of the demo is heavily commented with:
- Explanations of the mathematical concepts
- Code documentation
- References to the official documentation
- Tips and best practices

## 🤝 Contributing

Found a bug or have a suggestion? Feel free to:
- Open an issue
- Submit a pull request
- Share your own examples

## 📜 License

This demo is part of SciMLSensitivity.jl and follows the same license.

## 🔗 Resources

- [SciMLSensitivity.jl Documentation](https://docs.sciml.ai/SciMLSensitivity/stable/)
- [SciML Ecosystem](https://sciml.ai/)
- [DifferentialEquations.jl](https://docs.sciml.ai/DiffEqDocs/stable/)
- [Universal Differential Equations Paper](https://arxiv.org/abs/2001.04385)

## 🌟 Acknowledgments

Built on the amazing work of the SciML community and contributors to SciMLSensitivity.jl.

---

**Happy Exploring! 🎉**
