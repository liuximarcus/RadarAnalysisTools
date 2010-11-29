      PROGRAM CEDWRITE
C
C     THIS ROUTINE IS A DRIVER FOR WRITING CEDRIC FORMAT FILES.
C     YOU WILL HAVE TO REPLACE THIS PROGRAM AND THE SUBROUTINE FETCHPLANE
C     IN THIS FILE WITH YOUR OWN. THESE ARE JUST EXAMPLES.
C
      PARAMETER (MAXFLD=25, NID=510)
      CHARACTER*4 PROJECT
      CHARACTER*6 SCINAME,NAMLND(7),RADSTN,TAPE
      CHARACTER*8 VOLNAM,FLDNAM(MAXFLD),SOURCE
      DIMENSION ISCLFLD(MAXFLD),XLND(7),YLND(7),ZLND(7)
      DIMENSION IDAT(200,200)
      INTEGER*2 IDATA(5,400000)
      REAL U(400000),V(400000),W(400000),DBZ(400000),DIV(400000)
      CHARACTER KEYWORD*4,FLTNAME*8,STMNAME*12,RADAR*4,EXPERIMENT*32
      CHARACTER CREATIME*32,EXTRA1*28,FILNAM*56
      INTEGER IMAX,JMAX,KMAX,KOUNT,NMOSM,
     + IUNFLD,IATTEN,FLAG,EXTRA2,EXTRA3
      REAL STIME,ETIME,OLAT,OLON,SX,SY,SZ,XZ,YZ,ZZ,ROT,RA,CO1,
     + CO2,AZMCOR,ELCOR,THRESH,POWERT,BIEL,AZBIEL,ETIME1,STIME2,
     + EXTRA6,EXTRA7
      CHARACTER NAME*56
      WRITE(6,*)'ENTER WIND3D OR RUV FILE NAME'
      READ(5,'(A56)')NAME
10    CALL READHEADER(99,NAME,KEYWORD,FLTNAME,
     + STMNAME,RADAR,EXPERIMENT,
     + CREATIME,EXTRA1,IMAX,JMAX,KMAX,KOUNT,NMOSM,
     + IUNFLD,IATTEN,FLAG,EXTRA2,EXTRA3,STIME,ETIME,OLAT,OLON,
     + SX,SY,SZ,XZ,YZ,ZZ,ROT,RA,CO1,CO2,AZMCOR,ELCOR,THRESH,
     + POWERT,BIEL,AZBIEL,ETIME1,STIME2,EXTRA6,EXTRA7)
      LUOUT=6
      WRITE(LUOUT,*)CREATIME
      WRITE(LUOUT,*)FLTNAME
      WRITE(LUOUT,*)STMNAME
      WRITE(LUOUT,*)'KEYWORD,RADAR,EXPERIMENT'
      WRITE(LUOUT,'(A4,2X,A4,2X,A32)')KEYWORD,RADAR,EXPERIMENT
      WRITE(LUOUT,*)'EXTRA1,IMAX,JMAX,KMAX,KOUNT,NMOSM,IUNFLD,IATTEN'
      WRITE(LUOUT,*)EXTRA1,IMAX,JMAX,KMAX,KOUNT,NMOSM,IUNFLD,IATTEN
      WRITE(LUOUT,*)'FLAG,EXTRA2'
      WRITE(LUOUT,*)FLAG,EXTRA2
      WRITE(LUOUT,*)'EXTRA3,STIME,ETIME,OLAT,OLON,SX,SY,SZ,XZ,YZ,ZZ'
      WRITE(LUOUT,*)EXTRA3,STIME,ETIME,OLAT,OLON,SX,SY,SZ,XZ,YZ,ZZ
      WRITE(LUOUT,*)'ROT,RA,CO1,CO2,AZMCOR,ELCOR,THRESH,POWERT,BIEL'
      WRITE(LUOUT,*)ROT,RA,CO1,CO2,AZMCOR,ELCOR,THRESH,POWERT,BIEL
      WRITE(LUOUT,*)'AZBIEL,ETIME1,STIME2,EXTRA6,EXTRA7'
      WRITE(LUOUT,*)AZBIEL,ETIME1,STIME2,EXTRA6,EXTRA7
      IF(KEYWORD.EQ.'RUV '.OR.KEYWORD.EQ.'ruv ')THEN
       IUV=1
      ELSE
       IUV=0
      ENDIF
      CALL LDPLN(U,V,W,DBZ,DIV,IMAX,JMAX,KMAX,IUV)
      CLOSE(99)
c      CALL WRITEVS(U,V,W,DBZ,DIV,IMAX,JMAX,KMAX)
      CALL CHANGEFORM(U,V,W,DBZ,DIV,IMAX,JMAX,KMAX,IDATA)
