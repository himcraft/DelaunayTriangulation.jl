@testset "Testing point insertion with the Bowyer-Watson method" begin
      ## Existing triangulation with no bounding etc 
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

      DT.add_point_bowyer!(T, adj, adj2v, DG, pts, 11)
      _T, _adj, _adj2v, _DG, _HG = DT.triangulate_berg(pts)
      DT.clear_empty_keys!(adj)
      DT.clear_empty_keys!(_adj)
      @test DT.compare_triangle_sets(T, _T) &&
            adjacent(adj) == adjacent(_adj) &&
            adjacent2vertex(adj2v) == adjacent2vertex(_adj2v) &&
            graph(DG) == graph(_DG)

      p12 = (10.3, 2.85)
      push!(pts, p12)
      DT.add_point_bowyer!(T, adj, adj2v, DG, pts, 12)
      _T, _adj, _adj2v, _DG, _HG = DT.triangulate_berg(pts)
      DT.clear_empty_keys!(adj)
      DT.clear_empty_keys!(_adj)
      @test DT.compare_triangle_sets(T, _T) &&
            adjacent(adj) == adjacent(_adj) &&
            adjacent2vertex(adj2v) == adjacent2vertex(_adj2v) &&
            graph(DG) == graph(_DG)

      p13 = (7.5, 3.5)
      push!(pts, p13)
      DT.add_point_bowyer!(T, adj, adj2v, DG, pts, 13)
      _T, _adj, _adj2v, _DG, _HG = DT.triangulate_berg(pts)
      DT.clear_empty_keys!(adj)
      DT.clear_empty_keys!(_adj)
      @test DT.compare_triangle_sets(T, _T) &&
            adjacent(adj) == adjacent(_adj) &&
            adjacent2vertex(adj2v) == adjacent2vertex(_adj2v) &&
            graph(DG) == graph(_DG)

      ## Now do this for some circular points so that we can do some random tests - only testing for interior insertion here
      R = 10.0
      n = 1381
      pts = [(rand((-1, 1)) * R * rand(), rand((-1, 1)) * R * rand()) for _ in 1:n] # rand((-1, 1)) to get random signs
      pushfirst!(pts, (-11.0, -11.0), (11.0, -11.0), (11.0, 11.0), (-11.0, 11.0)) # bounding box to guarantee interior insertions only
      T, adj, adj2v, DG, HG = @views DT.triangulate_berg(pts[1:7])
      _T, _adj, _adj2v, _DG, _HG = @views DT.triangulate_berg(pts[1:7])
      n = length(pts)
      for i in 8:n
            DT.add_point_bowyer!(T, adj, adj2v, DG, pts, i)
            DT.add_point_berg!(_T, _adj, _adj2v, _DG, _HG, pts, i)
            @test DT.compare_unconstrained_triangulations(T, adj, adj2v, DG, _T, _adj, _adj2v, _DG)
      end
end

@testset "Adding a point outside of the triangulation" begin
      ## Small example
      p1 = @SVector[-3.32, 3.53]
      p2 = @SVector[-5.98, 2.17]
      p3 = @SVector[-6.36, -1.55]
      p4 = @SVector[-2.26, -4.31]
      p5 = @SVector[6.34, -3.23]
      p6 = @SVector[-3.24, 1.01]
      p7 = @SVector[0.14, -1.51]
      p8 = @SVector[0.2, 1.25]
      p9 = @SVector[1.0, 4.0]
      p10 = @SVector[4.74, 2.21]
      p11 = @SVector[2.32, -0.27]
      pts = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11]
      DT.compute_centroid!(pts)
      T = Set{NTuple{3,Int64}}()
      adj = DT.Adjacent{Int64,NTuple{2,Int64}}()
      adj2v = DT.Adjacent2Vertex{Int64,Set{NTuple{2,Int64}},NTuple{2,Int64}}()
      DG = DT.DelaunayGraph{Int64}()
      for (i, j, k) in (
            (1, 2, 6),
            (1, 6, 8),
            (9, 1, 8),
            (9, 8, 10),
            (10, 8, 11),
            (8, 7, 11),
            (8, 6, 7),
            (6, 2, 3),
            (6, 3, 4),
            (6, 4, 7),
            (7, 4, 5),
            (11, 7, 5),
            (10, 11, 5)
      )
            DT.add_triangle!(i, j, k, T, adj, adj2v, DG; update_ghost_edges=true)
      end
      p12 = @SVector[4.382, 3.2599]
      push!(pts, p12)
      DT.add_point_bowyer!(T, adj, adj2v, DG, pts, 12)
      _T, _adj, _adj2v, _DG, _HG = DT.triangulate_berg(pts)
      DT.add_ghost_triangles!(_T, _adj, _adj2v, _DG)
      @test DT.compare_unconstrained_triangulations(T, adj, adj2v, DG, _T, _adj, _adj2v, _DG)
      @test DT.compare_deberg_to_bowyerwatson(T, adj, adj2v, DG, _T, _adj, _adj2v, _DG)

      p13 = @SVector[-5.25303, 4.761]
      p14 = @SVector[-9.83801, 0.562]
      p15 = @SVector[-7.15986, -5.99]
      p16 = @SVector[4.79, 2.74]
      p17 = @SVector[3.77, 2.7689]
      push!(pts, p13, p14, p15, p16, p17)
      DT.add_point_bowyer!(T, adj, adj2v, DG, pts, 13)
      DT.add_point_bowyer!(T, adj, adj2v, DG, pts, 14)
      DT.add_point_bowyer!(T, adj, adj2v, DG, pts, 15)
      DT.add_point_bowyer!(T, adj, adj2v, DG, pts, 16)
      DT.add_point_bowyer!(T, adj, adj2v, DG, pts, 17)
      _T, _adj, _adj2v, _DG, _HG = DT.triangulate_berg(pts)
      DT.add_ghost_triangles!(_T, _adj, _adj2v, _DG)
      @test DT.compare_unconstrained_triangulations(T, adj, adj2v, DG, _T, _adj, _adj2v, _DG)
      @test DT.compare_deberg_to_bowyerwatson(T, adj, adj2v, DG, _T, _adj, _adj2v, _DG)
      @test DT.compare_deberg_to_bowyerwatson(T, adj, adj2v, DG, pts)

      DT.remove_ghost_triangles!(T, adj, adj2v, DG)
      @test !DT.compare_deberg_to_bowyerwatson(T, adj, adj2v, DG, _T, _adj, _adj2v, _DG)
      @test !DT.compare_deberg_to_bowyerwatson(T, adj, adj2v, DG, pts)
end