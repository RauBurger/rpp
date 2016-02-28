module rpp.server.matlab.mex;

import rpp.server.matlab.matrix;

extern (C):

alias impl_info_tag* MEX_impl_info;
alias void function () mex_exit_fn;
alias mexGlobalTableEntry_Tag mexGlobalTableEntry;
alias mexGlobalTableEntry_Tag* mexGlobalTable;
alias mexFunctionTableEntry_tag mexFunctionTableEntry;
alias mexFunctionTableEntry_tag* mexFunctionTable;
alias _mexLocalFunctionTable mexLocalFunctionTable;
//alias _mexLocalFunctionTable* mexLocalFunctionTable;
alias _Anonymous_0 _mexInitTermTableEntry;
alias _Anonymous_0* mexInitTermTableEntry;
alias _Anonymous_1 _mex_information;
alias _Anonymous_1* mex_information;
alias _Anonymous_1* function () fn_mex_file;
alias void function () fn_clean_up_after_error;
alias const(char)* function (void function (int, mxArray_tag**, int, mxArray_tag**)) fn_simple_function_to_string;
alias void function (_Anonymous_1*) fn_mex_enter_mex_library;
alias void function (_Anonymous_1*) fn_mex_exit_mex_library;
alias _mexLocalFunctionTable* function () fn_mex_get_local_function_table;
alias _mexLocalFunctionTable* function (_mexLocalFunctionTable*) fn_mex_set_local_function_table;

struct mexGlobalTableEntry_Tag
{
    const(char)* name;
    mxArray** variable;
}

struct mexFunctionTableEntry_tag
{
    const(char)* name;
    mxFunctionPtr f;
    int nargin;
    int nargout;
    _mexLocalFunctionTable* local_function_table;
}

struct _mexLocalFunctionTable
{
    size_t length;
    mexFunctionTable entries;
}

struct _Anonymous_0
{
    void function () initialize;
    void function () terminate;
}

struct _Anonymous_1
{
    int version_;
    int file_function_table_length;
    mexFunctionTable file_function_table;
    int global_variable_table_length;
    mexGlobalTable global_variable_table;
    int npaths;
    const(char*)* paths;
    int init_term_table_length;
    mexInitTermTableEntry init_term_table;
}

struct impl_info_tag{};

void mexFunction (int nlhs, mxArray** plhs, int nrhs, mxArray** prhs);
void mexErrMsgTxt (const(char)* error_msg);
void mexErrMsgIdAndTxt (const(char)* identifier, const(char)* err_msg, ...);
void mexWarnMsgTxt (const(char)* warn_msg);
void mexWarnMsgIdAndTxt (const(char)* identifier, const(char)* warn_msg, ...);
int mexPrintf (const(char)* fmt, ...);
void mexMakeArrayPersistent (mxArray* pa);
void mexMakeMemoryPersistent (void* ptr);
int mexCallMATLAB (int nlhs, mxArray** plhs, int nrhs, mxArray** prhs, const(char)* fcn_name);
int mexCallMATLABWithObject (int nlhs, mxArray** plhs, int nrhs, mxArray** prhs, const(char)* fcn_name);
mxArray* mexCallMATLABWithTrap (int nlhs, mxArray** plhs, int nrhs, mxArray** prhs, const(char)* fcn_name);
mxArray* mexCallMATLABWithTrapWithObject (int nlhs, mxArray** plhs, int nrhs, mxArray** prhs, const(char)* fcn_name);
void mexSetTrapFlag (int flag);
void mexPrintAssertion (const(char)* test, const(char)* fname, int linenum, const(char)* message);
bool mexIsGlobal (const(mxArray)* pA);
int mexPutVariable (const(char)* workspace, const(char)* name, const(mxArray)* parray);
const(mxArray)* mexGetVariablePtr (const(char)* workspace, const(char)* name);
mxArray* mexGetVariableWithObject (const(char)* workspace, const(char)* name);
void mexLock ();
void mexUnlock ();
bool mexIsLocked ();
const(char)* mexFunctionName ();
int mexEvalString (const(char)* str);
mxArray* mexEvalStringWithTrap (const(char)* str);
int mexAtExit (mex_exit_fn exit_fcn);