c      CALL WRITEIDATA(IDATA,IMAX,JMAX,KMAX)
      SCINAME = 'GAMACH'
      BASANG  = 90.0+ROT
      WRITE(6,*)'ENTER VOLUME NAME UP TO 8 CHARACTERS'
      READ(5,'(A8)')VOLNAM
      WRITE(6,*)'ENTER FLIGHT ID'
      READ(5,'(A8)')SOURCE
      WRITE(6,*)'ENTER YEAR (2-DIGIT)'
      READ(5,*)IBEGYR
      WRITE(6,*)'ENTER MONTH NUMBER'
      READ(5,*)IBEGMNT
      WRITE(6,*)'ENTER DAY OF MONTH'
      READ(5,*)IBEGDAY
      WRITE(6,*)'ENTER 4BYTE PROJECT NAME'
      READ(5,'(A4)')PROJECT
      TAPE    = '000000'
      RADCON  = -99.9
      VNYQ    = -99.9
      IBEGHR=STIME/3600
      IREM=STIME-3600*IBEGHR
      IBEGMIN=IREM/60
      IBEGSEC=IREM-IBEGMIN*60
      IENDHR=STIME/3600
      IREM=STIME-3600*IENDHR
      IENDMIN=IREM/60
      IENDSEC=IREM-IENDMIN*60
      IENDYR  = IBEGYR
      IENDMNT = IBEGMNT
      IENDDAY = IBEGDAY

      LATDEG = INT(OLAT)
      REMLAT = OLAT-LATDEG
      LATMIN = INT(REMLAT*60.)
      REMLAT = REMLAT-LATMIN/60.
      LATSEC = NINT(REMLAT*3600.)
      LONDEG = INT(OLON)
      REMLON = OLON-LONDEG
      LONMIN = INT(REMLON*60.)
      REMLON = REMLON-LONMIN/60.
      LONSEC = NINT(REMLON*3600.)
      
      XMIN  = -XZ+.5*SX
      XMAX  = XMIN+(IMAX-1)*SX
      NUMX  = IMAX
      ISPCX = NINT(SX*1000.)

      YMIN  = -YZ+.5*SY
      YMAX  = YMIN+(JMAX-1)*SY
      NUMY  = JMAX
      ISPCY = NINT(SY*1000.)

      ZMIN  = ZZ*1000.
      ZMAX  = 1000*(ZZ+(KMAX-1)*SZ)
      NUMZ  = KMAX
      ISPCZ = NINT(SZ*1000.)

      NFLD=5
      FLDNAM(1)  = 'U-COMPON'
      FLDNAM(2)  = 'V-COMPON'
      FLDNAM(3)  = 'W-COMPON'
      FLDNAM(4)  = 'DBZ     '
      FLDNAM(5)  = 'DIVERGEN'
      ISCLFLD(1) = 100
      ISCLFLD(2) = 100
      ISCLFLD(3) = 100
      ISCLFLD(4) = 100
      ISCLFLD(5) = 100
      RADSTN     = 'NOAA42'

      NUMLND = 1
      NUMRAD = 0
      NAMLND(1) = 'ANCHOR'
      XLND(1) = 0.0
      YLND(1) = 0.0
      ZLND(1) = 0.0


      write(6,*)'nfld = ',nfld
      CALL WRITCED(SCINAME,BASANG,VOLNAM,IBEGYR,
     X     IBEGMNT,IBEGDAY,IBEGHR,IBEGMIN,IBEGSEC,IENDYR,
     X     IENDMNT,IENDDAY,IENDHR,IENDMIN,IENDSEC,XMIN,
     X     XMAX,NUMX,ISPCX,YMIN,YMAX,NUMY,ISPCY,ZMIN,
     X     ZMAX,NUMZ,ISPCZ,NFLD,FLDNAM,ISCLFLD,NUMLND,
     X     NUMRAD,NAMLND,XLND,YLND,ZLND,IDAT,RADSTN,SOURCE,
     X     PROJECT,TAPE,RADCON,VNYQ,LATDEG,LATMIN,LATSEC,
     X     LONDEG,LONMIN,LONSEC,IDATA)


      
      END


      SUBROUTINE CHANGEFORM(U,V,W,DBZ,DIV,IMAX,JMAX,KMAX,IDATA)
      REAL U(IMAX,JMAX,KMAX),V(IMAX,JMAX,KMAX),W(IMAX,JMAX,KMAX)
      REAL DBZ(IMAX,JMAX,KMAX),DIV(IMAX,JMAX,KMAX)
      INTEGER*2 IDATA(5,IMAX,JMAX,KMAX)
      FLAG=-1.0E+10
      DO K=1,KMAX
       DO J=1,JMAX
        DO I=1,IMAX
         IF(U(I,J,K).GT.FLAG)THEN
          IDATA(1,I,J,K)=NINT(U(I,J,K)*100.)
         ELSE 
          IDATA(1,I,J,K)=-32768
         ENDIF
         IF(V(I,J,K).GT.FLAG)THEN
          IDATA(2,I,J,K)=NINT(V(I,J,K)*100.)
         ELSE
          IDATA(2,I,J,K)=-32768
         ENDIF
         IF(W(I,J,K).GT.FLAG)THEN
          IDATA(3,I,J,K)=NINT(W(I,J,K)*100.)
         ELSE
          IDATA(3,I,J,K)=-32768
         ENDIF
         IF(DBZ(I,J,K).GT.FLAG)THEN
          IDATA(4,I,J,K)=NINT(DBZ(I,J,K)*100.)
         ELSE
          IDATA(4,I,J,K)=-32768
         ENDIF
         IF(DIV(I,J,K).GT.FLAG)THEN
          IDATA(5,I,J,K)=NINT(DIV(I,J,K)*100000.)
         ELSE
          IDATA(5,I,J,K)=-32768
         ENDIF
        ENDDO
       ENDDO
      ENDDO
      RETURN
      END

      SUBROUTINE LDPLN(U,V,W,DBZ,DIV,IMAX,JMAX,KMAX,IUV)
      REAL U(IMAX,JMAX,KMAX),V(IMAX,JMAX,KMAX),W(IMAX,JMAX,KMAX)
      REAL DBZ(IMAX,JMAX,KMAX),DIV(IMAX,JMAX,KMAX)
      REAL RWD(200),RWS(200),RWW(200),RDV(200)
      INTEGER*2 WD(200),WS(200),DB(200),WW(200),DV(200)         
      FLAG=-1.0E+10
      DO 1 K=1,KMAX                                                             
       WRITE(1,'("loading plane #",i3)') K                                    
       DO 2 J=1,JMAX                                                          
        IF(IUV.EQ.1)THEN
         READ(99)(RWD(I),RWS(I),RWW(I),DB(I),RDV(I),I=1,IMAX)
        ELSE
         READ(99) (WD(I),WS(I),WW(I),DB(I),DV(I),I=1,IMAX)                   
        ENDIF
        DO 3 I=1,IMAX                                                       
