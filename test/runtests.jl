using Test

@testset "LMDB" for t in ["common", "env", "dbi", "cur","dict"]
    fp = "$t.jl"
    @testset "$(t)" begin
        include(fp)
    end
end
