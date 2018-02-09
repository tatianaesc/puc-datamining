#########################################################
#### Data Mining 1
#### Aula 2 - Prática 1: Importação de Dados
#########################################################

# Lê de um arquivo ou URL e armazena o resultado em um novo data frame uciCar
uciCar <- read.table(
  'http://www.win-vector.com/dfiles/car.data.csv',
  sep=',',      # separador de colunas
  header=T      # indicativo de que a primeira linha é cabeçalho
)

class(uciCar) # mostra o tipo do objeto
help(class(uciCar)) # mostra a documentação de uma classe
summary(uciCar) # mostra a distribuição de cada variável do dataset
dim(uciCar) # mostra quantas linhas e colunas há nos dados
