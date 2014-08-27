immutable Nullable{T}
    isnull::Bool
    value::T

    Nullable() = new(true)
    Nullable(value::T) = new(false, value)
end

immutable NullException <: Exception
end

Null{T}(::Type{T}) = Nullable{T}()

NotNull{T}(value::T) = Nullable{T}(value)

function show{T}(io::IO, x::Nullable{T})
    if x.isnull
        @printf(io, "Null(%s)", repr(T))
    else
        @printf(io, "NotNull(%s)", repr(x.value))
    end
end

get(x::Nullable) = x.isnull ? throw(NullException()) : x.value

get{S, T}(x::Nullable{S}, y::T) = x.isnull ? convert(S, y) : x.value

unsafe_get(x::Nullable) = x.value

isnull(x::Nullable) = x.isnull

function isequal{S, T}(x::Nullable{S}, y::Nullable{T})
    if x.isnull && y.isnull
        return true
    elseif x.isnull || y.isnull
        return false
    else
        return isequal(x.value, y.value)
    end
end

=={S, T}(x::Nullable{S}, y::Nullable{T}) = throw(NullException())

function hash(x::Nullable, h::Uint)
    if x.isnull
        return h + uint(0x932e0143e51d0171)
    else
        return hash(x.value, h + uint(0x932e0143e51d0171))
    end
end
