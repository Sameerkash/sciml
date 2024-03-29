using ComponentArrays, Lux, DiffEqFlux, OrdinaryDiffEq, Optimization, OptimizationOptimJL,
    OptimizationOptimisers, Random, Plots


#u = [s(t), I(t), R(t)]
function trueSirModel!(du, u, p, t)
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
datasize = 160
tsteps = range(tspan[1], tspan[2]; length=datasize)

# Solving the ODE solution
trueOdeProblem = ODEProblem(trueSirModel!, u0, tspan, p)
trueOdeData = Array(solve(trueOdeProblem, Tsit5(), saveat=tsteps))

# Defining the Nueral Network
rng = Random.default_rng()

# After multiple iteraations, the layer with 3x150 fit the true data very well.
sirNN = Lux.Chain(Lux.Dense(3, 150, tanh), Lux.Dense(150, 150, tanh), Lux.Dense(150, 3))
p, st = Lux.setup(rng, sirNN)

sirNNOde = NeuralODE(sirNN, tspan, Tsit5(), saveat=tsteps)

# prediciton function that is determined for every iteration
function prediction(p)
    Array(sirNNOde(u0, p, st)[1])
end

# Loss represents the difference between the original data and the predicted output
function loss(p)
    pred = prediction(p)
    loss = sum(abs2, trueOdeData .- pred)
    return loss, pred
end



# A Callback function to plot the output of the true dat and predicted output for suspectible, infected and recvered data points
callback = function (p, l, pred; doplot=true)
    println(l)
    if doplot
        plt = scatter(tsteps, trueOdeData[1, :]; label="true suspectible")
        scatter!(plt, tsteps, pred[1, :]; label="prediction suspectible")

        iplt = scatter(tsteps, trueOdeData[2, :]; label="true infected")
        scatter!(iplt, tsteps, pred[2, :]; label="prediction infected")

        rplt = scatter(tsteps, trueOdeData[3, :]; label="true recovered")
        scatter!(rplt, tsteps, pred[3, :]; label="prediction recovered")

        display(plot(plt, iplt, rplt))
    end
    return false
end

# Defining optimization techniques
pinit = ComponentArray(p)
adtype = Optimization.AutoZygote()
optimizeFunction = Optimization.OptimizationFunction((x, p) -> loss(x), adtype)

# Defining the problem to be optimized
neuralProblem = Optimization.OptimizationProblem(optimizeFunction, pinit)

# NN solver that iterates over 3000 using ADAM optimizer
result = Optimization.solve(neuralProblem, Optimisers.Adam(0.001); callback=callback,
    maxiters=3000)