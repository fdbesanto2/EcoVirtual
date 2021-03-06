###########################################
### EcoVirtual - Multispecies Functions ###
###########################################
### Sucessional Niche


##' Successional Niche Model
##' 
##' Simulates the process of niche succession by successional stages in a
##' community with 2 species (a superior and an inferior competitor), following
##' the model of Pacala and Rees (1998).
##' 
##' There are five possible states of this model: \itemize{ \item \emph{free} -
##' open, unoccupied space; \item \emph{early} - occupied by only the early
##' successional species; \item \emph{susceptible} - occupied by only the late
##' succesional species and susceptible to invasion by the early succesional
##' species; \item \emph{mixed} - occupied by both species; \item
##' \emph{resistant} - occupied by only the late successional species.  }
##' 
##' The early successional species is the inferior competitor in the model, and
##' the later successional species is the superior competitor.
##' 
##' The number of patches in the simulated landscape is defined by rw*cl.
##' 
##' 'dst' is the proportion of patches in any stage that turns empty, it
##' represents a disturbance in the landscape.
##' 
##' 'ec' is the probability of succeptible and mixed stages turns resistant
##' stage.
##' 
##' @param tmax maximum simulation time.
##' @param rw number of rows for the simulated landscape.
##' @param cl number of columns for the simulated landscape.
##' @param c1 colonization rate for the late successional species (superior
##' competitor).
##' @param c2 colonization rate for the early successional species (inferior
##' competitor).
##' @param ec rate of competitive exclusion.
##' @param dst disturbance rate.
##' @param er inicial proportion of patches in early stage.
##' @param sc inicial proportion of patches in susceptible stage.
##' @param mx initial proportion of patches in mixed stage.
##' @param rs initial proportion of pathces in resistant stage.
##' @param anima show animation frames.
##' @return 'regNicho' returns the simulation results of patch occupancy in
##' time for each successional stage.
##' 
##' 'regNicho' also returns an invisible array with the simulation results per
##' time.
##' @author Alexandre Adalardo de Oliveira \email{ecovirtualpackage@@gmail.com}
##' @seealso \code{\link{comCompete}}, \url{http://ecovirtual.ib.usp.br}
##' @references Pacala, S & Rees, M. 1998. Models suggesting field experiments
##' to test two hypotheses explaining successional diversity. The American
##' Naturalist 152(2): 729:737.
##' 
##' Stevens, MHH. 2009. A primer in ecology with R. New York, Springer.
##' @keywords simulation Niche sucession
##' @examples
##' 
##' \dontrun{
##' regNicho(tmax=50, rw=100, cl=100, c1=0.2, c2=0.8, ec=0.5, dst=0.04,  er=0.08, sc=0.02, mx=0, rs=0)
##' }
##' 
##' @export regNicho
regNicho=function(tmax, rw, cl, c1,c2, ec, dst,  er, sc, mx, rs, anima=TRUE) 
{
N=cl*rw
V=1-er-sc-mx-rs
cena=array(NA,dim=c(rw,cl,tmax))
cena[,,1]<-sample(c(0:4), N, prob=c(V,er,sc,mx, rs), replace=TRUE)
resulta=matrix(0, ncol=5, nrow = tmax)
conta=table(cena[,,1])/N
resulta[1,(as.numeric(names(conta))+1)]<-conta
	for (t in 2:tmax)
	{
	Vvf<-cena[,,t-1]==0
	nV=sum(Vvf)
	ervf<-cena[,,t-1]==1
	ner=sum(ervf)
	scvf<-cena[,,t-1]==2
	nsc=sum(scvf)
	mxvf<-cena[,,t-1]==3
	nmx=sum(mxvf)
	rsvf<-cena[,,t-1]==4
	nrs=sum(rsvf)
	p_col1=c1*(nsc+nmx+nrs)/N
	p_col2=c2*(ner+nmx)/N
	p_ncol=1-p_col1- p_col2
	p_permer = 1- (dst + p_col1)
	p_permsc = 1- (dst + p_col2 + ec)
	p_permmx = 1 - (dst + ec)
	if(p_ncol<0){p_ncol=0}
	if(p_permer<0){p_permer=0}
	if(p_permsc<0){p_permsc=0}
	if(p_permmx<0){p_permmx=0}
	cena[,,t][Vvf]<-sample(c(0,1,2),nV, replace=TRUE, prob=c(p_ncol,p_col2,p_col1)) 
	cena[,,t][ervf]<-sample(c(0,1,3), ner, replace=TRUE, prob=c(dst,p_permer , p_col1))
	cena[,,t][scvf]<-sample(c(0,2,3,4), nsc, replace=TRUE, prob=c(dst,p_permsc, p_col2, ec))
	cena[,,t][mxvf]<-sample(c(0,3,4), nmx, replace=TRUE, prob=c(dst,p_permmx, ec))
	cena[,,t][rsvf]<-sample(c(0,4), nrs, replace=TRUE, prob=c(dst,1 - dst))
	conta=table(cena[,,t])/N
	resulta[t,(as.numeric(names(conta))+1)]<-conta
    }
if(anima==TRUE)
    {
        dev.new()   
        animaCena(cena)
    }
dev.new()
op = par(mar=c(5.5,5,4,2), las=1,mgp= c(3.2,1,0))
matplot( 1:tmax,resulta[,2:5], type="l", main="Niche Regeneration Model" , xlab="time", ylab="Patch occupancy", lty=2:5, col=c( "gold", "orange", "blue", "green"),cex.lab=1.3, cex.main=1.4, cex.axis=1.2,lwd=2, cex.sub=1.1)
legend("topright", c("Early", "Susceptible", "Mixed", "Resistant"), bty="n", lty=2:5, col=c("gold", "orange", "blue", "green"), cex= 1.2, lwd=2)
invisible(cena)
}
#regNicho(tmax=50, rw=100, cl=100, c1=0.2, c2=0.8, ec=0.5, dst=0.04,  er=0.08, sc=0.02, mx=0, rs=0)
##################################################
### Trade-off between competition and colonization
################################################## 


