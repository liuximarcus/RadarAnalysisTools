/* *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* */
/* ** Copyright UCAR (c) 1992 - 2001 */
/* ** University Corporation for Atmospheric Research(UCAR) */
/* ** National Center for Atmospheric Research(NCAR) */
/* ** Research Applications Program(RAP) */
/* ** P.O.Box 3000, Boulder, Colorado, 80307-3000, USA */
/* ** 2001/11/19 23:15:6 */
/* *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* */
#ifdef __cplusplus
 extern "C" {
#endif

#ifndef MEMBUF_WAS_INCLUDED
#define MEMBUF_WAS_INCLUDED 

/* 
 * NAME: 
 *	membuf.h 
 * 
 * SYNOPSIS: 
 *	#include <toolsa/membuf.h>
 * 
 * DESCRIPTION: 
 *	Header file for "membuf.c"
 *	Automatically-resizing accumulating buffer.
 *      Resizes as necessary.
 *	See below for a description of function arguments
 *	 
 * AUTHOR: 
 *	Thomas Wilsher (wilsher@rap.ucar.edu)
 *      Copied to toolsa by Mike Dixon.
 * 
 * BUGS: 
 *	None noticed. 
 * 
 * REVISIONS: 
 * 
 */ 
 
#include <stdio.h> 
#include <sys/types.h> 

#ifndef _MEMBUF_INTERNAL

/*
 * Incomplete definition for public interface
 */

struct MEMbuf;
typedef struct MEMbuf MEMbuf;

#endif


/*
 * NOTES ON USE:
 *
 * The following functions return the pointer to the user
 * buffer:
 *
 * MEMbufAlloc, MEMbufGrow
 * MEMbufLoad, MEMbufAdd, MEMbufConcat
 *
 * When using these, you must set your local buffer pointer
 * to the return value. This allows for the fact that the
 * buffer position may change during a realloc.
 *
 * MEMbufPtr() may also be used at any time to get the
 * user buffer location.
 * 
 * After using MEMbufDup(), MEMbufPtr() must be used to
 * get the pointer to the user buffer.
 *
 */

/*__________________________________________________________________________
 *
 * Default constructor
 *__________________________________________________________________________
 */ 

extern MEMbuf * 
MEMbufCreate(void);

/*__________________________________________________________________________
 *
 * Copy constructor
 *__________________________________________________________________________
 */ 

extern MEMbuf * 
MEMbufCreateCopy(MEMbuf *rhs);

/*___________________________________________________________________________
 * 
 * Destructor
 *___________________________________________________________________________
 */ 

extern void
MEMbufDelete(MEMbuf * );

/*___________________________________________________________________________
 *
 * Reset the memory buffer - sets current length to 0
 * Zero's out allocated buffer memory.
 *___________________________________________________________________________
 */

extern void
MEMbufReset(MEMbuf * );

/*___________________________________________________________________________
 *
 * Free up memory allocated for data. MEMbuf still valid.
 *___________________________________________________________________________
 */

extern void
MEMbufFree(MEMbuf * );

/*___________________________________________________________________________
 * 
 * Prepare a buffer by allocating or reallocating a starting size.
 * This is done if you want to read data directly into the buffer.
 * Note that this routine sets things up so that the internal buffer
 * looks like the data has already been added, although that is left
 * up to the calling routine (i.e. the buffer length is numbytes
 * after the call to this routine).
 *
 * This routine does not change the existing parts of the buffer,
 * only adjusts the size.
 *
 * Buffer is resized as necessary.
 *
 * Returns pointer to user buffer.
 *___________________________________________________________________________
 */

extern void *
MEMbufPrepare(MEMbuf * , size_t numbytes);

/*___________________________________________________________________________
 * 
 * Load numbytes from source array into start of target buffer.
 *
 * Buffer is resized as necessary.
 *
 * Returns pointer to user buffer.
 *___________________________________________________________________________
 */

extern void *
MEMbufLoad(MEMbuf * target, void * source, size_t numbytes);

/*___________________________________________________________________________
 *
 * Add numbytes from source array onto end of buffer.
 *
 * Buffer is resized as necessary.
 *
 * Returns pointer to user buffer.
 *___________________________________________________________________________
 */

extern void *
MEMbufAdd(MEMbuf * target, void * source, size_t numbytes);

/*___________________________________________________________________________
 *
 * Concat the contents of one membuf onto end of another one.
 *
 * Target buffer is automatically resized as necessary.
 *
 * Returns pointer to user buffer.
 *___________________________________________________________________________
 */

extern void *
MEMbufConcat(MEMbuf * target, MEMbuf *src);

/*___________________________________________________________________________
 * 
 * Duplicates the message buffer and its contents.
 *
 * Returns pointer to new message buffer.
 *___________________________________________________________________________
 */

extern MEMbuf *
MEMbufDup(MEMbuf * );

/*___________________________________________________________________________
 * 
 * Get the currently-used length of the current buffer - in bytes
 *___________________________________________________________________________
 */

extern size_t
MEMbufLen(MEMbuf * );

/*___________________________________________________________________________
 * 
 * Get a pointer to the start of the usable buffer
 *___________________________________________________________________________
 */

extern void *
MEMbufPtr(MEMbuf * );

/*___________________________________________________________________________
 *
 * Check available space, grow or shrink as needed
 * Returns pointer to user buffer.
 *___________________________________________________________________________
 */

extern void *
MEMbufAlloc(MEMbuf * , size_t nbytes_total);

/*___________________________________________________________________________
 *
 * Check available space, grow if needed
 * Returns pointer to user buffer.
 *___________________________________________________________________________
 */

extern void *
MEMbufGrow(MEMbuf * , size_t nbytes_needed);

/*___________________________________________________________________________
 *
 * Print out an MEMbuf struct. For internal debugging
 *___________________________________________________________________________
 */

extern void 
MEMbufPrint(MEMbuf * , FILE * fp);


#endif 
#ifdef __cplusplus
}
#endif
