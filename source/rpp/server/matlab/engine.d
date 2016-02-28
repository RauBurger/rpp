module rpp.server.matlab.engine;

import rpp.server.matlab.matrix;

extern (C):

alias engine Engine;

struct engine{};

int engEvalString (Engine* ep, const(char)* string);
Engine* engOpenSingleUse (const(char)* startcmd, void* reserved, int* retstatus);
int engSetVisible (Engine* ep, bool newVal);
int engGetVisible (Engine* ep, bool* bVal);
Engine* engOpen (const(char)* startcmd);
int engClose (Engine* ep);
mxArray* engGetVariable (Engine* ep, const(char)* name);
int engPutVariable (Engine* ep, const(char)* var_name, const(mxArray)* ap);
int engOutputBuffer (Engine* ep, char* buffer, int buflen);