# 📑 Demo Package Index

Welcome to the SciMLSensitivity.jl comprehensive demo package! This index helps you navigate all available resources.

## 🚀 Quick Links

| Document | Purpose | Time to Read |
|----------|---------|--------------|
| [README.md](README.md) | Package overview and introduction | 2 min |
| [QUICKSTART.md](QUICKSTART.md) | Get started immediately | 5 min |
| [exploratory_demo.jl](exploratory_demo.jl) | Main interactive demo | 10-15 min to run |

## 📚 Documentation Library

### Getting Started
1. **[README.md](README.md)** - Start here!
   - What's included
   - Feature highlights
   - Quick introduction

2. **[QUICKSTART.md](QUICKSTART.md)** - Installation & first run
   - Step-by-step setup
   - Running the demo
   - Troubleshooting
   - Tips for best experience

### Learning Resources
3. **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** - Conceptual understanding
   - Diagrams and flowcharts
   - Algorithm selection guide
   - Mathematical notation
   - Visual explanations

4. **[EXAMPLES.md](EXAMPLES.md)** - Additional examples
   - SIR epidemic model
   - Chemical reactions
   - Optimal control
   - Stochastic systems
   - Sensitivity heatmaps

### Advanced Topics
5. **[AGENT_WORKFLOW.md](AGENT_WORKFLOW.md)** - Automation guide
   - GitHub Agent integration
   - CI/CD examples
   - Docker setup
   - Programmatic usage
   - Batch processing

6. **[PACKAGE_SUMMARY.md](PACKAGE_SUMMARY.md)** - Complete overview
   - Detailed package contents
   - Technical specifications
   - Usage scenarios
   - Quality assurance
   - Success metrics

## 💻 Code Files

### Main Demo
- **[exploratory_demo.jl](exploratory_demo.jl)** - Comprehensive interactive demo
  - Section 1: Lotka-Volterra basics
  - Section 2: Forward sensitivity
  - Section 3: Adjoint methods
  - Section 4: Neural ODEs
  - Section 5: Parameter estimation
  - Section 6: Algorithm comparison

### Templates
- **[template_starter.jl](template_starter.jl)** - Customizable starter template
  - Copy and modify for your projects
  - Step-by-step structure
  - Extensive comments and tips
  - Real parameter estimation workflow

### Testing
- **[test_demo.jl](test_demo.jl)** - Environment validation
  - Checks file structure
  - Validates packages
  - Quick smoke tests

- **[test_demo_headless.jl](test_demo_headless.jl)** - CI-friendly validation
  - Headless execution
  - Core functionality tests
  - No plotting required
  - Exit codes for CI

### Configuration
- **[Project.toml](Project.toml)** - Package dependencies
  - All required packages listed
  - Version compatibility
  - Standard Julia format

## 🎯 Choose Your Path

### Path 1: Quick Exploration (15 minutes)
1. Read [QUICKSTART.md](QUICKSTART.md)
2. Run `exploratory_demo.jl`
3. Enjoy the visualizations!

### Path 2: Deep Learning (1-2 hours)
1. Start with [README.md](README.md)
2. Study [VISUAL_GUIDE.md](VISUAL_GUIDE.md)
3. Run `exploratory_demo.jl` section by section
4. Read [EXAMPLES.md](EXAMPLES.md)
5. Try `template_starter.jl` with your data

### Path 3: Practical Application (varies)
1. Skim [QUICKSTART.md](QUICKSTART.md)
2. Copy `template_starter.jl`
3. Modify for your problem
4. Refer to [EXAMPLES.md](EXAMPLES.md) as needed
5. Check [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md) for automation

### Path 4: Teaching/Presenting (varies)
1. Review [PACKAGE_SUMMARY.md](PACKAGE_SUMMARY.md)
2. Use `exploratory_demo.jl` sections as modules
3. Show [VISUAL_GUIDE.md](VISUAL_GUIDE.md) diagrams
4. Reference [EXAMPLES.md](EXAMPLES.md) for variety
5. Provide [template_starter.jl](template_starter.jl) for exercises

