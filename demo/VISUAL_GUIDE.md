# 🎨 Visual Guide to SciMLSensitivity.jl

This visual guide helps you understand the concepts behind sensitivity analysis using diagrams and illustrations.

## 📊 What is Sensitivity Analysis?

```
┌─────────────────────────────────────────────────────────────┐
│                  SENSITIVITY ANALYSIS                        │
│                                                              │
│  Parameters (p) ──────────┐                                 │
│                           │                                  │
│                           ▼                                  │
│                    ┌─────────────┐                          │
│                    │  Solve ODE  │                          │
│                    │   du/dt=f   │                          │
│                    └─────────────┘                          │
│                           │                                  │
│                           ▼                                  │
│                    Solution (u(t))                          │
│                                                              │
│  Question: How does u change when p changes?                │
│  Answer: Sensitivity = ∂u/∂p                               │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Forward vs Adjoint Sensitivity

### Forward Sensitivity
```
Good for: Few Parameters, Many Outputs

Parameters: p₁, p₂  (2 parameters)
           │  │
           ▼  ▼
        ┌────────┐
        │ Solve  │
        │  ODE   │
        └────────┘
           │  │  │
           ▼  ▼  ▼
        u₁ u₂ ... uₙ  (n outputs)

Cost: O(n_params) ODE solves
Example: 2 params → 2 forward passes
```

### Adjoint Sensitivity
```
Good for: Many Parameters, Few Outputs

Parameters: p₁, p₂, ..., pₙ  (n parameters)
           ▲  ▲       ▲
           │  │  ...  │
        ┌────────────────┐
        │  Adjoint ODE   │
        │  (backward)    │
        └────────────────┘
                ▲
                │
        Loss Function L(u)

Cost: O(1) backward pass regardless of n_params
Example: 1000 params → 1 forward + 1 backward pass
```

## 🧠 Neural Ordinary Differential Equations

```
┌──────────────────────────────────────────────────────────────┐
│                   NEURAL ODE ARCHITECTURE                     │
│                                                               │
│  Input: u(t₀)                                                │
│     │                                                         │
│     ▼                                                         │
│  ┌─────────────────────────────────────┐                    │
│  │  Neural Network f_θ(u, t)          │                    │
│  │  ┌───┐    ┌───┐    ┌───┐          │                    │
│  │  │ ● │───▶│ ● │───▶│ ● │          │                    │
│  │  └───┘    └───┘    └───┘          │                    │
│  │    │        │        │              │                    │
│  │    └────────┴────────┘              │                    │
│  │           du/dt                      │                    │
│  └─────────────────────────────────────┘                    │
│                │                                              │
│                ▼                                              │
│       ODE Solver Integration                                 │
│    u(t₁) = u(t₀) + ∫f_θ(u,t)dt                             │
│                │                                              │
│                ▼                                              │
│           Output: u(t₁)                                      │
│                │                                              │
│                ▼                                              │
│           Loss = ||u(t₁) - target||²                        │
│                │                                              │
│                ▼                                              │
│     Backprop through ODE solver (Adjoint!)                  │
│                │                                              │
│                ▼                                              │
│         Update θ parameters                                  │
└──────────────────────────────────────────────────────────────┘
```

## 🎯 Algorithm Selection Flowchart

```
                    Start
                      │
                      ▼
            ┌─────────────────────┐
            │ How many parameters?│
            └─────────────────────┘
                 /           \
                /             \
               /               \
         Few (<10)           Many (>10)
            │                    │
            ▼                    ▼
    ┌──────────────┐    ┌──────────────────┐
    │   Forward    │    │  Is memory tight? │
    │ Sensitivity  │    └──────────────────┘
    └──────────────┘         /          \
                            /            \
                          Yes            No
                           │              │
                           ▼              ▼
                  ┌─────────────┐  ┌────────────────┐
                  │ Backsolve   │  │ Interpolating  │
                  │  Adjoint    │  │    Adjoint     │
                  │ (O(1) mem)  │  │  (faster)      │
                  └─────────────┘  └────────────────┘
                                          │
                                          ▼
                                   Need high accuracy?
                                        /    \
                                      Yes     No
                                       │       │
                                       ▼       ▼
                              ┌──────────┐   Use as-is
                              │Quadrature│
                              │ Adjoint  │
                              └──────────┘
