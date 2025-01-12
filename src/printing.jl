## ============================ Printing utilities ========================== ##

function Base.show(io::IO,s::SRational{T,N}) where {T <: Integer, N <: Unsigned}
	print(io,"$(s.num)//$(s.den) of type $T and $N")
end

function Base.print(io::IO,s::SRational)
	print(io,"$(s.num)//$(s.den)")
end

function Base.println(io::IO,s::SRational)
	println(io,"$(s.num)//$(s.den)")
end

Base.show(s::SRational) = show(stdout,s)
Base.print(s::SRational) = print(stdout,s)
Base.println(s::SRational) = println(stdout,s)