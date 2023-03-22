
println("===============================================")
println("Testing dynamics.jl")
println("===============================================")


function _check_distance()

    l1 = CellAdhesion.distance(BitVector([0,0,1,1,0,1,0,0,1,1,0,1]), 12)
    l2 = CellAdhesion.distance(BitVector([0,0,0,0,0,1,0,0,0,0,0,0]), 12)
    l3 = CellAdhesion.distance(BitVector([0,0,0,0,0,0,0,0,0,0,0,0]), 12)    
    l4 = CellAdhesion.distance(BitVector([1,1,1,0,1,0,1,1,0,0,1,0]), 12)    


    ((l1 == [0,0,4,3,0,5,0,0,4,3,0,5]) 
      && (l2 == [0,0,0,0,0,12,0,0,0,0,0,0]) 
      && (l3 == zeros(12)) 
      && (l4 == [3,2,3,0,4,0,3,4,0,0,5,0]) 
      && (typeof(l1) == Vector{CellAdhesionFloat}))

end
@test _check_distance()


function _check_force_bonds_global(tol)

    force_string = :force_global
  
    model = model_init((model=k_on_constant, k_on_0=1.0), (model=k_off_slip, k_off_0=0.0, f_1e=1))
  
    n = 10
    l = 1.0
    v1 = Cluster(Bond.([true,true,true,true,true,true,true,true,true,true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 10.0, force_string, n, l)
    v2 = Cluster(Bond.([false,true,false,true,false,false,false,false,false,false], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 10.0, force_string,n, l)
    v3 = Cluster(Bond.([false,true,true,false,false,false,false,true,false,true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 10.0, force_string,n, l)


    force(v1)
    force(v2)
    force(v3)

    f1 = getfield.(v1.u, :f)
    f2 = getfield.(v2.u, :f)
    f3 = getfield.(v3.u, :f)

    ((f1 == repeat([1.0], 10)) 
      && (f2==[0.0, 5.0, 0.0, 5.0, 0.0, 0.0,0.0,0.0,0.0,0.0]) 
      && (f3==[0.0, 2.5, 2.5, 0.0, 0.0, 0.0,0.0, 2.5,0.0, 2.5]))

end

@test _check_force_bonds_global(tol)



function _check_force_clusters_global(tol)

    model = model_init((model=k_on_constant, k_on_0=1.0), (model=k_off_slip, k_off_0=0.0, f_1e=1))

    int_1 =  interface([2, 3], [1.0, 0.1], model, 18.0, [:force_global, :force_global])
    update_state(int_1)
    force(int_1)
    
    f_check_1 = sum(getfield.(int_1.u, :f))
    f_check_2 = 0
    for i = 1:1:int_1.n
        f_check_2 = f_check_2 + sum(getfield.(int_1.u[i].u, :f))
    end

    n = 3
    l = 1
    v1 = Cluster(Bond.([false,true,true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 0.0, :force_global, n, l)
    v2 = Cluster(Bond.([false,false,true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 0.0, :force_global, n, l)
    int_2 = Interface([v1, v2], false, 60.0, :force_global, 2, l)

    update_state(int_2)
    force(int_2)
    
    f2_check_1 = sum(getfield.(int_2.u, :f))
    f2_check_2 = 0
    for i = 1:1:int_2.n
        f2_check_2 = f2_check_2 + sum(getfield.(int_2.u[i].u, :f))
    end

    ((int_1.f == f_check_1) 
      && (int_1.f == f_check_2) 
      && (int_2.f == f2_check_1) 
      && (int_2.f == f2_check_2)) 

end

@test _check_force_clusters_global(tol)


function _check_force_bonds_local(tol)

  model = model_init((model=k_on_constant, k_on_0=1.0), (model=k_off_slip, k_off_0=0.0, f_1e=1))

    n = 10
    l = 1.0
    v1 = Cluster(Bond.([true,true,true,true,true,true,true,true,true,true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 10.0, :force_local, n, l)
    v2 = Cluster(Bond.([false,true,false,true,false,false,false,false,false,false], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 10.0, :force_local, n, l)
    v3 = Cluster(Bond.([false,true,true,false,false,false,false,true,false,true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 10.0, :force_local, n, l)


    force(v1)
    force(v2)
    force(v3)

    f1 = getfield.(v1.u, :f)
    f2 = getfield.(v2.u, :f)
    f3 = getfield.(v3.u, :f)

    ((f1 == repeat([1.0], 10)) 
      && (f2==[0.0, 5.0, 0.0, 5.0, 0.0, 0.0,0.0,0.0,0.0,0.0]) 
      && (f3==[0.0, 1.5, 3.0, 0.0, 0.0, 0.0,0.0, 3.5,0.0, 2.0]))

end

@test _check_force_bonds_local(tol)




function _check_force_clusters_local(tol)

  model = model_init((model=k_on_constant, k_on_0=1.0), (model=k_off_slip, k_off_0=0.0, f_1e=1))
  int_1 =  interface([2, 3], [1.0, 0.1], model, 18.0, [:force_local, :force_local])
  update_state(int_1)
  force(int_1)
  
  f_check_1 = sum(getfield.(int_1.u, :f))
  f_check_2 = 0
  for i = 1:1:int_1.n
      f_check_2 = f_check_2 + sum(getfield.(int_1.u[i].u, :f))
  end

  n = 5
  l = 1
  v1 = Cluster(Bond.([false,true,true, false, true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 0.0, :force_local, n, l)
  v2 = Cluster(Bond.([false,true,true, true, true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 0.0, :force_local, n, l)
  int_2 = Interface([v1, v2], false, 60.0, :force_local, 2, l)

  update_state(int_2)
  force(int_2)
  
  f2_check_1 = sum(getfield.(int_2.u, :f))
  f2_check_2 = 0
  for i = 1:1:int_2.n
      f2_check_2 = f2_check_2 + sum(getfield.(int_2.u[i].u, :f))
  end

  ((int_1.f == f_check_1) 
    && (int_1.f == f_check_2) 
    && (int_2.f == f2_check_1) 
    && (int_2.f == f2_check_2)) 

end

@test _check_force_clusters_local(tol)



function _check_k_on_constant(tol)

  n = 5
  l = 1
  model = model_init((model=k_on_constant, k_on_0=0.2), (model=k_off_slip, k_off_0=0.0, f_1e=1))
  v1 = Cluster(Bond.([false,true,true, false, true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 0.0, :force_global, n, l)

  k_on_constant(v1)


  (isapprox(getfield.(v1.u, :k_on), [0.2, 0.0, 0.0, 0.2, 0.0], atol=tol) 
    && (typeof(getfield.(v1.u,:k_on)) == Vector{CellAdhesionFloat}))

end

@test _check_k_on_constant(tol)


function _check_k_off_slip(tol)

    n = 5
    l = 1

    model = model_init((model=k_on_constant, k_on_0=0.2), (model=k_off_slip, k_off_0=0.5, f_1e=1))
    v1 = Cluster(Bond.([false,true,true, false, true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 0.1, :force_global, n, l)
    k_off_slip(v1)


    (isapprox(getfield.(v1.u, :k_off), [0.0, 0.51694757, 0.51694757, 0.0, 0.51694757], atol=tol) 
      && (typeof(getfield.(v1.u,:k_off)) == Vector{CellAdhesionFloat}))

end

@test _check_k_off_slip(tol)


function _check_k_rate_junction(tol)

    n = 5
    l = 1

    model = model_init((model=k_on_constant, k_on_0=0.2), (model=k_off_slip, k_off_0=0.5, f_1e=1))
    v1 = Cluster(Bond.([false,true,true, false, true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 0.1, :force_global, n, l)
    update_state(v1)
    force(v1)
    k_rate_junction(v1)

    v2 = Cluster(Bond.([false,true,true, false, true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 0.0, :force_global, n, l)
    v3 = Cluster(Bond.([false,true,true, true, true], zeros(n), zeros(n), zeros(n), repeat([model], n)), false, 0.0, :force_global, n, l)
    int_1 = Interface([v2, v3], false, 0.2, :force_global, 2, l)
    update_state(int_1)
    force(int_1)
    k_rate_junction(int_1)

    (isapprox(getfield.(v1.u, :k_on), [0.2, 0.0, 0.0, 0.2, 0.0], atol=tol) 
      && (typeof(getfield.(v1.u,:k_on)) == Vector{CellAdhesionFloat})
      && isapprox(getfield.(int_1.u[1].u, :k_on), [0.2, 0.0, 0.0, 0.2, 0.0], atol=tol) 
      && isapprox(getfield.(int_1.u[2].u, :k_on), [0.2, 0.0, 0.0, 0.0, 0.0], atol=tol)
      && isapprox(getfield.(v1.u, :k_off), [0.0, 0.51694757, 0.51694757, 0.0, 0.51694757], atol=tol) 
      && isapprox(getfield.(int_1.u[1].u, :k_off), [0.0, 0.51694757, 0.51694757, 0.0, 0.51694757], atol=tol) 
      && isapprox(getfield.(int_1.u[2].u, :k_off), [0.0, 0.5126576, 0.5126576, 0.5126576, 0.5126576], atol=tol))

end

@test _check_k_rate_junction(tol)



