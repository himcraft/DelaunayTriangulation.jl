@testset "Can we identify boundary edges" begin
    adj = DT.Adjacent(DefaultDict(DT.DefaultAdjacentValue,
        Dict(
            (6, 3) => 1, (3, 1) => 6, (1, 6) => 3,
            (3, 2) => 5, (2, 5) => 3, (5, 3) => 2,
            (4, 1) => 5, (1, 5) => 4, (5, 4) => 1,
            (4, 6) => 1, (6, 1) => 4, (1, 4) => 6,
            (5, 1) => 3, (1, 3) => 5, (3, 5) => 1,
            (4, 5) => DT.BoundaryIndex, (5, 2) => DT.BoundaryIndex,
            (2, 3) => DT.BoundaryIndex, (3, 6) => DT.BoundaryIndex,
            (6, 4) => DT.BoundaryIndex
        )
    ))
    adj2v = DT.Adjacent2Vertex(Dict(
        DT.BoundaryIndex => Set{NTuple{2,Int64}}([(4, 5), (5, 2), (2, 3), (3, 6), (6, 4)]),
        1 => Set{NTuple{2,Int64}}([(5, 4), (3, 5), (6, 3), (4, 6)]),
        2 => Set{NTuple{2,Int64}}([(5, 3)]),
        3 => Set{NTuple{2,Int64}}([(1, 6), (5, 1), (2, 5)]),
        4 => Set{NTuple{2,Int64}}([(1, 5), (6, 1)]),
        5 => Set{NTuple{2,Int64}}([(4, 1), (1, 3), (3, 2)]),
        6 => Set{NTuple{2,Int64}}([(1, 4), (3, 1)])
    ))
    for (k, S) in adjacent2vertex(adj2v)
        for (i, j) in S
            if k == DT.BoundaryIndex
                @test DT.is_boundary_edge((i, j), adj)
                @test DT.is_boundary_edge(i, j, adj)
                @test DT.is_boundary_edge((i, j), adj2v)
                @test DT.is_boundary_edge(i, j, adj2v)
            else
                @test !DT.is_boundary_edge((i, j), adj)
                @test !DT.is_boundary_edge(i, j, adj)
                @test !DT.is_boundary_edge((i, j), adj2v)
                @test !DT.is_boundary_edge(i, j, adj2v)
            end
        end
    end
end

@testset "Can we check edge validity?" begin
    adj = DT.Adjacent(DefaultDict(DT.DefaultAdjacentValue,
        Dict(
            (6, 3) => 1, (3, 1) => 6, (1, 6) => 3,
            (3, 2) => 5, (2, 5) => 3, (5, 3) => 2,
            (4, 1) => 5, (1, 5) => 4, (5, 4) => 1,
            (4, 6) => 1, (6, 1) => 4, (1, 4) => 6,
            (5, 1) => 3, (1, 3) => 5, (3, 5) => 1,
            (4, 5) => DT.BoundaryIndex, (5, 2) => DT.BoundaryIndex,
            (2, 3) => DT.BoundaryIndex, (3, 6) => DT.BoundaryIndex,
            (6, 4) => DT.BoundaryIndex
        )
    ))
    for (i, j) in edges(adj)
        @test DT.edge_exists(i, j, adj)
    end
    for _ in 1:1000
        i, j = abs.(rand(Int64, 3))
        @test !DT.edge_exists(i, j, adj)
    end
end

@testset "Is choose_uvw working correctly?" begin
    for _ in 1:99818
        i, j, k = abs.(rand(Int64, 3))
        @test DT.choose_uvw(true, false, false, i, j, k) == (i, j, k)
        @test DT.choose_uvw(false, true, false, i, j, k) == (j, k, i)
        @test DT.choose_uvw(false, false, true, i, j, k) == (k, i, j)
    end
end