c         WRITE(6,*)'I,J,K,RWD,RWS,RWW,DB,RDV = ',I,J,K,
c     1              RWD(I),RWS(I),RWW(I),
c     1              DB(I),RDV(I)
         IF(IUV.EQ.0)THEN
          WDR=WD(I)*.1                                                     
          WSP=WS(I)*.1                                                     
          IF (WDR.LT.0.) THEN                                              
           U(I,J,K)=FLAG
           V(I,J,K)=FLAG
          ELSE                                                             
c           CALL COMP(XU,XV,WDR,WSP)                                       
           XU=-SIN(WDR*3.14159/180.)*WSP
           XV=-COS(WDR*3.14159/180.)*WSP
           U(I,J,K)=XU
           V(I,J,K)=XV
          ENDIF                                                            
          IF(WW(I).GT.-9000)THEN
           W(I,J,K)=WW(I)*.01
          ELSE
           W(I,J,K)=FLAG
          ENDIF
          IF(DV(I).LT.32767)THEN
           DIV(I,J,K)=DV(I)/100000.
          ELSE
           DIV(I,J,K)=FLAG
          ENDIF
         ELSE
          IF(RWW(I).LE.-100000.)RWD(I)=FLAG
          IF(RWS(I).LE.-100000.)RWS(I)=FLAG
          IF(RWW(I).LE.-100000.)RWW(I)=FLAG
          IF(RDV(I).LE.-100000.)RDV(I)=FLAG
          U(I,J,K)=RWD(I)
          V(I,J,K)=RWS(I)
          W(I,J,K)=RWW(I)
          DIV(I,J,K)=RDV(I)
         ENDIF
         IF(DB(I).GT.-9000)THEN
          DBZ(I,J,K)=DB(I)*.1
         ELSE
          DBZ(I,J,K)=FLAG
         ENDIF
c         WRITE(6,*)'I,J,K,U,V,W,DBZ,DIV = ',I,J,K,U(I,J,K),V(I,J,K),
c     1              W(I,J,K),DBZ(I,J,K),DIV(I,J,K)
3       CONTINUE                                                         
2      CONTINUE                                                               
1     CONTINUE                                                                  
      RETURN                                                                    
      END                                                                       


      SUBROUTINE FETCHPLANE(IDAT,IMAX,JMAX,KMAX,IFIELD,K,IDATA)
