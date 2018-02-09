#### AULA 2b: Análise exploratória de dados

cat("\014") # Limpa a console
rm(list = ls()) # Limpa o global environment

# load("C:/Users/epaf/Desktop/Códigos Livro R/zmPDSwR-master/Custdata/exampleData.rData") # carrega o dataframe
custdata <- read.table('C:/Users/epaf/Desktop/Códigos Livro R/zmPDSwR-master/Custdata/custdata.tsv',header = T,sep = '\t') # carrega o arquivo

summary(custdata) # dá uma olhada nos dados
summary(custdata$income)

library(ggplot2) # carrega a biblioteca ggplot2
# binwidth define o intervalo dos bins e fill a cor das barras do histograma
ggplot(custdata) + 
  geom_histogram(aes(x=age),
                 binwidth=5, fill="gray")

library(scales)
ggplot(custdata) + geom_density(aes(x=income)) +
  scale_x_continuous(labels=dollar)

ggplot(custdata) + geom_density(aes(x=income)) +
  scale_x_log10(breaks=c(100,1000, 10000, 100000), labels=dollar) +
  annotation_logticks(sides ="bt")
# adiciona marcadores no topo e na base do gráfico

ggplot(custdata) + geom_bar(aes(x=marital.stat), fill="gray")

ggplot(custdata) + geom_bar(aes(x=state.of.res), fill="gray") +
  coord_flip() + # inverte os eixos x e y
  theme(axis.text.y=element_text(size = rel(0.8))) #reduz a largura das barras para 80%

# agrega os dados por state.of.res
statesums <- table(custdata$state.of.res)
# converte a tabela em um data frame
statef <- as.data.frame(statesums)
# renomeia as colunas para melhor legibilidade
colnames(statef) <- c("state.of.res", "count")
# note que a ordenação padrão é alfabética
summary(statef)

# reordena a pelo campo count e aplica a transformação ao data frame
statef <- transform(statef,
                    state.of.res=reorder(state.of.res, count))
# note que a ordenação agora é por count
summary(statef)

# como os dados foram pré-agregados, use stat="identity" para plotá-los exatamente como passados
ggplot(statef) + geom_bar(aes(x=state.of.res, y=count), 
                          stat="identity",
                          fill="gray") +
  coord_flip() +
  theme(axis.text.y=element_text(size = rel(0.8))) 


# considera apenas um subconjunto dos dados originais
custdata2 <- subset(custdata,
                    (custdata$age > 0 & custdata$age < 100
                     & custdata$income > 0))
# calcula a correlação entre idade e renda
cor(custdata2$age, custdata2$income)

ggplot(custdata2, aes(x=age, y=income)) +
  geom_point() + ylim(0, 200000)


ggplot(custdata) + geom_bar(aes(x=marital.stat,
                                fill=health.ins))

ggplot(custdata) + geom_bar(aes(x=marital.stat,
                                fill=health.ins),
                            position="dodge")

ggplot(custdata) + geom_bar(aes(x=marital.stat,
                                fill=health.ins),
                            position="fill")

ggplot(custdata2) +
  geom_bar(aes(x=housing.type, fill=marital.stat),
           position="dodge") +
  theme(axis.text.x = element_text(angle=45, hjust=1))

ggplot(custdata2) +
  geom_bar(aes(x=marital.stat), position="dodge",
           fill="darkgray") +
  facet_wrap(~housing.type, scales="free_y") +
  theme(axis.text.x = element_text(angle=45, hjust=1))

### CAP 4

# cat("\014") # Limpa a console
# rm(list = ls()) # Limpa o global environment
# 
# load("C:/Users/epaf/Desktop/Códigos Livro R/zmPDSwR-master/Custdata/exampleData.rData") # carrega o dataframe

summary(custdata[is.na(custdata$housing.type), 	# Restringe as linhas em que housing.type é NA
                 c("recent.move","num.vehicles")]) 	# Olha apenas as colunas recent.move e num.vehicles. 
