## ----DataManipulation----------------------------------------------------
data <- haven::read_sas("chapter15_example.sas7bdat")

data <- data %>%
  rename_all( ~ str_replace(string = ., pattern=params$endpoint, replacement="outcome")) %>%
  bind_cols(data,.) %>%
  drop_na()


data %>%
  head(10)

