using DifferentialEquations

#u = [s(t), I(t), R(t)]
function sirModel!(du, u, p, t)
    beta, gamma, N = p

    du[1] = -(beta * u[1] * u[2]) / N

    du[2] = ((beta * u[1] * u[2]) / N) - (gamma * u[2])

    du[3] = gamma * u[2]
end


# Boundary conditions
N = 1000
i0 = 1
r0 = 0
s0 = (N - i0 - r0)

u0 = [s0, i0, r0]
# constants
beta = 0.3
gamma = 0.1

p = (beta, gamma, N)

# time duration
tspan = (0.0, 160.0)

# Solving the ODE solution
problem = ODEProblem(sirModel!, u0, tspan, p)
sol = solve(problem)

using Plots
plots = []
@gif for (i, x) in enumerate(range(tspan[1], tspan[2], length=160))
    push!(plots, sol[1], sol[2], sol[3])
end
