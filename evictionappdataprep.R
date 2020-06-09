
load("/Users/victorhaley/Desktop/evictionapp/evictionapp/myevictiondata10.rda")
setwd("/Users/victorhaley/Desktop/evictionapp/evictionapp/")
# concat and read in long form eviction csvs
fulton <- st_read("/Users/victorhaley/Downloads/Counties_Atlanta_Region-shp/Counties_Atlanta_Region.shp", crs = 4326)
fulton <- fulton[,c("NAME10", "geometry")]
fulton <- fulton %>% filter(NAME10 == "Fulton")

dekalb <- st_read("/Users/victorhaley/Downloads/Counties_Atlanta_Region-shp/Counties_Atlanta_Region.shp", crs = 4326)
dekalb <- dekalb[,c("NAME10", "geometry")]
dekalb <- dekalb %>% filter(NAME10 == "DeKalb")
dekalb = st_cast(dekalb,"LINESTRING")

coa <- st_read("/Users/victorhaley/Downloads/Atlanta_City_Limits/Atlanta_City_Limits.shp", crs = 4326)
coa = st_cast(coa,"LINESTRING")

filenames <- list.files(path="/Users/victorhaley/Desktop/Evictions/2017/Long/", pattern="*.csv")
fullpath <- file.path("/Users/victorhaley/Desktop/Evictions/2017/Long/", filenames)
f2017df <- do.call("rbind",lapply(fullpath,FUN=function(files){ read.csv(files)}))

filenames <- list.files(path="/Users/victorhaley/Desktop/Evictions/2018/Long/", pattern="*.csv")
fullpath <- file.path("/Users/victorhaley/Desktop/Evictions/2018/Long/", filenames)
f2018df <- do.call("rbind",lapply(fullpath,FUN=function(files){ read.csv(files)}))

filenames <- list.files(path="/Users/victorhaley/Desktop/Evictions/2019/Long/", pattern="*.csv")
fullpath <- file.path("/Users/victorhaley/Desktop/Evictions/2019/Long/", filenames)
f2019df <- do.call("rbind",lapply(fullpath,FUN=function(files){ read.csv(files)}))
length(unique(f2019df$Case.ID))
f2019test <- filingsfplot2[filingsfplot2$File.Date >= "2019-01-01" & filingsfplot2$File.Date <= "2019-12-31",]
length(unique(f2019test$Case.ID))

filenames <- list.files(path="/Users/victorhaley/Desktop/Evictions/2020/Long/", pattern="*.csv")
fullpath <- file.path("/Users/victorhaley/Desktop/Evictions/2020/Long/", filenames)
f2020df <- do.call("rbind",lapply(fullpath,FUN=function(files){ read.csv(files)}))
View(f2020df)


# 
filenames <- list.files(path="/Users/victorhaley/Desktop/evictionapp/", pattern="*geocoded.csv")
oct19f <- read.csv("/Users/victorhaley/Desktop/evictionapp/oct19_geocoded.csv")
oct19f$File.Date <- as.Date(oct19f$File.Date, format="%m/%d/%Y")

nov19f <- read.csv("/Users/victorhaley/Desktop/evictionapp/november_geocoded.csv")
nov19f$File.Date <- as.Date(nov19f$File.Date, format="%m/%d/%Y")

dec19f <- read.csv("/Users/victorhaley/Desktop/evictionapp/december_geocoded.csv")
dec19f$File.Date <- as.Date(dec19f$File.Date, format="%m/%d/%Y")

jan20f <- read.csv("/Users/victorhaley/Desktop/evictionapp/february2020_geocoded.csv")
jan20f$File.Date <- as.Date(jan20f$File.Date, format="%m/%d/%Y")

feb20f <- read.csv("/Users/victorhaley/Desktop/evictionapp/january2020_geocoded.csv")
feb20f$File.Date <- as.Date(feb20f$File.Date, format="%m/%d/%Y")

mar20f <- read.csv("/Users/victorhaley/Desktop/evictionapp/march_geocoded.csv")
mar20f$File.Date <- as.Date(mar20f$File.Date, format="%m/%d/%Y")

apr20f <- read.csv("/Users/victorhaley/Desktop/Evictions/2020/Geocoding/apr_geocoded.csv")
apr20f$File.Date <- as.Date(apr20f$File.Date, format="%m/%d/%Y")