@testset "Can we correctly clear the empty keys in the adjacent map?" begin
    p1 = (5.0, 6.0)
    p2 = (9.0, 6.0)
    p3 = (13.0, 5.0)
    p4 = (10.38, 0.0)
    p5 = (12.64, -1.69)
    p6 = (2.0, -2.0)
    p7 = (3.0, 4.0)
    p8 = (7.5, 3.53)
    p9 = (4.02, 1.85)
    p10 = (4.26, 0.0)
    pts = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]
    Random.seed!(928881)
    T, adj, adj2v, DG, HG = DT.triangulate_berg(pts)
    p11 = (6.0, 2.5)
    push!(pts, p11)
    r = 11
    V = DT.locate_triangle(T, pts, r)
    i, j, k = indices(V)
    DT.delete_triangle!(i, j, k, T, adj, adj2v, DG)
    @test adjacent(adj) == DefaultDict(DT.DefaultAdjacentValue,
        Dict(
            (8, 3) => 2, (3, 2) => 8, (2, 8) => 3,
            (1, 7) => 8, (7, 8) => 1, (8, 1) => 7,
            (8, 7) => 9, (7, 9) => 8, (9, 8) => 7,
            (4, 10) => 6, (10, 6) => 4, (6, 4) => 10,
            (4, 6) => 5, (6, 5) => 4, (5, 4) => 6,
            (8, 4) => 3, (4, 3) => 8, (3, 8) => 4,
            (9, 6) => 10, (6, 10) => 9, (10, 9) => 6,
            (1, 8) => 2, (8, 2) => 1, (2, 1) => 8,
            (9, 7) => 6, (7, 6) => 9, (6, 9) => 7,
            (5, 3) => 4, (3, 4) => 5, (4, 5) => 3,
            (8, 10) => 4, (10, 4) => 8, (4, 8) => 10,
            (1, 2) => DT.BoundaryIndex,
            (2, 3) => DT.BoundaryIndex,
            (3, 5) => DT.BoundaryIndex,
            (5, 6) => DT.BoundaryIndex,
            (6, 7) => DT.BoundaryIndex,
            (7, 1) => DT.BoundaryIndex,
            (((8, -1), (2, 7), (10, 7), (7, 5), (-3, 8), (-3, 10),
                (-3, 2), (5, 10), (2, -1), (-3, 5), (8, 5)) .=> DT.DefaultAdjacentValue)...
        )
    )
    DT.clear_empty_keys!(adj, DG)
    @test adjacent(adj) == DefaultDict(DT.DefaultAdjacentValue,
        Dict(
            (8, 3) => 2, (3, 2) => 8, (2, 8) => 3,
            (1, 7) => 8, (7, 8) => 1, (8, 1) => 7,
            (8, 7) => 9, (7, 9) => 8, (9, 8) => 7,
            (4, 10) => 6, (10, 6) => 4, (6, 4) => 10,
            (4, 6) => 5, (6, 5) => 4, (5, 4) => 6,
            (8, 4) => 3, (4, 3) => 8, (3, 8) => 4,
            (9, 6) => 10, (6, 10) => 9, (10, 9) => 6,
            (1, 8) => 2, (8, 2) => 1, (2, 1) => 8,
            (9, 7) => 6, (7, 6) => 9, (6, 9) => 7,
            (5, 3) => 4, (3, 4) => 5, (4, 5) => 3,
            (8, 10) => 4, (10, 4) => 8, (4, 8) => 10,
            (1, 2) => DT.BoundaryIndex,
            (2, 3) => DT.BoundaryIndex,
            (3, 5) => DT.BoundaryIndex,
            (5, 6) => DT.BoundaryIndex,
            (6, 7) => DT.BoundaryIndex,
            (7, 1) => DT.BoundaryIndex,
        )
    )
end

@testset "Can we correctly compare collections of triangles?" begin
    T = [(1, 5, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1), (7, 10, 0)]
    V = [(1, 5, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1), (7, 10, 0)]
    @test DT.compare_triangle_sets(T, V)
    @test DT.compare_triangle_sets(V, T)
    V = [(1, 5, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1)]
    @test !DT.compare_triangle_sets(T, V)
    @test !DT.compare_triangle_sets(V, T)
    V = [(1, 5, 7), (10, 5, 3), (1, 2, 3), (1, 3, 2), (0, 7, 10)]
    @test DT.compare_triangle_sets(T, V)
    @test DT.compare_triangle_sets(V, T)
    V = [(1, 5, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1), (7, 6, 3)]
    @test !DT.compare_triangle_sets(T, V)
    @test !DT.compare_triangle_sets(V, T)
    V = [(5, 1, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1), (7, 6, 3)]
    @test !DT.compare_triangle_sets(T, V)
    @test !DT.compare_triangle_sets(V, T)
    T = Set{NTuple{3,Int64}}([(1, 5, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1), (7, 10, 0)])
    V = Set{NTuple{3,Int64}}([(1, 5, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1), (7, 10, 0)])
    @test DT.compare_triangle_sets(T, V)
    @test DT.compare_triangle_sets(V, T)
    V = Set{NTuple{3,Int64}}([(1, 5, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1)])
    @test !DT.compare_triangle_sets(T, V)
    @test !DT.compare_triangle_sets(V, T)
    V = Set{NTuple{3,Int64}}([(1, 5, 7), (10, 5, 3), (1, 2, 3), (1, 3, 2), (0, 7, 10)])
    @test DT.compare_triangle_sets(T, V)
    @test DT.compare_triangle_sets(V, T)
    V = Set{NTuple{3,Int64}}([(1, 5, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1), (7, 6, 3)])
    @test !DT.compare_triangle_sets(T, V)
    @test !DT.compare_triangle_sets(V, T)
    V = Set{NTuple{3,Int64}}([(5, 1, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1), (7, 6, 3)])
    @test !DT.compare_triangle_sets(T, V)
    @test !DT.compare_triangle_sets(V, T)
