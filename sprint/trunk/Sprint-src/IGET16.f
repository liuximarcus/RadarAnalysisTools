      SUBROUTINE IGET16(IWRD,IVAL1,IVAL2)
C
C     UNPACKS TWO 16 BIT WORDS FROM A 32 BIT (OR BIGGER) WORD
C
      CALL GBYTES(IWRD,IVAL1,0,16,0,1)
      CALL GBYTES(IWRD,IVAL2,16,16,0,1)

      IF (IVAL1.GT.32767) IVAL1=IVAL1-65536
      IF (IVAL2.GT.32767) IVAL2=IVAL2-65536

      
      RETURN

      END
