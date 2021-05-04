setwd("C:/pp")  #set work directory

library(dplyr)
library(ggplot2)
library(scales)
library(reshape2)
library(ggsci)

# read csv files
data = read.csv("profit.csv",header = TRUE)
data2 = read.csv("pop_by_year.csv",header = TRUE)

# bind two files
data <- cbind(data, data2[,2:4])
data$전체<-gsub(",","",data$전체)
data$우대권.사용자 <-gsub(",","",data$우대권.사용자)
data$적자현황 <-gsub(",","",data$적자현황)
data$우대권.손실금 <-gsub(",","",data$우대권.손실금)
data$전체 <- as.numeric(data$전체)
data$우대권.사용자 <- as.numeric(data$우대권.사용자)
data$적자현황 <- as.numeric(data$적자현황)
data$적자현황<-abs(data$적자현황)/10000000000     #적자현황, 우대권 손실금 단위 백억
data$우대권.손실금 <- as.numeric(data$우대권.손실금)/10000000000
적자비율 <- (data$우대권.손실금/data$적자현황)*100
우대인구비율 <- (data$우대/data$총인구수)*100 
우대권사용자비율 <- (data$우대권.사용자/data$전체)*100
data <- cbind(data,우대인구비율,우대권사용자비율,적자비율)
data_org <- data
data<-data[0:12,]         #코로나로인한 2020년 데이터 제외  except 2020 data(Corona vir)
#data
#매년 지하철 운영 적자, 지하철 이용객 수 등은 독립데이터라고 볼 수 있다
#우대인구비율(고령인구)에 대한 우대권 사용자 비율 회귀분석
out=lm(우대인구비율~우대권사용자비율,data)
summary(out)  # 결과값으로 p-value가 3.066* 10^-8, 상관관계가 매우 높음.
#따라서 고령인구 비율이 늘어남에 따라 우대권 사용자 비율또한 늘어난다고 생각할 수 있음.
out=lm(우대권사용자비율~우대권.손실금,data)
summary(out)  # p-value = 6.918* 10^-7, 우대권 사용자 비율에 따라 우대권 손실금 또한 늘어남.



#데이터의 수가 30개보다 작기 때문에 정규성 검증
x=data$적자현황
shapiro.test(x)   # pvalue = 0.464( >0.05) -> 정규분포를 따른다는 귀무가설을 기각할 수 없음
summary(x)

#적자 현황에 대한 우대권 손실금 회귀 분석
cor(data$우대권.손실금,data$적자현황) # 0.45 -> 0.3보다 크므로, 강한 상관관계
out2 = lm(우대권.손실금~적자현황,data)
summary(out2) # 결과로 p-value = 0.1406, 약 86%의 확률로 우대권 손실금과 적자 현황은 상관관계가 있다.
pre = lm(적자현황~우대인구비율,data)
summary(pre)  # p-value=0.03, 상관관계가 매우 높음.
xx = data.frame(우대인구비율=c(25, 30, 35, 40))
predict(pre,newdata=xx)
# > predict(pre,newdata=xx)       #우대인구 비율이 25%, 30%, 35%, 40% 일때 적자 비율의 예측치
# 1        2        3        4 
# 58.00428 66.32094 74.63760 82.95425 
# 2030    2036    2042    2050  (년)


#####
myhead <- c("연도","인구","고령여부")
data_old <- cbind(data$연도,(data$우대),"O")
colnames(data_old) <- myhead
data_old <- data.frame(data_old)

myhead <- c("연도","인구","고령여부")
data_tot <- cbind(data$연도,(data$비우대),"X")
colnames(data_tot) <- myhead
data_tot <- data.frame(data_tot)

data_pop <- rbind(data_old,data_tot)
colnames(data_pop) <- c("연도","총인구","고령")
data_pop <- data.frame(data_pop)
data_pop$총인구<- as.numeric(as.character(data_pop$총인구))/10000 #단위 만명
data_pop$연도<- as.numeric(as.character(data_pop$연도))

#draw graph
options(scipen = 0)
summary(data_pop)

#고령인구  그래프
g<-ggplot(data_pop,aes(연도,총인구,fill=고령))+
  geom_bar(stat='identity',position='dodge')+
  ylab('인구(만 명)')
ggsave("청년층과 고령인구.pdf")
plot(g)

#고령인구 비율과 우대권 사용자 비율
g<-ggplot(data,aes(x=연도,y=우대인구비율))+geom_line(color='red')+
  geom_line(aes(x=연도,y=우대권사용자비율), color='blue')+
  ylab('비율(%)')
ggsave("고령인구비율과 우대권 사용자비율.pdf")
plot(g)

asdf <- melt(data,id.vars=c("연도","적자현황"))
g<-ggplot(data,aes(x=연도,y=적자현황))+geom_line(colour="myline1")+
  geom_line(aes(x=연도,y=우대권.손실금),colour="ml2")+
  scale_colour_manual(name="lll",values=c(myline1='blue',ml2='red'))+
  ylab('적자(단위 : 백 억)')
#ggsave("적자 대비 우대권 손실금.pdf")
plot(g)