end

@testset "Can we correctly compare triangulations?" begin
    p1 = (5.0, 6.0)
    p2 = (9.0, 6.0)
    p3 = (13.0, 5.0)
    p4 = (10.38, 0.0)
    p5 = (12.64, -1.69)
    p6 = (2.0, -2.0)
    p7 = (3.0, 4.0)
    p8 = (7.5, 3.53)
    p9 = (4.02, 1.85)
    p10 = (4.26, 0.0)
    pts = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]
    Random.seed!(928881)
    T, adj, adj2v, DG, HG = DT.triangulate_berg(pts)
    @test DT.compare_unconstrained_triangulations(T, adj, adj2v, DG, T, adj, adj2v, DG)
    @test !DT.compare_unconstrained_triangulations(T, adj, adj2v, DG, Set{NTuple{3,Int64}}([(5, 1, 7), (10, 5, 3), (1, 2, 3), (3, 2, 1), (7, 6, 3)]), adj, adj2v, DG)
    adj2 = deepcopy(adj)
    adj2.adjacent[(6, 10)] = 120
    @test !DT.compare_unconstrained_triangulations(T, adj, adj2v, DG, T, adj2, adj2v, DG)
    adj2v2 = deepcopy(adj2v)
    DT.delete_point!(adj2v2, 3)
    @test !DT.compare_unconstrained_triangulations(T, adj, adj2v, DG, T, adj, adj2v2, DG)
    DG2 = deepcopy(DG)
    DT.delete_point!(DG2, 7)
    @test !DT.compare_unconstrained_triangulations(T, adj, adj2v, DG, T, adj, adj2v, DG2)
end

