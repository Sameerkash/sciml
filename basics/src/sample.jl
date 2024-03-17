
# Print Statement
print("Hello Julia")

# Variable declaration and operatioon
c = 4 + 4
print(c)

# arrays
a = [1, 2, 3, 4, 5]

d = 0
for i in a
    d += i
end
print(d)

# Functions
function sqaure(a::Int)
    return a * a
end
 
sqaure(4)

#Structs
mutable struct dog
    breed::String
    paws::Int
    name::String
    weight::Float64
end

mydog = dog("Poodle", 4, "benji", 56.4)

print(mydog)

