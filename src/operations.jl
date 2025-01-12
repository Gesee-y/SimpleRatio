## ============================ Operations on SimpleRatio ========================= ##

export to_float, simplify, unsafe_add

## Basic operations

Base.:+(a::T,b::T) where T <: AbstractRatio = begin
	
	# Getting the necessary data
	na = numerator(a) # a's numerator
	da = denominator(a) # a's denominator
	nb = numerator(b) # b's numerator
	db = denominator(b) # b's denominator	

	n = na*db + da*nb
	d = da*db
	
	return T(n, d)
end
Base.:+(a::SRational,b::MRational) = begin
	
	# Getting the necessary data
	na = numerator(a)
	da = denominator(a)
	nb = numerator(b)
	db = denominator(b)

	n = na*db + da*nb
	d = da*db
	
	return MRational(n, d)
end
Base.:+(a::T, n::Integer) where T <: AbstractRatio = T(numerator(a) + n * denominator(a), denominator(a))
Base.:+(a::T, n::AbstractFloat) where T <: AbstractRatio = convert(typeof(n), a)
Base.:+(n::Number, a::T) where T <: AbstractRatio = a + n

Base.:-(a::T) where T <: AbstractRatio = T(-numerator(a),denominator(a))
Base.:-(a::T,b::T) where T <: AbstractRatio = a + (-b)
Base.:-(a::T, n::Integer) where T <: AbstractRatio = T(numerator(a) + n * denominator(a), denominator(a))
Base.:-(n::Integer, a::T) where T <: AbstractRatio = -a + n

Base.:*(a::T,b::T) where T <: AbstractRatio = T(numerator(a) * numerator(b), denominator(a) * denominator(b))
Base.:*(a::T,n::Integer) where T <: AbstractRatio = T(numerator(a)*n, denominator(a))
Base.:*(n::Integer, a::T) where T <: AbstractRatio = a * n

Base.:/(a::T,b::T) where T <: AbstractRatio = T(numerator(a)*denominator(b), denominator(a)*numerator(b))
Base.:/(a::T,n::Integer) where T <: AbstractRatio = T(numerator(a), denominator(a)*n)
Base.:/(n::Integer, a::T) where T <: AbstractRatio = T(denominator(a)*n, numerator(a))

Base.:^(a::T,n::Integer) where T <: AbstractRatio = T(numerator(a) ^ n, denominator(a) ^ n)

Base.isless(a::T,b::T) where T <: AbstractRatio = (a-b)[1] < 0
Base.isequal(a::T,b::T) where T <: AbstractRatio = (a - b)[1] == 0

Base.abs(s::T) where T <: AbstractRatio = T(abs(s[1]),s[2])
Base.abs2(s::T) where T <: AbstractRatio = T(abs2(s[1]),s[2])

func_to_create = (:exp,:log,:log2,:log10,:log1p,:sqrt,:cbrt,:exp10,:expm1)

for func in func_to_create
	eval(:(Base.$func(s::T) where T <: AbstractRatio = $func(to_float(s)) ))
end

"""
	unsafe_add(a::SRational,b::SRational)

This function will add 2 SRational together as if they were ints, this will consider that the 2 SRational have the same denominator
If not, the denominator of `a` will be taken.
"""
unsafe_add(a::SRational,b::SRational) = SRational(numerator(a)+numerator(b),denominator(a))

"""
	to_float(s::SRational)

This function will convert the SRational 's' into a float
"""
to_float(s::SRational) = s[1]/s[2]

"""
	simplify(s::SRational)

This function will simplify the SRational 's' when possible.
"""
simplify(s::SRational) = begin 
	a, b = s[1], s[2]
	d = gcd(a, b)
	
	return SRational(div(a,d), div(b,d),Val(true);skip=true)
end
simplify(s::MRational) = begin 
	a, b = s[1], s[2]
	d = gcd(a, b)
	
	return MRational(div(a,d), div(b,d),Val(true))
end
simplify(a::Integer,b::Integer) = begin 
	d = gcd(a, b)
	
	return (div(a,d), div(b,d))
end
########################################## Helpers ######################################################

_simplify_if_necessary(s::AbstractRatio;margin=DEFAULT_MARGIN) = may_overflow(s;margin=DEFAULT_MARGIN) ? simplify(s) : s