may20f <- read.csv("/Users/victorhaley/Desktop/Evictions/2020/Geocoding/may20_geocoded.csv")
may20f$File.Date <- as.Date(may20f$File.Date, format="%m/%d/%Y")

filenames <- list.files(path="/Users/victorhaley/Desktop/Evictions/2017/GIS/", pattern="*.csv")
fullpath <- file.path("/Users/victorhaley/Desktop/Evictions/2017/GIS/", filenames)
e17df <- do.call("rbind",lapply(fullpath,FUN=function(files){ read.csv(files)}))
e17df$File.Date <- as.character(e17df$File.Date)
e17df <- e17df[,c(1,2,14,15)]
e17df$File.Date <- sapply(e17df[,1], function(i) if (substr(i, nchar(i) - 3, nchar(i))!="2017")
  paste0(substr(i, 1, sapply(gregexpr("/", i), "[", 2)),"2017")
  else i)
e17df$File.Date <- as.Date(e17df$File.Date, format="%m/%d/%Y")
View(e17df)

filenames <- list.files(path="/Users/victorhaley/Desktop/Evictions/2018/Merge/", pattern="*_geocoded.csv")
fullpath <- file.path("/Users/victorhaley/Desktop/Evictions/2018/Merge/", filenames)
e18df <- do.call("rbind",lapply(fullpath,FUN=function(files){ read.csv(files)}))
e18df <- e18df[,c(1,2,14,15)]
e18df$File.Date <- as.character(e18df$File.Date)
e18df$File.Date <- sapply(e18df[,1], function(i) if (substr(i, nchar(i) - 3, nchar(i))!="2018")
  paste0(substr(i, 1, sapply(gregexpr("/", i), "[", 2)),"2018")
  else i)
e18df$File.Date <- as.Date(e18df$File.Date, format="%m/%d/%Y")
View(e18df)

filenames <- list.files(path="/Users/victorhaley/Desktop/Evictions/2019/Geocoding/", pattern="*_geocoded.csv")
fullpath <- file.path("/Users/victorhaley/Desktop/Evictions/2019/Geocoding/", filenames)
e19df <- do.call("rbind",lapply(fullpath,FUN=function(files){ read.csv(files)}))
e19df <- e19df[,c(1,2,14,15)]
e19df$File.Date <- as.character(e19df$File.Date)
e19df$File.Date <- sapply(e19df[,1], function(i) if (substr(i, nchar(i) - 3, nchar(i))!="2019")
  paste0(substr(i, 1, sapply(gregexpr("/", i), "[", 2)),"2019")
  else i)
e19df$File.Date <- as.Date(e19df$File.Date, format="%m/%d/%Y")
View(e19df)
# 
filenames <- list.files(path="/Users/victorhaley/Desktop/Evictions/2020/Geocoding/", pattern="*geocoded.csv")
fullpath <- file.path("/Users/victorhaley/Desktop/Evictions/2020/Geocoding/", filenames)
e20df <- do.call("rbind",lapply(fullpath,FUN=function(files){ read.csv(files)}))
e20df <- e20df[,c(1,2,14,15)]
e20df$File.Date <- as.character(e20df$File.Date)
e20df$File.Date <- sapply(e20df[,1], function(i) if (substr(i, nchar(i) - 3, nchar(i))!="2020")
  paste0(substr(i, 1, sapply(gregexpr("/", i), "[", 2)),"2020")
  else i)
e20df$File.Date <- as.Date(e20df$File.Date, format="%m/%d/%Y")
View(e20df)

