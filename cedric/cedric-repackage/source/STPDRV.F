      SUBROUTINE  STPDRV (KRD,IBUF,RBUF,SBUF,IPR)
C
C        GENERATES STATISTICAL DISPLAYS
C

      INCLUDE 'CEDRIC.INC'      
      PARAMETER (MAXST=7)
C
      COMMON /VOLUME/ INPID(NID),ID(NID),NAMF(4,NFMAX),SCLFLD(NFMAX),
     X                IRCP(NFMAX),MAPVID(NFMAX,2),CSP(3,3),NCX(3),
     X                NCXORD(3),NFL,NPLANE,BAD
      CHARACTER*2 NAMF
      COMMON /DSPECS/ IWIND(2,3),PWIND(2,3),NCWORD(3),IFLDW(NFMAX),
     X                SCLFAC(NFMAX),NSYMCD(2,NFMAX),WIDCD(NFMAX),
     X                ZREFCD(NFMAX),THKLIN(NFMAX)
      COMMON /AXUNTS/ IUNAXS,LABAXS(3,3),SCLAXS(3,3),AXNAM(3)
      CHARACTER*4 AXNAM
C
      DIMENSION IBUF(1),RBUF(1),SBUF(MAXAXIS,MAXST),
     X          AXLIM(2,2),ISYMB(4,MAXST),IDEFL(4),IPTPRF(5)
      CHARACTER*1 IPTAB(3),IBL,IDEST,IHORV,IWOP,IPATUS,ISYMUS
      CHARACTER*2 NAME(4)
      CHARACTER*3 ICOM,ITEST
      CHARACTER*8 NOWDAT,NAMIN
      CHARACTER*80 LAB(2)
      CHARACTER*80 ITIT(3)
      CHARACTER*(*) KRD(10)
      CHARACTER*1 LFIX,CTEMP
C
      DATA IPTAB/'S','D','L'/
      DATA IDEFL/0,2,1HS,10/
      DATA NCRT/10/
      DATA IPTPRF/ 7,6,5,6,8 /
      DATA IBL/ ' ' /
C
C        DETERMINE OPERATION AND PARAMETERIZATION
C
      READ (KRD,100)ICOM,IDEST,LFIX,IHORV,SDFAC,IWOP