C
C     SAMPLE ROUTINE FOR FETCHING Z PLANES OF CEDRIC DATA.
C     FILLS IN ARRAY WITH BOGUS DATA
C
      DIMENSION IDAT(IMAX,JMAX)
      INTEGER*2 IDATA(5,IMAX,JMAX,KMAX)
      DO 100 J=1,JMAX
         DO 50 I=1,IMAX
            IDAT(I,J)=IDATA(IFIELD,I,J,K)
c         write(6,*)'j,k,ifield,idat,idata = ',j,k,
c     1    ifield,(idat(i,j),idata(ifield,i,j,k),i=1,imax)
 50      CONTINUE
 100  CONTINUE

      RETURN

      END

         
      SUBROUTINE READHEADER(LU,FILNAM,KEYWORD,FLTNAME,
     + STMNAME,RADAR,EXPERIMENT,
     + CREATIME,EXTRA1,IMAX,JMAX,KMAX,KOUNT,NMOSM,
     + IUNFLD,IATTEN,FLAG,EXTRA2,EXTRA3,STIME,ETIME,OLAT,OLON,
     + SX,SY,SZ,XZ,YZ,ZZ,ROT,RA,CO1,CO2,AZMCOR,ELCOR,THRESH,
     + POWERT,BIEL,AZBIEL,ETIME1,STIME2,EXTRA6,EXTRA7)
      CHARACTER KEYWORD*4,FLTNAME*8,STMNAME*12,RADAR*4,EXPERIMENT*32
      CHARACTER CREATIME*32,EXTRA1*28,FILNAM*56
      INTEGER IMAX,JMAX,KMAX,KOUNT,NMOSM,
     + IUNFLD,IATTEN,FLAG,EXTRA2,EXTRA3
      REAL STIME,ETIME,OLAT,OLON,SX,SY,SZ,XZ,YZ,ZZ,ROT,RA,CO1,
     + CO2,AZMCOR,ELCOR,THRESH,POWERT,BIEL,AZBIEL,ETIME1,STIME2,
     + EXTRA6,EXTRA7
      OPEN(LU,FILE=FILNAM,STATUS='OLD',FORM='UNFORMATTED')
      READ(LU)KEYWORD,FLTNAME,STMNAME,RADAR,EXPERIMENT,CREATIME,
     + EXTRA1,IMAX,JMAX,KMAX,KOUNT,NMOSM,IUNFLD,IATTEN,FLAG,EXTRA2,
     + EXTRA3,STIME,ETIME,OLAT,OLON,SX,SY,SZ,XZ,YZ,ZZ,ROT,RA,CO1,
     + CO2,AZMCOR,ELCOR,THRESH,POWERT,BIEL,AZBIEL,ETIME1,STIME2,
     + EXTRA6,EXTRA7
      RETURN
      END
      SUBROUTINE WRITEVS(U,V,W,DBZ,DIV,IMAX,JMAX,KMAX)
      REAL U(IMAX,JMAX,KMAX),V(IMAX,JMAX,KMAX),W(IMAX,JMAX,KMAX)
      REAL DBZ(IMAX,JMAX,KMAX),DIV(IMAX,JMAX,KMAX)
      DO K=1,KMAX
       DO J=1,JMAX
        WRITE(6,*)'J,K,U = ',(U(I,J,K),I=1,IMAX)
        WRITE(6,*)'J,K,V = ',(V(I,J,K),I=1,IMAX)
        WRITE(6,*)'J,K,W = ',(W(I,J,K),I=1,IMAX)
        WRITE(6,*)'J,K,DBZ = ',(DBZ(I,J,K),I=1,IMAX)
        WRITE(6,*)'J,K,DIV = ',(DIV(I,J,K),I=1,IMAX)
       ENDDO
      ENDDO
      RETURN
      END
      SUBROUTINE WRITEIDATA(IDATA,IMAX,JMAX,KMAX)
      INTEGER*2 IDATA(5,IMAX,JMAX,KMAX)
      DO K=1,KMAX
       DO J=1,JMAX
        WRITE(6,*)'J,K,IDATU = ',(IDATA(1,I,J,K),I=1,IMAX)
        WRITE(6,*)'J,K,IDATV = ',(IDATA(2,I,J,K),I=1,IMAX)
        WRITE(6,*)'J,K,IDATW = ',(IDATA(3,I,J,K),I=1,IMAX)
        WRITE(6,*)'J,K,IDATDBZ = ',(IDATA(4,I,J,K),I=1,IMAX)
        WRITE(6,*)'J,K,IDATDIV = ',(IDATA(5,I,J,K),I=1,IMAX)
       ENDDO
      ENDDO
      RETURN
      END

      