```

## 🔬 Parameter Estimation Workflow

```
┌───────────────────────────────────────────────────────────────┐
│               PARAMETER ESTIMATION PIPELINE                    │
│                                                                │
│  1. Data Collection                                           │
│     Observations: y₁, y₂, ..., yₙ                            │
│            │                                                   │
│            ▼                                                   │
│  2. Define Model                                              │
│     ┌──────────────────┐                                     │
│     │ du/dt = f(u,p,t) │  ← Unknown parameters p             │
│     └──────────────────┘                                     │
│            │                                                   │
│            ▼                                                   │
│  3. Initial Guess                                             │
│     p₀ = [p₁⁰, p₂⁰, ...]                                    │
│            │                                                   │
│            ▼                                                   │
│  4. Optimization Loop                                         │
│     ┌─────────────────────────────┐                          │
│     │ a) Solve ODE with p         │                          │
│     │ b) Compute loss L = ||u-y||²│                          │
│     │ c) Compute ∇L (via adjoint) │                          │
│     │ d) Update p ← p - α∇L       │                          │
│     └─────────────────────────────┘                          │
│            │                                                   │
│            ▼                                                   │
│       Converged?                                              │
│         /    \                                                │
│       No     Yes                                              │
│       │       │                                               │
│       └───────┘                                               │
│            │                                                   │
│            ▼                                                   │
│  5. Estimated Parameters                                      │
│     p* = [p₁*, p₂*, ...]                                     │
│                                                                │
└───────────────────────────────────────────────────────────────┘
```

## 📈 Lotka-Volterra Phase Space

```
     Predators (y)
         ▲
         │     ┌─────────────────┐
      3  │    ╱                   ╲
         │   ╱    Stable Cycle     ╲
      2  │  │      ↗     ↖         │
         │  │    ↗         ↖       │
      1  │  │   ↙           ↘      │
         │   ╲               ↙    ╱
      0  │    ╲─────────────────╱
         └────────────────────────▶ Prey (x)
            0    1    2    3    4
         
  Fixed Point: (γ/δ, α/β)
  
  Dynamics:
  • Top-right: Many prey + predators → Predators eat prey
  • Top-left: Few prey, many predators → Predators starve
  • Bottom-left: Few of both → Prey grows
  • Bottom-right: Many prey, few predators → Predators grow
```

## 🎓 Key Concepts Summary

### 1. Sensitivity Analysis
```
┌──────────────────────────────────────┐
│ ∂u/∂p tells us:                     │
│                                      │
│ • How robust is our solution?       │
│ • Which parameters matter most?     │
│ • How to optimize parameters?       │
│ • Uncertainty propagation           │
└──────────────────────────────────────┘
```

### 2. Adjoint Methods
```
┌──────────────────────────────────────┐
│ Solve backwards in time to get:     │
│                                      │
│ • Efficient gradients               │
│ • O(1) memory with BacksolveAdjoint│
│ • Works with any AD system          │
│ • Handles stiff problems            │
└──────────────────────────────────────┘
```

### 3. Neural ODEs
```
┌──────────────────────────────────────┐
│ Replace unknown dynamics with NN:   │
│                                      │
│ • Learn from data                   │
│ • Incorporate physical constraints  │
│ • Universal approximators           │
│ • Continuous-depth networks         │
└──────────────────────────────────────┘
```

## 🌈 Color Scheme Reference

Throughout the demos, we use a consistent color scheme:

```
Prey/Population 1:     🟢 Green     #2ecc71
Predator/Population 2: 🔴 Red       #e74c3c
True Model:           🔵 Blue      #3498db
Estimated:            🟣 Purple    #9b59b6
Observed Data:        ⚫ Black     #2c3e50
Neural Network:       🟠 Orange    #f39c12
```

## 📚 Mathematical Notation Guide

| Symbol | Meaning |
|--------|---------|
| `u` | State vector (solution) |
| `p` | Parameter vector |
| `t` | Time |
| `f(u,p,t)` | Right-hand side of ODE |
| `∂u/∂p` | Sensitivity (Jacobian) |
| `λ` | Adjoint variable |
| `L` | Loss function |
| `∇L` | Gradient of loss |
| `θ` | Neural network parameters |

## 🔗 Connections to Machine Learning

```
Traditional ML          │  Scientific ML (SciML)
─────────────────────────┼──────────────────────────────
                        │
Neural Networks         │  Neural ODEs
  y = NN(x)            │    du/dt = NN(u,t)
                        │
Backpropagation        │  Adjoint Sensitivity
  ∂L/∂θ via chain rule │    ∂L/∂θ via adjoint ODE
                        │
Data-driven only       │  Data + Physics
  Learn from data      │    Combine both
                        │
Discrete layers        │  Continuous depth
  Layer 1 → 2 → 3      │    Continuous flow
```

## 🚀 Performance Tips Visualization

```
                    Problem Size
                         │
    ┌────────────────────┼────────────────────┐
    │ Small (<1000 eqs)  │  Large (>1000)     │
    │                    │                    │
    │ ✓ Direct methods   │  ✓ Iterative      │
    │ ✓ Dense Jacobian   │  ✓ Sparse Jacobian│
    │ ✓ ForwardDiff      │  ✓ Adjoints       │
    └────────────────────┴────────────────────┘
                         │
                    Parameters
                         │
    ┌────────────────────┼────────────────────┐
    │ Few (<10)          │  Many (>100)       │
    │                    │                    │
    │ ✓ Forward sens.    │  ✓ Adjoint methods│
    │ ✓ Simple           │  ✓ Checkpointing  │
    └────────────────────┴────────────────────┘
```

---

## 🎯 Next Steps

1. ✅ Run `exploratory_demo.jl` to see these concepts in action
2. ✅ Read `EXAMPLES.md` for specific use cases
3. ✅ Experiment with your own ODEs
4. ✅ Check out the [official docs](https://docs.sciml.ai/SciMLSensitivity/stable/)

---

**Remember**: Sensitivity analysis is powerful because it connects:
- **Mathematics** (differential equations)
- **Computation** (efficient algorithms)
- **Applications** (real-world problems)

Happy learning! 📚✨
