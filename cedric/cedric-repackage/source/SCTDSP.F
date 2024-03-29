      SUBROUTINE SCTDSP(IBUF,RBUF,LEV,RLEV,IWIND,NCWORD,IFLSCT,ITIT,
     X                  SCATAX,IFIXAX,NST,SCATCHAR,NSCATCOL,
     X                  ISKPI,ISKPJ,LABFLG,ISLOPE,OVLYFLG)
C
C        PRODUCES A SCATTER PLOT DISPLAY ACCORDING TO THE PARAMETERIZATION
C                 IN /VCTSCT/
C                 NST=0, OK;  NST=1, INSUFFICIENT PARAMETERIZATION.
C
C     August 29, 1997 (LJM) - changed to exclude field values outside the 
C                             scatter plot window.  This also excludes them
C                             from the correlation calculation.
C     September 2, 1999 (LJM) - added drawing 1:1 line when correlation asked
C                             for is linear
C
      INCLUDE 'CEDRIC.INC'
      COMMON /VOLUME/ INPID(NID),ID(NID),NAMF(4,NFMAX),SCLFLD(NFMAX),
     X                IRCP(NFMAX),MAPVID(NFMAX,2),CSP(3,3),NCX(3),
     X                NCXORD(3),NFL,NPLANE,BAD
      CHARACTER*2 NAMF
      COMMON /AXUNTS/ IUNAXS,LABAXS(3,3),SCLAXS(3,3),AXNAM(3)
      CHARACTER*4 AXNAM
      DIMENSION CF(10),IBUF(1),RBUF(1),DELRG(2),
     X          IWIND(2,3),NCWORD(3),
     X          IFLSCT(2),SCATAX(5)
      DIMENSION ICOLMAP(9)
      CHARACTER*1 SCATCHAR
      CHARACTER*16 CFMTX, CFMTY
      CHARACTER*8 NAME(2),NOWDAT,IFMTX(2),IFMTY(2),ITIT(5)
      CHARACTER*80 JTIT
      CHARACTER*80 CITIT
      CHARACTER*12 NAMTITLE
      CHARACTER*1 BLANK
      PARAMETER (BLANK=' ')
      INTEGER OVLYFLG
      DATA NPLOT,LNC,KMIN/100, 128, 10/
      DATA IN/0/
      DATA ICOLMAP/1,61,5,8,25,38,32,2,60/
      DATA XL,XR,YB,YT/.07,.92,.07,.92/

C     Use for smaller vertical dimension for scatterplots
C
c      DATA XL,XR,YB,YT/.07,.92,.71,.92/
     
      XSIDE=XR-XL
      YSIDE=YT-YB

      CALL GSCLIP(0)
      CALL GQPLCI(IERROR,IOLDCOL)
      IF (IERROR.NE.0) THEN
         WRITE(*,*)'***ERROR CALLING GQPLCI IN SCTDSP***'
         CALL FLUSH_STDOUT
      END IF

C
C     TRANSFER ITIT DATA TO CHAR ARRAY
C
      WRITE (CITIT(1:80),500)(ITIT(I),I=1,5),BLANK
 500  FORMAT(5A8,39A1,'X')
c      print *,'SCTDSP: itit =',itit
c      print *,'SCTDSP: citit=',citit
C
C        CHECK FOR SUFFICIENT PARAMETERIZATION
C
      DELRG(1)=ABS(SCATAX(2)-SCATAX(1))
      DELRG(2)=ABS(SCATAX(4)-SCATAX(3))
      ICCF=SCATAX(5)
C
C        PARAMETERIZATION IS O.K.
C           FETCH IN THE TWO FIELDS TO BE COMPARED...
C
      IH=NCWORD(1)
      IV=NCWORD(2)
      I1=(IWIND(1,IH) - 1)/ISKPI + 1
      I2=(IWIND(2,IH) - 1)/ISKPI + 1
      J1=(IWIND(1,IV) - 1)/ISKPJ + 1
      J2=(IWIND(2,IV) - 1)/ISKPJ + 1
      LOC=1
      DO 5 I=1,2
      M=IFLSCT(I)
      WRITE (NAME(I),100)(NAMF(L,M),L=1,4)
  100 FORMAT(4A2)
      IFLD=MAPVID(M,1)
      CALL FETCHD(IN,ID,LEV,IFLD,IBUF,RBUF(LOC),N1,N2,
     X            IFIXAX,BAD,RLEV,NST)
      IF(NST.NE.0) RETURN
      LOC=LOC+N1*N2
    5 CONTINUE
