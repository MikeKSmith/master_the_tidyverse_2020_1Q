ggplot(data = mtcars,
       mapping = aes(x = displ, y = hyw)) +
  geom_point(aes(colour = "class"))