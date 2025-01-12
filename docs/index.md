## SRational

SRational are rational but with a an occasional simplification stage, if the value of the 
rational tend to overflow of their type, the program will try to do simplification, making this struct a bit faster that Julia's Rational.

## MRational

MRational stands for "Manual Rational". These number won't simplify themselves unless you do it with `simplify(s::MRational)`. to know if the value of the MRational are overflowing you can use the function `may_overflow(s::MRational{T};margin=DEFAULT_MARGIN)`, margin is the percentage of the type interval that is considered as an overflow, for example if `margin=90` then if the value of the numerator exceed 90% of the maximum value of the type T, then it return true