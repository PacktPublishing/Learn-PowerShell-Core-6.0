//Usage: prog.exe "path_to_powershell_file"



using System;

using System.Configuration.Install;

using System.Runtime.InteropServices;

using System.Management.Automation.Runspaces;



public class Program

{

    public static void Main( string[] args )

    {

     Mycode.Exec( args[ 0 ] );

    }

}



public class Mycode

{

    public static void Exec(string file)

    {

     string command = System.IO.File.ReadAllText( file );

     RunspaceConfiguration rspacecfg = RunspaceConfiguration.Create();

     Runspace rspace = RunspaceFactory.CreateRunspace( rspacecfg );

     rspace.Open();

     Pipeline pipeline = rspace.CreatePipeline();

    pipeline.Commands.AddScript( command );

     pipeline.Invoke();

    }

}