##' Multispecies competition-colonization tradeoff
##' 
##' Simulates the trade-off between colonization and competition abilities in a
##' multispecies system.
##' 
##' In the system, the competitive abilities are inversely proportional to the
##' colonization abilities.
##' 
##' The number of patches in the simulated landscape is defined by rw*cl.
##' 
##' @param rw number of rows for the simulated landscape.
##' @param cl number of columns for the simulated landscape.
##' @param S number of species.
##' @param fi initial fraction of patchs occupied
##' @param fsp1 superior competitor abundance.
##' @param pe mortality rate.
##' @param fr disturbance frequency.
##' @param int disturbance intensity.
##' @param tmax maximum simulation time.
##' @return 'comCompete' returns a graph with the proportion of patches
##' occupied in time by each species and the trade-off scale, the superior
##' competitor in one side and the superior colonizator in the other.
##' @author Alexandre Adalardo de Oliveira \email{ecovirtualpackage@@gmail.com}
##' @seealso \code{\link{metaComp}}, \url{http://ecovirtual.ib.usp.br}
##' @references Tilman. R. 1994. Competition and biodiversity in spatially
##' structured habitats. Ecology,75:2-16.
##' 
##' Stevens, M.H.H. 2009. A primer in ecology with R. New York, Springer.
##' @keywords simulation metacompetition
##' @importFrom stats na.omit
##' @examples
##' 
##' \dontrun{
##' comCompete(tmax=1000, rw=100, cl=100, S=10, fi=1, fsp1=0.20, pe=0.01, fr=0, int=0)
##' }
##' 
##' @export comCompete
comCompete = function(rw, cl, S, fi, fsp1, pe, fr=0, int=0, tmax)
{
rank=1:S
vetor_dist=rep("n", tmax)
  if(fr>0 & int>0)
  {
  vetor_dist[round(seq(0,tmax, length.out=fr*tmax),0)[-1]]="d"
  }
vetor_dist=vetor_dist[-1]
ci= pe/(1-fsp1)^(2*rank-1)
N <- rw*cl
resulta=matrix(nrow=S,ncol=tmax)
attributes(resulta)=c(attributes(resulta),list(tempo=tmax, riqueza=S, n_manchas=N, inicial= fi, comp=fsp1, coloniza=ci, freq_dist=fr, int=int))
n_ocup= sum(fi)*N
temp=1
	if(length(fi)==S)
	{ 
	resulta[,1]=fi
	antes=sample(c(rep(0,N-n_ocup),rep(rank,each=fi*N)))
	}
	if(length(fi)==1)
	{
	antes <- sample(c(1:S, sample(1:S, (n_ocup-S),replace=TRUE), rep(0, N-n_ocup)))
	t_antes=table(antes)
	n_sp=rep(0,S)
	names_antes=match(as.numeric(names(t_antes)), rank)
	rank_antes=match(rank,as.numeric(names(t_antes)))
	n_sp[na.omit(names_antes)]=t_antes[na.omit(rank_antes)]
	resulta[,1]<-n_sp/N
	}
	for (f in vetor_dist)
		{
		temp=temp+1
		depois <- rep(0,N)
		pi=ci*resulta[,temp-1]
		pi[pi>1]=0.999
			for(rs in S:1)
			{
			depois[antes==rs]<-sample(c(0,rs),sum(antes==rs),replace=TRUE,prob=c(pe,1-pe))
			d1<-sample(c(0,rs),sum(antes>rs | antes==0),replace=TRUE,prob=c(1-pi[rs],pi[rs]))
			depois[antes>rs | antes==0][d1==rs] <- rs
			}
		n_sp=rep(0,S)
		if(f=="d")
		{
		depois[sample(1:N,N*int)]=0
		}
		t_depois=table(depois)
		names_match=match(as.numeric(names(t_depois)), rank)
		rank_match=match(rank,as.numeric(names(t_depois)))
		n_sp[na.omit(names_match)]=t_depois[na.omit(rank_match)]
		resulta[,temp]<-n_sp/N
		antes<-depois
		}
#grafico
#dev.new()
layout(matrix(data=c(1,2), nrow=2, ncol=1), widths=c(1,1), heights=c(4,1))
matplot(1:tmax,t(resulta),type="l", lty=3, col=rainbow(S),bty="n", lwd=2,xlab="Time", ylab="Patch occupancy", main="Competition/Colonization Trade-off", sub=paste("\n best competitor abundance=",fsp1,"; mortality rate=",pe, "; disturbance frequency=",fr, "; disturbance intensity=", int), cex.sub=0.7) 
old<-par(mar=c(3,5,2,4))
image(x=1:S, y=1, matrix(data=1:S, nrow=S,ncol=1),col=rainbow(S), xlab="competition/colonization scale", ylab="",xaxt="n", yaxt="n")
axis(1, at=c(1.5,9.5),tick=FALSE, labels=c("best competitor", "best colonizer"))
par(old)
invisible(resulta)
}
#comCompete(tmax=10,rw=100,cl=100, S=10, fi=1, fsp1=0.20, pe=0.01,fr=0,int=0)
## Sucessional stages matrix


