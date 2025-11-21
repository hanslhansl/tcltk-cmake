#include <tcl.h>
#include <stdio.h>

// A simple C function exposed to Tcl
int HelloCmd(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
    if (argc != 2) {
        Tcl_SetResult(interp, "Usage: hello <name>", TCL_STATIC);
        return TCL_ERROR;
    }

    char buffer[256];
    snprintf(buffer, sizeof(buffer), "Hello, %s!", argv[1]);
    Tcl_SetResult(interp, buffer, TCL_VOLATILE);
    return TCL_OK;
}

int main(int argc, char *argv[]) {
    // Create a Tcl interpreter
    Tcl_FindExecutable(argv[0]);


    Tcl_Interp *interp = Tcl_CreateInterp();

    if (Tcl_Init(interp) == TCL_ERROR) {
        fprintf(stderr, "Tcl_Init error: %s\n", Tcl_GetStringResult(interp));
        return 1;
    }

    // Register the "hello" command with Tcl
    Tcl_CreateCommand(interp, "hello", HelloCmd, NULL, NULL);

    // Evaluate Tcl code from C
    if (Tcl_Eval(interp, "puts [hello World]") != TCL_OK) {
        fprintf(stderr, "Tcl_Eval error: %s\n", Tcl_GetStringResult(interp));
        Tcl_DeleteInterp(interp);
        return 1;
    }

    Tcl_DeleteInterp(interp);

    printf("Tcl program executed successfully.\n");
    return 0;
}


/*#include <tk.h>

int main(int argc, char *argv[]) {
    // Create a Tcl interpreter
    Tcl_FindExecutable(argv[0]);
    
    Tcl_Interp *interp = Tcl_CreateInterp();
    if (Tcl_Init(interp) == TCL_ERROR) {
        fprintf(stderr, "Tcl_Init error: %s\n", Tcl_GetStringResult(interp));
        return 1;
    }

    if (Tk_Init(interp) == TCL_ERROR) {
        fprintf(stderr, "Tk_Init error: %s\n", Tcl_GetStringResult(interp));
        return 1;
    }

    Tk_Window mainWin = Tk_MainWindow(interp);
    if (!mainWin) {
        fprintf(stderr, "Could not get main window: %s\n", Tcl_GetStringResult(interp));
        return 1;
    }

    Tcl_Eval(interp, "button .b -text {Hello World} -command {exit}; pack .b");

    Tk_MainLoop();

    return 0;
}*/