filingsdf <- rbind(e17df, e18df)
filingsdf <- rbind(filingsdf, e19df)
filingsdf <- rbind(filingsdf, e20df)
filingsdf <- filingsdf[!is.na(filingsdf$lon),]
filingsdf <- st_as_sf(filingsdf, coords=c("lon", "lat"), crs = 4326)
# 
# filenames <- list.files(path="/Users/victorhaley/Desktop/Evictions/Judgments/", pattern="*.csv")
# fullpath <- file.path("/Users/victorhaley/Desktop/Evictions/Judgments/", filenames)
# jdf <- do.call("rbind",lapply(fullpath,FUN=function(files){ read.csv(files)}))
# View(jdf)
# jdf <- jdf[,c(1,2)]
# # nov19mar20df <- nov19mar20df[,c(1,2,14,15)]
# # nov19mar20df <- nov19mar20df[!is.na(nov19mar20df$lon),]
# # nov19mar20df <- st_as_sf(nov19mar20df, coords=c("lon", "lat"), crs = 4326)
# # 
# oct19 <- read.csv("/Users/victorhaley/Desktop/evictionapp/October19finaljudgments.csv")
# oct19 <- oct19[,c(1,2)]
# nov19 <- read.csv("/Users/victorhaley/Desktop/evictionapp/November19finaljudgments.csv")
# nov19 <- nov19[,c(1,2)]
# dec19 <- read.csv("/Users/victorhaley/Desktop/evictionapp/December19finaljudgments.csv")
# dec19 <- dec19[,c(1,2)]
# jan20 <- read.csv("/Users/victorhaley/Desktop/evictionapp/January20finaljudgments.csv")
# jan20 <- jan20[,c(1,2)]
# feb20 <- read.csv("/Users/victorhaley/Desktop/evictionapp/February20finaljudgments.csv")
# feb20 <- feb20[,c(1,2)]
# mar20 <- read.csv("/Users/victorhaley/Desktop/evictionapp/March20finaljudgments.csv")
# mar20 <- mar20[,c(1,2)]
# 
# jdf <- rbind(jdf, oct19)
# jdf <- rbind(jdf, nov19)
# jdf <- rbind(jdf, dec19)
# jdf <- rbind(jdf, jan20)
# jdf <- rbind(jdf, feb20)
# jdf <- rbind(jdf, mar20)
# str(jdf)
# jdf$Case.ID <- as.character(jdf$Case.ID)
# 
# jcases <- unique(jdf$Case.ID)
# judgmentsfplot2 <- filingsdf[filingsdf$Case.ID %in% jcases,]
# View(judgmentsfplot2)
# nov19mar20df <- rbind(oct19f, nov19f)
# nov19mar20df <- rbind(nov19mar20df, dec19f)
# nov19mar20df <- rbind(nov19mar20df, jan20f)
# nov19mar20df <- rbind(nov19mar20df, feb20f)
# nov19mar20df <- rbind(nov19mar20df, mar20f)
# nov19mar20df <- nov19mar20df[nov19mar20df$Case.ID!="14CR013579",]
# nov19mar20df <- nov19mar20df[nov19mar20df$Case.ID!="18CR007243G",]
# nov19mar20df <- nov19mar20df[,c(1,2,14,15)]

# nov19mar20judgmentsdf <- rbind(oct19, nov19)
# nov19mar20judgmentsdf <- rbind(nov19mar20judgmentsdf, dec19)
# nov19mar20judgmentsdf <- rbind(nov19mar20judgmentsdf, jan20)
# nov19mar20judgmentsdf <- rbind(nov19mar20judgmentsdf, feb20)
# nov19mar20judgmentsdf <- rbind(nov19mar20judgmentsdf, mar20)
# nov19mar20judgmentsdf <- nov19mar20judgmentsdf[,c(1,2)]
# nov19mar20judgmentsdf$File.Date <- as.Date(nov19mar20judgmentsdf$File.Date, format="%m/%d/%Y")
# View(nov19mar20judgmentsdf)
# nov19mar20cases <- unique(nov19mar20judgmentsdf$Case.ID)
# nov19mar20judgmentsdf <- filingsfplot2[filingsfplot2$Case.ID %in% nov19mar20cases,]
# 
# # nov19mar20df <- nov19mar20df[nov19mar20df$lon <= -85.0 & nov19mar20df$lon >= -84.0,]
# # nov19mar20df <- nov19mar20df[nov19mar20df$lat <= 34.2 & nov19mar20df$lat >= 33.5,]
# # nov19mar20dfgeom <- st_geometry(nov19mar20dfgeom)
# 
# nov19mar20df$File.Date <- as.Date(nov19mar20df$File.Date, format="%m/%d/%Y")
# View(nov19mar20df)

