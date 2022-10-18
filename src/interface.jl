###################################################
#/
#/
#/ Triangle(s)
#/
#/
###################################################
function indices end            # indices(::Triangle)
function geti end               # geti(::Triangle)
function getj end               # getj(::Triangle)
function getk end               # getk(::Triangle)
function construct_triangle end # construct_triangle(::Type{Triangle}, ::I, ::I, ::I)

indices(T::NTuple{3,I}) where {I} = T
geti(T::NTuple{3,I}) where {I} = T[1]
getj(T::NTuple{3,I}) where {I} = T[2]
getk(T::NTuple{3,I}) where {I} = T[3]
construct_triangle(::Type{NTuple{3,I}}, i, j, k) where {I} = (i, j, k)

shift_triangle_1(T::V) where {V} = construct_triangle(V, getj(T), getk(T), geti(T))
shift_triangle_2(T::V) where {V} = construct_triangle(V, getk(T), geti(T), getj(T))
shift_triangle(T::V, i) where {V} = i == 0 ? T : (i == 1 ? shift_triangle_1(T) : shift_triangle_2(T))

function construct_triangles end # construct_triangles(::Type{Triangles})
function triangle_type end       # triangle_type(::Type{Triangles})

construct_triangles(::Type{T}) where {T} = T()
triangle_type(::Type{T}) where {T} = eltype(T)

function add_triangle!(T, V::Vararg{Tri,N}) where {Tri,N}
    push!(T, V...)
    return nothing
end
function delete_triangle!(T, V)
    delete!(T, V)
    delete!(T, shift_triangle_1(V))
    delete!(T, shift_triangle_2(V))
    return nothing
end
function delete_triangle!(T, V::Vararg{Tri,N}) where {Tri,N}
    for i in 1:N
        delete_triangle!(T, V[i])
    end
    return nothing
end

###################################################
#/
#/
#/ Edge(s)
#/
#/
###################################################
function construct_edge end # construct_edge(::Type{Edge}, ::I, ::I)

construct_edge(::Type{NTuple{2,I}}, i, j) where {I} = (i, j)
construct_edge(::Type{Vector{I}}, i, j) where {I} = I[i, j]

###################################################
#/
#/
#/ Point(s)
#/
#/
###################################################
function getx end
function gety end

getx(p::Base.AbstractVecOrTuple) = p[1]
gety(p::Base.AbstractVecOrTuple) = p[2]

function get_point end      # get_point(::Points, ::I)

function get_point(pts::AbstractVector, i)
    if i ≥ FirstPointIndex
        return pts[i]
    elseif i == LowerRightBoundingIndex
        return lower_right_bounding_triangle_coords(pts)
    elseif i == LowerLeftBoundingIndex
        return lower_left_bounding_triangle_coords(pts)
    elseif i == UpperBoundingIndex
        return upper_bounding_triangle_coords(pts)
    end
    throw(BoundsError(pts, i))
end
function get_point(pts::AbstractVector, i::Vararg{I,N}) where {I,N}
    return ntuple(j -> get_point(pts, i[j]), Val(N))
end
function point_stats(points)
    T = Float64
    xmin = typemax(T)
    xmax = typemin(T)
    ymin = typemax(T)
    ymax = typemin(T)
    for pt in points
        if getx(pt) < xmin
            xmin = getx(pt)
        end
        if getx(pt) > xmax
            xmax = getx(pt)
        end
        if gety(pt) < ymin
            ymin = gety(pt)
        end
        if gety(pt) > ymax
            ymax = gety(pt)
        end
    end
    width = max(xmax - xmin, MinWidthHeight)
    height = max(ymax - ymin, MinWidthHeight)
    xcentroid = (xmax + xmin) / 2
    ycentroid = (ymax + ymin) / 2
    max_width_height = max(width, height)
    return xcentroid, ycentroid, max_width_height
end
function lower_right_bounding_triangle_coords(points)
    xcentroid, ycentroid, max_width_height = point_stats(points)
    return (xcentroid + BoundingTriangleShift * max_width_height,
        ycentroid - max_width_height)
end
function lower_left_bounding_triangle_coords(points)
    xcentroid, ycentroid, max_width_height = point_stats(points)
    return (xcentroid - BoundingTriangleShift * max_width_height,
        ycentroid - max_width_height)
end
function upper_bounding_triangle_coords(points)
    xcentroid, ycentroid, max_width_height = point_stats(points)
    return (xcentroid,
        ycentroid + BoundingTriangleShift * max_width_height)
end

function add_point!(pts, p)
    push!(pts, p)
    return nothing
end
function add_point!(pts, p::Vararg{P,N}) where {P,N}
    for i in 1:N
        add_point!(pts, p[i])
    end
    return nothing
end