C  100 FORMAT(A3,5X,A1,7X,A1,7X,A1,7X,32X,F8.0,A1,7X)
 100  FORMAT(A3/A1/A1/A1/////F8.0/A1)
C
      IHOR = 1
      IF(IHORV .EQ. 'H') IHOR=2
C
      IF(SDFAC .LE. 0.0) SDFAC = 1.0
      CALL WINSET (IWIND,PWIND,IWOP)
      CALL SETAXS (NCWORD,LFIX,IPR)

CINITIALIZE IFLDW,WIDCD,ZREFCD
      DO I = 1,NFMAX
         IFLDW(I)  = 0
         WIDCD(I)  = 0.0
         ZREFCD(I) = 0.0
      END DO

C
C     DECODE EACH PROFILE FORMAT INTO THE TABLES
C
      K=0
      DO 5 I=1,5
         J=IPTPRF(I)
         READ (KRD(J),110)IPATUS,ISYMUS,X
  110    FORMAT(A1,1X,A1,1X,F4.0)
         IPNUM=LOCATE(IPATUS,IPTAB,3)
         IF(IPNUM.NE.0.OR.ISYMUS.NE.IBL) THEN
C
C           GOOD PROFILE DEFINITION
C
            ISYMB(1,I) = 1
            ISYMB(2,I) = IPNUM
            READ(ISYMUS,123)ISYMB(3,I)
 123        FORMAT(A1)
C            ISYMB(3,I) = ISYMUS
            ISYMB(4,I) = NINT(X)
            IF(ISYMB(4,I).LE.3.OR.ISYMB(4,I).GE.49)
     X         ISYMB(4,I)=NCRT
         ELSE
C
C           COPY DEFAULT INFO OVER TO THIS PROFILE
C
            CALL COPIX(ISYMB(1,I),IDEFL,4)
C
         END IF
         K=K+ISYMB(1,I)
C
    5 CONTINUE
C
      IF(K.LE.0) THEN
C
C        SET UP DEFAULTS IF NO CURVES SPECIFIED PROPERLY
C
         ISYMB(1,2)=1
         ISYMB(1,3)=1
         ISYMB(1,4)=1
         ISYMB(2,3)=1
         CTEMP='X'
         READ(CTEMP,23)ISYMB(3,3)
 23      FORMAT(A2)
C         ISYMB(3,3)='X'
      END IF
   10 CONTINUE
C
C        STATISTICS - FIELD CARD LOOP
C
         CALL KARDIN(KRD)
         CALL COMCHK(IPR,KRD)
         READ (KRD,101)ITEST,NAMIN,S1,S2
C  101    FORMAT(A3,5X,A8,2F8.0)
 101     FORMAT(A3/A8/F8.0/F8.0)
         IF(ITEST.EQ.'END') GO TO 15
         CALL FLDSET(NAMIN,NAMF,IFLDW,1,NST)
         IF(NST.NE.0) GO TO 10
         CALL FLDSETR (NAMIN,NAMF, WIDCD,S1,NST)
         CALL FLDSETR (NAMIN,NAMF,ZREFCD,S2,NST)
         GO TO 10
C
   15 CONTINUE
C
      CALL PLNFLD(IFIXAX,L1,L2,NFDSP)
      IF(NFDSP.EQ.0) GO TO 91
C
      IF(ABS(PWIND(2,IFIXAX)-PWIND(1,IFIXAX)).LE.0.0001) GO TO 92
C
      AXLIM(1,2) = PWIND(1,IFIXAX)
      AXLIM(2,2) = PWIND(2,IFIXAX)
      WRITE (LAB(2),120)AXNAM(IFIXAX), LABAXS(IFIXAX,IUNAXS)
120   FORMAT(A1,1X,A4,2X)
C
C        GENERATE STATISTICAL DISPLAYS
C
      DO 80 I=1,NFL
C
      IV=MAPVID(I,2)
      IF(IFLDW(IV).EQ.0) GO TO 80
C
      AXLIM(1,1) = WIDCD(IV)
      AXLIM(2,1) = ZREFCD(IV)
      WRITE (LAB(1),130)(NAMF(J,IV),J=1,4)
130   FORMAT(4A2)
      CALL  DATEE (NOWDAT)
      WRITE (ITIT(1),140)(ID(J),J=116,121),(ID(J),J=125,127),
     X                          (ID(J),J=13,15),NOWDAT
140   FORMAT(I2.2,'/',I2.2,'/',I2.2,5X,I2.2,2(':',I2.2),'-',
     X       I2.2,2(':',I2.2),7X,3A2,20X,'(AS OF ',A8,')')
      WRITE (ITIT(3),150)SDFAC
150   FORMAT(52X,'SIGMA SCALING FACTOR:',F7.2)
      CALL STATZI
C
      K=0
      DO 50 L=L1,L2
         K = K+1
         CALL NEXACT(IFIXAX,L,IV,RLEV,NAME,1)
C
C        PRODUCE STATISTICS FOR THIS FIELD
C
         CALL FETCHD (IN,ID,L,I,IBUF,RBUF,N1,N2,
     X                IFIXAX,BAD,RLEV,NST)
         CALL STRID (RBUF,N1,N2,IWIND,NCWORD,BAD,FAVG,FSTD,NP,
     X               M1,M2,M3,M4,FMN,FMX,1)
         SBUF(K,1) = FMN
         SBUF(K,2) = FAVG - FSTD*SDFAC
         SBUF(K,3) = FAVG
         SBUF(K,4) = FAVG + FSTD*SDFAC
         SBUF(K,5) = FMX
         SBUF(K,6) = NP
         SBUF(K,7) = RLEV
C
   50    CONTINUE
C
C  GET STATS FOR THE ENTIRE VOLUME.
C
            CALL STRID(RBUF,N1,N2,IWIND,NCWORD,BAD,FAVG,FSTD,NP,
     X                 M1,M2,M3,M4,FMN,FMX,2)
C
        IF(NP .LE. 0) GO TO 80
C
C  SHOULD RANGE OF PLOT BE CALCULATED?
C
        IF(ABS(AXLIM(1,1)-AXLIM(2,1)) .GT. 0.0001) GO TO 75
           RMIN =  1.E20
           RMAX = -RMIN
           DO 70 J=1,5
              IF(ISYMB(1,J) .LE. 0) GO TO 70
              DO 60 JJ=1,K
                 IF(SBUF(JJ,6) .LE. 0.0) GO TO 60
                 RMIN = AMIN1(RMIN,SBUF(JJ,J))
                 RMAX = AMAX1(RMAX,SBUF(JJ,J))
60            CONTINUE
70         CONTINUE
           CALL  STPOBD (RMIN, RMAX, NST)
           AXLIM(1,1)=RMIN
           AXLIM(2,1)=RMAX
75      CONTINUE
C
        IF(NST .EQ. 1) THEN
           PRINT 666
666        FORMAT(' PROGRAM STOPPED IN SUB STPDRV AFTER CALL TO',
     X            1X,'BOUNDS.')
           CALL FLUSH_STDOUT
        ENDIF
C
        WRITE (ITIT(2),160)NP,FAVG,FSTD,FMN,FMX
160     FORMAT('N=',I7,5X,'MEAN=',F8.2,5X,'SIGMA=',F8.2,5X,
     X         'MIN=',F8.2,5X,'MAX=',F8.2)
        CALL  STPLOT (ITIT,SBUF,MAXAXIS,MAXST,K,ISYMB,AXLIM,LAB,IHOR)
C
   80 CONTINUE
   90 CONTINUE
      RETURN
   91 CONTINUE
      CALL CEDERX(539,0)
      RETURN
   92 CONTINUE
      CALL CEDERX(565,0)
      RETURN
      END