##' Successional Stages Matrix
##' 
##' Simulates a successional model based on a transitional matrix of stages and
##' its initial proportion of occurence in the landscape.
##' 
##' 
##' The number of patches in the simulated landscape is defined by rw*cl.
##' 
##' @param mat.trans a matrix of stage transition probabilites.
##' @param init.prop a vector with the initial proportions of each stage.
##' @param rw number of rows to build the simulated landscape.
##' @param cl number of columns to build the simulated landscape.
##' @param tmax maximum simulation time.
##' @return 'sucMatrix' return a simulation graphic with the proportions of
##' stages in the landscape in time, and a stage distribution graphic with the
##' results of the simulation with the number o patches in time for each stage.
##' 
##' 'sucMatrix' also return an invisible array with the simulation results.
##' @author Alexandre Adalardo de Oliveira \email{ecovirtualpackage@@gmail.com}
##' @references Gotelli, N.J. 2008. A primer of Ecology. 4th ed. Sinauer
##' Associates, 291pp.
##' @keywords simulation ecological succession
##' @examples
##' 
##' \dontrun{
##' sucMatrix(mat.trans=matrix(data=c(0.5,0.5,0.5,0.5), nrow=2), 
##' init.prop=c(0.5,0.5),rw=20,cl=20, tmax=100)
##' }
##' 
##' 
##' @export sucMatrix
sucMatrix=function(mat.trans, init.prop, rw, cl, tmax)
{
          mat.trans=as.matrix(mat.trans)
          porc1=apply(mat.trans,2,sum)
          if(sum(porc1!=1)>0)
          {
                    stop("the transition for each phase should sum 1: there is no reduction of area in the model")
          }
          if(sum(init.prop)!=1 | length(init.prop) != dim(mat.trans)[2])
          {
                    stop("the initial proportion of occupancy should sum 1 and the number of stages should be equal to transition matrix")
          }
          nfase=dim(mat.trans)[1]
          ncel=rw*cl
          fase_n=round(init.prop*ncel)
          cl_fase=colorRampPalette(c("gray","yellow", "orange","green"))
          arena=matrix(NA,nrow=rw,ncol=cl)
          pais=array(0,dim=c(rw, cl, tmax))
          n0=sample(rep(0:(nfase-1), fase_n))
          arena[1:ncel]<-n0
          pais[,,1]<-arena
          dev.new()
          image(0:rw, 0:cl, arena, col=cl_fase(nfase) , breaks=c(-0.1,(1:nfase)-0.1), xlab="", ylab="", main="Successional Model")
          grid(rw,cl)
          for (tc in 2:tmax)
          {
          for(nf in 0:(nfase-1))
                    {
                    nf_vf=pais[,,(tc-1)]==nf
                    contn=sum(nf_vf)
                    pais[,,tc][nf_vf]<-sample(0:(nfase-1),contn,replace=TRUE, prob=as.numeric(mat.trans[,(nf+1)]))
                    }
                    image(0:rw, 0:cl, pais[,,tc], col=cl_fase(nfase) , breaks=c(-0.1,(1:nfase)-0.1), add=TRUE)
                    Sys.sleep(.1)
          }
          dev.new()
          op=par(mfrow=c(2,2))
          image(0:rw, 0:cl, arena, col=cl_fase(nfase) , breaks=c(-0.1,(1:nfase)-0.1), xlab="", ylab="", main="Initial Conditions")
          for(ts in c(4,2,1))
          {
          image(0:rw, 0:cl, pais[,,round(tc/ts)], col=cl_fase(nfase) , breaks=c(-0.1,(1:nfase)-0.1), main=paste("Time", round(tc/ts)), xlab='', ylab='')
          }
          par(op)
          resulta=t(apply(pais,3, table))
          dev.new()
          matplot(resulta, type="l", ylim=c(min(resulta)*0.8, max(resulta)*1.1), main="Stage Distribution",ylab="Number of patches", xlab="Time", col=cl_fase(nfase), lty=2, lwd=2)
          legend("topright", legend=paste("Stage", 1:nfase), lty=2, lwd=2, col=cl_fase(nfase), bty="n", cex=0.8)
          eigs_st=eigen(mat.trans)
          dom_pos=which.max(Re(eigs_st$values))
          stage_v<- Re(eigs_st[["vectors"]][, dom_pos])
          stage_stable=(stage_v/sum(stage_v))*ncel
          abline(h=stage_stable, col=cl_fase(nfase), lwd=0.8)
          legend("topleft", legend=paste("Stable Stage", 1:nfase), lty=1, lwd=0.9, col=cl_fase(nfase), bty="n", cex=0.8)
          invisible(pais)
     }
#sucMatrix(mat.trans=matrix(data=c(0.5,0.5,0.5,0.5), nrow=2), init.prop=c(0.2,0.8),rw=20,cl=20, tmax=100)
#sucMatrix(mat.trans=matrix(data=c(0.3,0.4,0.3,0.5,0.2,0.3, 0.2,0.4,0.4), nrow=3), init.prop=c(0.2,0.5,0.3),rw=20,cl=20, tmax=100)
