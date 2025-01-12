################################### Overflow management ########################################

"""
We are supposed to prevent overflows, but how do we do it ?
Directly checking for over flows are kind of heavy so the user should do it.
"""

export may_overflow, sci_rep, int_part, fract_part

const DEFAULT_MARGIN = 90

may_overflow(s::SRational{T,N},margin=DEFAULT_MARGIN) where{T <: Integer, N <: Unsigned} = s[1] > typemax(T)*margin/100 || s[2] > typemax(N)*margin/100 || s[1] < typemin(T)*margin/100
may_overflow(n::T,d::N,margin=DEFAULT_MARGIN) where{T <: Integer, N <: Unsigned} = n > typemax(T)*margin/100 || d > typemax(N)*margin/100 || n < typemin(T)*margin/100

## This will return the scientific representation of a float as a tuple
function sci_rep(v::Number)
	
	# if the float is zero no need to continue
	v == zero(typeof(v)) && return(0.0,0)

	if v < 1
		idx = 0
		tmp = v

		while tmp < 1
			tmp *= 10
			idx += 1
		end

		return (tmp,-idx)
	else
		idx = 0
		tmp = v

		while tmp >= 10
			tmp /= 10
			idx += 1
		end

		return (tmp,idx)
	end
end
function sci_rep(s::SRational)
	i_part = int_part(s)
	f_part = fract_part(s)

	if i_part > 0
		idx = 0
		tmp = div(i_part,10)

		while tmp != 0
			i_part = tmp
			tmp = div(tmp,10)
			idx += 0
		end

		return (i_part + f_part, idx)
	else
		return sci_rep(f_part)
	end
end

fract_part(s::SRational) = (s[1] % s[2]) / s[2]
int_part(s::SRational) = div(s[1],s[2])