evictintersect <- st_intersection(fulton, filingsdf)
ent <- st_join(filingsdf, fulton, join = st_contains)
View(ent)
str(evictintersect)
View(evictintersect)
filingintersect <- st_intersection(fulton, filingsfplot)
str(filingintersect)
evictintersect$Case.ID <- as.character(evictintersect$Case.ID)
evictintersect2 <- evictintersect %>% distinct(File.Date, Case.ID, .keep_all = TRUE)
judgmentintersect <- st_intersection(fulton, judgmentsfplot2)
str(judgmentintersect)
judgmentintersect2 <- st_intersection(fulton, nov19mar20judgmentsdf)
plot(st_geometry(nov19mar20df), add = TRUE)
plot(st_geometry(fulton))
plot(st_geometry(evictintersect2), add = TRUE)
# 
View(evictintersect2)
evictintersect <- evictintersect2[,c(2,3,4)]
filingintersect <- filingintersect[,c(2,3,4)]
judgmentintersect <- judgmentintersect[,c(2,3,4)]
judgmentintersect2 <- judgmentintersect2[,c(2,3,4)]
# 
filingsfplot2 <- evictintersect
judgmentsfplot2 <- judgmentintersect
save(filingsfplot2, judgmentsfplot2, file = "myevictiondata5.rda")
filingsfplot2 <- rbind(filingintersect, evictintersect)
View(filingsfplot3)
dup <- filingsfplot2[duplicated(filingsfplot2$Case.ID), ]
filingsfplot2 <- filingsfplot2 %>% distinct(Case.ID, .keep_all = TRUE)
View(filingsfplot2)
write.csv(filingsfplot2, "test.csv", row.names=FALSE)
filingsfplot2 <- str(filingsfplot2[!duplicated(filingsfplot2$Case.ID), ])
f2019test <- filingsfplot2[filingsfplot2$File.Date >= "2019-01-01" & filingsfplot2$File.Date <= "2019-12-31",]
testdf <- read.csv("/Users/victorhaley/Downloads/filings2019-01-012019-12-31.csv")
judgmentsfplot2[judgmentsfplot2$File.Date>="2018-07-01" & judgmentsfplot2$File.Date<="2018-07-31",]

july18df <- read.csv("/Users/victorhaley/Desktop/Evictions/2018Merge/july_geocoded.csv")
july18df <- july18df[!is.na(july18df$lon),]
july18df <- st_as_sf(july18df, coords=c("lon", "lat"), crs = 4326)
july18jdf <- read.csv("/Users/victorhaley/Desktop/Evictions/Judgments/July18finaljudgments.csv")
july18jdf$Case.ID <- as.character(july18jdf$Case.ID)
july18df$Case.ID <- as.character(july18df$Case.ID)
jul18jcids <- july18jdf$Case.ID
july18jdf <- filter(july18df, (Case.ID %in% jul18jcids))

july18df$File.Date <- as.character(july18df$File.Date)
july18df$File.Date <- sapply(july18df[,1], function(i) if (substr(i, nchar(i) - 3, nchar(i))!="2018")
  paste0(substr(i, 1, sapply(gregexpr("/", i), "[", 2)),"2018")
  else i)
july18df$File.Date <- as.Date(july18df$File.Date, format="%m/%d/%Y")

july18jdf$File.Date <- as.character(july18jdf$File.Date)
july18jdf$File.Date <- sapply(july18jdf[,1], function(i) if (substr(i, nchar(i) - 3, nchar(i))!="2018")
  paste0(substr(i, 1, sapply(gregexpr("/", i), "[", 2)),"2018")
  else i)
july18jdf$File.Date <- as.Date(july18jdf$File.Date, format="%m/%d/%Y")

july18df <- st_intersection(fulton, july18df)
july18jdf <- st_intersection(fulton, july18jdf)
colnames(july18df)
colnames(july18jdf)
colnames(filingsfplot2)
july18df <- july18df[,c(2,3,15)]
View(july18jdf)
july18jdf <- july18jdf[,c(2,3,15)]
filingsfplot2 <- rbind(filingsfplot2, july18df)
judgmentsfplot2 <- judgmentsfplot2[,c(2:4)]
judgmentsfplot2 <- rbind(judgmentsfplot2, july18df)
filingsfplot2 <- filingsfplot2 %>% distinct(Case.ID, .keep_all = TRUE)
judgmentsfplot2 <- judgmentsfplot2 %>% distinct(Case.ID, .keep_all = TRUE)
july18long <- read.csv("/Users/victorhaley/Desktop/Evictions/2018/Long/July.csv")
str(july18long)
july18long$File.Date <- as.character(july18long$File.Date)
july18long$File.Date <- sapply(july18long[,1], function(i) if (substr(i, nchar(i) - 3, nchar(i))!="2018")
  paste0(substr(i, 1, sapply(gregexpr("/", i), "[", 2)),"2018")
  else i)
