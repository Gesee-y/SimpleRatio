include("../src/SimpleRatio.jl")

using .SimpleRatio
using BenchmarkTools

function main()
	# We check the rational creation

	@timev a = SRational(10,9)
	println(a)

	@timev b = @SRational 3//5
	println(b)

	println("To float conversion")

	@timev r1 = to_float(a)
	@timev r2 = to_float(b)

	println("Operations")

	println("Additions")
	@timev c = a + b
	@timev r3 = r1 + r2
	@timev c5 = a + c
	
	println("Multiplications")
	@timev d = a * b
	@timev r4 = r1 * r2
	@timev d2 = a * d

	println("Divisions")
	@timev e = 2/d
	@timev r5 = 2/r1
	@timev e2 = 7/d
	
	@timev f = c + d

	println(c)
	println(d)
	println(e)
	println(f)

	@timev g = simplify(e)

	println(g)

end

#main()

a = SRational(10,9)
b = @SRational 3//5
aa = MRational(10,9)
bb = @MRational 3//5
a2 = 10//9
b2 = 3//5
a3 = 10/9
b3 = 3/5

println("Addition Test")
println("")

@btime a + b
@btime aa + bb
@btime a2 + b2
@btime a3 + b3

println("Substraction Test")
println("")

@btime a - b
@btime aa - bb
@btime a2 - b2
@btime a3 - b3

println("Product Test")
println("")

@btime a * b
@btime aa * bb
@btime a2 * b2
@btime a3 * b3

println("Division Test")
println("")

@btime a / b
@btime aa / bb
@btime a2 / b2
@btime a3 / b3

println("Power Test")
println("")

@btime a ^ 3
@btime aa ^ 3
@btime a2 ^ 3
@btime a3 ^ 3

sleep(1)