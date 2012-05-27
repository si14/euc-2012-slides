library("ggplot2")
library("plyr")

my.theme <- function(base_size = 12){
  modifyList(theme_gray(base_size, base_family="Ubuntu"),
             list(axis.ticks.length = unit(0.1,"line"),
                  plot.background=theme_rect(fill="#3F3F3F"),
                  plot.title=theme_text(colour="#DCDCCC",
                    size=base_size*1.2, face="bold"),
                  legend.text=theme_text(colour="#DCDCCC"),
                  legend.title=theme_text(colour="#DCDCCC",
                    face="bold", hjust=0),
                  legend.background=theme_rect(colour=NA),
                  legend.key=theme_rect(fill="#4F4F4F", colour=NA),
                  axis.title.x=theme_text(colour="#DCDCCC",
                    vjust=0.5, face="bold", size=base_size*1.15),
                  axis.title.y=theme_text(colour="#DCDCCC",
                    vjust=0.5, face="bold", size=base_size*1.15, angle=90),
                  axis.text.x=theme_text(colour="#7F7F7F", size=base_size*0.7),
                  axis.text.y=theme_text(colour="#7F7F7F", size=base_size*0.7),
                  panel.background=theme_rect(fill="#4F4F4F", colour=NA),
                  panel.grid.major=theme_line(colour="#6F6F6F"),
                  panel.grid.minor=theme_line(colour="#5F5F5F"),
                  strip.background=theme_rect(fill="#6F6F6F", colour=NA),
                  strip.text.x=theme_text(colour="#DCDCCC", face="bold",
                    size=base_size*0.85)))
}

my.colours <- c("#7FC97F", "#BEAED4", "#FDC086", "#FFFF99", "#386CB0")

data <- data.frame(test.subject=factor(c(
                     "base", "base", "base",
                     "erlando", "erlando", "erlando",
                     "z_validate", "z_validate", "z_validate")),
                   test=factor(c(
                     "good", "bad early", "bad lately",
                     "good", "bad early", "bad lately",
                     "good", "bad early", "bad lately")),
                   time=c(
                     0.8797,0.31715,0.72506,
                     2.36475,0.40388,1.83395,
                     1.07253,0.41907,0.84424))

plot <- (ggplot(data, aes(x=test.subject))
         + geom_histogram(aes(y=time, fill=test.subject))
         + facet_grid(~ test)
         + opts(axis.title.x=theme_blank(),
                axis.title.y=theme_blank(),
                axis.text.x=theme_blank(),
                axis.text.y=theme_blank(),
                axis.ticks=theme_blank(),
                legend.title=theme_blank(),
                legend.text=theme_text(colour="#000000", size=15),
                strip.text.x=theme_text(colour="#000000", size=13),
                legend.key.size=theme_gray()$legend.key.size * 1.2))

plot
## ggsave(filename="plot.pdf", plot=plot)
