install.packages("dplyr")
library(dplyr)

df <- read.csv("https://raw.githubusercontent.com/MI2-Education/2023Z-DataVisualizationTechniques/main/homeworks/hw1/house_data.csv")

colnames(df)
dim(df)
apply(df, 2, function(x) sum(is.na(x))) # nie ma warto�ci NA w �adnej kolumnie



# 1. Jaka jest �rednia cena nieruchomo�ci z liczb� �azienek powy�ej mediany i po�o�onych na wsch�d od po�udnika 122W?
odp1 <- df %>%
  select(price, bathrooms, long) %>%
  filter(long > -122 & bathrooms > median(bathrooms)) %>%
  summarise(mean_price = mean(price))

# Odp: 
  print(paste("Srednia cena wybranych nieruchomosci to", round(odp1, 2), "USD"))
  
  
  
  
# 2. W kt�rym roku zbudowano najwi�cej nieruchomo�ci?
odp2 <- df %>%
  mutate(dateY = substr(df$date, 0, 4)) %>%
  count(dateY) %>%
  top_n(1, n) %>% 
  select(dateY)

# Odp:
  print(paste("Najwiecej nieruchomosci zbudowano w", odp2, "roku"))

  
  
  
# 3. O ile procent wi�ksza jest mediana ceny budynk�w po�o�onych nad wod� w por�wnaniu z tymi po�o�onymi nie nad wod�?
median_water <- median(pull(df %>%
                              filter(waterfront == 1) %>%
                              select(price), price))
median_land <- median(pull(df %>%
                             filter(waterfront == 0) %>%
                             select(price), price))
odp3 <- median_water/median_land*100-100

# Odp:
  print(paste("O", round(odp3, 2), "%"))
  
  
  
  
# 4. Jaka jest �rednia powierzchnia wn�trza mieszkania dla najta�szych nieruchomo�ci posiadaj�cych 1 pi�tro (tylko parter) wybudowanych w ka�dym roku?
odp4 <- df %>%
  arrange(price) %>%
  select(sqft_living, floors) %>%
  filter(floors == 1) %>%
  head(25) %>%
  summarize(mean = mean(sqft_living))

# Odp:
  print(paste(odp4, "stop kwadratowych"))

  
  

# 5. Czy jest r�nica w warto�ci pierwszego i trzeciego kwartyla jako�ci wyko�czenia pomieszcze� pomi�dzy nieruchomo�ciami z jedn� i dwoma �azienkami? Je�li tak, to jak r�ni si� Q1, a jak Q3 dla tych typ�w nieruchomo�ci?
odp5 <- df %>%
  filter(bathrooms %in% c(1, 2)) %>%
  select(grade) %>%
  summary()

# Odp:
  odp5
  cat("Jak widac dla tych typow mieszkan pierwszy kwartyl jest rowny 6, a drugi 7. Kwartyle roznia sie jedynie o jeden stopien")
  
  
  
  
# 6. Jaki jest odst�p mi�dzykwartylowy ceny mieszka� po�o�onych na p�nocy a jaki tych na po�udniu? (P�noc i po�udnie definiujemy jako po�o�enie odpowiednio powy�ej i poni�ej punktu znajduj�cego si� w po�owie mi�dzy najmniejsz� i najwi�ksz� szeroko�ci� geograficzn� w zbiorze danych)
latitudeV <- df %>%
  arrange(lat) %>%
  select(lat)
#Dany punkt z tresci zadania
mid_lat <- (head(latitudeV, 1)$lat+tail(latitudeV, 1)$lat)/2
#Nasze "summary"
summaryN <- df %>%
  filter(lat > mid_lat) %>%
  select(price) %>%
  summary()
summaryS <- df %>%
  filter(lat < mid_lat) %>%
  select(price) %>%
  summary()
#Funkcja wyliczajaca rozstep miedzykwartylowy
interquartile_range6 <- function(summary) {
  return(strtoi(substr(summary[5,], 10, 15))-strtoi(substr(summary[2,], 10, 15)))
}