july18long$File.Date <- as.Date(july18long$File.Date, format="%m/%d/%Y")
july18long$Case.ID <- as.character(july18long$Case.ID)
str(filingsflongplot2)
july18long <- july18long[,-c(15)]
filingsflongplot2 <- rbind(filingsflongplot2, july18long)
filingsflongplot2 <- distinct(filingsflongplot2)
save(filingsflongplot2, filingsfplot2, judgmentsfplot2, fultonlines, file = "/Users/victorhaley/Desktop/evictionapp/evictionapp/myevictiondata10.rda")
filingsfplot2[filingsfplot2$File.Date >= "2017-01-01" & filingsfplot2$File.Date <= "2017-12-31",]
length(unique(testdf$Case.ID))
load(file = "/Users/victorhaley/Desktop/evictionapp/evictionapp/myevictiondata8.rda")
remove(filingsflongplot2)
# 
judgmentsfplot2 <- rbind(judgmentintersect, judgmentintersect2)
judgmentsfplot2 <- judgmentsfplot2[!duplicated(judgmentsfplot2$Case.ID), ]
# 
save(judgmentsfplot2, filingsfplot2, file = "myevictiondata5.rda")
# 
# oct19long <- read.csv("/Users/victorhaley/Desktop/evictionapp/October.csv")
# nov19long <- read.csv("/Users/victorhaley/Desktop/evictionapp/November.csv")
# dec19long <- read.csv("/Users/victorhaley/Desktop/evictionapp/December.csv")
# jan20long <- read.csv("/Users/victorhaley/Desktop/evictionapp/January.csv")
# feb20long <- read.csv("/Users/victorhaley/Desktop/evictionapp/February.csv")
mar20long <- read.csv("/Users/victorhaley/Desktop/Evictions/2020/Long/March.csv")
apr20long <- read.csv("/Users/victorhaley/Desktop/Evictions/2020/Long/April.csv")

# nov19mar20longdf <- rbind(oct19long, nov19long)
# nov19mar20longdf <- rbind(nov19mar20longdf, dec19long)
# nov19mar20longdf <- rbind(nov19mar20longdf, jan20long)
# nov19mar20longdf<- rbind(nov19mar20longdf, feb20long)
# nov19mar20longdf <- rbind(nov19mar20longdf, mar20long)
nov19mar20longdf <- nov19mar20longdf[,c(1:14)]
mar20apr20longdf <- rbind(mar20long, apr20long)
mar20apr20longdf <- mar20apr20longdf[,c(1:14)]
f2020df <- f2020df[,c(1:14)]
filingsflongplot2 <- filingsflongplot[,c(1:14)]
filingsflongplot2 <- rbind(filingsflongplot2, mar20apr20longdf)
filingsflongplot2 <- rbind(filingsflongplot2, f2020df)
filingsflongplot3 <- filingsflongplot2 %>% distinct()
filingsflongplot2 <- filingsflongplot3
save(filingsflongplot2, file = "myevictiondata6.rda")

save(filingsflongplot2, filingsfplot2, judgmentsfplot2, fultonlines, file = "/Users/victorhaley/Desktop/evictionapp/evictionapp/myevictiondata11.rda")

write.csv(filingsflongplot2, "/Users/victorhaley/Desktop/Evictions/Full/longform/FultonEvictions.csv", row.names=FALSE)#geo <- sf_geojson(filingsfplot)
# str(filingsflongplot)
save(filingsflongplot2, filingsfplot2, judgmentsfplot2, fultonlines, file = "/Users/victorhaley/Desktop/evictionapp/evictionapp/myevictiondata8.rda")
load(file = "/Users/victorhaley/Desktop/evictionapp/evictionapp/myevictiondata8.rda")
str(filingsfplot2)
log <- filingsfplot2[filingsfplot2$File.Date>="2020-01-01" & filingsfplot2$File.Date<="2020-04-14",]
log2 <- filingsfplot2[filingsfplot2$File.Date>="2020-03-27" & filingsfplot2$File.Date<="2020-04-14",]
# create variables of the week and month of each observation:
log$Month <- as.Date(cut(log$File.Date,
                         breaks = "month"))
