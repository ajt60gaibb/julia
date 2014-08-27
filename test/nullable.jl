types = [
    Bool,
    Char,
    Float16,
    Float32,
    Float64,
    Int128,
    Int16,
    Int32,
    Int64,
    Int8,
    Uint16,
    Uint32,
    Uint64,
    Uint8,
]

# Nullable{T}() = new(true)
for T in types
    x = Nullable{T}()
    @test x.isnull === true
    @test isa(x.value, T)
end

# Nullable{T}(value::T) = new(false, value)
for T in types
    x = Nullable{T}(zero(T))
    @test x.isnull === false
    @test isa(x.value, T)
    @test x.value === zero(T)

    x = Nullable{T}(one(T))
    @test x.isnull === false
    @test isa(x.value, T)
    @test x.value === one(T)
end

# immutable NullException <: Exception
@test isa(NullException(), NullException)
@test_throws NullException throw(NullException())

# Null{T}(::Type{T}) = Nullable{T}()
for T in types
    x = Null(T)
    @test x.isnull === true
    @test isa(x.value, T)
end

# NotNull{T}(value::T) = Nullable{T}(value)
for T in types
    v = zero(T)
    x = NotNull(v)
    @test x.isnull === false
    @test isa(x.value, T)
    @test x.value === v

    v = one(T)
    x = NotNull(v)
    @test x.isnull === false
    @test isa(x.value, T)
    @test x.value === v
end

p1s = [
    "Null(Bool)",
    "Null(Char)",
    "Null(Float16)",
    "Null(Float32)",
    "Null(Float64)",
    "Null(Int128)",
    "Null(Int16)",
    "Null(Int32)",
    "Null(Int64)",
    "Null(Int8)",
    "Null(Uint16)",
    "Null(Uint32)",
    "Null(Uint64)",
    "Null(Uint8)",
]

p2s = [
    "NotNull(false)",
    "NotNull('\0')",
    "NotNull(float16(0.0))",
    "NotNull(0.0f0)",
    "NotNull(0.0)",
    "NotNull(0)",
    "NotNull(0)",
    "NotNull(0)",
    "NotNull(0)",
    "NotNull(0)",
    "NotNull(0x0000)",
    "NotNull(0x00000000)",
    "NotNull(0x0000000000000000)",
    "NotNull(0x00)",
]

p3s = [
    "NotNull(true)",
    "NotNull('\x01')",
    "NotNull(float16(1.0))",
    "NotNull(1.0f0)",
    "NotNull(1.0)",
    "NotNull(1)",
    "NotNull(1)",
    "NotNull(1)",
    "NotNull(1)",
    "NotNull(1)",
    "NotNull(0x0001)",
    "NotNull(0x00000001)",
    "NotNull(0x0000000000000001)",
    "NotNull(0x01)",
]

# show{T}(io::IO, x::Nullable{T})
io = IOBuffer()
for (i, T) in enumerate(types)
    x1 = Null(T)
    x2 = NotNull(zero(T))
    x3 = NotNull(one(T))
    show(io, x1)
    takebuf_string(io) == p1s[i]
    show(io, x2)
    takebuf_string(io) == p2s[i]
    show(io, x3)
    takebuf_string(io) == p3s[i]
end

# get(x::Nullable)
for T in types
    x1 = Null(T)
    x2 = NotNull(zero(T))
    x3 = NotNull(one(T))

    @test_throws NullException get(x1)
    @test get(x2) === zero(T)
    @test get(x3) === one(T)
end

# get{S, T}(x::Nullable{S}, y::T)
for T in types
    x1 = Null(T)
    x2 = NotNull(zero(T))
    x3 = NotNull(one(T))

    @test get(x1, zero(T)) === zero(T)
    @test get(x1, one(T)) === one(T)
    @test get(x2, one(T)) === zero(T)
    @test get(x3, zero(T)) === one(T)
end

# unsafe_get(x::Nullable)
for T in types
    x1 = Null(T)
    x2 = NotNull(zero(T))
    x3 = NotNull(one(T))

    @test isa(unsafe_get(x1), T)
    @test isa(unsafe_get(x2), T)
    @test isa(unsafe_get(x3), T)
end

# isnull(x::Nullable)
for T in types
    x1 = Null(T)
    x2 = NotNull(zero(T))
    x3 = NotNull(one(T))

    @test isnull(x1) === true
    @test isnull(x2) === false
    @test isnull(x3) === false
end

# function isequal{S, T}(x::Nullable{S}, y::Nullable{T})
for T in types
    x1 = Null(T)
    x2 = Null(T)
    x3 = NotNull(zero(T))
    x4 = NotNull(one(T))

    @test isequal(x1, x1) === true
    @test isequal(x1, x2) === true
    @test isequal(x1, x3) === false
    @test isequal(x1, x4) === false

    @test isequal(x2, x1) === true
    @test isequal(x2, x2) === true
    @test isequal(x2, x3) === false
    @test isequal(x2, x4) === false

    @test isequal(x3, x1) === false
    @test isequal(x3, x2) === false
    @test isequal(x3, x3) === true
    @test isequal(x3, x4) === false

    @test isequal(x4, x1) === false
    @test isequal(x4, x2) === false
    @test isequal(x4, x3) === false
    @test isequal(x4, x4) === true
end

# function =={S, T}(x::Nullable{S}, y::Nullable{T})
for T in types
    x1 = Null(T)
    x2 = Null(T)
    x3 = NotNull(zero(T))
    x4 = NotNull(one(T))

    @test_throws NullException (x1 == x1)
    @test_throws NullException (x1 == x2)
    @test_throws NullException (x1 == x3)
    @test_throws NullException (x1 == x4)

    @test_throws NullException (x2 == x1)
    @test_throws NullException (x2 == x2)
    @test_throws NullException (x2 == x3)
    @test_throws NullException (x2 == x4)

    @test_throws NullException (x3 == x1)
    @test_throws NullException (x3 == x2)
    @test_throws NullException (x3 == x3)
    @test_throws NullException (x3 == x4)

    @test_throws NullException (x4 == x1)
    @test_throws NullException (x4 == x2)
    @test_throws NullException (x4 == x3)
    @test_throws NullException (x4 == x4)
end

# function hash(x::Nullable, h::Uint)
for T in types
    x1 = Null(T)
    x2 = Null(T)
    x3 = NotNull(zero(T))
    x4 = NotNull(one(T))

    @test isa(hash(x1), Uint)
    @test isa(hash(x2), Uint)
    @test isa(hash(x3), Uint)
    @test isa(hash(x4), Uint)

    @test hash(x1) == hash(x2)
    @test hash(x1) != hash(x3)
    @test hash(x1) != hash(x4)
    @test hash(x2) != hash(x3)
    @test hash(x2) != hash(x4)
    @test hash(x3) != hash(x4)
end
