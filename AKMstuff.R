# devtools::install_github("tlamadon/rblm")
pacman::p_load(rblm)

CJ.dt = function(X,Y) {
  stopifnot(is.data.table(X),is.data.table(Y))
  k = NULL
  X = X[, c(k = 1, .SD)]
  setkey(X, k)
  Y = Y[, c(k = 1, .SD)]
  setkey(Y, NULL)
  X[Y, allow.cartesian = TRUE][, k := NULL][]
}

n_firms = 2
n_workers = 2
n_periods = 2
firms = data.table(firm = 1:n_firms, firm_effect = c(-3, 3))
workers = data.table(worker = 1:n_workers, worker_effect = c(-35.5, 35.5))
time = data.table(t = 1:n_periods, time_effect = c(0, 0))
test = CJ.dt(CJ.dt(firms, workers), time)

constant = 50.5

test[firm == 1 & worker == 1, match_effect := -2]
test[firm == 2 & worker == 1, match_effect := 2]
test[firm == 1 & worker == 2, match_effect := 2]
test[firm == 2 & worker == 2, match_effect := -2]

test[, wage := constant + firm_effect + worker_effect + time_effect + match_effect]




model = m2.mini.new(10,serial = F,fixb=T)

# we set the parameters to something simple
model$A1 = seq(0,2,l=model$nf) # setting increasing intercepts
model$B1 = seq(1,2,l=model$nf) # adding complementarity (increasing interactions)
model$Em = seq(0,1,l=model$nf) # adding sorting (mean type of workers is increasing in k)

# we make the model stationary (same in both periods)
model$A2 = model$A1
model$B2 = model$B1

# setting the number of movers and stayers
model$Ns   = array(300000/model$nf,model$nf)
model$Nm   = 10*toeplitz(ceiling(seq(100,10,l=model$nf)))

# creating a simulated data set
ad =  m2.mini.simulate(model)

ms    = grouping.getMeasures(ad,"ecdf",Nw=20,y_var = "y1")
grps  = grouping.classify.once(ms,k = 10,nstart = 1000,iter.max = 200,step=250)
ad   = grouping.append(ad,grps$best_cluster,drop=T)

res = m2.mini.estimate(ad$jdata,ad$sdata,model0 = model,method = "fixb")

results_table = data.table(j1true = 1:10, A1hat = res$A1, B1hat = res$B1, eps1SDhat = res$eps1_sd, avg_worker_effecthat = res$Em, avg_worker_effectSDhat = res$Esd)
model_table = data.table(j1true = 1:10, A1true = model$A1, B1true = model$B1)

jdata_table = ad$jdata

jdata_table[results_table, on = .(j1true), `:=`(A1hat = A1hat, B1hat = B1hat, eps1SDhat = eps1SDhat, avg_worker_effecthat = avg_worker_effecthat, avg_worker_effectSDhat = avg_worker_effectSDhat)]
jdata_table[model_table, on = .(j1true), `:=`(A1true = A1hat, B1true = B1hat)]

# I think everything EE incl. EEsd is about movers: movers can have a different
# mean and a different SD

jdata_table[, alphahat := avg_worker_effecthat + rnorm(.N, sd = avg_worker_effectSDhat)]

jdata_table[, predicted_y_if_alpha_known := A1hat + B1hat * alpha + rnorm(.N, sd = eps1SDhat)]
jdata_table[, predicted_y := A1hat + B1hat * alphahat]
jdata_table[, true_y := A1true + B1true * alpha + e1]

