ggplot(data = data,
       mapping = aes(x = RELDAYS, y = HAMDTL17)) +
  geom_point(aes(colour = "THERAPY1"))