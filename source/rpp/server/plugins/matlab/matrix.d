module matlab.matrix;

@nogc:
extern (C):

alias mxArray_tag mxArray;
alias void function (int, mxArray_tag**, int, mxArray_tag**) mxFunctionPtr;
alias ubyte mxLogical;
alias ushort mxChar;
alias _Anonymous_0 mxClassID;
alias _Anonymous_1 mxComplexity;

enum _Anonymous_0
{
    mxUNKNOWN_CLASS = 0,
    mxCELL_CLASS = 1,
    mxSTRUCT_CLASS = 2,
    mxLOGICAL_CLASS = 3,
    mxCHAR_CLASS = 4,
    mxVOID_CLASS = 5,
    mxDOUBLE_CLASS = 6,
    mxSINGLE_CLASS = 7,
    mxINT8_CLASS = 8,
    mxUINT8_CLASS = 9,
    mxINT16_CLASS = 10,
    mxUINT16_CLASS = 11,
    mxINT32_CLASS = 12,
    mxUINT32_CLASS = 13,
    mxINT64_CLASS = 14,
    mxUINT64_CLASS = 15,
    mxFUNCTION_CLASS = 16,
    mxOPAQUE_CLASS = 17,
    mxOBJECT_CLASS = 18,
    mxINDEX_CLASS = 15,
    mxSPARSE_CLASS = 5
}

enum _Anonymous_1
{
    mxREAL = 0,
    mxCOMPLEX = 1
}

struct mxArray_tag{};


