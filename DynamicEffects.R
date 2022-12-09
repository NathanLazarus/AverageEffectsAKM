# devtools::install_github("tlamadon/rblm")
pacman::p_load(rblm, data.table, foreach, doSNOW, ggplot2, viridis)

set.seed(10)

CJ.dt = function(X,Y) {
  stopifnot(is.data.table(X),is.data.table(Y))
  k = NULL
  X = X[, c(k = 1, .SD)]
  setkey(X, k)
  Y = Y[, c(k = 1, .SD)]
  setkey(Y, NULL)
  X[Y, allow.cartesian = TRUE][, k := NULL][]
}

n_firms = 3
n_workers = 10000
n_periods = 9
age_range = c(25, 54)
max_experience = 10
firms = data.table(firm = 1:n_firms
                 )[, firm_effect := -1.5 * (firm == 2) - 10 * (firm == 3)
                 ][, firm_experience_effect := 1/2 * (firm - 1)
                 ][, firm_age_effect := 0 # n_firms - sqrt(firm)
                 ][, firm_experience_exponent := 1 + (firm == n_firms)]
workers = data.table(worker = 1:n_workers, worker_effect = c(-35.5, 35.5)
                   )[, start_age := sample(age_range[1]:age_range[2], .N, replace = TRUE)]
time = data.table(t = 1:n_periods, time_effect = c(0, 0))
# test = CJ.dt(CJ.dt(firms, workers), time)

# experience_earnings_profiles = CJ.dt(data.table(experience = 1:max_experience), firms)
# experience_earnings_profiles[firm == 1, firm_experience_effect := 0
#                            ][firm == 2, firm_experience_effect := experience
#                            ][firm == 3, firm_experience_effect := 2 * experience]

match_effects = CJ.dt(firms, workers)
match_effects[firm < n_firms & worker < n_workers, match_effect = runif(.N, -1, 1)]
match_effects[, worker_total := sum(match_effect, na.rm = TRUE), worker]
match_effects[, firm_total := sum(match_effect, na.rm = TRUE), firm]
match_effects[firm == n_firms, ] # The last guy has way higher variance

match_effects = CJ.dt(firms, workers)
match_effects[, match_effect := runif(.N, -1, 1)]
match_effects[, worker_mean := mean(match_effect), worker]
match_effects[, firm_mean := mean(match_effect), firm]
match_effects[, match_effect := match_effect - worker_mean - firm_mean + mean(match_effect)] # Note that these are mean 0 only in a balanced panel

create_simmed_matches = function() {

  dt_out = CJ.dt(time, workers)[, age := start_age + (t - 1)]

  dt_out[, new_firm := sample(firms$firm, .N, replace = TRUE) # sample(c(1, 2, 3, 3), .N, replace = TRUE) to mess with the sizes
     ][, transition := sample(c(0, 0, 0, 0, 0, 1), .N, replace = TRUE)
     ][t == 1, transition := 1
     ][transition == 1, actual_firm := new_firm]

  dt_out[, actual_firm := actual_firm[1], .(cumsum(!is.na(actual_firm)))]
  dt_out[, spell := rleid(actual_firm), worker]
  dt_out[, experience := 1:.N, .(spell, worker)]

  observed_max_experience = max(dt_out$experience)

  while (observed_max_experience > max_experience) {

    dt_out[experience == max_experience + 1, new_firm := sample(1:(n_firms - 1), .N, replace = TRUE)
       ][experience == max_experience + 1 & new_firm == actual_firm, new_firm := n_firms # shifts the probability from the existing firm to the last firm
       ][experience == max_experience + 1, transition := 1
       ][experience > max_experience + 1, `:=`(actual_firm = NA, transition = 0)
       ][transition == 1, actual_firm := new_firm
       ][, actual_firm := actual_firm[1], .(cumsum(!is.na(actual_firm)))
       ][, spell := rleid(actual_firm), worker
       ][, experience := 1:.N, .(spell, worker)]

    observed_max_experience = max(dt_out$experience)

  }

  dt_out

}

test = create_simmed_matches()


add_wages = function(dt) {
  dt[, firm := actual_firm]

  dt[firms,
       on = .(firm),
       `:=`(firm_effect = i.firm_effect,
            firm_age_effect = i.firm_age_effect,
            firm_experience_effect = i.firm_experience_effect,
            firm_experience_exponent = i.firm_experience_exponent)]

  dt[, eps := rnorm(.N, sd = 0.001)]
  dt[, wage := firm_effect + firm_experience_effect * experience ^ firm_experience_exponent + eps]
}

add_wages(test)


clusters=makeCluster(7)
registerDoSNOW(clusters)

counterfactuals = foreach(imputation_dataset = 1:200, .combine = rbind) %dopar% {
  add_wages(create_simmed_matches())[, imputation_dataset := imputation_dataset]
}

stopCluster(clusters)

worker_Y0s = counterfactuals[, .(worker_Y0 = mean(wage)), .(worker, t)]
firm_Y0s = counterfactuals[, .(firm_Y0 = mean(wage)), .(firm, t)]


test[, Y1 := wage]
test[firm_Y0s, on = .(firm, t), firm_Y0 := i.firm_Y0]
test[worker_Y0s, on = .(worker, t), worker_Y0 := i.worker_Y0]
firm_ATT_ests = test[, .(firm_ATT = mean(Y1 - worker_Y0)), firm]
test[, .(worker_ATT = mean(Y1 - firm_Y0)), worker]


firm_relative_ATTs = firm_ATT_ests[firm != 1, .(firm = firm, firm_ATT = firm_ATT - firm_ATT_ests[firm == 1, firm_ATT])]
setkey(firm_relative_ATTs, firm)[]

twfe = feols(wage ~ factor(firm) | t + worker, test)
twfe



unique_by_workers_and_firms = unique(test, by = c("worker", "firm"))
unique_by_workers_and_firms[, n_firms := .N, worker]
stayers = unique_by_workers_and_firms[n_firms == 1][, stayer := 1]

test[stayers, on = .(worker), stayer := i.stayer]
average_profile = test[, .(wage = mean(wage)), .(firm, t)]

setkey(average_profile, firm, t)

average_profile[, Firm := factor(firm)]

ggplot(average_profile) +
  geom_line(aes(x = t, y = wage, color = Firm), size = 0.9) +
  scale_colour_viridis(discrete = TRUE, direction = -1, end = 0.7, option = "inferno") +
  theme_cowplot() +
  xlab("Experience") +
  theme(
    axis.title.y = element_blank(),
    plot.title = element_text(hjust = 0)
  ) +
  ggtitle("Wage") +
  scale_x_continuous(breaks = 1:9, expand = expansion(add = c(0, 0)))

ggsave("DynamicWages.pdf")

