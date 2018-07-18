using System;
using System.Configuration.Install;
using System.Runtime.InteropServices;
//Loading the asembly
using System.Management.Automation.Runspaces;

public class Program
{
    //Constructor
    public static void Main( string[] args )
    {
        //Loading the executor class and executing it with the first gathered argument from the command line
        //Example: prog.exe c:\temp\MimiKatz.psm1
        Executor.Execute( args[ 0 ] );
    }
}

//Class to retrieve content of a file and execute it with .Invoke()
public class Executor
{
    public static void Execute(string file)
    {
        //load file content into variable
        string fileContent = System.IO.File.ReadAllText(file);
        //create a config for the runspace
        RunspaceConfiguration runspaceConfig = RunspaceConfiguration.Create();
        //create a runspace with the config
        Runspace runspace = RunspaceFactory.CreateRunspace(runspaceConfig);
        //open the runspace
        runspace.Open();
        //create a new pipeline in the created runspace
        Pipeline createdPipeline = runspace.CreatePipeline();
        //add the content of the script as command to the pipeline
        createdPipeline.Commands.AddScript(fileContent);
        //invoke the pipeline with the inserted command
        createdPipeline.Invoke();
    }
}