C
C        GENERATE THE PLOT
C
      CALL MAJMIN(SCATAX(1),DELRG(1),IFMTX,MAJORX,MINORX,NDIG1,ISZ1,
     X            SCATAX(3),DELRG(2),IFMTY,MAJORY,MINORY,NDIG2,ISZ2)

c      CALL SET(.07,.92,.07,.92,
      CALL SET(XL,XR,YB,YT,
     X          SCATAX(1),SCATAX(2),SCATAX(3),SCATAX(4),1)
      call getset(fl,fr,fb,ft,ul,ur,ub,ut,ll)
c      print *,'SCTDSP: xl,xr,yb,yt=',xl,xr,yb,yt
c      print *,'SCTDSP: fl,fr,fb,ft=',fl,fr,fb,ft
c      print *,'SCTDSP: ul,ur,ub,ut=',ul,ur,ub,ut
      WRITE (CFMTX,510)IFMTX
 510  FORMAT(2A8)
      WRITE (CFMTY,510)IFMTY

      CALL LABMOD(CFMTX,CFMTY,NDIG1,NDIG2,ISZ1,ISZ2,4,4,0)
C      CALL HALFAX(MAJORX,MINORX,MAJORY,MINORY,SCATAX(1),SCATAX(3),1,1)
      CALL PERIML(MAJORX,MINORX,MAJORY,MINORY)

      WRITE (JTIT,101)(ID(I),I=116,121),(ID(I),I=125,127),
     X                    (ID(I),I=13,15),AXNAM(IFIXAX),RLEV,
     X                     LABAXS(IFIXAX,IUNAXS)
  101 FORMAT(I2.2,'/',I2.2,'/',I2.2,6X,I2.2,2(':',I2.2),'-',
     X       I2.2,2(':',I2.2),7X,3A2,7X,A2,'=',F7.2,' ',A4)
      LL=1
c      print *,'SCTDSP-BEF: fl,fr,fb,ft=',fl,fr,fb,ft
c      print *,'SCTDSP-BEF: ul,ur,ub,ut=',ul,ur,ub,ut
      CALL GETSET(FL,FR,FB,FT,UL,UR,UB,UT,LL)
c      print *,'SCTDSP-AFT: fl,fr,fb,ft=',fl,fr,fb,ft
c      print *,'SCTDSP-AFT: ul,ur,ub,ut=',ul,ur,ub,ut
      CALL SET(0.,1.,0.,1.,0.,1.,0.,1.,1)
      IF (LABFLG.GT.5) THEN
         RX=FL
         RY=FT+0.065
c         print *,'SCTDSP: RX,RY,JTIT(1:66)=',rx,ry,jtit(1:66)
         CALL PLCHMQ(RX,RY,JTIT(1:66),12.,0.,-1.)
         RX=FL+0.2*XSIDE
         RY=FB-0.05
c         print *,'SCTDSP: RX,RY,NAME(1)=',rx,ry,NAME(1)
         CALL PLCHMQ(RX,RY,NAME(1),12.,0.,-1.)
         IF (NSCATCOL.GT.0) CALL GSPLCI(ICOLMAP(NSCATCOL))

C        Add colored text for field name label and symbol
C        OVLYFLG - (0) do    call frame, plot namtitle normally
C                  (1) don't call frame, plot namtitle offset
C
c         print *,'SCTDSP: ovlyflg,scatchar=',ovlyflg,' ',scatchar,'-x'
         IF (OVLYFLG.GT.0)THEN
            WRITE(NAMTITLE,1011)SCATCHAR,NAME(2)
 1011       FORMAT('[',A1,']-',A8)
            RX=FL-0.05
            RY=FB+0.5*YSIDE
c            print *,'SCTDSP: ovlyflg,RX,RY,NAMTITLE=',
c     +           ovlyflg,rx,ry,NAMTITLE
            CALL PLCHMQ(RX,RY,NAMTITLE,12.,90.,-1.)
         ELSE
            WRITE(NAMTITLE,1012)SCATCHAR,NAME(2)
 1012       FORMAT('[',A1,']-',A8)
            RX=FL-0.05
            RY=FB+0.5*YSIDE
c            print *,'SCTDSP: ovlyflg,RX,RY,NAMTITLE=',
c     +           ovlyflg,rx,ry,NAMTITLE
            CALL PLCHMQ(RX,RY,NAMTITLE,12.,90.,-1.)
         END IF
         CALL GSPLCI(IOLDCOL)

         CALL DATEE(NOWDAT)
         WRITE (JTIT,102)NOWDAT
 102     FORMAT('(AS OF ',A8,')')
         RX=FL-0.05
         RY=FT+0.04
c         print *,'SCTDSP: RX,RY,JTIT(1:66)=',rx,ry,jtit(1:16)
         CALL PLCHMQ(RX,RY,JTIT(1:16),12.,0.,-1.)
         RX=FL+0.25*XSIDE
         RY=FT+0.02
c         print *,'SCTDSP: RX,RY,CITIT=',rx,ry,citit
         CALL PLCHMQ(RX,RY,CITIT,12.,0.,-1.)
      END IF
      CALL SET(FL,FR,FB,FT,UL,UR,UB,UT,1)
      CALL GETSET(FL,FR,FB,FT,UL,UR,UB,UT,LL)
c      print *,'SCTDSP-AFT: fl,fr,fb,ft=',fl,fr,fb,ft
c      print *,'SCTDSP-AFT: ul,ur,ub,ut=',ul,ur,ub,ut

C-------------------------------------
C     Temporary - LJM (April 10, 2002)
C     Draw a horizontal reference line 
C-------------------------------------
c      XX1=SCATAX(1)
c      YY1=0.0
c      XX2=SCATAX(2)
c      YY2=0.0
c      CALL DASHDB (O'170360')
call c      CALL LINED(XX1,YY1,XX2,YY2)
C-------------------------------------

      IF (ISKPJ.NE.1 .OR. ISKPI.NE.1) THEN
C
C     USE SKIPPING FACTORS TO GET RID OF SOME DATA VALUES
C
         LNUM=0
         DO 43 J=1,N2,ISKPJ
            DO 53 I=1,N1,ISKPI
               K = I + (J-1)*N1
               LNUM=LNUM+1
               RBUF(LNUM)=RBUF(K)
 53         CONTINUE
 43      CONTINUE
         
         N1N=((N1-1)/ISKPI) + 1
         N2N=((N2-1)/ISKPJ) + 1
         LNUM=0
         DO 63 J=1,N2,ISKPJ
            DO 73 I=1,N1,ISKPI
               K = I + (J-1)*N1
               LNUM=LNUM+1
               RBUF(LNUM+N1N*N2N)=RBUF(K+N1*N2)
 73         CONTINUE
 63      CONTINUE
         N1=N1N
         N2=N2N
      END IF
      N=N1*N2
      K=0
      DO 10 I=1,N
      J=I+N
C
C        TOSS DATA POINTS IF EITHER IS BAD OR OUTSIDE WINDOW
C
      IF(RBUF(I).EQ.BAD.OR.RBUF(J).EQ.BAD) GO TO 10
      IF(RBUF(I).LE.SCATAX(1).OR.RBUF(I).GE.SCATAX(2)) GO TO 10
      IF(RBUF(J).LE.SCATAX(3).OR.RBUF(J).GE.SCATAX(4)) GO TO 10
      JTEST=(I-1)/N1+1
      IF(JTEST.LT.J1.OR.JTEST.GT.J2) GO TO 10
      ITEST=MOD(I-1,N1)+1
      IF(ITEST.LT.I1.OR.ITEST.GT.I2) GO TO 10
      K=K+1
      L=K+N
      RBUF(K)=RBUF(I)
      RBUF(L)=RBUF(J)
C
C        PLOT A SMALL CROSS AT EACH DATA PAIR
C             MOVE ANY DATA POINTS OUTSIDE THE WINDOW TO THE EDGE
C
      XPLT=AMAX1(SCATAX(1),RBUF(K))
      XPLT=AMIN1(SCATAX(2),XPLT)
      YPLT=AMAX1(SCATAX(3),RBUF(L))
      YPLT=AMIN1(SCATAX(4),YPLT)
      CALL FL2INT(XPLT,YPLT,IP,JP)
      FIP=float(ip)/32767.
      FJP=float(jp)/32767.
c      print *,'SCTDSP: ip,jp,fip,fjp=',ip,jp,fip,fjp
      IF (NSCATCOL.GT.0) CALL GSPLCI(ICOLMAP(NSCATCOL))
c      print *,'SCTDSP: ip,jp,xplt,yplt,rbuf(k),rbuf(l)=',
c     +     ip,jp,xplt,yplt,rbuf(k),rbuf(l)
      CALL PLCHMQ(XPLT,YPLT,SCATCHAR,10.,0.,-1.)
      IF (SCATCHAR.NE.' ') THEN
         RCMUX=FIP
         RCMUY=FJP
c         print *,'SCTDSP-scatchar.ne.blank: rcmux,rcmuy=',rcmux,rcmuy
         CALL PLCHMQ(RCMUX,RCMUY,SCATCHAR,10.,0.,-1.)
      ELSE
         FIP1=float(ip-lnc)/32767.
         FIP2=float(ip+lnc)/32767.
         FJP1=float(jp)/32767.
         FJP2=float(jp)/32767.
c         print *,'SCTDSP-scatchar.eq.blank: fip1,fjp1,fip2,fjp2=',
c     +        fip1,fjp1,fip2,fjp2
         CALL PLOTIF(FIP1,FJP1,0)
         CALL PLOTIF(FIP2,FJP2,1)
         FIP3=float(ip)/32767.
         FIP4=float(ip)/32767.
         FJP3=float(jp-lnc)/32767.
         FJP4=float(jp+lnc)/32767.
c         print *,'SCTDSP-scatchar.eq.blank: fip3,fjp3,fip4,fjp4=',
c     +        fip3,fjp3,fip4,fjp4
         CALL PLOTIF(FIP3,FJP3,0)
         CALL PLOTIF(FIP4,FJP4,1)
      END IF
      CALL GSPLCI(IOLDCOL)
   10 CONTINUE
      WRITE (JTIT,103)K
  103 FORMAT('N=',I5)
      IF (LABFLG.GT.5) THEN
         LL=1
         CALL GETSET(FL,FR,FB,FT,UL,UR,UB,UT,LL)
         CALL SET(0.,1.,0.,1.,0.,1.,0.,1.,1)
         RX=FL+0.4*XSIDE
         RY=FB-0.045
         CALL PLCHMQ(RX,RY,JTIT(1:7),12.,0.,-1.)
         CALL SET(FL,FR,FB,FT,UL,UR,UB,UT,LL)
      END IF
C
C     PLOT THE 1:1 CURVE WHEN THE FIT ASKED FOR IS LINEAR
C     DRAW DASHED LINE FOR Y=SLOPE*(X-X0)+Y0
C        XMIN (XMAX) : Minimum (maximum) bound of plot in X-direction
C        YMIN (YMAX) : Minimum (maximum) bound of plot in Y-direction
C        SLOPE       : (+1) (XMIN,YMIN) --> (X2,Y2) near (XMAX,YMAX)
C                      (-1) (XMIN,YMAX) --> (X2,Y2) near (XMAX,YMIN)
C        Y = M*(X-X0) + Y0
C        X = X0 + (Y - Y0)/M
C
      XMIN=SCATAX(1)
      XMAX=SCATAX(2)
      YMIN=SCATAX(3)
      YMAX=SCATAX(4)
c      print *,'SCTDSP: ',islope,xmin,xmax,ymin,ymax
      IF(ISLOPE .EQ. 1)THEN
         X1=XMIN
         Y1=YMIN
         Y_XMAX=ISLOPE*(XMAX-X1)+Y1
         IF(Y_XMAX.LT.YMAX)THEN
            X2=XMAX
            Y2=Y_XMAX
         ELSE IF(Y_XMAX.EQ.YMAX)THEN
            X2=XMAX
            Y2=YMAX
         ELSE IF(Y_XMAX.GT.YMAX)THEN
            Y2=YMAX
            X2=X1+(Y2-Y1)/ISLOPE
         END IF
         CALL DASHDB (O'170360')
         CALL LINED(X1,Y1,X2,Y2)
      ELSE IF(ISLOPE .EQ. -1)THEN
         X1=XMIN
         Y1=YMAX
         Y_XMAX=ISLOPE*(XMAX-X1)+Y1
         IF(Y_XMAX.LT.YMIN)THEN
            Y2=YMIN
            X2=X1+(Y2-Y1)/ISLOPE
         ELSE IF(Y_XMAX.EQ.YMIN)THEN
            X2=XMAX
            Y2=YMIN
         ELSE IF(Y_XMAX.GT.YMIN)THEN
            Y2=Y_XMAX
            X2=X1+(Y2-Y1)/ISLOPE
         END IF
         CALL DASHDB (O'170360')
         CALL LINED(X1,Y1,X2,Y2)
      END IF

      IF(ICCF.LE.0.OR.K.LT.KMIN) THEN
         IF (LABFLG.GT.5) THEN
            LL=1
            CALL GETSET(FL,FR,FB,FT,UL,UR,UB,UT,LL)
            CALL SET(0.,1.,0.,1.,0.,1.,0.,1.,1)
            RX=FL+0.70*XSIDE
            RY=FB-0.045
            CALL PLCHMQ(RX,RY,'NO REGRESSION',12.,0.,-1.)
            CALL SET(FL,FR,FB,FT,UL,UR,UB,UT,1)
         END IF
         GO TO 90
      END IF
C
C        SUFFICIENT NUMBER OF PAIRS TO PERFORM CORRELATION AND CURVE FIT.
C
      NCF=ICCF+1
C
C        CALCULATE AND DISPLAY CORRELATION COEFFICIENT
C
      IF(ICCF.NE.1) GO TO 15
      CCF=CORR(K,RBUF(1),RBUF(1+N),SE)
      WRITE (JTIT,104)CCF,SE
  104 FORMAT('CORR.=',F5.2,5X,'STD ERR.=',F7.2)
      IF (LABFLG.GT.5) THEN
         CALL MY_PLCHMQ(590,25,JTIT(1:32),12.,0.,-1.)
      END IF
   15 CONTINUE
C
C        PERFORM AN ICCF-DIMENSIONAL CURVE FIT.
C
      CALL LSTSQR(NCF,K,RBUF(1),RBUF(1+N),CF,IBUF)
      WRITE (JTIT,105)ICCF
  105 FORMAT('LEAST SQUARES ORDER=',I2)
      IF (LABFLG.GT.5) THEN
         CALL MY_PLCHMQ(350,985,JTIT(1:22),12.,0.,-1.)
      END IF
      LOCY=985
      DO 20 M=1,NCF
      MM1=M-1
      WRITE (JTIT,106)MM1,CF(M)
  106 FORMAT('C',I1,'=',F7.3)
      IF (LABFLG.GT.5) THEN
        CALL MY_PLCHMQ(850,LOCY,JTIT(1:10),12.,0.,-1.)
      END IF
      LOCY=LOCY-22
   20 CONTINUE
C
C        PLOT THE REGRESSION CURVE
C
      BEGY=AMIN1(SCATAX(3),SCATAX(4))
      ENDY=AMAX1(SCATAX(3),SCATAX(4))
      CINC=(SCATAX(2)-SCATAX(1))/(NPLOT-1)
      XP=SCATAX(1)-CINC
      LAST=1
      DO 30 I=1,NPLOT
      XP=XP+CINC
      YP=FUNK(XP,CF,NCF)
      IF(YP.LT.BEGY.OR.YP.GT.ENDY) GO TO 23
      IF(LAST.EQ.0) GO TO 25
         LAST=0
         CALL FRSTPT(XP,YP)
         GO TO 30
   23 CONTINUE
         LAST=1
         GO TO 30
   25 CONTINUE
         CALL VECTOR(XP,YP)
   30 CONTINUE
   90 CONTINUE
C
C        NORMAL TERMINATION
C
      NST=0
      IF (OVLYFLG.LE.0)THEN
         IF (LABFLG.GT.5) THEN
            CALL MYFRAME
         ELSE
            CALL FRAME
         END IF
      END IF
      CALL GQPLCI(IERROR,ICOLCK)
      RETURN
      END