### Path 5: GitHub Agent/CI (setup time)
1. Read [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md)
2. Use [test_demo_headless.jl](test_demo_headless.jl)
3. Configure CI with `.github/workflows/demo_validation.yml`
4. Customize for your needs

## 📊 Content Overview

### By File Type

**Documentation** (6 files, ~40KB)
- README.md (3KB)
- QUICKSTART.md (4KB)
- EXAMPLES.md (10KB)
- VISUAL_GUIDE.md (13KB)
- AGENT_WORKFLOW.md (10KB)
- PACKAGE_SUMMARY.md (9KB)

**Code** (4 files, ~30KB)
- exploratory_demo.jl (15KB) - Main demo
- template_starter.jl (9KB) - Starter template
- test_demo.jl (3KB) - Basic tests
- test_demo_headless.jl (5KB) - CI tests

**Configuration** (2 files, ~3KB)
- Project.toml (1KB) - Dependencies
- demo_validation.yml (2KB) - CI workflow

### By Topic

**Sensitivity Analysis**
- Forward: `exploratory_demo.jl` Section 2
- Adjoint: `exploratory_demo.jl` Section 3
- Examples: `EXAMPLES.md` - all sections
- Theory: `VISUAL_GUIDE.md`

**Neural ODEs**
- Tutorial: `exploratory_demo.jl` Section 4
- Examples: `EXAMPLES.md` (can be adapted)
- Architecture: `VISUAL_GUIDE.md`

**Parameter Estimation**
- Tutorial: `exploratory_demo.jl` Section 5
- Template: `template_starter.jl`
- Examples: `EXAMPLES.md` - SIR, Chemical
- Workflow: `VISUAL_GUIDE.md` flowchart

**Performance**
- Comparison: `exploratory_demo.jl` Section 6
- Tips: `VISUAL_GUIDE.md`
- Benchmarking: `AGENT_WORKFLOW.md`

## 🎓 Learning Objectives

After completing this demo package, you will be able to:

✅ Solve ordinary differential equations with Julia  
✅ Compute parameter sensitivities (forward & adjoint)  
✅ Choose appropriate sensitivity algorithms  
✅ Train neural ordinary differential equations  
✅ Estimate parameters from data  
✅ Optimize model performance  
✅ Visualize results effectively  
✅ Integrate with CI/CD pipelines  
✅ Apply to your own research problems  

## 🔗 External Resources

### SciML Ecosystem
- [SciMLSensitivity.jl Docs](https://docs.sciml.ai/SciMLSensitivity/stable/)
- [DifferentialEquations.jl](https://docs.sciml.ai/DiffEqDocs/stable/)
- [SciML Homepage](https://sciml.ai/)

### Community
- [Julia Discourse](https://discourse.julialang.org)
- [Julia Zulip](https://julialang.zulipchat.com)
- [GitHub Issues](https://github.com/SciML/SciMLSensitivity.jl/issues)

### Papers
- [Universal Differential Equations](https://arxiv.org/abs/2001.04385)
- [Neural ODEs](https://arxiv.org/abs/1806.07366)

## 💡 Pro Tips

1. **First Time?** Follow Quick Exploration path
2. **Teaching?** Sections work great as standalone modules
3. **Research?** Start with template_starter.jl
4. **Automation?** Check AGENT_WORKFLOW.md first
5. **Stuck?** QUICKSTART.md has troubleshooting

## 📝 Version History

- **v1.0.0** (Dec 2024) - Initial comprehensive release
  - Complete demo with 6 sections
  - Extensive documentation
  - CI/CD support
  - Starter template

## 🙏 Acknowledgments

This demo package builds on the excellent work of:
- SciML community
- SciMLSensitivity.jl contributors
- Julia language developers
- Scientific computing community

## 📧 Feedback

We welcome feedback! Please:
- Open issues for bugs
- Submit PRs for improvements
- Share your examples
- Ask questions on Discourse

---

**Ready to start?** Pick a path above and dive in! 🚀

**Need help deciding?** Start with [QUICKSTART.md](QUICKSTART.md) - it takes 5 minutes and gets you running immediately!

---

*Last updated: December 2024*  
*Maintained by: SciML Community*  
*License: MIT*
