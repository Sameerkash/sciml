using NeuralPDE, Lux, Optimization, OptimizationOptimJL
using ModelingToolkit: Interval

@parameters t, x
@variables u(..)
@derivatives Dxx'' ~ x
@derivatives Dtt'' ~ t
@derivatives Dt' ~ t



# Defining the PDE equation
C = 1
eq = Dtt(u(t, x)) ~ C^2 * Dxx(u(t, x))

# Boundary coniditons
bcs = [u(t, 0) ~ 0.0,# for all t > 0
    u(t, 1) ~ 0.0,# for all t > 0
    u(0, x) ~ x * (1.0 - x), #for all 0 < x < 1
    Dt(u(0, x)) ~ 0.0] #for all  0 < x < 1]

# Space and time domains
domains = [t ∈ Interval(0.0, 1.0),
    x ∈ Interval(0.0, 1.0)]


# Discretization
dx = 0.1

# Neural network
chain = Lux.Chain(Dense(2, 16, Lux.σ), Dense(16, 16, Lux.σ), Dense(16, 1))
discretization = PhysicsInformedNN(chain, GridTraining(dx))

# Declare the PDE System for the equations and domains
@named pde_system = PDESystem(eq, bcs, domains, [t, x], [u(t, x)])
prob = discretize(pde_system, discretization)

callback = function (_, l)
    println("Loss is is: $l")
    return false
end

# optimizer
opt = OptimizationOptimJL.BFGS()
res = Optimization.solve(prob, opt; callback=callback, maxiters=1500)
phi = discretization.phi

using Plots


ts, xs = [infimum(d.domain):dx:supremum(d.domain) for d in domains]
function analytic_sol_func(t, x)
    sum([(8 / (k^3 * pi^3)) * sin(k * pi * x) * cos(C * k * pi * t) for k in 1:2:50000])
end

u_predict = reshape([first(phi([t, x], res.u)) for t in ts for x in xs],
    (length(ts), length(xs)))
u_real = reshape([analytic_sol_func(t, x) for t in ts for x in xs],
    (length(ts), length(xs)))

p1 = plot(ts, xs, u_real, linetype=:contourf, title="analytic");
p2 = plot(ts, xs, u_predict, linetype=:contourf, title="predict");
plot(p1, p2)