@testset "Can we correctly validate the relationship between Adjacent and Adjacent2Vertex?" begin
    adj = DT.Adjacent(DefaultDict(DT.DefaultAdjacentValue,
        Dict(
            (1, 2) => 3, (2, 3) => 1, (3, 1) => 2,
            (3, 2) => 4, (2, 4) => 3, (4, 3) => 2,
            (3, 4) => 5, (4, 5) => 3, (5, 3) => 4,
            (4, 2) => 6, (2, 6) => 4, (6, 4) => 2,
            (5, 4) => 6, (4, 6) => 5, (6, 5) => 4,
            (2, 1) => DT.BoundaryIndex, (1, DT.BoundaryIndex) => 2, (DT.BoundaryIndex, 2) => 1,
            (1, 3) => DT.BoundaryIndex, (3, DT.BoundaryIndex) => 1, (DT.BoundaryIndex, 1) => 3,
            (3, 5) => DT.BoundaryIndex, (5, DT.BoundaryIndex) => 3, (DT.BoundaryIndex, 3) => 5,
            (5, 6) => DT.BoundaryIndex, (6, DT.BoundaryIndex) => 5, (DT.BoundaryIndex, 5) => 6,
            (6, 2) => DT.BoundaryIndex, (2, DT.BoundaryIndex) => 6, (DT.BoundaryIndex, 6) => 2
        )))
    adj2v = DT.Adjacent2Vertex(
        Dict(
            DT.BoundaryIndex => Set{NTuple{2,Int64}}([(1, 3), (3, 5), (5, 6), (6, 2), (2, 1)]),
            1 => Set{NTuple{2,Int64}}([(2, 3), (3, DT.BoundaryIndex), (DT.BoundaryIndex, 2)]),
            2 => Set{NTuple{2,Int64}}([(3, 1), (4, 3), (6, 4), (1, DT.BoundaryIndex), (DT.BoundaryIndex, 6)]),
            3 => Set{NTuple{2,Int64}}([(1, 2), (2, 4), (4, 5), (DT.BoundaryIndex, 1), (5, DT.BoundaryIndex)]),
            4 => Set{NTuple{2,Int64}}([(3, 2), (2, 6), (6, 5), (5, 3)]),
            5 => Set{NTuple{2,Int64}}([(3, 4), (4, 6), (6, DT.BoundaryIndex), (DT.BoundaryIndex, 3)]),
            6 => Set{NTuple{2,Int64}}([(4, 2), (5, 4), (DT.BoundaryIndex, 5), (2, DT.BoundaryIndex)])
        )
    )
    @test DT.check_adjacent_is_adjacent2vertex_inverse(adj, adj2v)
    adj2v = DT.Adjacent2Vertex(
        Dict(
            DT.BoundaryIndex => Set{NTuple{2,Int64}}([(1, 3), (3, 5), (5, 6), (10, 11), (6, 2), (2, 1)]),
            1 => Set{NTuple{2,Int64}}([(2, 3), (3, DT.BoundaryIndex), (DT.BoundaryIndex, 2)]),
            2 => Set{NTuple{2,Int64}}([(3, 1), (4, 3), (6, 4), (1, DT.BoundaryIndex), (DT.BoundaryIndex, 6)]),
            3 => Set{NTuple{2,Int64}}([(1, 2), (2, 4), (4, 5), (DT.BoundaryIndex, 1), (5, DT.BoundaryIndex)]),
            4 => Set{NTuple{2,Int64}}([(3, 2), (2, 6), (6, 5), (5, 3)]),
            5 => Set{NTuple{2,Int64}}([(3, 4), (4, 6), (6, DT.BoundaryIndex), (DT.BoundaryIndex, 3)]),
            6 => Set{NTuple{2,Int64}}([(4, 2), (5, 4), (DT.BoundaryIndex, 5), (2, DT.BoundaryIndex)])
        )
    )
    @test !DT.check_adjacent_is_adjacent2vertex_inverse(adj, adj2v)
    adj2v = DT.Adjacent2Vertex(
        Dict(
            DT.BoundaryIndex => Set{NTuple{2,Int64}}([(1, 3), (3, 5), (5, 6), (6, 2), (2, 1)]),
            1 => Set{NTuple{2,Int64}}([(2, 3), (3, DT.BoundaryIndex), (DT.BoundaryIndex, 2)]),
            2 => Set{NTuple{2,Int64}}([(3, 1), (4, 3), (6, 4), (1, DT.BoundaryIndex), (DT.BoundaryIndex, 6)]),
            3 => Set{NTuple{2,Int64}}([(1, 2), (2, 4), (4, 5), (DT.BoundaryIndex, 1), (5, DT.BoundaryIndex)]),
            4 => Set{NTuple{2,Int64}}([(3, 2), (2, 6), (6, 5), (5, 3)]),
            5 => Set{NTuple{2,Int64}}([(3, 4), (4, 6), (6, DT.BoundaryIndex), (DT.BoundaryIndex, 3)]),
            6 => Set{NTuple{2,Int64}}([(4, 2), (5, 4), (DT.BoundaryIndex, 5), (2, DT.BoundaryIndex)])
        )
    )
    DT.get_edge(adj, 92918, 29991) # Should just skip over the empty keys
    @test DT.check_adjacent_is_adjacent2vertex_inverse(adj, adj2v)
end

