// =====================================================================
// FILE: C:\Users\HP\Desktop\minmax\src\MinMax\Program.cs
// PURPOSE: The single entry point of MinMax. Calls the Windows Shell
//          ToggleDesktop method, which is the exact same call the
//          built-in taskbar "Show Desktop" button makes.
//          Behavior: click once  -> show desktop (all windows minimized)
//                    click again -> restore all previously minimized
//                                   windows, in their original state.
//          Windows itself tracks the minimized-window list; MinMax does
//          NOT store any state. The process runs and exits in ms.
// RELATES TO: MinMax.csproj (entry point, WinExe so no console flash).
//             Invoked from the pinned taskbar shortcut.
// =====================================================================

using System;
using System.Runtime.InteropServices;

namespace MinMax
{
    // -----------------------------------------------------------------
    // INTERFACE: IShellDispatch4
    // WHAT: COM interface exposed by the Windows Shell (Shell.Application).
    // WHY : We only need its ToggleDesktop method. Declaring it here
    //       lets us call it via late binding without adding a COM
    //       reference to the csproj.
    // GUID: 13709620-C279-11CE-A49E-444553540000  (stable across
    //       every supported Windows version).
    // -----------------------------------------------------------------
    [ComImport]
    [Guid("13709620-C279-11CE-A49E-444553540000")]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    public interface IShellDispatch4
    {
        // The single method we depend on. No parameters, no return value.
        // Produces the toggle-desktop behavior described in the file header.
        void ToggleDesktop();
    }

    internal static class Program
    {
        // -----------------------------------------------------------------
        // METHOD: Main
        // WHAT : Entry point. Fires ToggleDesktop and exits.
        // WHY  : WinExe means this runs with no console window; the whole
        //        operation finishes in milliseconds so nothing stays
        //        resident in memory.
        // -----------------------------------------------------------------
        private static void Main(string[] args)
        {
            try
            {
                // Step 1: Resolve the Shell.Application COM type by ProgID.
                //         This is the live automation object Windows exposes.
                Type? shellType = Type.GetTypeFromProgID("Shell.Application");

                if (shellType != null)
                {
                    // Step 2: Instantiate the Shell object.
                    object? shell = Activator.CreateInstance(shellType);

                    if (shell != null)
                    {
                        // Step 3: Invoke ToggleDesktop via late binding.
                        //         This is the ONLY call that does work.
                        shellType.InvokeMember(
                            "ToggleDesktop",
                            System.Reflection.BindingFlags.InvokeMethod,
                            null,
                            shell,
                            null);
                    }
                }
            }
            catch
            {
                // Step 4: Fail silently. No message box, no log file,
                //         no residue. A background utility should never
                //         interrupt the user with error dialogs.
            }

            // Step 5: Implicit exit. Process ends here.
        }
    }
}
