## ===================================== Core =================================== ##

export SRational, MRational
export @SRational, @MRational

abstract type AbstractRatio <: Number end

"""
	struct SRational{T,N} <: Number
		num :: T
		den :: N

A struct to represent a light weight version of rational numbers.
simplification is done if the numerator or denominator seem to overflow.
`T` is the type of the numerator `num` it should be an Integer type, `N` is the type of the denominator `den`, it should be an Unsigned type

## Constructors 

	`SRational{T}(n::T,d::Integer)`

This will create a new SRational from `n` and `d` that should be greater than 0, the type of the denominator will be the unsigned equivalent of `T` (Int128 will be UInt128, etc)

	`SRational{T,N}(n::Integer,d::Integer) where {T <: Integer, N <: Unsigned}`

This will create a new SRational from `n` and `d` that should be an convertible to the unsigned integer type `N` 

	`SRational{T,N}(n::Integer,d::Integer,::Val{True}) where {T <: Integer, N <: Unsigned}`

This is an unsafe constructor for SRationals, no check will be performed to verify the entry, this should increase performance.

	`SRational(n::Integer,d::Integer)`

This will create a new SRational, the type of the entries will be deducted.

	`SRational(v::AbstractFloat,[prec]::Int)`

This will create a SRational from a float, `prec` is the number of digit that should be saved,
if not mentionned, this function will save every digit of the decimal part of the number.
"""
struct SRational{T,N} <: AbstractRatio
	num :: T
	den :: N

	## Constructors ##

	SRational{T}(n::T,d::Integer;skip=false) where T <: Integer = begin

		# We verify that the denominator is non zero 
		d <= 0 && throw(ArgumentError("The denominator should be a positive non zero integer"))
		vals = (n,d)

		N = _unsigned_equivalent(T)
		
		# We check if the value of the SRational may get out the bound of their type
		# So we simplify it if skip is false
		if !skip
			vals = may_overflow(n,N(d)) ? simplify(n,d) : (n,d)
		end
		s = new{T, N}(vals[1],vals[2])

	end
	SRational{T,N}(n::Integer,d::Integer;skip=false) where {T <: Integer, N <: Unsigned} = begin
		# We verify that the denominator is non zero 
		d <= 0 && throw(ArgumentError("The denominator should be a positive non zero integer"))
		vals = (n,d)

		if !skip
			vals = may_overflow(n,N(d)) ? simplify(n,d) : (n,d)
		end
		s = new{T, N}(vals[1],vals[2])
	end
	SRational{T,N}(n::Integer,d::Integer,::Val{true};skip=false) where {T <: Integer, N <: Unsigned} = begin
		vals = (n,d)

		if !skip
			vals = may_overflow(n,N(d)) ? simplify(n,d) : (n,d)
		end
		s = new{T, N}(vals[1],vals[2])
	end

end

"""
	struct MRational{T,N} <: Number
		num :: T
		den :: N

A struct to represent a light weight version of SRational numbers.
Those don't have a simplification stage, making calculation faster but with some restriction.
`T` is the type of the numerator `num` it should be an Integer type, `N` is the type of the denominator `den`, it should be an Unsigned type

## Constructors 

	`MRational{T}(n::T,d::Integer)`

This will create a new MRational from `n` and `d` that should be greater than 0, the type of the denominator will be the unsigned equivalent of `T` (Int128 will be UInt128, etc)

	`MRational{T,N}(n::Integer,d::Integer) where {T <: Integer, N <: Unsigned}`

This will create a new MRational from `n` and `d` that should be an convertible to the unsigned integer type `N` 

	`MRational{T,N}(n::Integer,d::Integer,::Val{True}) where {T <: Integer, N <: Unsigned}`

This is an unsafe constructor for MRationals, no check will be performed to verify the entry, this should increase performance.

	`MRational(n::Integer,d::Integer)`

This will create a new MRational, the type of the entries will be deducted.

	`MRational(v::AbstractFloat,[prec]::Int)`

This will create a MRational from a float, `prec` is the number of digit that should be saved,
if not mentionned, this function will save every digit of the decimal part of the number.
"""
struct MRational{T,N} <: AbstractRatio
	num :: T
	den :: N

	## Constructors ##

	MRational{T}(n::T,d::Integer) where T <: Integer = begin

		# We verify that the denominator is non zero 
		d <= 0 && throw(ArgumentError("The denominator should be a positive non zero integer"))
		vals = (n,d)

		N = _unsigned_equivalent(T)
		
		s = new{T, N}(vals[1],vals[2])

	end
	MRational{T,N}(n::Integer,d::Integer) where {T <: Integer, N <: Unsigned} = begin
		# We verify that the denominator is non zero 
		d <= 0 && throw(ArgumentError("The denominator should be a positive non zero integer"))
		vals = (n,d)

		s = new{T, N}(vals[1],vals[2])
	end
	MRational{T,N}(n::Integer,d::Integer,::Val{true}) where {T <: Integer, N <: Unsigned} = begin
		vals = (n,d)

		s = new{T, N}(vals[1],vals[2])
	end