void* mxMalloc (size_t n);
void* mxCalloc (size_t n, size_t size);
void mxFree (void* ptr);
void* mxRealloc (void* ptr, size_t size);
size_t mxGetNumberOfDimensions (const(mxArray)* pa);
int mxGetNumberOfDimensions_700 (const(mxArray)* pa);
const(size_t)* mxGetDimensions (const(mxArray)* pa);
const(int)* mxGetDimensions_700 (const(mxArray)* pa);
size_t mxGetM (const(mxArray)* pa);
size_t* mxGetIr (const(mxArray)* pa);
int* mxGetIr_700 (const(mxArray)* pa);
size_t* mxGetJc (const(mxArray)* pa);
int* mxGetJc_700 (const(mxArray)* pa);
size_t mxGetNzmax (const(mxArray)* pa);
int mxGetNzmax_700 (const(mxArray)* pa);
void mxSetNzmax (mxArray* pa, size_t nzmax);
void mxSetNzmax_700 (mxArray* pa, int nzmax);
const(char)* mxGetFieldNameByNumber (const(mxArray)* pa, int n);
mxArray* mxGetFieldByNumber (const(mxArray)* pa, size_t i, int fieldnum);
mxArray* mxGetFieldByNumber_700 (const(mxArray)* pa, int i, int fieldnum);
mxArray* mxGetCell (const(mxArray)* pa, size_t i);
mxArray* mxGetCell_700 (const(mxArray)* pa, int i);
mxClassID mxGetClassID (const(mxArray)* pa);
void* mxGetData (const(mxArray)* pa);
void mxSetData (mxArray* pa, void* newdata);
bool mxIsNumeric (const(mxArray)* pa);
bool mxIsCell (const(mxArray)* pa);
bool mxIsLogical (const(mxArray)* pa);
bool mxIsScalar (const(mxArray)* pa);
bool mxIsChar (const(mxArray)* pa);
bool mxIsStruct (const(mxArray)* pa);
bool mxIsOpaque (const(mxArray)* pa);
bool mxIsFunctionHandle (const(mxArray)* pa);
bool mxIsObject (const(mxArray)* pa);
void* mxGetImagData (const(mxArray)* pa);
void mxSetImagData (mxArray* pa, void* newdata);
bool mxIsComplex (const(mxArray)* pa);
bool mxIsSparse (const(mxArray)* pa);
bool mxIsDouble (const(mxArray)* pa);
bool mxIsSingle (const(mxArray)* pa);
bool mxIsInt8 (const(mxArray)* pa);
bool mxIsUint8 (const(mxArray)* pa);
bool mxIsInt16 (const(mxArray)* pa);
bool mxIsUint16 (const(mxArray)* pa);
bool mxIsInt32 (const(mxArray)* pa);
bool mxIsUint32 (const(mxArray)* pa);
bool mxIsInt64 (const(mxArray)* pa);
bool mxIsUint64 (const(mxArray)* pa);
size_t mxGetNumberOfElements (const(mxArray)* pa);
double* mxGetPr (const(mxArray)* pa);
void mxSetPr (mxArray* pa, double* pr);
double* mxGetPi (const(mxArray)* pa);
void mxSetPi (mxArray* pa, double* pi);
mxChar* mxGetChars (const(mxArray)* pa);
int mxGetUserBits (const(mxArray)* pa);
void mxSetUserBits (mxArray* pa, int value);
double mxGetScalar (const(mxArray)* pa);
bool mxIsFromGlobalWS (const(mxArray)* pa);
void mxSetFromGlobalWS (mxArray* pa, bool global);
void mxSetM (mxArray* pa, size_t m);
void mxSetM_700 (mxArray* pa, int m);
size_t mxGetN (const(mxArray)* pa);
bool mxIsEmpty (const(mxArray)* pa);
int mxGetFieldNumber (const(mxArray)* pa, const(char)* name);
void mxSetIr (mxArray* pa, size_t* newir);
void mxSetIr_700 (mxArray* pa, int* newir);
void mxSetJc (mxArray* pa, size_t* newjc);
void mxSetJc_700 (mxArray* pa, int* newjc);
size_t mxGetElementSize (const(mxArray)* pa);
size_t mxCalcSingleSubscript (const(mxArray)* pa, size_t nsubs, const(size_t)* subs);
int mxCalcSingleSubscript_700 (const(mxArray)* pa, int nsubs, const(int)* subs);
int mxGetNumberOfFields (const(mxArray)* pa);
void mxSetCell (mxArray* pa, size_t i, mxArray* value);
void mxSetCell_700 (mxArray* pa, int i, mxArray* value);
void mxSetFieldByNumber (mxArray* pa, size_t i, int fieldnum, mxArray* value);
void mxSetFieldByNumber_700 (mxArray* pa, int i, int fieldnum, mxArray* value);
mxArray* mxGetField (const(mxArray)* pa, size_t i, const(char)* fieldname);
mxArray* mxGetField_700 (const(mxArray)* pa, int i, const(char)* fieldname);
void mxSetField (mxArray* pa, size_t i, const(char)* fieldname, mxArray* value);
void mxSetField_700 (mxArray* pa, int i, const(char)* fieldname, mxArray* value);
mxArray* mxGetProperty (const(mxArray)* pa, const size_t i, const(char)* propname);
mxArray* mxGetProperty_700 (const(mxArray)* pa, const int i, const(char)* propname);
void mxSetProperty (mxArray* pa, size_t i, const(char)* propname, const(mxArray)* value);
void mxSetProperty_700 (mxArray* pa, int i, const(char)* propname, const(mxArray)* value);
const(char)* mxGetClassName (const(mxArray)* pa);
bool mxIsClass (const(mxArray)* pa, const(char)* name);
mxArray* mxCreateNumericMatrix (size_t m, size_t n, mxClassID classid, mxComplexity flag);
mxArray* mxCreateNumericMatrix_700 (int m, int n, mxClassID classid, mxComplexity flag);
mxArray* mxCreateUninitNumericMatrix (size_t m, size_t n, mxClassID classid, mxComplexity flag);
mxArray* mxCreateUninitNumericArray (size_t ndim, size_t* dims, mxClassID classid, mxComplexity flag);
void mxSetN (mxArray* pa, size_t n);
void mxSetN_700 (mxArray* pa, int n);
int mxSetDimensions (mxArray* pa, const(size_t)* pdims, size_t ndims);
int mxSetDimensions_700 (mxArray* pa, const(int)* pdims, int ndims);
void mxDestroyArray (mxArray* pa);
mxArray* mxCreateNumericArray (size_t ndim, const(size_t)* dims, mxClassID classid, mxComplexity flag);
mxArray* mxCreateNumericArray_700 (int ndim, const(int)* dims, mxClassID classid, mxComplexity flag);
mxArray* mxCreateCharArray (size_t ndim, const(size_t)* dims);
mxArray* mxCreateCharArray_700 (int ndim, const(int)* dims);
mxArray* mxCreateDoubleMatrix (size_t m, size_t n, mxComplexity flag);
mxArray* mxCreateDoubleMatrix_700 (int m, int n, mxComplexity flag);
mxLogical* mxGetLogicals (const(mxArray)* pa);
mxArray* mxCreateLogicalArray (size_t ndim, const(size_t)* dims);
mxArray* mxCreateLogicalArray_700 (int ndim, const(int)* dims);
mxArray* mxCreateLogicalMatrix (size_t m, size_t n);
mxArray* mxCreateLogicalMatrix_700 (int m, int n);
mxArray* mxCreateLogicalScalar (bool value);
bool mxIsLogicalScalar (const(mxArray)* pa);
bool mxIsLogicalScalarTrue (const(mxArray)* pa);
mxArray* mxCreateDoubleScalar (double value);
mxArray* mxCreateSparse (size_t m, size_t n, size_t nzmax, mxComplexity flag);
mxArray* mxCreateSparse_700 (int m, int n, int nzmax, mxComplexity flag);
mxArray* mxCreateSparseLogicalMatrix (size_t m, size_t n, size_t nzmax);
mxArray* mxCreateSparseLogicalMatrix_700 (int m, int n, int nzmax);
void mxGetNChars (const(mxArray)* pa, char* buf, size_t nChars);
void mxGetNChars_700 (const(mxArray)* pa, char* buf, int nChars);
int mxGetString (const(mxArray)* pa, char* buf, size_t buflen);
int mxGetString_700 (const(mxArray)* pa, char* buf, int buflen);
char* mxArrayToString (const(mxArray)* pa);
char* mxArrayToUTF8String (const(mxArray)* pa);
mxArray* mxCreateStringFromNChars (const(char)* str, size_t n);
mxArray* mxCreateStringFromNChars_700 (const(char)* str, int n);
mxArray* mxCreateString (const(char)* str);
mxArray* mxCreateCharMatrixFromStrings (size_t m, const(char*)* str);
mxArray* mxCreateCharMatrixFromStrings_700 (int m, const(char*)* str);
mxArray* mxCreateCellMatrix (size_t m, size_t n);
mxArray* mxCreateCellMatrix_700 (int m, int n);
mxArray* mxCreateCellArray (size_t ndim, const(size_t)* dims);
mxArray* mxCreateCellArray_700 (int ndim, const(int)* dims);
mxArray* mxCreateStructMatrix (size_t m, size_t n, int nfields, const(char*)* fieldnames);
mxArray* mxCreateStructMatrix_700 (int m, int n, int nfields, const(char*)* fieldnames);
mxArray* mxCreateStructArray (size_t ndim, const(size_t)* dims, int nfields, const(char*)* fieldnames);
mxArray* mxCreateStructArray_700 (int ndim, const(int)* dims, int nfields, const(char*)* fieldnames);
mxArray* mxDuplicateArray (const(mxArray)* in_);
int mxSetClassName (mxArray* pa, const(char)* classname);
int mxAddField (mxArray* pa, const(char)* fieldname);
void mxRemoveField (mxArray* pa, int field);
double mxGetEps ();
double mxGetInf ();
double mxGetNaN ();
bool mxIsFinite (double x);
bool mxIsInf (double x);
bool mxIsNaN (double x);