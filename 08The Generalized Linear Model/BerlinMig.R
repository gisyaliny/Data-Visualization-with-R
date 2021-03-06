rm(list=ls())
setwd("G:\\UTD_Classes\\2020Spring\\GISC7310_AdvancedDataAnalysis\\08The Generalized Linear Model")
berlin <- foreign::read.spss("bmigvec91_92.sav", use.value.labels=TRUE, to.data.frame=TRUE)
attach(berlin)
names(berlin)

##
## Prepare the variables
## index i for origin, index j for destination, and index ij for inter-regional links
##
i <- org
j <- dest

lnpi91 <- log(poporg91)
lnpj91 <- log(popdest91)

lnpi92 <- log(poporg92)
lnpj92 <- log(popdest92)

lnmij91 <- mij91
lnmij91[mij91 >0 ] <- log(mij91[mij91 >0 ])

lndij <- dij                         # Make sure that the log(dij=0) is treated properly
lndij[dij > 0] <- log(dij[dij > 0])  # dij = 0 remains zero

## Plain Migration Model
mod01 <- glm(mij92 ~ lnpi92+lnpj92+lndij, weights = cwt, data=berlin, family = poisson(log))
summary(mod01)
logLik(mod01)

## check disperion
mod01b <- glm(mij92 ~ lnpi92+lnpj92+lndij, weights = cwt, data=berlin, family =quasipoisson)
summary(mod01b)
logLik(mod01b)

## Plain Migration Model with Offset: variation around the migration flow in 1991
mod02 <- glm(mij92 ~ lnpi92+lnpj92+lndij, offset=lnmij91, weights = cwt, data=berlin, family = poisson)
summary(mod02)
logLik(mod02)

bymedian <- with(berlin, reorder(i, dij, median))
boxplot(dij ~ bymedian, subset=(i!=j), data=berlin,
        main="Distance Distribution from Each District")

## Origin specific distance decay parameter
mod03 <- glm(mij92 ~ lnpi92+lnpj92+ lndij+lndij:i, weights = cwt, data=berlin, family = poisson, 
                     contrast = list(i="contr.sum"))
summary.glm(mod03)
logLik(mod03)
coef23 <- -sum(coef(mod03)[5:26])   # Get missing last distance decay parameter
orgDist <- c(coef(mod03)[5:26],coef23)

