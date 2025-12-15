module LMDB_DBI
    using LMDB
    using Test

    key = 10
    val = "key value is "

    # Create dir
    mktempdir() do dbname
    try

        # Procedural style
        env = create()
        try
            open(env, dbname)
            txn = start(env)
            dbi = open(txn)
            put!(txn, dbi, key+1, val*string(key+1))
            put!(txn, dbi, key, val*string(key))
            put!(txn, dbi, key+2, key+2)
            put!(txn, dbi, key+3, [key, key+1, key+2])
            @test isopen(txn)
            commit(txn)
            @test !isopen(txn)
            # Don't close dbi after modifying it - this can cause corruption
            # The environment will automatically close it when env is closed
        finally
            close(env)
        end
        @test !isopen(env)

        # Block style
        create() do env
            set!(env, LMDB.MDB_NOSYNC)
            open(env, dbname)
            start(env) do txn
                open(txn) do dbi
                    k = key
                    value = get(txn, dbi, k, String)
                    println("Got value for key $(k): $(value)")
                    @test value == val*string(k)
                    delete!(txn, dbi, k)
                    k += 1
                    value = get(txn, dbi, k, String)
                    println("Got value for key $(k): $(value)")
                    @test value == val*string(k)
                    delete!(txn, dbi, k, value)
                    @test_throws LMDBError get(txn, dbi, k, String)
                    k += 1
                    value = get(txn, dbi, k, Int)
                    println("Got value for key $(k): $(value)")
                    @test value == k
                    k += 1
                    value = get(txn, dbi, k, Vector{Int})
                    println("Got value for key $(k): $(value)")
                    @test value == [key, key+1, key+2]
                end
            end
        end
    finally
        # mktempdir will clean up automatically
    end
    end
end