# Odp:
  print(paste("Rozstep miedzykwartylowy cen mieszkan na polnocy jest rowny:", interquartile_range6(summaryN), ", a tych na poludniu:", interquartile_range6(summaryS)))










# 7. Jaka liczba �azienek wyst�puje najcz�ciej i najrzadziej w nieruchomo�ciach niepo�o�onych nad wod�, kt�rych powierzchnia wewn�trzna na kondygnacj� nie przekracza 1800 sqft?
bath_counter <- (df %>%
  filter(waterfront == 0, (sqft_living/floors) <= 1800) %>% 
  select(bathrooms) %>%
  count(bathrooms) %>%
  arrange(n))$bathrooms

# Odp:
  print(paste("Najczesciej wystepuje", tail(bath_counter, 1), ", a najrzadziej", head(bath_counter, 1)))



  
# 8. Znajd� kody pocztowe, w kt�rych znajduje si� ponad 550 nieruchomo�ci. Dla ka�dego z nich podaj odchylenie standardowe powierzchni dzia�ki oraz najpopularniejsz� liczb� �azienek
zipcodes <- pull(df %>%
  select(zipcode) %>%
  count(zipcode) %>%
  filter(n > 550), zipcode)
#funkcja wyliczjaca odchylenie standardowe powierzchni dzialki dla danego zipcode
zipSD <- function(zip_code) {
  sd <- (df %>%
           filter(zipcode == zip_code) %>%
           summarise(SD = sd(sqft_lot))
      )$SD
  return(round(sd,2))
}
#funkcja wyliczjaca najpopularniejsza liczbe lazienek dla danego zipcode
zipbath <- function(zip_code, dataframe) {
  Pbathrooms <- ((df %>%
                    filter(zipcode == zip_code) %>%
                    count(bathrooms) %>%
                    arrange(-n))$bathrooms %>%
                   head(1))
  return(Pbathrooms)
}
odp8 <- data_frame(ZipCode = zipcodes,
                   sd_sqft_lot = sapply(zipcodes, zipSD),
                   preferable_bath = sapply(zipcodes, zipbath))

# Odp:
  odp8
  
  
  

# 9. Por�wnaj �redni� oraz median� ceny nieruchomo�ci, kt�rych powierzchnia mieszkalna znajduje si� w przedzia�ach (0, 2000], (2000,4000] oraz (4000, +Inf) sqft, nieznajduj�cych si� przy wodzie.
price_area <- df %>%
  filter(waterfront == 0) %>%
  select(price, sqft_living)
#zmienna (0, 2000]
price_area_02000 <- filter(price_area, sqft_living>0 & sqft_living <= 2000) %>%
  summarise(mean = mean(price), median = median(price))
#zmienna (2000, 4000]
price_area_20004000 <- filter(price_area, sqft_living>2000 & sqft_living <= 4000) %>%
  summarise(mean = mean(price), median = median(price))
#zmienna (4000, +Inf)
price_area_4000 <- filter(price_area, sqft_living>4000) %>%
  summarise(mean = mean(price), median = median(price))

# Odp:
  cat("Porownanie (0, 2000]")
  price_area_02000
  cat("Porownanie (2000, 4000]")
  price_area_20004000
  cat("Porownanie (4000, +Inf)")
  price_area_4000


  
  
# 10. Jaka jest najmniejsza cena za metr kwadratowy nieruchomo�ci? (bierzemy pod uwag� tylko powierzchni� wewn�trz mieszkania)
odp10 <- df %>%
  #stala 0.09290304 to zaleznosc miedzy m2 i ft2, pobrana z google
  mutate(USD_m2 = price/(0.09290304*sqft_living)) %>%
  arrange(USD_m2) %>%
  select(USD_m2) %>%
  head(1)

# Odp:
  print(paste("Najmniejsza cena za m2 to", round(odp10, 2), "USD"))
  
  