log$Day <- as.Date(cut(log$File.Date,
                         breaks = "day"))
log$Week <- as.Date(cut(log$File.Date,
                        breaks = "week",
                        start.on.monday = TRUE))
log2$Week <- as.Date(cut(log2$File.Date,
                        breaks = "week",
                        start.on.monday = TRUE))

  
  # graph by week:
fig <- ggplot(data = log,
         aes(x = File.Date, y = nrow(log))) +
    stat_summary(fun.y = sum, # adds up all observations for the week
                 geom = "line") + # or "bar"
    scale_x_date(
      labels = date_format("%Y-%m-%d"))
fig





s <- schema()
agg <- s$transforms$aggregate$attributes$aggregations$items$aggregation$func$values


log$count <- 1
log <- arrange(log, File.Date)

fig <- log %>% plot_ly(
  mode = 'lines',
  x =~File.Date,
  y =~count,
  line = list(color = 'blue',
              width = 4),
  transforms = list(
    list(
      type = 'aggregate',
      groups = log$File.Date,
      aggregations = list(
        list(
          target = 'y', func = 'sum', enabled = TRUE)
      )
    )
  )
)

fig

fig <- fig %>% layout(
  title = '<b>Eviction Filings</b><br>use dropdown to change timeline',
  xaxis = list(title = 'File Date'),
  yaxis = list(title = 'Eviction Filings'),
  updatemenus = list(
  list(
    y = 0.7,
    buttons = list(
      list(method = "restyle",
           args = list("x", list(log$File.Date)),  # put it in a list
           label = "Daily"),
      list(method = "restyle",
           args = list("x", list(log$Week)),  # put it in a list
           label = "Weekly"),
      list(method = "restyle",
       args = list("x", list(log$Month)),  # put it in a list
       label = "Monthly")
      )
    )
  )
)

fig

library(plotly)

week <- 604800000
day <- week / 4


df <- read.csv("https://plotly.com/~public.health/17.csv", skipNul = TRUE, encoding = "UTF-8")
View(df)

labels <- function(size, label) {
  list(
    args = c("xbins.size", size), 
    label = label, 
    method = "restyle"
  )
}

add_vline = function(p, x) {
  l_shape = list(
    type = "line", 
    y0 = 0, 
    y1 = 1, 
    yref = "paper", # i.e. y as a proportion of visible region
    x0 = x, 
    x1 = x, 
    line = list(dash="dot", color = "green"))
  callout = list(yref = 'paper', 
                 xref = "x", 
                 y = 0.85, x = x, 
                 text = "3/27/2020 - CARES Act Passed", 
                 showarrow=FALSE)
  p %>% layout(shapes=list(l_shape), annotations = list(callout))
}


fig

fig <- log %>%
  plot_ly(
    x = ~File.Date,
    autobinx = FALSE, 
    autobiny = TRUE, 
    marker = list(color = "rgb(68, 68, 68)"), 
    name = "date", 
    type = "histogram", 
    xbins = list(
      end = "2020-4-14", 
      size = "D1", 
      start = "2020-01-01"
    )
  )
fig <- fig %>% layout(
  paper_bgcolor = "rgb(240, 240, 240)", 
  plot_bgcolor = "rgb(240, 240, 240)", 
  title = "<b>Eviction Filings</b><br>use dropdown to change bin size",
  xaxis = list(
    type = 'date',
    title = "File Date"
  ),
  yaxis = list(
    title = "Eviction Filings"
  ),
  updatemenus = list(
    list(
      x = 0.1, 
      y = 1.15,
      active = 0, 
      showactive = TRUE,
      buttons = list(
        labels("D1", "Day"),
        labels(week, "Week"),
        labels("M1", "Month")
      )
    )
  )
)
fig <- add_vline(fig, "2020-03-27")
fig