end

SRational(n::Integer,d::Integer;skip=false) = SRational{typeof(n)}(n, d;skip=skip)
SRational(n::Integer,d::Integer,::Val{true};skip=false) = SRational{typeof(n),_unsigned_equivalent(typeof(n))}(n, d,Val(true);skip=skip)

# From a float
SRational(v::AbstractFloat;skip = false) = begin

	decimal_part_length = _number_of_digit(v)
	d = 10^decimal_part_length
	n = Int(round(v*d))
	
	return SRational(n,d;skip = skip)
end
SRational(v::AbstractFloat,prec::Int;skip = false) = begin
	d = 10^prec
	n = Int(round(v*d))
	
	return SRational(n,d;skip = skip)
end

"""
	@SRational a//b

A shortcut to create simple rational number. I think the syntax is simple enough.
"""
macro SRational(expr)
	a, b = expr.args[2], expr.args[3]
	return :(SRational($a,$b))
end

MRational(n::Integer,d::Integer) = MRational{typeof(n)}(n, d)
MRational(n::Integer,d::Integer,::Val{true}) = MRational{typeof(n),_unsigned_equivalent(typeof(n))}(n, d,Val(true))

# From a float
MRational(v::AbstractFloat) = begin

	decimal_part_length = _number_of_digit(v)
	d = 10^decimal_part_length
	n = Int(round(v*d))
	
	return MRational(n,d)
end
MRational(v::AbstractFloat,prec::Int) = begin
	d = 10^prec
	n = Int(round(v*d))
	
	return MRational(n,d)
end

"""
	@MRational a//b

A shortcut to create simple rational number. I think the syntax is simple enough.
"""
macro MRational(expr)
	a, b = expr.args[2], expr.args[3]
	return :(MRational($a,$b))
end

"""
	getindex(s::AbstractRatio, i::Int)

This function will return the numerator of the SRational 's' if i is 1 of the denominator if i is 2
"""
Base.getindex(s::AbstractRatio, i::Int) = getfield(s, (:num, :den)[i])

Base.convert(T::Type{<:AbstractFloat}, s::AbstractRatio) = convert(T,s.num / s.den)
Base.convert(::Type{Rational}, s::AbstractRatio) = Rational(s.num, s.den)
Base.convert(T::Type{<:AbstractRatio}, v::AbstractFloat) = T(v)
Base.convert(T::Type{<:AbstractRatio}, r::Rational{N}) where N <: Integer = T{N}(r.num, r.den)

Base.promote_rule(s::SRational{T},S::Type{<:Integer}) where T <: Integer = SRational{promote_type(T,S),N} 

"""
	numerator(s::SRational)

Return the numerator of the SRational `s`

	numerator(s::MRational)

Return the numerator of the MRational `s`
"""
Base.numerator(s::SRational) = getfield(s,:num)
Base.numerator(s::MRational) = getfield(s,:num)

"""
	denominator(s::SRational)

Return the denominator of the SRational `s`

	denominator(s::MRational)

Return the denominator of the MRational `s`
"""
Base.denominator(s::SRational) = getfield(s,:den)
Base.denominator(s::MRational) = getfield(s,:den)

## ================================= _Helpers ======================================= ##

function _number_of_digit(a::AbstractFloat)
	decimal_part::Float64 = a - floor(a)
	
	
	return decimal_part == zero(typeof(Float64)) ? 0 : (length(string(decimal_part)) - 2)
end

_unsigned_equivalent(T::Type{<:Unsigned}) = T
_unsigned_equivalent(::Type{Int8}) = UInt8
_unsigned_equivalent(::Type{Int16}) = UInt16
_unsigned_equivalent(::Type{Int32}) = UInt32
_unsigned_equivalent(::Type{Int64}) = UInt64
_unsigned_equivalent(::Type{Int128}) = UInt128