summary(custdata)

##
custdata$is.employed.fix <- ifelse(is.na(custdata$is.employed),  	# Se is.employed é NA 
                                   "missing",                    	# substitua o valor por "missing"
                                   ifelse(custdata$is.employed==T, 	# caso contrário, se is.employed = TRUE
                                          "employed",
                                          "not employed"))  	# substitua o valor por "employed", senão, "unemployed"

summary(as.factor(custdata$is.employed.fix)) 	# A transformação modificou a variável de factor para string. Transforme-a novamente.

##
summary(custdata$income)

meanIncome <- mean(custdata$income, na.rm=T) 	# "na.rm=T" para que a função mean() não inclua os NAs 
Income.fix <- ifelse(is.na(custdata$income),
                     meanIncome,
                     custdata$income)
summary(Income.fix)

##

breaks <-c(0, 10000, 50000, 100000, 250000, 1000000)  # Categorias de interesse - para usar a função cut(), os limites superior e inferior devem cobrir todos os dados

Income.groups <- cut(custdata$income,
                     breaks=breaks, include.lowest=T)  	# Particiona os dados em intervalos. include.lowest=T garante que o 0 seja incluído (por padrão, é desconsiderado)

summary(Income.groups)                                        	# A função cut() produz variáveis do tipo factor. NAs são preservados.

Income.groups <- as.character(Income.groups)                   	# Para preservar os nomes das categorias antes de adicionar uma nova, converta as variáveis para strings

Income.groups <- ifelse(is.na(Income.groups),                  	# Adicione a categoria "no income" para os NAs
                        "no income", Income.groups)

summary(as.factor(Income.groups))

##

missingIncome <- is.na(custdata$income)  	# missingIncome sinaliza se Income era NA 
Income.fix <- ifelse(is.na(custdata$income), 0, custdata$income) 	# Substitui os NAs por 0
summary(Income.fix)
##

medianincome <- aggregate(income~state.of.res,custdata,FUN=median)
colnames(medianincome) <- c('State','Median.Income')

summary(medianincome)  	# data frame com a renda mediana por estado

custdata <- merge(custdata, medianincome,
                  by.x="state.of.res", by.y="State")  	# mescla os dois dataframes usando as colunas "state.of.res" e "State"

summary(custdata[,c("state.of.res", "income", "Median.Income")]) 	# Agora Median.Income é parte de custdata 

custdata$income.norm <- with(custdata, income/Median.Income) 	# Normaliza Income por Median.Income
summary(custdata$income.norm)

##

brks <- c(0, 25, 65, Inf)  	# Selecione os intervalos de interesse. Os limites inferior e superior devem cobrir todos os dados. 
custdata$age.range <- cut(custdata$age,
                          breaks=brks, include.lowest=T) 	# Particiona os dados em intervalos. include.lowest=T garante que o 0 seja incluído (por padrão, é desconsiderado) 
summary(custdata$age.range) 		# A função cut() produz variáveis do tipo factor.

##

summary(custdata$age)
meanage <- mean(custdata$age)
custdata$age.normalized <- custdata$age/meanage
summary(custdata$age.normalized)

##

summary(custdata$age)
meanage <- mean(custdata$age)  	# Calcula a média 
stdage <- sd(custdata$age)     	# Calcula o desvio padrão
meanage
stdage
custdata$age.normalized <- (custdata$age-meanage)/stdage 	# Usa a média como referência e reescala a distância da média pelo desvio padrão
summary(custdata$age.normalized)

##

custdata$gp <- runif(dim(custdata)[1])  	# Retorna o numero de linhas do data frame
testSet <- subset(custdata, custdata$gp <= 0.1) 	# Gera um conjunto de teste com 10% dos dados 
trainingSet <- subset(custdata, custdata$gp > 0.1) 	# Gera um conjunto de treino com os 90% restantes
dim(testSet)[1]
dim(trainingSet)[1]