@testset "Can we correctly delete empty sets from Adjacent2Vertex?" begin
    adj2v = DT.Adjacent2Vertex(
        Dict(
            DT.BoundaryIndex => Set{NTuple{2,Int64}}([(1, 3), (3, 5), (5, 6), (6, 2), (2, 1)]),
            1 => Set{NTuple{2,Int64}}([(2, 3), (3, DT.BoundaryIndex), (DT.BoundaryIndex, 2)]),
            2 => Set{NTuple{2,Int64}}([(3, 1), (4, 3), (6, 4), (1, DT.BoundaryIndex), (DT.BoundaryIndex, 6)]),
            3 => Set{NTuple{2,Int64}}([(1, 2), (2, 4), (4, 5), (DT.BoundaryIndex, 1), (5, DT.BoundaryIndex)]),
            4 => Set{NTuple{2,Int64}}([(3, 2), (2, 6), (6, 5), (5, 3)]),
            5 => Set{NTuple{2,Int64}}([(3, 4), (4, 6), (6, DT.BoundaryIndex), (DT.BoundaryIndex, 3)]),
            6 => Set{NTuple{2,Int64}}([(4, 2), (5, 4), (DT.BoundaryIndex, 5), (2, DT.BoundaryIndex)]),
            7 => Set{NTuple{2,Int64}}(),
            10 => Set{NTuple{2,Int64}}()
        )
    )
    DT.clear_empty_keys!(adj2v)
    @test adj2v.adjacent2vertex == Dict(
        DT.BoundaryIndex => Set{NTuple{2,Int64}}([(1, 3), (3, 5), (5, 6), (6, 2), (2, 1)]),
        1 => Set{NTuple{2,Int64}}([(2, 3), (3, DT.BoundaryIndex), (DT.BoundaryIndex, 2)]),
        2 => Set{NTuple{2,Int64}}([(3, 1), (4, 3), (6, 4), (1, DT.BoundaryIndex), (DT.BoundaryIndex, 6)]),
        3 => Set{NTuple{2,Int64}}([(1, 2), (2, 4), (4, 5), (DT.BoundaryIndex, 1), (5, DT.BoundaryIndex)]),
        4 => Set{NTuple{2,Int64}}([(3, 2), (2, 6), (6, 5), (5, 3)]),
        5 => Set{NTuple{2,Int64}}([(3, 4), (4, 6), (6, DT.BoundaryIndex), (DT.BoundaryIndex, 3)]),
        6 => Set{NTuple{2,Int64}}([(4, 2), (5, 4), (DT.BoundaryIndex, 5), (2, DT.BoundaryIndex)])
    )
    DT.clear_empty_keys!(adj2v)
    @test adj2v.adjacent2vertex == Dict(
        DT.BoundaryIndex => Set{NTuple{2,Int64}}([(1, 3), (3, 5), (5, 6), (6, 2), (2, 1)]),
        1 => Set{NTuple{2,Int64}}([(2, 3), (3, DT.BoundaryIndex), (DT.BoundaryIndex, 2)]),
        2 => Set{NTuple{2,Int64}}([(3, 1), (4, 3), (6, 4), (1, DT.BoundaryIndex), (DT.BoundaryIndex, 6)]),
        3 => Set{NTuple{2,Int64}}([(1, 2), (2, 4), (4, 5), (DT.BoundaryIndex, 1), (5, DT.BoundaryIndex)]),
        4 => Set{NTuple{2,Int64}}([(3, 2), (2, 6), (6, 5), (5, 3)]),
        5 => Set{NTuple{2,Int64}}([(3, 4), (4, 6), (6, DT.BoundaryIndex), (DT.BoundaryIndex, 3)]),
        6 => Set{NTuple{2,Int64}}([(4, 2), (5, 4), (DT.BoundaryIndex, 5), (2, DT.BoundaryIndex)])
    )
end

@testset "Can we correctly clear degree 0 points from a DelaunayGraph?" begin
    DG = DT.DelaunayGraph(UndirectedGraph(
        [
            0 0 0
            0 1 1
            0 1 1
        ]
    ))
    DT.clear_empty_points!(DG)
    @test DG.graph == relabel(UndirectedGraph([1 1; 1 1]), Dict((1, 2) .=> (2, 3)))
    DT.clear_empty_points!(DG)
    @test DG.graph == relabel(UndirectedGraph([1 1; 1 1]), Dict((1, 2) .=> (2, 3)))
    DG = DT.DelaunayGraph(UndirectedGraph(
        [
            0 1 0 0
            1 1 1 0
            0 1 1 0
            0 0 0 0
        ]
    ))
    DT.clear_empty_points!(DG)
    @test DG.graph == relabel(UndirectedGraph([0 1 0; 1 1 1; 0 1 1]))
    DT.clear_empty_points!(DG)
    @test DG.graph == relabel(UndirectedGraph([0 1 0; 1 1 1; 0 1 1]))
    DG = DT.DelaunayGraph(UndirectedGraph(
        [
            0 1 0 0
            1 1 1 0
            0 1 1 0
            0 0 0 0
        ]
    ))
    DT.clear_empty_points!(DG)
    @test DG.graph == relabel(UndirectedGraph([0 1 0; 1 1 1; 0 1 1]))
    DT.clear_empty_points!(DG)
    @test DG.graph == relabel(UndirectedGraph([0 1 0; 1 1 1; 0 1 1]))
    DG = DT.DelaunayGraph(UndirectedGraph(
        [
            1 0 1
            0 0 0
            1 0 0
        ]
    ))
    DT.clear_empty_points!(DG)
    @test DG.graph == relabel(UndirectedGraph([1 1; 1 0]), Dict((1,2).=>(1,3)))
end